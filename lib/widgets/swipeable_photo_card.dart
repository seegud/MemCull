import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'dart:ui';
import 'dart:math' as Math;
import 'dart:io';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:exif/exif.dart';
import 'package:provider/provider.dart';
import '../providers/photo_provider.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';
import '../l10n/app_localizations.dart';

class SwipeablePhotoCard extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final bool isCurrent; // 新增：是否是当前显示的卡片

  const SwipeablePhotoCard({
    super.key,
    required this.asset,
    required this.onSwipeUp,
    required this.onSwipeDown,
    this.isCurrent = true,
  });

  @override
  State<SwipeablePhotoCard> createState() => _SwipeablePhotoCardState();
}

class _SwipeablePhotoCardState extends State<SwipeablePhotoCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _zoomController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  Animation<Matrix4>? _zoomAnimation;

  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;
  double _dragOffset = 0.0;
  static const double _swipeThreshold = 120.0;
  static const double _gestureThreshold = 5.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _offsetAnimation = const AlwaysStoppedAnimation(Offset.zero);
    _scaleAnimation = const AlwaysStoppedAnimation(1.0);

    // 初始透明度逻辑优化：如果是当前卡片，从 0 到 1 淡入；如果不是当前卡片，直接 1.0 保持在底层
    _opacityAnimation = Tween<double>(
      begin: widget.isCurrent ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _transformationController.addListener(() {
      setState(() {
        _currentScale = _transformationController.value.getMaxScaleOnAxis();
      });
    });

    _zoomController.addListener(() {
      if (_zoomAnimation != null) {
        _transformationController.value = _zoomAnimation!.value;
      }
    });

    if (widget.isCurrent) {
      _controller.forward();
    } else {
      // 如果不是当前卡片（即预加载卡片），提前触发图片预热
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _precacheFullImage();
        }
      });
    }
  }

  /// 预热图片缓存，消除切换时的瞬时黑屏或模糊
  void _precacheFullImage() {
    final provider = AssetEntityImageProvider(
      widget.asset,
      isOriginal: _isAnimated,
      thumbnailSize: _isAnimated ? null : const ThumbnailSize(1200, 1200),
      thumbnailFormat: _isAnimated ? ThumbnailFormat.png : ThumbnailFormat.jpeg,
    );
    precacheImage(provider, context);
  }

  @override
  void didUpdateWidget(SwipeablePhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果从非当前变为当前，确保透明度为 1.0（因为它原本就在底层以 1.0 显示）
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _opacityAnimation = const AlwaysStoppedAnimation(1.0);
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _zoomController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // 只有在未放大的情况下才允许滑动
    if (_currentScale <= 1.01) {
      setState(() {
        _dragOffset += details.delta.dy;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) async {
    if (_currentScale > 1.01) return;

    final settings = context.read<SettingsProvider>();

    if (_dragOffset.abs() > _swipeThreshold) {
      bool isUp = _dragOffset < 0;

      _offsetAnimation = Tween<Offset>(
        begin: Offset(0, _dragOffset / MediaQuery.of(context).size.height),
        end: Offset(0, isUp ? -1.2 : 1.2),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _opacityAnimation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.8,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      if (!settings.isVibrationDisabled) {
        HapticFeedback.mediumImpact();
      }

      await _controller.forward(from: 0);

      // 根据设置决定滑动逻辑
      if (settings.isSwipeReversed) {
        // 反向：向上保留 (onSwipeDown)，向下删除 (onSwipeUp)
        // 注意：原本向上是删除，向下是保留
        if (isUp) {
          widget.onSwipeDown();
        } else {
          widget.onSwipeUp();
        }
      } else {
        // 默认：向上删除，向下保留
        if (isUp) {
          widget.onSwipeUp();
        } else {
          widget.onSwipeDown();
        }
      }
    } else {
      _offsetAnimation =
          Tween<Offset>(
            begin: Offset(0, _dragOffset / MediaQuery.of(context).size.height),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const ElasticOutCurve(0.8),
            ),
          );

      _opacityAnimation = const AlwaysStoppedAnimation(1.0);
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);

      _dragOffset = 0;
      final provider = context.read<PhotoProvider>();
      _controller.forward(from: 0).then((_) {
        // 动画结束后强制重置进度为 0
        provider.swipeProgress.value = 0.0;
      });
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_zoomController.isAnimating) return;

    final Matrix4 endMatrix;
    if (_currentScale > 1.0) {
      endMatrix = Matrix4.identity();
    } else {
      final position = details.localPosition;
      endMatrix = Matrix4.identity()
        ..translate(position.dx, position.dy)
        ..scale(2.0)
        ..translate(-position.dx, -position.dy);
    }

    _zoomAnimation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: endMatrix,
        ).animate(
          CurvedAnimation(
            parent: _zoomController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _zoomController.forward(from: 0);
  }

  // 格式化文件大小
  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (Math.log(bytes) / Math.log(1024)).floor();
    return ((bytes / Math.pow(1024, i)).toStringAsFixed(2)) + ' ' + suffixes[i];
  }

  // 将 EXIF 中的分数（Ratio）转换为小数显示
  // allowFraction: 是否允许保留短分数（用于曝光时间）
  String _toDecimal(
    dynamic value, {
    int precision = 2,
    bool allowFraction = false,
  }) {
    if (value == null) return "";
    String strValue = value.toString();
    if (strValue.contains('/')) {
      try {
        final parts = strValue.split('/');
        if (parts.length == 2) {
          final numStr = parts[0].trim();
          final denStr = parts[1].trim();
          double num = double.parse(numStr);
          double den = double.parse(denStr);

          if (den == 0) return strValue;

          // 如果分母为 1，直接返回分子整数
          if (den == 1) return num.toInt().toString();

          // 如果允许分数，且分子分母都不长（不超过4位），则返回原始分数形式
          if (allowFraction && numStr.length <= 4 && denStr.length <= 4) {
            return strValue;
          }

          double result = num / den;
          // 如果是整数，不保留小数位
          if (result == result.toInt()) {
            return result.toInt().toString();
          }
          // 否则按精度保留，并去掉末尾多余的 0
          String formatted = result.toStringAsFixed(precision);
          if (formatted.contains('.')) {
            formatted = formatted.replaceAll(RegExp(r'0+$'), '');
            formatted = formatted.replaceAll(RegExp(r'\.$'), '');
          }
          return formatted;
        }
      } catch (e) {
        return strValue;
      }
    }
    return strValue;
  }

  // 显示图片详情
  void _showPhotoInfo() async {
    final l10n = AppLocalizations.of(context)!;
    final latlng = await widget.asset.latlngAsync();
    final file = await widget.asset.file;
    final size = file?.lengthSync() ?? 0;

    String detailedAddress = l10n.fetchingLocation;
    if (latlng == null || (latlng.latitude == 0 && latlng.longitude == 0)) {
      detailedAddress = l10n.noLocationInfo;
    }

    String cameraParams = l10n.readingCameraParams;
    Map<String, IfdTag>? exifData;

    if (!mounted) return;

    // 先显示弹窗，然后在弹窗内部异步更新地址和 EXIF
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // 允许高度自适应且支持全屏滑动
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10nModal = AppLocalizations.of(context)!;
            // 异步获取位置
            if (detailedAddress == l10nModal.fetchingLocation &&
                latlng != null &&
                (latlng.latitude != 0 || latlng.longitude != 0)) {
              final settings = context.read<SettingsProvider>();

              LocationService.getAddress(
                latlng.longitude,
                latlng.latitude,
                settings.amapKey,
              ).then((address) {
                if (context.mounted) {
                  String translatedAddress = address;
                  if (address == 'NO_LOCATION_INFO') {
                    translatedAddress = l10nModal.noLocationInfo;
                  } else if (address == 'UNKNOWN_LOCATION') {
                    translatedAddress = l10nModal.unknown;
                  } else if (address.startsWith('QUOTA_EXCEEDED')) {
                    translatedAddress = l10nModal.quotaExhausted;
                  } else if (address.startsWith('PARSE_ADDRESS_FAILED')) {
                    if (address.contains('No API Key provided')) {
                      translatedAddress = '未配置高德 Key';
                    } else {
                      translatedAddress = l10nModal.locationError;
                    }
                  } else if (address.startsWith('NETWORK_REQUEST_FAILED') ||
                      address.startsWith('NETWORK_CONNECTION_FAILED')) {
                    translatedAddress = l10nModal.networkError;
                  }

                  setModalState(() {
                    detailedAddress = translatedAddress;
                  });
                }
              });
            }

            // 异步获取 EXIF 参数
            if (cameraParams == l10nModal.readingCameraParams && file != null) {
              file
                  .readAsBytes()
                  .then((bytes) {
                    readExifFromBytes(bytes).then((data) {
                      if (context.mounted) {
                        setModalState(() {
                          if (data.isEmpty) {
                            cameraParams = l10nModal.noCameraParams;
                          } else {
                            String getVal(String tag) => data.containsKey(tag)
                                ? data[tag].toString()
                                : "";

                            String make = getVal('Image Make');
                            String model = getVal('Image Model');
                            String lens = getVal('EXIF LensModel');
                            if (lens.isEmpty) lens = getVal('EXIF LensMake');

                            // 使用 _toDecimal 转换分数
                            // 曝光时间 (shutter speed) 允许保留短分数
                            String exposure = _toDecimal(
                              data['EXIF ExposureTime'],
                              precision: 4,
                              allowFraction: true,
                            );
                            String fNumber = _toDecimal(data['EXIF FNumber']);
                            String iso = getVal('EXIF ISOSpeedRatings');
                            String focal = _toDecimal(data['EXIF FocalLength']);

                            List<String> lines = [];
                            if (make.isNotEmpty || model.isNotEmpty) {
                              String device = "${make} ${model}".trim();
                              if (device.isNotEmpty) lines.add(l10nModal.deviceLabel(device));
                            }
                            if (lens.isNotEmpty) {
                              lines.add(l10nModal.lensLabel(lens.trim()));
                            }

                            List<String> settings = [];
                            if (focal.isNotEmpty) {
                              settings.add("${focal}mm");
                            }
                            if (fNumber.isNotEmpty)
                              settings.add("f/${fNumber}");
                            if (exposure.isNotEmpty)
                              settings.add("${exposure}s");
                            if (iso.isNotEmpty) settings.add("ISO ${iso}");

                            if (settings.isNotEmpty) {
                              lines.add(l10nModal.paramsLabel(settings.join(' ')));
                            }

                            cameraParams = lines.isEmpty
                                ? l10nModal.noCameraParams
                                : lines.join('\n');
                          }
                        });
                      }
                    });
                  })
                  .catchError((e) {
                    if (context.mounted) {
                      setModalState(() {
                        cameraParams = l10nModal.readFailed(e.toString());
                      });
                    }
                  });
            }

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height * 0.85, // 最大高度为屏幕的 85%
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Text(
                          l10nModal.photoInfo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          CupertinoIcons.calendar,
                          l10nModal.createTime,
                          widget.asset.createDateTime.toString().split('.')[0],
                        ),
                        _buildInfoItem(
                          CupertinoIcons.location,
                          l10nModal.captureLocation,
                          (latlng != null &&
                                  (latlng.latitude != 0 ||
                                      latlng.longitude != 0))
                              ? "$detailedAddress\n${l10nModal.longitudeLabel(latlng.longitude.toStringAsFixed(4))}, ${l10nModal.latitudeLabel(latlng.latitude.toStringAsFixed(4))}"
                              : l10nModal.noLocationInfo,
                        ),
                        _buildInfoItem(
                          CupertinoIcons.doc,
                          l10nModal.fileInfo,
                          "${l10nModal.filenameLabel(widget.asset.title ?? l10nModal.unknown)}\n"
                              "${l10nModal.sizeLabel(_formatSize(size))}\n"
                              "${l10nModal.resolutionLabel(widget.asset.width, widget.asset.height)}",
                        ),
                        _buildInfoItem(
                          CupertinoIcons.camera,
                          l10nModal.cameraParamsLabel,
                          cameraParams,
                        ),
                        _buildInfoItem(
                          CupertinoIcons.floppy_disk, // 修改为软盘图标
                          l10nModal.storageLocation,
                          file?.path ?? l10nModal.unknown,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 检查是否为 GIF 或 WebP 等动态图片
  bool get _isAnimated {
    final mime = widget.asset.mimeType?.toLowerCase();
    final title = widget.asset.title?.toLowerCase();
    return (mime != null && (mime.contains('gif') || mime.contains('webp'))) ||
        (title != null && (title.endsWith('.gif') || title.endsWith('.webp')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PhotoProvider>();

    return ValueListenableBuilder<double>(
      valueListenable: provider.swipeProgress,
      builder: (context, progress, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double screenHeight = MediaQuery.of(context).size.height;
            final double currentDy = _offsetAnimation.value.dy * screenHeight;
            final double dy = currentDy + _dragOffset;

            // 计算相对于屏幕高度的实际滑动进度 (0.0 - 1.0)
            final double totalProgress = (dy.abs() / screenHeight).clamp(
              0.0,
              1.0,
            );

            // 如果是当前卡片，将进度同步到 provider 供底层卡片使用
            if (widget.isCurrent) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (provider.swipeProgress.value != totalProgress) {
                  provider.swipeProgress.value = totalProgress;
                }
              });
            }

            Widget cardContent = child!;

            // 如果是非当前卡片（底层卡片），应用模糊效果
            if (!widget.isCurrent) {
              // 只有当顶层卡片的滑动进度达到阈值（0.7，即“几乎滑动到边缘”）时才显示底层卡片
              if (progress < 0.7 && !_controller.isAnimating) {
                return const SizedBox.shrink();
              }

              // 只有当顶层卡片几乎完全滑出（进度 > 0.95）时，底层卡片才开始变清晰
              final double blurAmount = progress > 0.95 ? 0.0 : 20.0;

              if (blurAmount > 0) {
                cardContent = ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ),
                  child: cardContent,
                );
              }
            }

            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    margin: EdgeInsets.zero,
                    // 如果是当前卡片，背景随滑动变透明；如果不是当前卡片，背景全透明
                    decoration: BoxDecoration(
                      color: widget.isCurrent
                          ? Colors.black.withOpacity(
                              (1.0 - totalProgress * 1.2).clamp(0.0, 1.0),
                            )
                          : Colors.transparent,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 1.0,
                        maxScale: 4.0,
                        onInteractionUpdate: (details) {
                          // 只有在单指且未放大的情况下才允许滑动
                          if (_currentScale <= 1.01 &&
                              details.pointerCount == 1) {
                            setState(() {
                              _dragOffset += details.focalPointDelta.dy;
                            });
                          } else if (_currentScale > 1.01) {
                            setState(() {
                              _currentScale = _transformationController.value
                                  .getMaxScaleOnAxis();
                            });
                          }
                        },
                        onInteractionEnd: (details) {
                          if (_currentScale <= 1.01) {
                            _onVerticalDragEnd(
                              DragEndDetails(velocity: details.velocity),
                            );
                          }
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _showPhotoInfo,
                          onDoubleTapDown: _handleDoubleTap,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [cardContent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: AssetEntityImage(
            widget.asset,
            isOriginal: _isAnimated, // 动态图片使用原图以支持播放
            thumbnailSize: _isAnimated ? null : const ThumbnailSize(1200, 1200),
            thumbnailFormat: _isAnimated
                ? ThumbnailFormat.png
                : ThumbnailFormat.jpeg,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CupertinoActivityIndicator(color: Colors.white),
              );
            },
          ),
        );
      },
    );
  }
}
