import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/administration/data/models/ride_report_model.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_report_providers.dart';

class ReportReviewCard extends ConsumerWidget {
  final RideReportModel report;

  const ReportReviewCard({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final reporterNameAsync = ref.watch(
      reportedUserNameProvider(report.reportedBy),
    );
    final reportedNameAsync = ref.watch(
      reportedUserNameProvider(report.reportedUserId),
    );
    final controller = ref.read(reportReviewControllerProvider.notifier);
    final isReviewed = report.status == RideReportStatus.reviewed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${reporterNameAsync.asData?.value ?? 'Loading…'} reported '
                  '${reportedNameAsync.asData?.value ?? 'Loading…'}',
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isReviewed
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isReviewed
                        ? Colors.blue.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isReviewed ? 'Reviewed' : 'Open',
                  style: text.labelSmall?.copyWith(
                    color: isReviewed ? Colors.blue[700] : Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.reason,
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            report.details,
            style: text.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!isReviewed)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.markReviewed(report.id),
                    child: const Text('Mark Reviewed'),
                  ),
                ),
              if (!isReviewed) const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => controller.resolve(report.id),
                  child: const Text('Resolve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
