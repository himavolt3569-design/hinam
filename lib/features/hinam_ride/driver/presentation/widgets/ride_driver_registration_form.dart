import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';

class RideDriverRegistrationForm extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController vehiclePlateController;
  final TextEditingController licenseNumberController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final String vehicleType;
  final ValueChanged<String> onVehicleTypeChanged;
  final DateTime? dateOfBirth;
  final ValueChanged<DateTime> onDateOfBirthChanged;

  const RideDriverRegistrationForm({
    super.key,
    required this.fullNameController,
    required this.vehiclePlateController,
    required this.licenseNumberController,
    required this.gender,
    required this.onGenderChanged,
    required this.vehicleType,
    required this.onVehicleTypeChanged,
    required this.dateOfBirth,
    required this.onDateOfBirthChanged,
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
          const _SectionLabel(label: 'Personal Info'),
          const SizedBox(height: 12),

          TextFormField(
            controller: fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Sita Gurung',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            initialValue: gender.isEmpty ? null : gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              if (value != null) onGenderChanged(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your gender';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          _DateOfBirthField(
            value: dateOfBirth,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
                firstDate: DateTime(now.year - 80),
                lastDate: now,
              );
              if (picked != null) onDateOfBirthChanged(picked);
            },
          ),

          const SizedBox(height: 20),

          const _SectionLabel(label: 'Vehicle Info'),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: vehicleType.isEmpty ? null : vehicleType,
            decoration: const InputDecoration(
              labelText: 'Vehicle Type',
              prefixIcon: Icon(Icons.two_wheeler_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'car', child: Text('Car')),
              DropdownMenuItem(value: 'scooter', child: Text('Scooter')),
              DropdownMenuItem(value: 'bike', child: Text('Bike')),
            ],
            onChanged: (value) {
              if (value != null) onVehicleTypeChanged(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your vehicle type';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          TextFormField(
            controller: vehiclePlateController,
            decoration: const InputDecoration(
              labelText: 'Vehicle Plate Number',
              hintText: 'Ba 3 Pa 5678',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your vehicle plate number';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          TextFormField(
            controller: licenseNumberController,
            decoration: const InputDecoration(
              labelText: 'License Number',
              hintText: 'DL-1234567',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your license number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      label,
      style: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _DateOfBirthField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = value == null
        ? 'Date of Birth'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: value == null
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.edit_calendar_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
