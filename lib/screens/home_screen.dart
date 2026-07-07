import 'package:flutter/material.dart';

import '../models/code_review.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/history_card.dart';
import '../widgets/stat_pill.dart';
import 'new_review_screen.dart';
import 'results_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _storage = StorageService.instance;

  late final AnimationController _fabController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.0,
    upperBound: 0.12,
  );

  void _refresh() => setState(() {});

  Future<void> _openNewReview({CodeReview? existing}) async {
    await _fabController.forward();
    await _fabController.reverse();
    if (!mounted) return;
    await Navigator.of(context).push(
      SlideRightRoute(page: NewReviewScreen(existing: existing)),
    );
    _refresh();
  }

  void _openResults(CodeReview review) {
    Navigator.of(context).push(
      SlideRightRoute(page: ResultsScreen.fromReview(review)),
    );
  }

  Future<void> _delete(CodeReview review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('⚠️ Delete this review?', style: AppTheme.ui(size: 17)),
        content: Text(
          'This review will be removed.',
          style: AppTheme.ui(size: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTheme.ui(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: AppTheme.ui(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    // Soft delete: remove from box, offer 7s undo, re-add if undone.
    await _storage.deleteReview(review.id);
    if (!mounted) return;
    _refresh();

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 7),
        backgroundColor: AppColors.card,
        content: Text('🗑️ Review deleted',
            style: AppTheme.ui(color: AppColors.textPrimary)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.cyan,
          onPressed: () async {
            await _storage.saveReview(review);
            if (mounted) _refresh();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _storage.allReviews();
    final avg = _storage.averageScore;

    return Scaffold(
      appBar: AppBar(
        title: Text('CodeSense 🔍',
            style: AppTheme.ui(
                size: 22, weight: FontWeight.w700, color: AppColors.cyan)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context)
                  .push(SlideRightRoute(page: const SettingsScreen()));
              _refresh();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.88).animate(_fabController),
        child: GestureDetector(
          onTap: _openNewReview,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.cyanGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: AppColors.bg, size: 30),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: StatPill(
                  emoji: '📚',
                  label: 'Total Reviews',
                  value: '${_storage.totalReviews}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatPill(
                  emoji: '⚡',
                  label: 'Avg. Quality',
                  value: _storage.totalReviews == 0
                      ? '—'
                      : avg.toStringAsFixed(0),
                  valueColor: _storage.totalReviews == 0
                      ? AppColors.textSecondary
                      : AppColors.forScore(avg.round()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('History',
              style: AppTheme.ui(size: 16, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            _emptyState()
          else
            ...reviews.asMap().entries.map(
                  (e) => HistoryCard(
                    review: e.value,
                    index: e.key,
                    onTap: () => _openResults(e.value),
                    onEdit: () => _openNewReview(existing: e.value),
                    onDelete: () => _delete(e.value),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text('No reviews yet',
              style: AppTheme.ui(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap + to review your first code',
              style: AppTheme.ui(size: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
