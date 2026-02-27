import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runout_log/models/practice_record.dart';
import 'package:runout_log/screens/splash_screen.dart';
import 'package:runout_log/services/ad_service.dart';
import 'package:runout_log/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PracticeRecordAdapter());
  await Hive.openBox<PracticeRecord>('practice_records');
  
  // 広告サービスの初期化
  await AdService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ポップな印象の丸文字フォントをベースにテキストテーマを作成
    final textTheme = GoogleFonts.mPlusRounded1cTextTheme(
      ThemeData.light().textTheme,
    );

    return MaterialApp(
      title: 'RunOut Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          brightness: Brightness.light,
        ),
        // Google Fontsの適用
        textTheme: textTheme.copyWith(
          bodyLarge: textTheme.bodyLarge?.copyWith(
            color: AppColors.textMain, 
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: textTheme.bodyMedium?.copyWith(
            color: AppColors.textMain, 
            fontWeight: FontWeight.w600,
          ),
          titleLarge: textTheme.titleLarge?.copyWith(
            color: AppColors.textMain, 
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textMain,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.mPlusRounded1c(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textDim,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
