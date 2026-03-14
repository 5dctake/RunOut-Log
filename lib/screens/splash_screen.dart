import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runout_log/models/practice_record.dart';
import 'package:runout_log/screens/home_screen.dart';
import 'package:runout_log/screens/onboarding_screen.dart';
import 'package:runout_log/utils/constants.dart';
import 'package:runout_log/services/ad_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    _controller.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      debugPrint('SplashScreen: Starting initialization...');
      
      // 1. Hiveの初期化
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) { // PracticeRecordAdapterのIDを確認
        Hive.registerAdapter(PracticeRecordAdapter());
      }
      await Hive.openBox<PracticeRecord>('practice_records');
      debugPrint('SplashScreen: Hive initialized');

      // 2. 広告サービスの初期化（並行して行い、タイムアウト付き）
      // addPostFrameCallbackで呼び出すことで、最初のフレーム描画を優先する
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AdService().init().catchError((e) {
          debugPrint('SplashScreen: AdService init error: $e');
        });
      });

      setState(() {
        _isInitialized = true;
      });
      
      _navigateToNext();
    } catch (e) {
      debugPrint('SplashScreen: Initialization failed: $e');
      // 致命的なエラーでもアプリを止めないよう、強引に進む
      setState(() {
        _isInitialized = true;
      });
      _navigateToNext();
    }
  }

  Future<void> _navigateToNext() async {
    // 最低限の表示時間を確保
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // 初期化が終わるまで待機
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool isFirstRun = prefs.getBool('is_first_run') ?? true;

    if (isFirstRun) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'RunOut Log',
                  style: GoogleFonts.mPlusRounded1c(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MASTER YOUR SKILLS',
                  style: GoogleFonts.mPlusRounded1c(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
