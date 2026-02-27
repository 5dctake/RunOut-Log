import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// クリーン・爽やかカラーパレット
class AppColors {
  // メイン：スカイブルー
  static const Color primary = Color(0xFF00A8E8);
  // サブ：ライトグレー
  static const Color background = Color(0xFFF8F9FA);
  // アクセント：朱色（バーミリオン） - ポップで印象的な赤
  static const Color accent = Color(0xFFFF4D00);
  // 濃いブルー：引き締め用
  static const Color primaryDark = Color(0xFF007EA7);
  
  // 表面色・カード
  static const Color surface = Colors.white;
  
  // テキストカラー
  static const Color textMain = Color(0xFF2D3436);
  static const Color textDim = Color(0xFF636E72);
  static const Color white = Colors.white;

  // 柔らかい影
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

// 以前のHUDテーマは廃止し、シンプルなカラー管理に移行
final colorThemeProvider = Provider((ref) => AppColors);
