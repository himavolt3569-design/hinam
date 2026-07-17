import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/trip/data/models/ride_model.dart';

const _steps = [
  (status: RideStatus.matched, label: 'Matched'),
  (status: RideStatus.arrived, label: 'Arrived'),
  (status: RideStatus.inProgress, label: 'In Trip'),
  (status: RideStatus.completed, label: 'Completed'),
];

class TripStatusBar extends StatelessWidget {
  final RideStatus status;

  const TripStatusBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((step) => step.status == status);

    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0) Expanded(child: _Connector(isDone: i <= currentIndex)),
          _StepDot(
            label: _steps[i].label,
            isDone: i < currentIndex,
            isCurrent: i == currentIndex,
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;

  const _StepDot({
    required this.label,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isDone || isCurrent;
    final color = isActive ? AppColors.primary : AppColors.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.inputFill,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isDone;

  const _Connector({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: isDone ? AppColors.primary : AppColors.border,
    );
  }
}
