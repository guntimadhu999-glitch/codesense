import 'package:hive_flutter/hive_flutter.dart';

import '../models/code_review.dart';

/// Thin wrapper over Hive for reviews + app settings.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String reviewsBoxName = 'reviews';
  static const String settingsBoxName = 'settings';

  late Box<CodeReview> _reviews;
  late Box _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CodeReviewAdapter());
    }
    _reviews = await Hive.openBox<CodeReview>(reviewsBoxName);
    _settings = await Hive.openBox(settingsBoxName);
  }

  // ---- Reviews ----

  List<CodeReview> allReviews() {
    final list = _reviews.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return list;
  }

  Future<void> saveReview(CodeReview review) async {
    await _reviews.put(review.id, review);
  }

  Future<void> deleteReview(String id) async {
    await _reviews.delete(id);
  }

  Future<void> clearAll() async {
    await _reviews.clear();
  }

  int get totalReviews => _reviews.length;

  double get averageScore {
    if (_reviews.isEmpty) return 0;
    final sum =
        _reviews.values.fold<int>(0, (acc, r) => acc + r.qualityScore);
    return sum / _reviews.length;
  }

  String get mostReviewedLanguage {
    if (_reviews.isEmpty) return '—';
    final counts = <String, int>{};
    for (final r in _reviews.values) {
      final lang = r.language.isEmpty ? 'Unknown' : r.language;
      counts[lang] = (counts[lang] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  // ---- Settings ----

  bool get seenOnboarding =>
      _settings.get('seenOnboarding', defaultValue: false) as bool;
  Future<void> setSeenOnboarding(bool value) =>
      _settings.put('seenOnboarding', value);

  bool get darkMode => _settings.get('darkMode', defaultValue: true) as bool;
  Future<void> setDarkMode(bool value) => _settings.put('darkMode', value);

  bool get soundEnabled =>
      _settings.get('soundEnabled', defaultValue: true) as bool;
  Future<void> setSoundEnabled(bool value) =>
      _settings.put('soundEnabled', value);
}
