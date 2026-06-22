import 'package:flutter/material.dart';
import 'package:hinam/core/theme/app_colors.dart';

import 'bus_type_selector.dart';
import 'section_label.dart';

class RegistrationFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController busNumberController;
  final TextEditingController routeController;
  final TextEditingController schoolController;
  final String busType;
  final ValueChanged<String> onBusTypeChanged;

  const RegistrationFormCard({
    super.key,
    required this.nameController,
    required this.busNumberController,
    required this.routeController,
    required this.schoolController,
    required this.busType,
    required this.onBusTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label: 'Personal Info'),
          const SizedBox(height: 12),

          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Ram Sharma',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Please enter your name';
              return null;
            },
          ),

          const SizedBox(height: 14),

          TextFormField(
            controller: busNumberController,
            decoration: const InputDecoration(
              labelText: 'Bus Number',
              hintText: 'Ba 3 Kha 1234',
              prefixIcon: Icon(Icons.directions_bus_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Please enter bus number';
              return null;
            },
          ),

          const SizedBox(height: 20),

          SectionLabel(label: 'Bus Type'),
          const SizedBox(height: 12),

          BusTypeSelector(busType: busType, onChanged: onBusTypeChanged),

          const SizedBox(height: 16),

          if (busType == 'public')
            TextFormField(
              controller: routeController,
              decoration: const InputDecoration(
                labelText: 'Route Name',
                hintText: 'Kalanki → Ratnapark',
                prefixIcon: Icon(Icons.route_outlined),
              ),
              validator: (value) {
                if (busType == 'public' &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Please enter route name';
                }
                return null;
              },
            ),

          if (busType == 'school')
            TextFormField(
              controller: schoolController,
              decoration: const InputDecoration(
                labelText: 'School Name',
                hintText: 'ABC Secondary School',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              validator: (value) {
                if (busType == 'school' &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Please enter school name';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }
}
