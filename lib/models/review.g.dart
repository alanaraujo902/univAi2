// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewAdapter extends TypeAdapter<Review> {
  @override
  final int typeId = 3;

  @override
  Review read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Review(
      id: fields[0] as String,
      summaryId: fields[1] as String,
      userId: fields[2] as String,
      reviewedAt: fields[3] as DateTime,
      quality: fields[4] as int,
      interval: fields[5] as int,
      easeFactor: fields[6] as double,
      repetition: fields[7] as int,
      nextReviewAt: fields[8] as DateTime?,
      timeSpentSeconds: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Review obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.summaryId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.reviewedAt)
      ..writeByte(4)
      ..write(obj.quality)
      ..writeByte(5)
      ..write(obj.interval)
      ..writeByte(6)
      ..write(obj.easeFactor)
      ..writeByte(7)
      ..write(obj.repetition)
      ..writeByte(8)
      ..write(obj.nextReviewAt)
      ..writeByte(9)
      ..write(obj.timeSpentSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
