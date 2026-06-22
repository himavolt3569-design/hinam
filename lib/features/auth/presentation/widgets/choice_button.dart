import 'package:flutter/material.dart';
import 'package:hinam/core/theme/app_colors.dart';

class ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool filled;
  final Color? color;

  const ChoiceButton({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.filled = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    const radius = BorderRadius.all(Radius.circular(10));

    final child = Row(
      children: [
        Icon(icon, size: 20, color: filled ? Colors.white : effectiveColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: filled
              ? Colors.white.withValues(alpha: 0.6)
              : AppColors.textTertiary,
        ),
      ],
    );

    if (filled) {
      return SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: effectiveColor,
            shape: const RoundedRectangleBorder(borderRadius: radius),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: child,
      ),
    );
  }
}
