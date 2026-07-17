import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/payments/presentation/providers/ride_payment_provider.dart';

class MarkPaidButton extends ConsumerWidget {
  final String rideId;
  final String payerId;
  final String payeeId;
  final double amount;

  const MarkPaidButton({
    super.key,
    required this.rideId,
    required this.payerId,
    required this.payeeId,
    required this.amount,
  });

  Future<void> _markPaid(BuildContext context, WidgetRef ref) async {
    await ref
        .read(ridePaymentControllerProvider.notifier)
        .markPaid(
          rideId: rideId,
          payerId: payerId,
          payeeId: payeeId,
          amount: amount,
        );

    if (!context.mounted) return;
    final error = ref.read(ridePaymentControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(rideTransactionProvider(rideId));
    final actionState = ref.watch(ridePaymentControllerProvider);

    return transactionAsync.when(
      loading: () => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => Text('$error'),
      data: (transaction) {
        if (transaction != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                SizedBox(width: 6),
                Text(
                  'Paid in Cash',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: actionState.isLoading
              ? null
              : () => _markPaid(context, ref),
          icon: const Icon(Icons.payments_outlined, size: 18),
          label: Text(
            actionState.isLoading ? 'Marking…' : 'Mark as Paid (Cash)',
          ),
        );
      },
    );
  }
}
