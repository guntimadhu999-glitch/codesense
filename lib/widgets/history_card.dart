import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/code_review.dart';
import '../theme.dart';

/// Card showing a single saved review with edit/delete actions.
/// Includes a staggered fade + slide-up entrance.
class HistoryCard extends StatefulWidget {
  const HistoryCard({
    super.key,
    required this.review,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final CodeReview review;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final score = r.qualityScore;
    final scoreColor = AppColors.forScore(score);
    final firstLine = r.codeSnapshot.split('\n').first.trim();
    final dateStr = DateFormat('MMM d, yyyy').format(r.date);

    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _badge('💻 ${r.language.isEmpty ? "Unknown" : r.language}',
                              AppColors.cyan),
                          const SizedBox(width: 8),
                          _scoreBadge(score, scoreColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '📅 $dateStr',
                        style: AppTheme.ui(
                            size: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        firstLine.isEmpty ? '(empty)' : firstLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.mono(
                            size: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined,
                          size: 20, color: AppColors.cyan),
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.danger),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style:
                AppTheme.ui(size: 11, weight: FontWeight.w600, color: color)),
      );

  Widget _scoreBadge(int score, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('⚡ $score',
            style:
                AppTheme.ui(size: 11, weight: FontWeight.w700, color: color)),
      );
}
