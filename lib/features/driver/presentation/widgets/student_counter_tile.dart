import 'package:flutter/material.dart';

class StudentCounterTile extends StatelessWidget {
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const StudentCounterTile({
    super.key,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.people_rounded, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Students on board',
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$count student${count != 1 ? 's' : ''}',
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _CountButton(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
                enabled: count > 0,
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 36,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
                ),
              ),
              const SizedBox(width: 4),
              _CountButton(icon: Icons.add_rounded, onTap: onIncrement, enabled: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _CountButton({required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? scheme.primary.withValues(alpha: 0.1) : scheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? scheme.primary : scheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
