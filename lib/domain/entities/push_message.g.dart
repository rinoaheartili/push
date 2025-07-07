// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PushMessageAdapter extends TypeAdapter<PushMessage> {
  @override
  final int typeId = 0;

  @override
  PushMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PushMessage(
      messageId: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      sentDate: fields[3] as DateTime,
      data: (fields[4] as Map?)?.cast<String, dynamic>(),
      imageUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PushMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.sentDate)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
