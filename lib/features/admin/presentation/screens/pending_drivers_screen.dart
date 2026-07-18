import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/admin/presentation/providers/admin_providers.dart';
import 'package:hinam/features/admin/presentation/widgets/driver_approval_card.dart';
import 'package:hinam/shared/widgets/empty_state_view.dart';

class PendingDriversScreen extends ConsumerWidget {
  const PendingDriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDriversProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: pendingAsync.when(
        data: (drivers) {
          if (drivers.isEmpty) {
            return EmptyStateView(
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.success,
              iconBackgroundColor: AppColors.success.withValues(alpha: 0.08),
              title: 'All caught up!',
              subtitle: 'No drivers pending approval.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: drivers.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) => DriverApprovalCard(driver: drivers[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
