import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/passenger/data/models/ride_passenger_model.dart';
import 'emergency_contact_tile.dart';

class EmergencyContactControllers {
  final TextEditingController name;
  final TextEditingController phone;

  EmergencyContactControllers()
    : name = TextEditingController(),
      phone = TextEditingController();

  void dispose() {
    name.dispose();
    phone.dispose();
  }
}

class RidePassengerRegistrationForm extends StatelessWidget {
  final TextEditingController fullNameController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final List<EmergencyContactControllers> emergencyContacts;
  final VoidCallback onAddContact;
  final ValueChanged<int> onRemoveContact;

  const RidePassengerRegistrationForm({
    super.key,
    required this.fullNameController,
    required this.gender,
    required this.onGenderChanged,
    required this.emergencyContacts,
    required this.onAddContact,
    required this.onRemoveContact,
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
              hintText: 'Anjali Shrestha',
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

          const SizedBox(height: 20),

          const _SectionLabel(label: 'Emergency Contacts'),
          const SizedBox(height: 12),

          for (var i = 0; i < emergencyContacts.length; i++)
            EmergencyContactTile(
              key: ValueKey(emergencyContacts[i]),
              nameController: emergencyContacts[i].name,
              phoneController: emergencyContacts[i].phone,
              onRemove: emergencyContacts.length > 1
                  ? () => onRemoveContact(i)
                  : null,
            ),

          if (emergencyContacts.length <
              RidePassengerModel.maxEmergencyContacts)
            OutlinedButton.icon(
              onPressed: onAddContact,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Another Contact'),
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
