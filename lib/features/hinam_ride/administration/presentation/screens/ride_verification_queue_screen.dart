import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_admin_providers.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/widgets/verification_review_card.dart';

class RideVerificationQueueScreen extends ConsumerWidget {
  const RideVerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRideVerificationsProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Verification Queue'),
        centerTitle: true,
      ),
      body: pendingAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 38,
                      color: Colors.green.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No ride verifications pending review.',
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
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
