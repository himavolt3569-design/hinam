import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';
import 'package:hinam/features/hinam_ride/trip/presentation/providers/cancellation_controller.dart';

class NoShowBanner extends ConsumerStatefulWidget {
  final RideModel ride;

  /// Only the assigned driver can actually mark a no-show (enforced by
  /// `firestore.rules`) — the passenger's copy of this banner shows the same
  /// countdown but never the action button.
  final bool canMarkNoShow;

  const NoShowBanner({
    super.key,
    required this.ride,
    required this.canMarkNoShow,
  });

  @override
  ConsumerState<NoShowBanner> createState() => _NoShowBannerState();
}

class _NoShowBannerState extends ConsumerState<NoShowBanner> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration get _remaining {
    final arrivedAt = widget.ride.arrivedAt;
    if (arrivedAt == null) return Duration.zero;

    final elapsed = DateTime.now().difference(arrivedAt.toDate());
    final remaining = noShowGracePeriod - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> _markNoShow() async {
    await ref
        .read(cancellationControllerProvider.notifier)
        .markNoShow(widget.ride.id);

    if (!mounted) return;
    final error = ref.read(cancellationControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining;
    final isElapsed = remaining == Duration.zero;
    final actionState = ref.watch(cancellationControllerProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isElapsed
                  ? 'Passenger has not shown up.'
                  : 'Waiting for passenger — '
                        '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')} remaining',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (isElapsed && widget.canMarkNoShow)
            TextButton(
              onPressed: actionState.isLoading ? null : _markNoShow,
              child: const Text('Mark No-Show'),
            ),
        ],
      ),
    );
  }
}
