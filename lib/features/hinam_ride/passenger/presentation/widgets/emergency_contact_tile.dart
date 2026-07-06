import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';

class EmergencyContactTile extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback? onRemove;

  const EmergencyContactTile({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.contact_phone_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Emergency Contact',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 10),

          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Contact name',
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '98XXXXXXXX',
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
