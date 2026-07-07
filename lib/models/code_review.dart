import 'package:hive/hive.dart';

part 'code_review.g.dart';

@HiveType(typeId: 0)
class CodeReview extends HiveObject {
  CodeReview({
    required this.id,
    required this.language,
    required this.date,
    required this.qualityScore,
    required this.bugs,
    required this.improvements,
    required this.fixedCode,
    required this.explanation,
    required this.codeSnapshot,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String language;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int qualityScore;

  @HiveField(4)
  List<Map<String, String>> bugs; // each: {severity, line, description}

  @HiveField(5)
  List<String> improvements;

  @HiveField(6)
  String fixedCode;

  @HiveField(7)
  String explanation;

  @HiveField(8)
  String codeSnapshot;
}
