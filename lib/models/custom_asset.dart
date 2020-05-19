import 'package:hive/hive.dart';

part 'custom_asset.g.dart';

@HiveType()
class CustomAsset extends HiveObject {
  CustomAsset(this.identifier, this.name, this.originalWidth, this.originalHeight);

  @HiveField(0)
  String identifier;
  @HiveField(1)
  String name;
  @HiveField(2)
  int originalWidth;
  @HiveField(3)
  int originalHeight;
}