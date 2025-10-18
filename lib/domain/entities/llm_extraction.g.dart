// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_extraction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LlmProviderAdapter extends TypeAdapter<LlmProvider> {
  @override
  final int typeId = 10;

  @override
  LlmProvider read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LlmProvider.claude;
      case 1:
        return LlmProvider.openai;
      case 2:
        return LlmProvider.gemini;
      default:
        return LlmProvider.claude;
    }
  }

  @override
  void write(BinaryWriter writer, LlmProvider obj) {
    switch (obj) {
      case LlmProvider.claude:
        writer.writeByte(0);
        break;
      case LlmProvider.openai:
        writer.writeByte(1);
        break;
      case LlmProvider.gemini:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
