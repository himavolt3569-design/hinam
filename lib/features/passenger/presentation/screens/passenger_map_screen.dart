import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Nearby Buses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, shadows: [
            Shadow(color: Colors.black26, blurRadius: 4),
          ]),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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

          // Tinted header gradient so app bar text is readable
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 110,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.primary.withValues(alpha: 0.85), Colors.transparent],
                ),
              ),
            ),
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
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
    final scheme = Theme.of(context).colorScheme;
    final isPublic = bus.busType == 'public';

    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 52,
      height: 52,
      child: GestureDetector(
        onTap: () => _showBusSheet(context, bus),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: scheme.primary.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: Icon(
            isPublic ? Icons.directions_bus_rounded : Icons.school_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Marker _buildStopMarker(BuildContext context, BusStopModel stop) {
    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showStopSheet(context, stop),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: const Color(0xFFEA580C).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.signpost_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  void _showBusSheet(BuildContext context, BusLocationModel bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BusDetailSheet(bus: bus),
    );
  }

  void _showStopSheet(BuildContext context, BusStopModel stop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
