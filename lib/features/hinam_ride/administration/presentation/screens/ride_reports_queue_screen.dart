import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_report_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/widgets/report_review_card.dart';
import 'package:hinam/shared/widgets/empty_state_view.dart';

class RideReportsQueueScreen extends ConsumerWidget {
  const RideReportsQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openAsync = ref.watch(openReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Reports Queue')),
      body: openAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyStateView(
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.success,
              iconBackgroundColor: AppColors.success.withValues(alpha: 0.08),
              title: 'All caught up!',
              subtitle: 'No open ride reports right now.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) => ReportReviewCard(report: reports[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
