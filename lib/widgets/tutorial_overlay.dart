import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runout_log/utils/constants.dart';
import 'package:runout_log/utils/l10n.dart';

class TutorialOverlay extends ConsumerWidget {
  final int step;
  final VoidCallback onNext;

  const TutorialOverlay({
    super.key,
    required this.step,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title = '';
    String desc = '';
    
    // ポインターの位置を計算
    double? top;
    double? bottom;
    double? left = 0;
    double? right = 0;

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (step == 0) {
      title = L10n.s(ref, 'tutorial_tab_title');
      desc = L10n.s(ref, 'tutorial_tab_desc');
      top = 100; // AppBarのTabBar付近
    } else if (step == 1) {
      title = L10n.s(ref, 'tutorial_input_title');
      desc = L10n.s(ref, 'tutorial_input_desc');
      top = screenHeight * 0.55; // 入力グリッド付近
    } else {
      title = L10n.s(ref, 'save');
      desc = L10n.s(ref, 'tutorial_reset_desc');
      bottom = 60 + bottomPadding; // 保存ボタン付近
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: InkWell(
        onTap: onNext,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      step == 0 ? Icons.ads_click_rounded : (step == 1 ? Icons.touch_app_rounded : Icons.save_alt_rounded),
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        step < 2 ? (ref.watch(languageProvider) == Language.jp ? '次へ' : 'NEXT') : (ref.watch(languageProvider) == Language.jp ? 'わかった！' : 'GOT IT!'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ポインターのアニメーション (Positionedを使用)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: top,
              bottom: bottom,
              left: left,
              right: right,
              child: const Center(
                child: _BlinkingPointer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingPointer extends StatefulWidget {
  const _BlinkingPointer();

  @override
  State<_BlinkingPointer> createState() => _BlinkingPointerState();
}

class _BlinkingPointerState extends State<_BlinkingPointer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.circle, color: Colors.white, size: 16),
      ),
    );
  }
}
