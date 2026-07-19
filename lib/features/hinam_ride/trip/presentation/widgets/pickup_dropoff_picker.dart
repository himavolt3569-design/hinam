import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';

const _defaultCenter = LatLng(27.7172, 85.3240);

enum _PickerMode { pickup, dropoff }

class PickupDropoffPicker extends StatefulWidget {
  final RideLocation? pickup;
  final RideLocation? dropoff;
  final ValueChanged<RideLocation> onPickupChanged;
  final ValueChanged<RideLocation> onDropoffChanged;

  const PickupDropoffPicker({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.onPickupChanged,
    required this.onDropoffChanged,
  });

  @override
  State<PickupDropoffPicker> createState() => _PickupDropoffPickerState();
}

class _PickupDropoffPickerState extends State<PickupDropoffPicker> {
  _PickerMode _mode = _PickerMode.pickup;

  void _handleTap(LatLng point) {
    final location = RideLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      address:
          '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
    );

    if (_mode == _PickerMode.pickup) {
      widget.onPickupChanged(location);
      setState(() => _mode = _PickerMode.dropoff);
    } else {
      widget.onDropoffChanged(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (widget.pickup != null)
        _buildMarker(
          widget.pickup!,
          AppColors.success,
          Icons.trip_origin_rounded,
        ),
      if (widget.dropoff != null)
        _buildMarker(
          widget.dropoff!,
          AppColors.error,
          Icons.location_on_rounded,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _ModeChip(
                label: 'Pickup',
                icon: Icons.trip_origin_rounded,
                color: AppColors.success,
                isSelected: _mode == _PickerMode.pickup,
                onTap: () => setState(() => _mode = _PickerMode.pickup),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ModeChip(
                label: 'Drop-off',
                icon: Icons.location_on_rounded,
                color: AppColors.error,
                isSelected: _mode == _PickerMode.dropoff,
                onTap: () => setState(() => _mode = _PickerMode.dropoff),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 260,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 13.0,
                onTap: (_, point) => _handleTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hinam.app',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          _mode == _PickerMode.pickup
              ? 'Tap the map to set your pickup point.'
              : 'Tap the map to set your drop-off point.',
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Marker _buildMarker(RideLocation location, Color color, IconData icon) {
    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
