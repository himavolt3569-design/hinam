import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String driverName;
  final VoidCallback onLogout;

  const DashboardHeader({
    super.key,
    required this.driverName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.person_rounded, color: scheme.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                driverName,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          tooltip: 'Logout',
        ),
      ],
    );
  }
}
