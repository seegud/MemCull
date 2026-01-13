import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/database_service.dart';
import 'dart:io';
import 'dart:math';

class PhotoProvider with ChangeNotifier {
  List<AssetEntity> _photos = [];
  int _currentIndex = 0;
  final List<AssetEntity> _recycleBin = [];
  Set<String> _processedIds = {}; // 已处理（保留或删除）的图片 ID
  bool _isLoading = false;
  bool _hasPermission = true;
  bool _isRoundCompleted = false; // 是否完成了一轮整理
  final DatabaseService _db = DatabaseService();
  final ValueNotifier<double> swipeProgress = ValueNotifier(0.0);

  PhotoProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 检查是否需要从 SharedPreferences 迁移数据到 sqflite
    if (prefs.containsKey('processed_ids') || prefs.containsKey('recycle_bin_ids')) {
      final oldProcessedIds = prefs.getStringList('processed_ids') ?? [];
      final oldRecycleIds = prefs.getStringList('recycle_bin_ids') ?? [];

      if (oldProcessedIds.isNotEmpty) {
        await _db.markAsProcessed(oldProcessedIds, isDeleted: false);
      }
      if (oldRecycleIds.isNotEmpty) {
        await _db.markAsProcessed(oldRecycleIds, isDeleted: true);
      }

      // 迁移完成后清除旧数据
      await prefs.remove('processed_ids');
      await prefs.remove('recycle_bin_ids');
      debugPrint("数据已从 SharedPreferences 迁移至 sqflite");
    }

    // 2. 从数据库加载状态
    _processedIds = await _db.getAllProcessedIds();
    _isRoundCompleted = prefs.getBool('is_round_completed') ?? false;

    final recycleIds = await _db.getRecycleBinIds();
    if (recycleIds.isNotEmpty) {
      final List<AssetEntity> assets = await _getAssetsByIds(recycleIds);
      _recycleBin.clear();
      _recycleBin.addAll(assets);
      notifyListeners();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_round_completed', _isRoundCompleted);
    // 注意：processed_ids 和 recycle_bin_ids 现在通过 _db 实时更新，不需要在 _saveState 中批量保存
  }

  Future<List<AssetEntity>> _getAssetsByIds(List<String> ids) async {
    const int chunkSize = 50;
    final List<AssetEntity> results = [];
    for (int i = 0; i < ids.length; i += chunkSize) {
      final int end = min(i + chunkSize, ids.length);
      final chunk = ids.sublist(i, end);
      final chunkResults = await Future.wait(chunk.map(AssetEntity.fromId));
      results.addAll(chunkResults.whereType<AssetEntity>());
    }
    return results;
  }

  List<AssetEntity> get photos => _photos;
  List<AssetEntity> get recycleBin => _recycleBin;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  bool get isRoundCompleted => _isRoundCompleted;

  AssetEntity? get currentPhoto =>
      (!_isRoundCompleted && _photos.isNotEmpty && _currentIndex < _photos.length)
      ? _photos[_currentIndex]
      : null;

  AssetEntity? get nextPhoto =>
      (!_isRoundCompleted && _photos.isNotEmpty && _currentIndex + 1 < _photos.length)
      ? _photos[_currentIndex + 1]
      : null;

  /// 请求权限并加载照片
  Future<void> loadPhotos() async {
    _isLoading = true;
    _hasPermission = true;
    notifyListeners();
    bool deferLoadingEnd = false;

    try {
      await _loadState(); // 确保加载了状态

      // 请求 Android 11+ 的所有文件访问权限，以尝试绕过删除弹窗
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      }

      // 使用 requestPermissionExtend 获取更详细的权限状态
      PermissionState ps = await PhotoManager.requestPermissionExtend();

      // 如果权限被拒绝，尝试再次请求（针对部分 Android 版本的特殊处理）
      if (ps == PermissionState.denied || ps == PermissionState.restricted) {
        ps = await PhotoManager.requestPermissionExtend();
      }

      if (ps.isAuth || ps.hasAccess) {
        _hasPermission = true;
        // 1. 快速获取“最近项目”或“所有照片”虚拟相册，这比遍历所有相册快得多
        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true, // 关键优化：优先只获取“全部”相册
          filterOption: FilterOptionGroup(
            orders: [
              const OrderOption(type: OrderOptionType.createDate, asc: false),
            ],
          ),
        );

        if (paths.isEmpty) {
          _photos = [];
          _isLoading = false;
          notifyListeners();
          return;
        }

        final mainPath = paths.first;
        final int totalAssetCount = await mainPath.assetCountAsync;

        // 如果已经完成了一轮且没有新照片，保持完成状态
        if (_isRoundCompleted) {
          // 检查是否有新照片（不在已处理列表中的）
          final List<AssetEntity> checkBatch = await mainPath.getAssetListRange(
            start: 0,
            end: totalAssetCount > 50 ? 50 : totalAssetCount,
          );
          final hasNew = checkBatch.any((e) => !_processedIds.contains(e.id));
          if (!hasNew) {
            _isLoading = false;
            notifyListeners();
            return;
          } else {
            // 有新照片，重置完成状态
            _isRoundCompleted = false;
            _saveState();
          }
        }

        final random = Random();

        const int initialTargetCount = 300;
        const int pageSize = 200;
        final int effectivePageSize =
            totalAssetCount < pageSize ? totalAssetCount : pageSize;

        final int pageCount = effectivePageSize == 0
            ? 0
            : (totalAssetCount / effectivePageSize).ceil();
        final List<int> pageOrder = List<int>.generate(pageCount, (i) => i);
        pageOrder.shuffle(random);

        final List<AssetEntity> initialEntities = [];
        int pageCursor = 0;
        const int maxInitialPages = 12;

        while (initialEntities.length < initialTargetCount &&
            pageCursor < pageOrder.length &&
            pageCursor < maxInitialPages) {
          final int pageIndex = pageOrder[pageCursor];
          pageCursor++;
          final int start = pageIndex * effectivePageSize;
          final int end = (start + effectivePageSize) > totalAssetCount
              ? totalAssetCount
              : (start + effectivePageSize);
          final List<AssetEntity> batch = await mainPath.getAssetListRange(
            start: start,
            end: end,
          );
          initialEntities.addAll(
            batch.where((e) => !_processedIds.contains(e.id)),
          );
        }

        if (initialEntities.isNotEmpty) {
          initialEntities.shuffle(random);
          _photos = List.from(initialEntities);
          _isLoading = false;
          _currentIndex = 0;
          notifyListeners();
          _precacheNextImages();
        } else if (totalAssetCount > 0) {
          deferLoadingEnd = true;
        }

        if (totalAssetCount > 0 && pageOrder.isNotEmpty) {
          _loadRemainingPhotosRandom(
            path: mainPath,
            totalCount: totalAssetCount,
            pageOrder: pageOrder,
            startPageCursor: pageCursor,
            pageSize: effectivePageSize,
          );
        } else if (_photos.isEmpty && totalAssetCount > 0) {
          _isRoundCompleted = true;
          _saveState();
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _hasPermission = false;
        debugPrint("权限未授予: $ps");
      }
    } catch (e) {
      _hasPermission = false;
      debugPrint("加载照片失败: $e");
    } finally {
      if (!deferLoadingEnd) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// 重新开始新的一轮整理
  Future<void> restartNewRound() async {
    _processedIds.clear();
    await _db.clearAll();
    _isRoundCompleted = false;
    _photos.clear();
    _currentIndex = 0;
    await _saveState();
    await loadPhotos();
  }

  /// 手动打开设置页面
  Future<void> openSettings() async {
    await PhotoManager.openSetting();
  }

  /// 保留当前照片
  void keepCurrentPhoto() {
    if (currentPhoto != null) {
      final id = currentPhoto!.id;
      _processedIds.add(id);
      _db.markAsProcessed([id], isDeleted: false);
      _saveState();
      _currentIndex++;
      swipeProgress.value = 0.0; // 重置滑动进度
      
      if (_currentIndex >= _photos.length) {
        _isRoundCompleted = true;
        _saveState();
      } else {
        _precacheNextImages(); // 预加载后续图片
      }
      notifyListeners();
    }
  }

  /// 将当前照片移入临时回收站
  void deleteCurrentPhoto() {
    if (currentPhoto != null) {
      final id = currentPhoto!.id;
      _processedIds.add(id);
      _recycleBin.add(currentPhoto!);
      _db.markAsProcessed([id], isDeleted: true);
      _saveState();
      _currentIndex++;
      swipeProgress.value = 0.0; // 重置滑动进度
      
      if (_currentIndex >= _photos.length) {
        _isRoundCompleted = true;
        _saveState();
      } else {
        _precacheNextImages(); // 预加载后续图片
      }
      notifyListeners();
    }
  }

  /// 预加载后续几张图片，提升滑动流畅度
  void _precacheNextImages() {
    if (_isRoundCompleted) return;
    final int nextIndex = _currentIndex + 1;

    // 1. 对于紧接着的下一张，加载更高清的缩略图或原图
    if (nextIndex < _photos.length) {
      final nextAsset = _photos[nextIndex];
      final mime = nextAsset.mimeType?.toLowerCase();
      final isAnimated = mime != null && (mime.contains('gif') || mime.contains('webp'));

      if (isAnimated) {
        // 动态图预加载原文件
        nextAsset.file;
      } else {
        // 静态图预加载高清缩略图 (匹配 UI 使用的 1200x1200)
        nextAsset.thumbnailDataWithSize(const ThumbnailSize(1200, 1200));
      }
    }

    // 2. 预加载接下来 3 张图片 (中等质量，用于后续平滑切换)
    for (int i = nextIndex; i < nextIndex + 3 && i < _photos.length; i++) {
      final asset = _photos[i];
      // 触发缩略图缓存
      asset.thumbnailDataWithSize(const ThumbnailSize(600, 1000));
    }
  }

  /// 彻底删除选中的图片
  Future<void> permanentlyDeletePhotos(
    List<AssetEntity> assets,
    BuildContext context,
  ) async {
    try {
      final List<String> ids = assets.map((e) => e.id).toList();
      final Set<String> deletedIdsSet = {};

      // 1. 尝试直接物理删除文件（绕过系统弹窗，需要 MANAGE_EXTERNAL_STORAGE 权限）
      if (Platform.isAndroid &&
          await Permission.manageExternalStorage.isGranted) {
        for (var asset in assets) {
          try {
            final file = await asset.originFile;
            if (file != null && await file.exists()) {
              await file.delete();
              deletedIdsSet.add(asset.id);
              debugPrint("物理删除成功: ${asset.id}");
            }
          } catch (e) {
            debugPrint("物理删除失败 (${asset.id}): $e");
          }
        }
      }

      // 2. 调用 PhotoManager 的接口来更新 MediaStore 并删除剩余未物理删除的文件
      // 如果文件已物理删除，deleteWithIds 在某些 Android 版本上能自动同步 MediaStore且不弹窗
      try {
        final List<String> pmDeletedIds =
            await PhotoManager.editor.deleteWithIds(ids);
        deletedIdsSet.addAll(pmDeletedIds);
        debugPrint("PhotoManager 删除返回: ${pmDeletedIds.length} 个");
      } catch (e) {
        debugPrint("PhotoManager 删除接口调用异常: $e");
      }

      // 3. 更新内存状态
      if (deletedIdsSet.isNotEmpty) {
        _recycleBin.removeWhere((element) => deletedIdsSet.contains(element.id));
        await _db.removeRecords(deletedIdsSet.toList());
        notifyListeners();
      }
    } catch (e) {
      debugPrint("删除操作整体异常: $e");
    }
  }

  /// 恢复选中的图片
  void recoverPhotos(List<AssetEntity> assets) {
    for (var asset in assets) {
      _recycleBin.remove(asset);
      _processedIds.remove(asset.id); // 恢复后标记为未处理，可以再次抉择
      _db.removeRecord(asset.id);
    }
    _isRoundCompleted = false; // 恢复后可能产生新可处理照片
    _saveState();
    notifyListeners();
  }

  /// 彻底清空回收站
  Future<void> emptyRecycleBin(BuildContext context) async {
    if (_recycleBin.isEmpty) return;
    await permanentlyDeletePhotos(List.from(_recycleBin), context);
  }

  /// 撤销上一步操作
  void undo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _isRoundCompleted = false; // 撤销后肯定未完成
      final prevPhoto = _photos[_currentIndex];
      _processedIds.remove(prevPhoto.id);
      _db.removeRecord(prevPhoto.id);
      
      // 如果上一张在回收站，则移除
      _recycleBin.removeWhere((e) => e.id == prevPhoto.id);

      _saveState();
      notifyListeners();
    }
  }

  /// 后台加载剩余照片
  Future<void> _loadRemainingPhotosRandom({
    required AssetPathEntity path,
    required int totalCount,
    required List<int> pageOrder,
    required int startPageCursor,
    required int pageSize,
  }) async {
    final random = Random();
    for (int i = startPageCursor; i < pageOrder.length; i++) {
      final int pageIndex = pageOrder[i];
      final int start = pageIndex * pageSize;
      final int end =
          (start + pageSize) > totalCount ? totalCount : (start + pageSize);

      final List<AssetEntity> batch = await path.getAssetListRange(
        start: start,
        end: end,
      );

      final List<AssetEntity> filteredBatch =
          batch.where((e) => !_processedIds.contains(e.id)).toList();

      if (filteredBatch.isNotEmpty) {
        filteredBatch.shuffle(random);
        final bool wasEmpty = _photos.isEmpty;
        _photos.addAll(filteredBatch);

        if (_isRoundCompleted) {
          _isRoundCompleted = false;
          _saveState();
        }

        if (wasEmpty) {
          _currentIndex = 0;
          _isLoading = false;
          notifyListeners();
          _precacheNextImages();
        } else {
          notifyListeners();
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_photos.isEmpty && totalCount > 0) {
      _isRoundCompleted = true;
      _saveState();
      _isLoading = false;
      notifyListeners();
    }

    debugPrint("后台加载完成，总照片数: ${_photos.length}");
  }
}
