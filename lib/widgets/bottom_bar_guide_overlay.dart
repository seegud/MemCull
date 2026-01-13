import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';

class BottomBarGuideOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const BottomBarGuideOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 全屏点击消失
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: Colors.black.withOpacity(0.4), // 降低透明度，让用户能看到首页图标
            ),
          ),
          
          // 底部图标说明文字
          Positioned(
            bottom: 112 + 20, // 底部栏高度(80) + 底部边距(32) + 额外间距(20)
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSimpleGuide(l10n.undo),
                _buildSimpleGuide(l10n.recycleBin),
                _buildSimpleGuide(l10n.keep),
              ],
            ),
          ),
          
          // 箭头提示
          Positioned(
            bottom: 112 + 5,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildArrow(),
                _buildArrow(),
                _buildArrow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleGuide(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return const Expanded(
      child: Center(
        child: Icon(
          CupertinoIcons.chevron_down,
          color: Colors.white54,
          size: 20,
        ),
      ),
    );
  }
}
