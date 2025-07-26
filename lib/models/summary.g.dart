// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SummaryAdapter extends TypeAdapter<Summary> {
  @override
  final int typeId = 2;

  @override
  Summary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Summary(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      subjectId: fields[3] as String,
      userId: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      isFavorite: fields[7] as bool,
      difficultyLevel: fields[8] as int,
      tags: (fields[9] as List).cast<String>(),
      imageUrl: fields[10] as String?,
      originalQuery: fields[11] as String?,
      citations: (fields[12] as List?)?.cast<String>(),
      subject: fields[13] as Subject?,
      lastReviewedAt: fields[14] as DateTime?,
      nextReviewAt: fields[15] as DateTime?,
      reviewCount: fields[16] as int,
      easeFactor: fields[17] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Summary obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.subjectId)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.difficultyLevel)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.imageUrl)
      ..writeByte(11)
      ..write(obj.originalQuery)
      ..writeByte(12)
      ..write(obj.citations)
      ..writeByte(13)
      ..write(obj.subject)
      ..writeByte(14)
      ..write(obj.lastReviewedAt)
      ..writeByte(15)
      ..write(obj.nextReviewAt)
      ..writeByte(16)
      ..write(obj.reviewCount)
      ..writeByte(17)
      ..write(obj.easeFactor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
