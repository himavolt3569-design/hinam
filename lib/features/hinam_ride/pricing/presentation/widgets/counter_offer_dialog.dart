import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hinam/core/theme/app_colors.dart';

class CounterOfferDialog extends StatefulWidget {
  final double currentAmount;
  final ValueChanged<double> onSubmit;

  const CounterOfferDialog({
    super.key,
    required this.currentAmount,
    required this.onSubmit,
  });

  @override
  State<CounterOfferDialog> createState() => _CounterOfferDialogState();
}

class _CounterOfferDialogState extends State<CounterOfferDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  double get _minAmount => widget.currentAmount * 0.8;
  double get _maxAmount => widget.currentAmount * 1.2;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final amount = double.tryParse(value);
    setState(() {
      if (amount == null || amount <= 0) {
        _errorText = 'Enter a valid amount';
      } else if (amount < _minAmount || amount > _maxAmount) {
        _errorText =
            'Must be between Rs. ${_minAmount.toStringAsFixed(0)} and '
            'Rs. ${_maxAmount.toStringAsFixed(0)}';
      } else {
        _errorText = null;
      }
    });
  }

  void _submit() {
    final amount = double.tryParse(_controller.text);
    if (amount == null || _errorText != null) return;
    Navigator.pop(context);
    widget.onSubmit(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Propose a Different Fare'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Must be within 20% of Rs. ${widget.currentAmount.toStringAsFixed(0)}.',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _validate,
            decoration: InputDecoration(
              prefixText: 'Rs. ',
              errorText: _errorText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Send'),
        ),
      ],
    );
  }
}
