import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hinam/core/theme/app_colors.dart';

class DocumentUploadTile extends StatelessWidget {
  final String label;
  final File? file;
  final ValueChanged<File> onPicked;

  const DocumentUploadTile({
    super.key,
    required this.label,
    required this.file,
    required this.onPicked,
  });

  Future<void> _pickDocument() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final isUploaded = file != null;

    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUploaded
                  ? Icons.check_circle_rounded
                  : Icons.upload_file_outlined,
              size: 20,
              color: isUploaded ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              isUploaded ? 'Uploaded' : 'Tap to upload',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isUploaded ? AppColors.success : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
