// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_asset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomAssetAdapter extends TypeAdapter<CustomAsset> {
  @override
  CustomAsset read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomAsset(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomAsset obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.originalWidth)
      ..writeByte(3)
      ..write(obj.originalHeight);
  }
}
