import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:hinam/core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Track School Bus'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
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

          if (schoolNames.isNotEmpty)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: SchoolFilterBar(
                schoolNames: schoolNames,
                selectedSchool: _selectedSchool,
                onSelected: (name) => setState(() => _selectedSchool = name),
              ),
            ),

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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(BuildContext context, BusLocationModel bus) {
    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => _showBusSheet(context, bus),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.schoolGreen,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.schoolGreen.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  void _showBusSheet(BuildContext context, BusLocationModel bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SchoolBusDetailSheet(bus: bus),
    );
  }
}
