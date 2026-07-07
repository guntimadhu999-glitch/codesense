import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/stat_pill.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService.instance;
  late bool _dark = _storage.darkMode;
  late bool _sound = _storage.soundEnabled;

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title:
            Text('⚠️ Delete ALL review history?', style: AppTheme.ui(size: 17)),
        content: Text('This cannot be undone.',
            style: AppTheme.ui(size: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTheme.ui(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete All',
                style: AppTheme.ui(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storage.clearAll();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final avg = _storage.averageScore;
    return Scaffold(
      appBar: AppBar(
        title: Text('CodeSense',
            style: AppTheme.ui(
                size: 20, weight: FontWeight.w700, color: AppColors.cyan)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: Text('CodeSense v1.0.0',
                style: AppTheme.ui(size: 13, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 20),
          Text('Stats', style: AppTheme.ui(size: 15, weight: FontWeight.w600)),
          const SizedBox(height: 12),
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
                  label: 'Avg. Score',
                  value: _storage.totalReviews == 0
                      ? '—'
                      : avg.toStringAsFixed(0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatPill(
            emoji: '🏆',
            label: 'Most Reviewed Language',
            value: _storage.mostReviewedLanguage,
          ),
          const SizedBox(height: 24),
          Text('Preferences',
              style: AppTheme.ui(size: 15, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          _toggleCard(
            emoji: '🌙',
            label: 'Dark Mode',
            value: _dark,
            onChanged: (v) async {
              setState(() => _dark = v);
              await _storage.setDarkMode(v);
            },
          ),
          const SizedBox(height: 12),
          _toggleCard(
            emoji: '🔔',
            label: 'Sound on review complete',
            value: _sound,
            onChanged: (v) async {
              setState(() => _sound = v);
              await _storage.setSoundEnabled(v);
            },
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _clearAll,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('🗑️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text('Clear All History',
                      style: AppTheme.ui(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.danger)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About', style: AppTheme.ui(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('CodeSense v1.0.0 — AI Code Review Assistant',
                    style:
                        AppTheme.ui(size: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleCard({
    required String emoji,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTheme.ui(size: 14))),
          Switch(
            value: value,
            activeThumbColor: AppColors.bg,
            activeTrackColor: AppColors.cyan,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
