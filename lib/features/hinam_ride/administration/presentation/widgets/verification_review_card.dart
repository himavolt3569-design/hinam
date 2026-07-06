import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_admin_providers.dart';
import 'package:hinam/features/hinam_ride/verification/data/models/verification_request_model.dart';

class VerificationReviewCard extends ConsumerWidget {
  final VerificationRequestModel request;

  const VerificationReviewCard({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final nameAsync = ref.watch(verificationSubjectNameProvider(request));
    final controller = ref.read(verificationReviewControllerProvider.notifier);
    final isDriver = request.subjectType == VerificationSubjectType.driver;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isDriver
                        ? Icons.two_wheeler_rounded
                        : Icons.favorite_rounded,
                    color: scheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameAsync.asData?.value ?? 'Loading…',
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isDriver ? 'Ride Driver' : 'Ride Passenger',
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Pending',
                    style: text.labelSmall?.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Documents
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in request.documentUrls.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DocumentPreview(
                        label: entry.key,
                        url: entry.value,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmReject(context, controller),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(
                        color: scheme.error.withValues(alpha: 0.4),
                      ),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => controller.approve(request),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReject(
    BuildContext context,
    VerificationReviewController controller,
  ) {
    var reason = '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Verification?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for rejecting this submission.',
            ),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. Blurry document photo',
              ),
              onChanged: (value) => reason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmedReason = reason.trim();
              if (trimmedReason.isEmpty) return;
              Navigator.pop(dialogContext);
              controller.reject(request, trimmedReason);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  final String label;
  final String url;

  const _DocumentPreview({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _labelize(label),
          style: text.labelSmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 140,
              alignment: Alignment.center,
              color: scheme.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                color: scheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _labelize(String key) {
    final withSpaces = key.replaceAllMapped(
      RegExp('([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}
