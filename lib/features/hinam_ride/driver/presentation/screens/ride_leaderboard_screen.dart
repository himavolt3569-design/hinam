import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/providers/ride_leaderboard_provider.dart';
import 'package:hinam/features/hinam_ride/driver/presentation/widgets/leaderboard_tile.dart';
import 'package:hinam/shared/widgets/empty_state_view.dart';

class RideLeaderboardScreen extends ConsumerWidget {
  const RideLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(rideLeaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Driver Leaderboard')),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
        data: (drivers) {
          if (drivers.isEmpty) {
            return const EmptyStateView(
              icon: Icons.emoji_events_outlined,
              title: 'No drivers online yet',
              subtitle:
                  'Verified drivers will appear here once they go online.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: drivers.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                LeaderboardTile(rank: i + 1, driver: drivers[i]),
          );
        },
      ),
    );
  }
}
