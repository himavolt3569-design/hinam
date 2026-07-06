import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';

class VerificationStatusBanner extends StatelessWidget {
  final VerificationStatus status;
  final String? rejectionReason;

  const VerificationStatusBanner({
    super.key,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon, message) = switch (status) {
      VerificationStatus.pending => (
        AppColors.warningBg,
        AppColors.warning,
        Icons.pending_rounded,
        'Your profile is pending review.',
      ),
      VerificationStatus.approved => (
        AppColors.successBg,
        AppColors.success,
        Icons.check_circle_rounded,
        'Your profile has been verified.',
      ),
      VerificationStatus.rejected => (
        AppColors.errorBg,
        AppColors.error,
        Icons.cancel_rounded,
        rejectionReason ?? 'Your verification was rejected.',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: foreground.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
