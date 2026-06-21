import 'package:flutter/material.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? scheme.primary;
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    );

    final child = Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: filled ? Colors.white.withValues(alpha: 0.2) : effectiveColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: filled ? Colors.white : effectiveColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : effectiveColor,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: filled ? Colors.white.withValues(alpha: 0.75) : effectiveColor.withValues(alpha: 0.65),
                  ),
                ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: filled ? Colors.white.withValues(alpha: 0.7) : effectiveColor.withValues(alpha: 0.6),
        ),
      ],
    );

    if (filled) {
      return SizedBox(
        height: 68,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: effectiveColor,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            minimumSize: const Size(double.infinity, 68),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 68,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: shape,
          side: BorderSide(color: effectiveColor.withValues(alpha: 0.4), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          minimumSize: const Size(double.infinity, 68),
        ),
        child: child,
      ),
    );
  }
}
