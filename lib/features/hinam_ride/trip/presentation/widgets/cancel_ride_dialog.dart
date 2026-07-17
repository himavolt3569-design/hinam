import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';

class CancelRideDialog extends StatefulWidget {
  final bool reasonRequired;
  final ValueChanged<String?> onConfirm;

  const CancelRideDialog({
    super.key,
    required this.reasonRequired,
    required this.onConfirm,
  });

  @override
  State<CancelRideDialog> createState() => _CancelRideDialogState();
}

class _CancelRideDialogState extends State<CancelRideDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim();

    if (widget.reasonRequired && reason.isEmpty) {
      setState(
        () => _errorText = 'A reason is required for this cancellation.',
      );
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(reason.isEmpty ? null : reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel This Ride?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.reasonRequired
                ? 'Please explain why you are cancelling this trip.'
                : 'You can optionally tell us why.',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 2,
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            decoration: InputDecoration(
              hintText: widget.reasonRequired ? 'Reason' : 'Reason (optional)',
              errorText: _errorText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep Trip'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Cancel Trip'),
        ),
      ],
    );
  }
}
