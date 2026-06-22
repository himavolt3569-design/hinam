import 'package:flutter/material.dart';

class BusTypeSelector extends StatelessWidget {
  final String busType;
  final ValueChanged<String> onChanged;

  const BusTypeSelector({
    super.key,
    required this.busType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: _BusTypeCard(
            label: 'Public Bus',
            icon: Icons.directions_bus_rounded,
            value: 'public',
            groupValue: busType,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () => onChanged('public'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BusTypeCard(
            label: 'School Bus',
            icon: Icons.school_rounded,
            value: 'school',
            groupValue: busType,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () => onChanged('school'),
          ),
        ),
      ],
    );
  }
}

class _BusTypeCard extends StatelessWidget {
  const _BusTypeCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
