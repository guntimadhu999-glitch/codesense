// Hand-written Hive TypeAdapter for CodeReview (no build_runner used).
part of 'code_review.dart';

class CodeReviewAdapter extends TypeAdapter<CodeReview> {
  @override
  final int typeId = 0;

  @override
  CodeReview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CodeReview(
      id: fields[0] as String,
      language: fields[1] as String,
      date: fields[2] as DateTime,
      qualityScore: fields[3] as int,
      bugs: (fields[4] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      improvements: (fields[5] as List).cast<String>(),
      fixedCode: fields[6] as String,
      explanation: fields[7] as String,
      codeSnapshot: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CodeReview obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.qualityScore)
      ..writeByte(4)
      ..write(obj.bugs.map((e) => Map<String, String>.from(e)).toList())
      ..writeByte(5)
      ..write(obj.improvements)
      ..writeByte(6)
      ..write(obj.fixedCode)
      ..writeByte(7)
      ..write(obj.explanation)
      ..writeByte(8)
      ..write(obj.codeSnapshot);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
