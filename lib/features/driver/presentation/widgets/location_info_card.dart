import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationInfoCard extends StatelessWidget {
  final Position position;

  const LocationInfoCard({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_rounded, size: 16, color: Colors.green),
              ),
              const SizedBox(width: 10),
              Text(
                'Current Location',
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                'Live',
                style: text.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CoordRow(label: 'Lat', value: position.latitude.toStringAsFixed(6)),
          const SizedBox(height: 4),
          _CoordRow(label: 'Lng', value: position.longitude.toStringAsFixed(6)),
          const SizedBox(height: 4),
          _CoordRow(label: 'Speed', value: '${(position.speed * 3.6).toStringAsFixed(1)} km/h'),
        ],
      ),
    );
  }
}

class _CoordRow extends StatelessWidget {
  final String label;
  final String value;
  const _CoordRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: text.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.45)),
          ),
        ),
        Text(value, style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
