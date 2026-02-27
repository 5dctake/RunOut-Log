// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PracticeRecordAdapter extends TypeAdapter<PracticeRecord> {
  @override
  final int typeId = 0;

  @override
  PracticeRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PracticeRecord(
      date: fields[0] as DateTime,
      ballCount: fields[1] as int,
      results: (fields[2] as List).cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, PracticeRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.ballCount)
      ..writeByte(2)
      ..write(obj.results);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
