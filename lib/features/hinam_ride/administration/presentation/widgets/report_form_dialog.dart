import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hinam/core/theme/app_colors.dart';
import 'package:hinam/features/hinam_ride/administration/presentation/providers/ride_report_providers.dart';

class ReportFormDialog extends ConsumerStatefulWidget {
  final String rideId;
  final String reportedUserId;

  const ReportFormDialog({
    super.key,
    required this.rideId,
    required this.reportedUserId,
  });

  @override
  ConsumerState<ReportFormDialog> createState() => _ReportFormDialogState();
}

class _ReportFormDialogState extends ConsumerState<ReportFormDialog> {
  final _reasonController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _reasonController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    final details = _detailsController.text.trim();

    if (reason.isEmpty || details.isEmpty) {
      setState(() => _errorText = 'Please fill in both fields.');
      return;
    }

    final navigator = Navigator.of(context);
    await ref
        .read(reportFilingControllerProvider.notifier)
        .fileReport(
          rideId: widget.rideId,
          reportedUserId: widget.reportedUserId,
          reason: reason,
          details: details,
        );

    if (!mounted) return;

    final error = ref.read(reportFilingControllerProvider).error;
    if (error != null) {
      setState(() => _errorText = error.toString());
      return;
    }

    navigator.pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(reportFilingControllerProvider).isLoading;

    return AlertDialog(
      title: const Text('Report an Issue'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _reasonController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Reason (e.g. Unsafe driving)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'What happened?'),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isSubmitting ? null : _submit,
          child: Text(isSubmitting ? 'Submitting…' : 'Submit Report'),
        ),
      ],
    );
  }
}
