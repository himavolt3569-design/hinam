import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/auth/presentation/providers/auth_controller.dart';
import 'package:hinam/features/hinam_ride/pricing/presentation/widgets/offer_card.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/active_ride_provider.dart';

class IncomingRequestScreen extends ConsumerWidget {
  const IncomingRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authControllerProvider.notifier).currentUser();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be signed in to see requests.')),
      );
    }

    final offersAsync = ref.watch(pendingOffersForDriverProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ride Requests')),
      body: offersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (offers) {
          if (offers.isEmpty) {
            return const Center(
              child: Text(
                'No incoming ride requests right now.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: offers.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                OfferCard(offer: offers[i], driverId: user.uid),
          );
        },
      ),
    );
  }
}
