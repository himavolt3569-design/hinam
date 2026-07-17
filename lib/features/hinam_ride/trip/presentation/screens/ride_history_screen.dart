import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/ride_history_provider.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/widgets/ride_history_tile.dart';

class RideHistoryScreen extends ConsumerWidget {
  final String uid;
  final bool isDriver;

  const RideHistoryScreen({
    super.key,
    required this.uid,
    required this.isDriver,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      rideHistoryProvider((uid: uid, isDriver: isDriver)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ride History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (rides) {
          if (rides.isEmpty) {
            return const Center(
              child: Text(
                'No rides yet.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rides.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                RideHistoryTile(ride: rides[i], isDriver: isDriver),
          );
        },
      ),
    );
  }
}
