import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class GlassmorphicBottomBar extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final int recycleCount;

  const GlassmorphicBottomBar({
    super.key,
    required this.onUndo,
    required this.onDelete,
    required this.onKeep,
    this.recycleCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBarItem(
                  icon: CupertinoIcons.arrow_counterclockwise,
                  onPressed: onUndo,
                  color: Colors.white.withOpacity(0.7),
                ),
                _buildCenterItem(
                  icon: CupertinoIcons.trash,
                  onPressed: onDelete,
                  label: recycleCount > 0 ? '$recycleCount' : null,
                ),
                _buildBarItem(
                  icon: CupertinoIcons.checkmark,
                  onPressed: onKeep,
                  color: Colors.white,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarItem({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
        size: 28,
        shadows: [
          if (isPrimary)
            const Shadow(
              color: Colors.white30,
              blurRadius: 10,
            ),
        ],
      ),
    );
  }

  Widget _buildCenterItem({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: 32,
            ),
          ),
          if (label != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
