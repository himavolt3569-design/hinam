import 'package:flutter/material.dart';

class NoBusesOverlay extends StatelessWidget {
  final bool hasQuery;

  const NoBusesOverlay({super.key, required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off_rounded : Icons.directions_bus_outlined,
              size: 20,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 10),
            Text(
              hasQuery ? 'No buses match your search' : 'No buses are currently active',
              style: text.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
