import 'package:flutter/material.dart';

import '../theme.dart';

/// Pill stat used in the 2-column grids on Home / Settings.
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.label,
    required this.value,
    this.emoji,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? emoji;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${emoji != null ? '$emoji ' : ''}$value',
            style: AppTheme.ui(
              size: 22,
              weight: FontWeight.w700,
              color: valueColor ?? AppColors.cyan,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.ui(size: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
