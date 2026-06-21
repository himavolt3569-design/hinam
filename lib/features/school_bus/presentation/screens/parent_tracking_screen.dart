import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:hinam/features/passenger/presentation/widgets/bus_count_badge.dart';
import 'package:hinam/features/school_bus/presentation/providers/school_bus_providers.dart';
import 'package:hinam/features/school_bus/presentation/widgets/school_bus_detail_sheet.dart';
import 'package:hinam/features/school_bus/presentation/widgets/school_bus_empty_state.dart';
import 'package:hinam/features/school_bus/presentation/widgets/school_filter_bar.dart';
import 'package:hinam/features/tracking/data/models/bus_location_model.dart';

const _defaultCenter = LatLng(27.7172, 85.3240);
const _defaultZoom = 13.0;

class ParentTrackingScreen extends ConsumerStatefulWidget {
  const ParentTrackingScreen({super.key});

  @override
  ConsumerState<ParentTrackingScreen> createState() => _ParentTrackingScreenState();
}

class _ParentTrackingScreenState extends ConsumerState<ParentTrackingScreen> {
  String _selectedSchool = '';

  @override
  Widget build(BuildContext context) {
    final schoolBusesAsync = ref.watch(schoolBusesProvider);
    final schoolNames = ref.watch(activeSchoolNamesProvider);
    final visibleBuses = ref.watch(filteredSchoolBusesProvider(_selectedSchool));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Track School Bus',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, shadows: [
            Shadow(color: Colors.black26, blurRadius: 4),
          ]),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: schoolBusesAsync.maybeWhen(
              data: (buses) => BusCountBadge(count: buses.length, icon: Icons.school_rounded),
              orElse: () => const SizedBox(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(initialCenter: _defaultCenter, initialZoom: _defaultZoom),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hinam.app',
              ),
              MarkerLayer(markers: visibleBuses.map((b) => _buildMarker(context, b)).toList()),
            ],
          ),

          // Header gradient
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
                  colors: [Colors.green.shade700.withValues(alpha: 0.85), Colors.transparent],
                ),
              ),
            ),
          ),

          // School filter bar
          if (schoolNames.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              right: 16,
              child: SchoolFilterBar(
                schoolNames: schoolNames,
                selectedSchool: _selectedSchool,
                onSelected: (name) => setState(() => _selectedSchool = name),
              ),
            ),

          // Empty state
          schoolBusesAsync.when(
            data: (buses) {
              if (buses.isEmpty) {
                return Center(child: SchoolBusEmptyState());
              }
              if (visibleBuses.isEmpty && _selectedSchool.isNotEmpty) {
                return Center(
                  child: SchoolBusEmptyState(message: 'No active buses for $_selectedSchool'),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: Colors.green.shade600),
            ),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(BuildContext context, BusLocationModel bus) {
    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 52,
      height: 52,
      child: GestureDetector(
        onTap: () => _showBusSheet(context, bus),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
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
      builder: (_) => SchoolBusDetailSheet(bus: bus),
    );
  }
}
