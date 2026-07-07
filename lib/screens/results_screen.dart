import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:share_plus/share_plus.dart';

import '../models/code_review.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/score_ring.dart';
import '../widgets/severity_chip.dart';
import '../widgets/toast.dart';
import 'new_review_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.review, this.playSound = false});

  factory ResultsScreen.fromReview(CodeReview review,
          {bool playSound = false}) =>
      ResultsScreen(review: review, playSound: playSound);

  final CodeReview review;
  final bool playSound;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    if (widget.playSound && StorageService.instance.soundEnabled) {
      // Pragmatic choice: use the platform click sound for "review complete"
      // instead of bundling an audio asset.
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.review.fixedCode));
    if (!mounted) return;
    setState(() => _copied = true);
    AppToast.show(context, '✅ Copied to clipboard!',
        icon: Icons.check_circle_outline);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _share() {
    final r = widget.review;
    final buffer = StringBuffer()
      ..writeln('CodeSense Review Report')
      ..writeln('Language: ${r.language}')
      ..writeln('Quality Score: ${r.qualityScore}/100')
      ..writeln('')
      ..writeln('Bugs Found:');
    if (r.bugs.isEmpty) {
      buffer.writeln('  None');
    } else {
      for (final b in r.bugs) {
        buffer.writeln(
            '  [${b['severity']}] (${b['line']}) ${b['description']}');
      }
    }
    buffer
      ..writeln('')
      ..writeln('Improvements:');
    if (r.improvements.isEmpty) {
      buffer.writeln('  None');
    } else {
      for (var i = 0; i < r.improvements.length; i++) {
        buffer.writeln('  ${i + 1}. ${r.improvements[i]}');
      }
    }
    buffer
      ..writeln('')
      ..writeln('Fixed Code:')
      ..writeln(r.fixedCode)
      ..writeln('')
      ..writeln('Explanation:')
      ..writeln(r.explanation);

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  void _tryAgain() {
    Navigator.of(context).pushReplacement(
      SlideRightRoute(page: NewReviewScreen(existing: widget.review)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final scoreColor = AppColors.forScore(r.qualityScore);
    final langUnknown =
        r.language.trim().isEmpty || r.language.toLowerCase() == 'unknown';

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Results', style: AppTheme.ui(size: 20, weight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _share,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(child: ScoreRing(score: r.qualityScore)),
          const SizedBox(height: 12),
          Center(
            child: Text('⚡ Code Quality Score',
                style: AppTheme.ui(
                    size: 15, weight: FontWeight.w600, color: scoreColor)),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: (langUnknown ? AppColors.textSecondary : AppColors.cyan)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '💻 ${langUnknown ? "Unknown" : r.language}',
                style: AppTheme.ui(
                    size: 13,
                    weight: FontWeight.w600,
                    color: langUnknown
                        ? AppColors.textSecondary
                        : AppColors.cyan),
              ),
            ),
          ),
          if (langUnknown) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Couldn\'t detect language — select manually below next time',
                textAlign: TextAlign.center,
                style: AppTheme.ui(size: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _bugsSection(r),
          const SizedBox(height: 16),
          _improvementsSection(r),
          const SizedBox(height: 16),
          _fixedCodeSection(r),
          const SizedBox(height: 16),
          _explanationSection(r),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _outlineButton(
                    '🔄 Try Again', AppColors.cyan, _tryAgain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _outlineButton(
                    '📤 Share', AppColors.electricBlue, _share),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.cyan, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTheme.ui(size: 16, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _bugsSection(CodeReview r) {
    return _sectionCard(
      title: '🐛 Bugs Found (${r.bugs.length})',
      child: r.bugs.isEmpty
          ? Text('No bugs detected. 🎉',
              style: AppTheme.ui(size: 13, color: AppColors.success))
          : Column(
              children: [
                for (var i = 0; i < r.bugs.length; i++)
                  _BugRow(bug: r.bugs[i], index: i),
              ],
            ),
    );
  }

  Widget _improvementsSection(CodeReview r) {
    return _sectionCard(
      title: '💡 Improvements',
      child: r.improvements.isEmpty
          ? Text('No suggestions.',
              style: AppTheme.ui(size: 13, color: AppColors.textSecondary))
          : Column(
              children: [
                for (var i = 0; i < r.improvements.length; i++)
                  _ImprovementRow(
                      text: r.improvements[i], number: i + 1, index: i),
              ],
            ),
    );
  }

  Widget _fixedCodeSection(CodeReview r) {
    return _sectionCard(
      title: '✅ Fixed Code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              color: const Color(0xFF282C34),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: HighlightView(
                  r.fixedCode.isEmpty ? '// (no code returned)' : r.fixedCode,
                  language: _highlightLang(r.language),
                  theme: atomOneDarkTheme,
                  padding: const EdgeInsets.all(14),
                  textStyle: AppTheme.mono(size: 12.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _copy,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_copied ? '✅' : '📋',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(_copied ? 'Copied!' : 'Copy Code',
                      style: AppTheme.ui(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.cyan)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _explanationSection(CodeReview r) {
    return _sectionCard(
      title: '📖 Explanation',
      child: Text(
        r.explanation.isEmpty ? 'No explanation provided.' : r.explanation,
        style: AppTheme.ui(
            size: 13.5, color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }

  Widget _outlineButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(label,
            style:
                AppTheme.ui(size: 14, weight: FontWeight.w600, color: color)),
      ),
    );
  }

  static String _highlightLang(String lang) {
    switch (lang.toLowerCase()) {
      case 'javascript':
        return 'javascript';
      case 'typescript':
        return 'typescript';
      case 'python':
        return 'python';
      case 'java':
        return 'java';
      case 'dart':
        return 'dart';
      case 'c++':
        return 'cpp';
      case 'c#':
        return 'cs';
      case 'go':
        return 'go';
      case 'rust':
        return 'rust';
      case 'php':
        return 'php';
      case 'kotlin':
        return 'kotlin';
      case 'swift':
        return 'swift';
      default:
        return 'plaintext';
    }
  }
}

class _BugRow extends StatefulWidget {
  const _BugRow({required this.bug, required this.index});
  final Map<String, String> bug;
  final int index;

  @override
  State<_BugRow> createState() => _BugRowState();
}

class _BugRowState extends State<_BugRow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 120 * widget.index), () {
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
    final b = widget.bug;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SeverityChip(severity: b['severity'] ?? 'minor'),
                  const SizedBox(width: 8),
                  if ((b['line'] ?? '').isNotEmpty)
                    Flexible(
                      child: Text('Line: ${b['line']}',
                          style: AppTheme.mono(
                              size: 11, color: AppColors.textSecondary)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(b['description'] ?? '',
                  style: AppTheme.ui(size: 13, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImprovementRow extends StatefulWidget {
  const _ImprovementRow(
      {required this.text, required this.number, required this.index});
  final String text;
  final int number;
  final int index;

  @override
  State<_ImprovementRow> createState() => _ImprovementRowState();
}

class _ImprovementRowState extends State<_ImprovementRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
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
    return FadeTransition(
      opacity: _controller,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Text('${widget.number}',
                  style: AppTheme.ui(
                      size: 11,
                      weight: FontWeight.w700,
                      color: AppColors.cyan)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.text,
                  style: AppTheme.ui(size: 13.5, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}
