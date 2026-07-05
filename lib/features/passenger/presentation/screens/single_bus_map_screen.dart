import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/bus_stops/presentation/providers/bus_stops_provider.dart';
import 'package:hinam/features/passenger/presentation/providers/bus_locations_provider.dart';
import 'package:hinam/shared/models/bus_location_model.dart';

const _defaultCenter = LatLng(27.7172, 85.3240);

class SingleBusMapScreen extends ConsumerStatefulWidget {
  final String driverId;

  const SingleBusMapScreen({super.key, required this.driverId});

  @override
  ConsumerState<SingleBusMapScreen> createState() => _SingleBusMapScreenState();
}

class _SingleBusMapScreenState extends ConsumerState<SingleBusMapScreen> {
  final _mapController = MapController();
  bool _hasInitialCenter = false;

  @override
  Widget build(BuildContext context) {
    final busAsync = ref.watch(singleBusProvider(widget.driverId));

    return busAsync.when(
      data: (bus) {
        if (bus != null && bus.isTracking && !_hasInitialCenter) {
          _hasInitialCenter = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(LatLng(bus.latitude, bus.longitude), 15.0);
          });
        }
        return _buildScaffold(bus);
      },
      loading: () => _buildScaffold(null),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Bus Location')),
        body: Center(child: Text(e.toString())),
      ),
    );
  }

  Scaffold _buildScaffold(BusLocationModel? bus) {
    final isActive = bus?.isTracking ?? false;
    final title = bus?.busNumber ?? 'Bus Location';
    final subtitle = bus?.routeOrSchool ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          if (isActive && bus != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.my_location_rounded, size: 20),
                tooltip: 'Center on bus',
                onPressed: () => _mapController.move(
                  LatLng(bus.latitude, bus.longitude),
                  15.0,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final stopsAsync = ref.watch(busStopsProvider);
              final busPoint = (bus != null && bus.isTracking)
                  ? LatLng(bus.latitude, bus.longitude)
                  : _defaultCenter;

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: busPoint,
                  initialZoom: bus != null ? 15.0 : 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.hinam.app',
                  ),
                  if (bus != null && bus.isTracking)
                    MarkerLayer(markers: [_buildBusMarker(bus)]),
                  stopsAsync.when(
                    data: (stops) => MarkerLayer(
                      markers: stops
                          .map((s) => Marker(
                                point: LatLng(s.latitude, s.longitude),
                                width: 32,
                                height: 32,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.stopOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.signpost_rounded, color: Colors.white, size: 14),
                                ),
                              ))
                          .toList(),
                    ),
                    loading: () => const MarkerLayer(markers: []),
                    error: (_, _) => const MarkerLayer(markers: []),
                  ),
                ],
              );
            },
          ),

          // Bottom info card
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _BusInfoPanel(bus: bus),
          ),

          // Not tracking overlay
          if (!isActive)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off_rounded, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text('Bus is not currently tracking', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Marker _buildBusMarker(BusLocationModel bus) {
    final isPublic = bus.busType == 'public';
    final color = isPublic ? AppColors.primary : AppColors.schoolGreen;

    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 52,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(
          isPublic ? Icons.directions_bus_rounded : Icons.school_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _BusInfoPanel extends StatelessWidget {
  final BusLocationModel? bus;

  const _BusInfoPanel({this.bus});

  @override
  Widget build(BuildContext context) {
    if (bus == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bus!.busNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (bus!.routeOrSchool.isNotEmpty)
                      Text(bus!.routeOrSchool, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bus!.isTracking ? AppColors.successBg : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bus!.isTracking ? 'Live' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: bus!.isTracking ? AppColors.success : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(icon: Icons.person_rounded, label: bus!.driverName.isEmpty ? 'Driver' : bus!.driverName),
              const SizedBox(width: 12),
              _InfoChip(icon: Icons.speed_rounded, label: '${bus!.speedKmh.toStringAsFixed(0)} km/h'),
              if (!bus!.isTracking && bus!.busType == 'school' && bus!.studentCount > 0) ...[
                const SizedBox(width: 12),
                _InfoChip(icon: Icons.people_rounded, label: '${bus!.studentCount} students'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
