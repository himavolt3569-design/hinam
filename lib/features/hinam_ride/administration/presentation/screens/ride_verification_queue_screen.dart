import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_admin_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/widgets/verification_review_card.dart';
import 'package:hinam/shared/widgets/empty_state_view.dart';

class RideVerificationQueueScreen extends ConsumerWidget {
  const RideVerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRideVerificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Verification Queue')),
      body: pendingAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return EmptyStateView(
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.success,
              iconBackgroundColor: AppColors.success.withValues(alpha: 0.08),
              title: 'All caught up!',
              subtitle: 'No ride verifications pending review.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                VerificationReviewCard(request: requests[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
