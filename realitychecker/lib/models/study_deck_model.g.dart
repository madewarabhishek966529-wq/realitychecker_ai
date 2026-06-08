// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_deck_model.dart';

class StudyDeckAdapter extends TypeAdapter<StudyDeck> {
  @override
  final int typeId = 0;

  @override
  StudyDeck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyDeck(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
      flashcardJsonList: (fields[3] as List).cast<String>(),
      quizQuestionJsonList: (fields[4] as List).cast<String>(),
      reviewHistory: (fields[5] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudyDeck obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.flashcardJsonList)
      ..writeByte(4)
      ..write(obj.quizQuestionJsonList)
      ..writeByte(5)
      ..write(obj.reviewHistory);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyDeckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
