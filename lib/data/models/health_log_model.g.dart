// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthLogModelAdapter extends TypeAdapter<HealthLogModel> {
  @override
  final int typeId = 11;

  @override
  HealthLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthLogModel(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      vitals: (fields[2] as List).cast<VitalMeasurementModel>(),
      notes: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HealthLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.vitals)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
