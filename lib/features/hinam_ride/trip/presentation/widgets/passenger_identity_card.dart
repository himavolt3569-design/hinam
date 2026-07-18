import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/passenger/presentation/providers/ride_passenger_provider.dart';

class PassengerIdentityCard extends ConsumerWidget {
  final String passengerId;

  const PassengerIdentityCard({super.key, required this.passengerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(ridePassengerByIdProvider(passengerId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: passengerAsync.when(
        loading: () => const SizedBox(
          height: 40,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (error, stackTrace) => const Text(
          'Could not load passenger details.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        data: (passenger) {
          if (passenger == null) {
            return const Text(
              'Passenger details unavailable.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            );
          }

          return Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.rideAccentBg,
                child: Icon(Icons.person_rounded, color: AppColors.rideAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      passenger.phoneNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    passenger.ratingAvg.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
