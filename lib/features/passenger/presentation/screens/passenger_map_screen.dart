import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/bus_stops/data/models/bus_stop_model.dart';
import 'package:hinam/features/bus_stops/presentation/providers/bus_stops_provider.dart';
import 'package:hinam/features/passenger/presentation/providers/bus_search_provider.dart';
import 'package:hinam/features/passenger/presentation/widgets/bus_count_badge.dart';
import 'package:hinam/features/passenger/presentation/widgets/bus_detail_sheet.dart';
import 'package:hinam/features/passenger/presentation/widgets/map_search_bar.dart';
import 'package:hinam/features/passenger/presentation/widgets/no_buses_overlay.dart';
import 'package:hinam/features/passenger/presentation/widgets/stop_detail_sheet.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

const _defaultCenter = LatLng(27.7172, 85.3240);
const _defaultZoom = 13.0;

class PassengerMapScreen extends ConsumerStatefulWidget {
  const PassengerMapScreen({super.key});

  @override
  ConsumerState<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends ConsumerState<PassengerMapScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busesAsync = ref.watch(filteredBusesProvider);
    final hasQuery = ref.watch(searchQueryProvider).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Buses'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: busesAsync.maybeWhen(
              data: (buses) => BusCountBadge(count: buses.length, icon: Icons.directions_bus_rounded),
              orElse: () => const SizedBox(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hinam.app',
              ),
              busesAsync.when(
                data: (buses) => MarkerLayer(markers: buses.map((b) => _buildBusMarker(context, b)).toList()),
                loading: () => const MarkerLayer(markers: []),
                error: (error, _) => const MarkerLayer(markers: []),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final stopsAsync = ref.watch(busStopsProvider);
                  return stopsAsync.when(
                    data: (stops) => MarkerLayer(markers: stops.map((s) => _buildStopMarker(context, s)).toList()),
                    loading: () => const MarkerLayer(markers: []),
                    error: (error, _) => const MarkerLayer(markers: []),
                  );
                },
              ),
            ],
          ),

          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: MapSearchBar(
              controller: _searchController,
              hasQuery: hasQuery,
              onChanged: (v) => ref.read(searchQueryProvider.notifier).update(v),
              onClear: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).clear();
              },
            ),
          ),

          busesAsync.when(
            data: (buses) {
              if (buses.isEmpty) return NoBusesOverlay(hasQuery: hasQuery);
              return const SizedBox.shrink();
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          ),
        ],
      ),
    );
  }

  Marker _buildBusMarker(BuildContext context, BusLocationModel bus) {
    final isPublic = bus.busType == 'public';

    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => _showBusSheet(context, bus),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Icon(
            isPublic ? Icons.directions_bus_rounded : Icons.school_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Marker _buildStopMarker(BuildContext context, BusStopModel stop) {
    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: 36,
      height: 36,
      child: GestureDetector(
        onTap: () => _showStopSheet(context, stop),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.stopOrange,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: AppColors.stopOrange.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.signpost_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  void _showBusSheet(BuildContext context, BusLocationModel bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BusDetailSheet(bus: bus),
    );
  }

  void _showStopSheet(BuildContext context, BusStopModel stop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (context, scrollController) => StopDetailSheet(
          stop: stop,
          scrollController: scrollController,
        ),
      ),
    );
  }
}
