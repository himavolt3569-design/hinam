import 'package:flutter/material.dart';

import 'package:hinam/core/theme/app_colors.dart';

class RatingPrompt extends StatefulWidget {
  final String title;
  final bool isSubmitting;
  final Future<void> Function(double rating, String? comment) onSubmit;

  const RatingPrompt({
    super.key,
    required this.title,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<RatingPrompt> createState() => _RatingPromptState();
}

class _RatingPromptState extends State<RatingPrompt> {
  final _commentController = TextEditingController();
  int _selectedStars = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedStars == 0) return;
    final comment = _commentController.text.trim();
    widget.onSubmit(
      _selectedStars.toDouble(),
      comment.isEmpty ? null : comment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starValue = i + 1;
              return IconButton(
                onPressed: () => setState(() => _selectedStars = starValue),
                icon: Icon(
                  starValue <= _selectedStars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppColors.warning,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Add a comment (optional)',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: (_selectedStars == 0 || widget.isSubmitting)
                ? null
                : _submit,
            child: Text(widget.isSubmitting ? 'Submitting…' : 'Submit Rating'),
          ),
        ],
      ),
    );
  }
}
