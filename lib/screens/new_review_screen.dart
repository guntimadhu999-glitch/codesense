import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/code_review.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/shimmer_button.dart';
import '../widgets/toast.dart';
import 'results_screen.dart';

class NewReviewScreen extends StatefulWidget {
  const NewReviewScreen({super.key, this.existing});

  final CodeReview? existing;

  @override
  State<NewReviewScreen> createState() => _NewReviewScreenState();
}

class _NewReviewScreenState extends State<NewReviewScreen> {
  static const _languages = [
    'Auto-Detect',
    'JavaScript',
    'Python',
    'Java',
    'Dart',
    'C++',
    'C#',
    'Go',
    'Rust',
    'PHP',
    'TypeScript',
    'Kotlin',
    'Swift',
  ];

  final _codeController = TextEditingController();
  final _gemini = GeminiService();
  String _language = 'Auto-Detect';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _codeController.text = widget.existing!.codeSnapshot;
      final lang = widget.existing!.language;
      if (_languages.contains(lang)) _language = lang;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        backgroundColor: AppColors.card,
        content: Text(message, style: AppTheme.ui(color: AppColors.textPrimary)),
      ));
  }

  Future<void> _analyze() async {
    final raw = _codeController.text;
    if (raw.trim().isEmpty) {
      _snack('⚠️ Please paste your code first');
      return;
    }
    if (raw.trim().length < 10) {
      _snack('⚠️ Paste at least a few lines of code');
      return;
    }
    var code = raw;
    if (code.length > 8000) {
      code = code.substring(0, 8000);
      _snack('ℹ️ Long code truncated for analysis');
    }

    setState(() => _loading = true);

    GeminiReviewResult? result;
    try {
      result = await _runWithRetry(code);
    } on GeminiNetworkException {
      if (mounted) {
        _snack('⚠️ Couldn\'t connect. Check your internet and try again.');
      }
    } on GeminiParseException {
      if (mounted) {
        _snack('⚠️ AI could not parse response. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (result == null || !mounted) return;

    final detected = result.detectedLanguage.trim();
    final storedLang = _language == 'Auto-Detect'
        ? (detected.isEmpty ? 'Unknown' : detected)
        : _language;

    final review = CodeReview(
      id: const Uuid().v4(),
      language: storedLang,
      date: DateTime.now(),
      qualityScore: result.qualityScore,
      bugs: result.bugs,
      improvements: result.improvements,
      fixedCode: result.fixedCode,
      explanation: result.explanation,
      codeSnapshot: raw,
    );
    await StorageService.instance.saveReview(review);
    if (!mounted) return;

    AppToast.show(context, '✅ Review saved!', icon: Icons.check_circle_outline);
    Navigator.of(context).pushReplacement(
      SlideRightRoute(page: ResultsScreen.fromReview(review, playSound: true)),
    );
  }

  /// Runs the review, retrying ONCE on a parse failure.
  Future<GeminiReviewResult> _runWithRetry(String code) async {
    try {
      return await _gemini.review(code: code, selectedLanguage: _language);
    } on GeminiParseException {
      return await _gemini.review(code: code, selectedLanguage: _language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Review' : 'Re-Review',
            style: AppTheme.ui(size: 20, weight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.15)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _codeController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTheme.mono(size: 13),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Paste your code here...',
                      hintStyle:
                          AppTheme.mono(size: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _language,
                    isExpanded: true,
                    dropdownColor: AppColors.card,
                    style: AppTheme.ui(size: 14),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.cyan),
                    items: [
                      for (final lang in _languages)
                        DropdownMenuItem(value: lang, child: Text(lang)),
                    ],
                    onChanged: _loading
                        ? null
                        : (v) => setState(() => _language = v ?? 'Auto-Detect'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShimmerButton(
                label: '🔍 Review with AI',
                loading: _loading,
                onPressed: _analyze,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
