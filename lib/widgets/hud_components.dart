import 'package:flutter/material.dart';
import 'package:runout_log/utils/constants.dart';

class CleanCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? borderColor;

  const CleanCard({
    super.key,
    required this.child,
    this.title,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.softShadow,
        border: borderColor != null ? Border.all(color: borderColor!, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 20, bottom: 4),
              child: Text(
                title!,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: child,
          ),
        ],
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isSecondary;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.white : color,
        foregroundColor: isSecondary ? color : AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        elevation: isSecondary ? 0 : 6,
        shadowColor: color.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: isSecondary ? BorderSide(color: color, width: 2) : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  final bool isSelected;
  final String label;

  const StatusIndicator({super.key, required this.isSelected, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textDim.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textDim,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
