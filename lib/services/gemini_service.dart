import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when the network request itself fails (no connectivity, timeout,
/// non-200 status, etc.).
class GeminiNetworkException implements Exception {
  GeminiNetworkException(this.message);
  final String message;
  @override
  String toString() => 'GeminiNetworkException: $message';
}

/// Thrown when the model responds but its text could not be parsed into the
/// expected JSON shape.
class GeminiParseException implements Exception {
  GeminiParseException(this.message);
  final String message;
  @override
  String toString() => 'GeminiParseException: $message';
}

/// Structured result of a code review.
class GeminiReviewResult {
  GeminiReviewResult({
    required this.qualityScore,
    required this.detectedLanguage,
    required this.bugs,
    required this.improvements,
    required this.fixedCode,
    required this.explanation,
  });

  final int qualityScore;
  final String detectedLanguage;
  final List<Map<String, String>> bugs;
  final List<String> improvements;
  final String fixedCode;
  final String explanation;
}

class GeminiService {
  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _model = 'gemini-1.5-flash';

  Uri get _endpoint => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
      );

  String _buildPrompt(String selectedLanguage, String code) {
    return '''
Review this code and respond ONLY with valid JSON, no extra text, no markdown:
{
  "quality_score": <number 0-100>,
  "detected_language": "<language name>",
  "bugs": [
    {"severity": "critical|warning|minor", "line": "<line number or area>", "description": "<bug description>"}
  ],
  "improvements": ["suggestion 1", "suggestion 2"],
  "fixed_code": "<complete corrected code as a string>",
  "explanation": "<summary of what was wrong and why the fix works>"
}

Language hint: $selectedLanguage

Code:
$code''';
  }

  /// Performs the review. Throws [GeminiNetworkException] on connectivity/HTTP
  /// errors and [GeminiParseException] when the JSON cannot be parsed.
  Future<GeminiReviewResult> review({
    required String code,
    required String selectedLanguage,
  }) async {
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _buildPrompt(selectedLanguage, code)}
          ]
        }
      ]
    });

    http.Response response;
    try {
      response = await _client
          .post(
            _endpoint,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw GeminiNetworkException(e.toString());
    }

    if (response.statusCode != 200) {
      throw GeminiNetworkException('HTTP ${response.statusCode}');
    }

    String rawText;
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>;
      final content = candidates.first['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      rawText = parts.first['text'] as String;
    } catch (e) {
      throw GeminiParseException('Malformed API envelope: $e');
    }

    return _parseModelText(rawText);
  }

  GeminiReviewResult _parseModelText(String text) {
    var cleaned = text.trim();
    // Strip markdown code fences if present.
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '');
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
    }
    // Fallback: extract the first {...} block.
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw GeminiParseException('Could not decode JSON: $e');
    }

    try {
      final score = (json['quality_score'] as num?)?.round() ?? 0;
      final detected = (json['detected_language'] as String?)?.trim() ?? '';

      final bugs = <Map<String, String>>[];
      for (final b in (json['bugs'] as List<dynamic>? ?? const [])) {
        final m = b as Map<String, dynamic>;
        bugs.add({
          'severity': (m['severity'] ?? 'minor').toString(),
          'line': (m['line'] ?? '').toString(),
          'description': (m['description'] ?? '').toString(),
        });
      }

      final improvements = <String>[
        for (final i in (json['improvements'] as List<dynamic>? ?? const []))
          i.toString(),
      ];

      return GeminiReviewResult(
        qualityScore: score.clamp(0, 100),
        detectedLanguage: detected,
        bugs: bugs,
        improvements: improvements,
        fixedCode: (json['fixed_code'] ?? '').toString(),
        explanation: (json['explanation'] ?? '').toString(),
      );
    } catch (e) {
      throw GeminiParseException('Unexpected JSON structure: $e');
    }
  }
}
