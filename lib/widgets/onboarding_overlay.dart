import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const OnboardingOverlay({super.key, required this.onDismiss});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  bool _isSwipeUpStep = true; // true: swipe up step, false: swipe down step
  bool _isAnimating = false;
  double _dragOffset = 0;
  static const double _swipeThreshold = 100.0;

  late AnimationController _hintController;
  late Animation<double> _upArrowAnimation;
  late Animation<double> _downArrowAnimation;
  
  // Card animations
  late AnimationController _cardController;
  late Animation<Offset> _cardOffsetAnimation;
  late Animation<double> _cardOpacityAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _upArrowAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    _downArrowAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _resetCardAnimations();
  }

  void _resetCardAnimations() {
    _cardOffsetAnimation = const AlwaysStoppedAnimation(Offset.zero);
    _cardOpacityAnimation = const AlwaysStoppedAnimation(1.0);
    _cardScaleAnimation = const AlwaysStoppedAnimation(1.0);
  }

  @override
  void dispose() {
    _hintController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _handleSwipe(bool isUp) async {
    if (_isAnimating) return;
    
    // Check if the action matches the current step
    if (_isSwipeUpStep && !isUp) return; // Expecting up, got down
    if (!_isSwipeUpStep && isUp) return; // Expecting down, got up

    setState(() {
      _isAnimating = true;
    });

    // Animate card away
    _cardOffsetAnimation = Tween<Offset>(
      begin: Offset(0, _dragOffset / MediaQuery.of(context).size.height),
      end: Offset(0, isUp ? -1.2 : 1.2),
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _cardOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _cardScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    await _cardController.forward(from: 0);

    if (_isSwipeUpStep) {
      // Transition to next step
      setState(() {
        _isSwipeUpStep = false; // Move to swipe down step
        _dragOffset = 0;
        
        // Setup entrance animation for the "new" card
        _cardOffsetAnimation = const AlwaysStoppedAnimation(Offset.zero);
        _cardOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
        );
        _cardScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
        );
      });
      
      // Play entry animation
      await _cardController.forward(from: 0);
      
      setState(() {
        _isAnimating = false;
        _cardOffsetAnimation = const AlwaysStoppedAnimation(Offset.zero);
        _cardOpacityAnimation = const AlwaysStoppedAnimation(1.0);
        _cardScaleAnimation = const AlwaysStoppedAnimation(1.0);
      });
      
    } else {
      // Done with both steps
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 顶部欢迎文字
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  l10n.welcomeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.welcomeSubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // 中心引导区域
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 上滑引导文字和箭头 (Only show if step is swipe up)
                AnimatedOpacity(
                  opacity: _isSwipeUpStep ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_isSwipeUpStep,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _upArrowAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _upArrowAnimation.value),
                              child: const Icon(
                                CupertinoIcons.chevron_compact_up,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.swipeUpDelete,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 中心图标 (可滑动)
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (_isAnimating) return;
                    setState(() {
                      _dragOffset += details.delta.dy;
                    });
                  },
                  onVerticalDragEnd: (details) {
                    if (_isAnimating) return;
                    if (_dragOffset < -_swipeThreshold) {
                      // Swipe Up
                      _handleSwipe(true);
                    } else if (_dragOffset > _swipeThreshold) {
                      // Swipe Down
                      _handleSwipe(false);
                    } else {
                      setState(() {
                        _dragOffset = 0;
                      });
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _cardController,
                    builder: (context, child) {
                      final double screenHeight = MediaQuery.of(context).size.height;
                      final double currentDy = _cardOffsetAnimation.value.dy * screenHeight;
                      
                      return Transform.translate(
                        offset: Offset(0, currentDy + _dragOffset),
                        child: Transform.scale(
                          scale: _cardScaleAnimation.value,
                          child: Opacity(
                            opacity: _cardOpacityAnimation.value,
                            child: _buildLogoCard(),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // 下滑引导文字和箭头 (Only show if step is swipe down)
                AnimatedOpacity(
                  opacity: !_isSwipeUpStep ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: _isSwipeUpStep,
                    child: Column(
                      children: [
                        Text(
                          l10n.swipeDownKeep,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _downArrowAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _downArrowAnimation.value),
                              child: const Icon(
                                CupertinoIcons.chevron_compact_down,
                                color: Colors.greenAccent,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 底部跳过按钮 (可选)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: CupertinoButton(
                onPressed: widget.onDismiss,
                child: Text(
                  l10n.startButton,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            "assets/images/logo.png",
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) => const Icon(
              CupertinoIcons.photo,
              color: Colors.white54,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }
}
