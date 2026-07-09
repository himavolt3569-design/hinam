import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/pricing/presentation/providers/negotiation_controller.dart';
import 'package:hinam/features/hinam_ride/pricing/presentation/widgets/counter_offer_dialog.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_offer_model.dart';

class OfferCard extends ConsumerWidget {
  final RideOfferModel offer;
  final String driverId;

  const OfferCard({super.key, required this.offer, required this.driverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negotiationState = ref.watch(negotiationControllerProvider);
    final isBusy = negotiationState.isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LocationRow(
            icon: Icons.trip_origin_rounded,
            color: AppColors.success,
            label: offer.pickup.address,
          ),
          const SizedBox(height: 8),
          _LocationRow(
            icon: Icons.location_on_rounded,
            color: AppColors.error,
            label: offer.dropoff.address,
          ),
          const SizedBox(height: 14),
          Text(
            'Offered Fare: Rs. ${offer.offerAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : () => _decline(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : () => _showCounterDialog(context, ref),
                  child: const Text('Counter'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: isBusy ? null : () => _accept(context, ref),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    await ref
        .read(negotiationControllerProvider.notifier)
        .acceptOffer(rideId: offer.rideId, offerId: offer.id, driverId: driverId);
    if (!context.mounted) return;
    _showErrorIfAny(context, ref);
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    await ref
        .read(negotiationControllerProvider.notifier)
        .declineOffer(rideId: offer.rideId, offerId: offer.id);
    if (!context.mounted) return;
    _showErrorIfAny(context, ref);
  }

  void _showCounterDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => CounterOfferDialog(
        currentAmount: offer.offerAmount,
        onSubmit: (amount) async {
          await ref
              .read(negotiationControllerProvider.notifier)
              .counterOffer(
                rideId: offer.rideId,
                offerId: offer.id,
                amount: amount,
              );
          if (!context.mounted) return;
          _showErrorIfAny(context, ref);
        },
      ),
    );
  }

  void _showErrorIfAny(BuildContext context, WidgetRef ref) {
    final error = ref.read(negotiationControllerProvider).error;
    if (error == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LocationRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
