// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigModelAdapter extends TypeAdapter<AppConfigModel> {
  @override
  final int typeId = 0;

  @override
  AppConfigModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfigModel(
      llmApiKey: fields[0] as String?,
      llmProvider: fields[1] as String?,
      useLlmExtraction: fields[2] as bool,
      darkModeEnabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppConfigModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.llmApiKey)
      ..writeByte(1)
      ..write(obj.llmProvider)
      ..writeByte(2)
      ..write(obj.useLlmExtraction)
      ..writeByte(3)
      ..write(obj.darkModeEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
