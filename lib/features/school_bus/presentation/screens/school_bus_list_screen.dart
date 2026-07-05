import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/routes/app_routes.dart';
import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/school_bus/presentation/providers/school_bus_providers.dart';
import 'package:hinam/features/school_bus/presentation/widgets/school_bus_list_card.dart';
import 'package:hinam/shared/models/bus_location_model.dart';

class SchoolBusListScreen extends ConsumerStatefulWidget {
  const SchoolBusListScreen({super.key});

  @override
  ConsumerState<SchoolBusListScreen> createState() => _SchoolBusListScreenState();
}

class _SchoolBusListScreenState extends ConsumerState<SchoolBusListScreen> {
  String _selectedSchool = '';

  @override
  Widget build(BuildContext context) {
    final schoolBusesAsync = ref.watch(schoolBusesProvider);
    final schoolNames = ref.watch(activeSchoolNamesProvider);
    final visibleBuses = ref.watch(filteredSchoolBusesProvider(_selectedSchool));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Track School Bus')),
      body: Column(
        children: [
          // School filter chips
          if (schoolNames.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _Chip(
                    label: 'All',
                    selected: _selectedSchool.isEmpty,
                    onTap: () => setState(() => _selectedSchool = ''),
                  ),
                  ...schoolNames.map((name) => _Chip(
                        label: name,
                        selected: _selectedSchool == name,
                        onTap: () => setState(() => _selectedSchool = name),
                      )),
                ],
              ),
            ),

          Expanded(
            child: schoolBusesAsync.when(
              data: (all) {
                if (all.isEmpty) {
                  return _buildEmpty(
                    'No school buses active',
                    'No school buses are currently tracking.',
                  );
                }
                final buses = visibleBuses;
                if (buses.isEmpty) {
                  return _buildEmpty(
                    'No buses for $_selectedSchool',
                    'Try selecting a different school.',
                  );
                }
                return _buildList(buses);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<BusLocationModel> buses) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: buses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => SchoolBusListCard(
        bus: buses[i],
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.singleBusMap,
          arguments: buses[i].driverId,
        ),
      ),
    );
  }

  Widget _buildEmpty(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.inputFill, shape: BoxShape.circle),
              child: const Icon(Icons.school_outlined, size: 32, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.schoolGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.schoolGreen : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
