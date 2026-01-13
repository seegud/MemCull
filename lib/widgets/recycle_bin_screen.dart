import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/photo_provider.dart';
import '../l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final Set<AssetEntity> _selectedPhotos = {};
  bool _isSelectionMode = false;

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedPhotos.contains(asset)) {
        _selectedPhotos.remove(asset);
      } else {
        _selectedPhotos.add(asset);
      }
      _isSelectionMode = _selectedPhotos.isNotEmpty;
    });
  }

  void _selectAll(List<AssetEntity> photos) {
    setState(() {
      if (_selectedPhotos.length == photos.length) {
        _selectedPhotos.clear();
        _isSelectionMode = false;
      } else {
        _selectedPhotos.addAll(photos);
        _isSelectionMode = true;
      }
    });
  }

  void _showPreview(BuildContext context, AssetEntity asset) {
    final l10n = AppLocalizations.of(context)!;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Hero(
                tag: asset.id,
                child: AssetEntityImage(
                  asset,
                  isOriginal: true,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CupertinoActivityIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: Colors.white54,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.loadFailed,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  void _handleRecover(PhotoProvider provider) {
    if (_selectedPhotos.isEmpty) return;
    provider.recoverPhotos(_selectedPhotos.toList());
    setState(() {
      _selectedPhotos.clear();
      _isSelectionMode = false;
    });
  }

  void _handleDelete(PhotoProvider provider) async {
    if (_selectedPhotos.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    final count = _selectedPhotos.length;
    final confirmed = await _showCustomConfirmDialog(
      context,
      title: l10n.permanentlyDeleteTitle,
      content: l10n.permanentlyDeleteContent(count),
      confirmLabel: l10n.delete,
      isDangerous: true,
    );

    if (confirmed == true) {
      provider.permanentlyDeletePhotos(_selectedPhotos.toList(), context);
      setState(() {
        _selectedPhotos.clear();
        _isSelectionMode = false;
      });
    }
  }

  // 弹出清空确认框
  void _showEmptyConfirmation(
    BuildContext context,
    PhotoProvider provider,
  ) async {
    final count = provider.recycleBin.length;
    if (count == 0) return;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await _showCustomConfirmDialog(
      context,
      title: l10n.emptyRecycleBin,
      content: l10n.emptyConfirmContent,
      confirmLabel: l10n.emptyLabel,
      isDangerous: true,
    );

    if (confirmed == true) {
      provider.emptyRecycleBin(context);
    }
  }

  Future<bool?> _showCustomConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    bool isDangerous = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Confirm",
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            backgroundColor: isDangerous
                                ? Colors.redAccent.withOpacity(0.1)
                                : Colors.blueAccent.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDangerous
                                    ? Colors.redAccent.withOpacity(0.5)
                                    : Colors.blueAccent.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            confirmLabel,
                            style: TextStyle(
                              color: isDangerous
                                  ? Colors.redAccent
                                  : Colors.blueAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);
    final photos = photoProvider.recycleBin;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black, // 确保背景纯黑
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isSelectionMode ? l10n.selectedCount(_selectedPhotos.length) : l10n.recycleBin,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.chevron_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (photos.isNotEmpty)
            IconButton(
              icon: Icon(
                _selectedPhotos.length == photos.length
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.checkmark_circle,
                color: _selectedPhotos.isNotEmpty
                    ? Colors.blueAccent
                    : Colors.white70,
              ),
              onPressed: () => _selectAll(photos),
              tooltip: l10n.selectAll,
            ),
          if (!_isSelectionMode && photos.isNotEmpty)
            IconButton(
              icon: const Icon(
                CupertinoIcons.trash_fill,
                color: Colors.white70,
              ),
              onPressed: () => _showEmptyConfirmation(context, photoProvider),
              tooltip: l10n.emptyRecycleBin,
            ),
        ],
      ),
      body: Stack(
        children: [
          if (photos.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.trash,
                    color: Colors.white24,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.recycleBinEmpty, style: const TextStyle(color: Colors.white38)),
                ],
              ),
            )
          else
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final asset = photos[index];
                      final isSelected = _selectedPhotos.contains(asset);

                      return GestureDetector(
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleSelection(asset);
                          } else {
                            _showPreview(context, asset);
                          }
                        },
                        onLongPress: () => _toggleSelection(asset),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Hero(
                                tag: asset.id,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AssetEntityImage(
                                    asset,
                                    isOriginal: false,
                                    thumbnailSize: const ThumbnailSize(
                                      300,
                                      300,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.checkmark_circle_fill,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }, childCount: photos.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          // 底部操作栏
          if (_isSelectionMode)
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          icon: CupertinoIcons.arrow_counterclockwise,
                          label: l10n.recover,
                          onTap: () => _handleRecover(photoProvider),
                        ),
                        _buildActionButton(
                          icon: CupertinoIcons.trash_fill,
                          label: l10n.delete,
                          onTap: () => _handleDelete(photoProvider),
                          isDangerous: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDangerous = false,
  }) {
    final color = isDangerous ? Colors.redAccent : Colors.greenAccent;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
