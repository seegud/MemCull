import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/photo_provider.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';
import 'widgets/swipeable_photo_card.dart';
import 'widgets/glassmorphic_bottom_bar.dart';
import 'widgets/onboarding_overlay.dart';
import 'widgets/bottom_bar_guide_overlay.dart';
import 'widgets/about_sheet.dart';
import 'widgets/settings_sheet.dart';

import 'package:mem_cull/widgets/recycle_bin_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 沉浸式状态栏设置
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MemCullApp(),
    ),
  );
}

class MemCullApp extends StatelessWidget {
  const MemCullApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'MemCull',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF000000), // 默认纯黑
            useMaterial3: true,
          ),
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
            Locale('zh', 'HK'),
            Locale('zh', 'TW'),
          ],
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showOnboarding = false;
  bool _showBottomGuide = false;
  bool _isTopBarVisible = true;
  DateTime? _lastInteractionTime;
  Timer? _hideTimer;
  late final SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = context.read<SettingsProvider>();
    _checkOnboarding();
    // 延迟请求权限和导入图片
    Future.microtask(() {
      final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
      if (!const bool.fromEnvironment('FLUTTER_TEST')) {
        photoProvider.loadPhotos();
      }

      // 监听设置变化以启动/停止折叠计时器
      _settingsProvider.addListener(_onSettingsChanged);
      // 如果初始状态就是开启折叠，启动计时器
      if (_settingsProvider.isTopBarCollapsible) {
        _resetHideTimer();
      }
    });
  }

  void _onSettingsChanged() {
    if (_settingsProvider.isTopBarCollapsible) {
      if (_isTopBarVisible && _hideTimer == null) {
        _resetHideTimer();
      }
    } else {
      // 如果关闭了折叠功能，强制显示顶栏并取消计时器
      _hideTimer?.cancel();
      _hideTimer = null;
      if (!_isTopBarVisible) {
        setState(() {
          _isTopBarVisible = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && context.read<SettingsProvider>().isTopBarCollapsible) {
        setState(() {
          _isTopBarVisible = false;
          _hideTimer = null;
        });
      } else {
        _hideTimer = null;
      }
    });
  }

  void _showTopBar() {
    setState(() {
      _isTopBarVisible = true;
    });
    _resetHideTimer();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstOpen = prefs.getBool('is_first_open') ?? true;
    final isFirstHomeEntry = prefs.getBool('is_first_home_entry') ?? true;

    if (isFirstOpen) {
      setState(() {
        _showOnboarding = true;
      });
    } else if (isFirstHomeEntry) {
      setState(() {
        _showBottomGuide = true;
      });
    }
  }

  Future<void> _dismissOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_open', false);
    setState(() {
      _showOnboarding = false;
      _showBottomGuide = true; // 显示完第一个引导后紧接着显示第二个
    });
  }

  Future<void> _dismissBottomGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_home_entry', false);
    setState(() {
      _showBottomGuide = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // 使用 Stack 确保底部栏悬浮在内容之上
      body: Stack(
        children: [
          // 1. 底层：纯黑背景
          Positioned.fill(child: const ColoredBox(color: Color(0xFF000000))),

          // 2. 中层：照片卡片流 (使用 RepaintBoundary 优化性能)
          RepaintBoundary(
            child: Center(
              child:
                  Selector<
                    PhotoProvider,
                    ({
                      bool isLoading,
                      bool hasPermission,
                      AssetEntity? currentPhoto,
                      AssetEntity? nextPhoto,
                      bool isRoundCompleted,
                    })
                  >(
                    selector: (_, provider) => (
                      isLoading: provider.isLoading,
                      hasPermission: provider.hasPermission,
                      currentPhoto: provider.currentPhoto,
                      nextPhoto: provider.nextPhoto,
                      isRoundCompleted: provider.isRoundCompleted,
                    ),
                    builder: (context, data, child) {
                      if (data.isLoading) {
                        return const CupertinoActivityIndicator(
                          color: Colors.white,
                          radius: 15,
                        );
                      }

                      if (!data.hasPermission) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.permissionDesc,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<PhotoProvider>().loadPhotos(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: Text(l10n.grantPermission),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.read<PhotoProvider>().openSettings(),
                              child: Text(
                                l10n.openSettings,
                                style: const TextStyle(color: Colors.white38),
                              ),
                            ),
                          ],
                        );
                      }

                      if (data.isRoundCompleted) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              context.read<PhotoProvider>().restartNewRound(),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    l10n.roundCompletedTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    l10n.roundCompletedSubtitle,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (data.currentPhoto != null) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 底层卡片 (预加载下一张)
                            if (data.nextPhoto != null)
                              SwipeablePhotoCard(
                                key: ValueKey(data.nextPhoto!.id),
                                asset: data.nextPhoto!,
                                onSwipeUp: () {},
                                onSwipeDown: () {},
                                isCurrent: false, // 标记为非当前卡片
                              ),
                            // 顶层卡片
                            SwipeablePhotoCard(
                              key: ValueKey(data.currentPhoto!.id),
                              asset: data.currentPhoto!,
                              onSwipeUp: () => context
                                  .read<PhotoProvider>()
                                  .deleteCurrentPhoto(),
                              onSwipeDown: () => context
                                  .read<PhotoProvider>()
                                  .keepCurrentPhoto(),
                              isCurrent: true, // 标记为当前卡片
                            ),
                          ],
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.done_all_rounded,
                            color: Colors.white54,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.allPhotosProcessed,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),

          // 3. 顶层拦截层：专门用于顶栏唤起，防止与图片详情点击冲突
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              if (settings.isTopBarCollapsible && !_isTopBarVisible) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height / 5,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showTopBar(),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // 4. 顶层：毛玻璃底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Selector<PhotoProvider, int>(
              selector: (_, provider) => provider.recycleBin.length,
              builder: (context, recycleCount, child) {
                final provider = context.read<PhotoProvider>();
                return GlassmorphicBottomBar(
                  recycleCount: recycleCount,
                  onUndo: () => provider.undo(),
                  onKeep: () => provider.keepCurrentPhoto(),
                  onDelete: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const RecycleBinScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 5. 顶层：顶部操作图标 (关于和设置)
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final isCollapsible = settings.isTopBarCollapsible;
              final isVisible = !isCollapsible || _isTopBarVisible;
              final topPadding = MediaQuery.of(context).padding.top;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                top: isVisible ? topPadding + 10 : topPadding - 10, // 短距离位移
                left: 20,
                right: 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isVisible ? 1.0 : 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左上角：关于图标
                      _buildTopIcon(
                        icon: CupertinoIcons.info,
                        onTap: () async {
                          _hideTimer?.cancel();
                          _hideTimer = null;
                          await showAboutSheet(context);
                          if (context.read<SettingsProvider>().isTopBarCollapsible) {
                            _resetHideTimer();
                          }
                        },
                      ),
                      // 右上角：设置图标
                      _buildTopIcon(
                        icon: CupertinoIcons.settings,
                        onTap: () async {
                          _hideTimer?.cancel();
                          _hideTimer = null;
                          await showSettingsSheet(context);
                          if (context.read<SettingsProvider>().isTopBarCollapsible) {
                            _resetHideTimer();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 6. 引导层
          if (_showOnboarding)
            Positioned.fill(
              child: OnboardingOverlay(onDismiss: _dismissOnboarding),
            ),

          if (_showBottomGuide)
            Positioned.fill(
              child: BottomBarGuideOverlay(onDismiss: _dismissBottomGuide),
            ),
        ],
      ),
    );
  }

  Widget _buildTopIcon({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.6),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // 弹出删除确认框 - 已根据用户要求移除自定义确认弹窗，直接调用彻底删除
  void _showDeleteConfirmation(BuildContext context, PhotoProvider provider) {
    provider.emptyRecycleBin(context);
  }
}
