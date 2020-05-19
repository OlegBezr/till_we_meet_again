import 'package:TillWeMeetAgain/models/custom_asset.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType()
class Profile extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  List<CustomAsset> images;

  Profile({this.date, this.images});

  List<AssetThumbImageProvider> getRenderImages() {
    return images.map((item) { 
      return AssetThumbImageProvider(
        Asset(item.identifier, item.name, item.originalWidth, item.originalHeight), 
        width: item.originalWidth, 
        height: item.originalHeight
      );
    }).toList();
  }

  set imagesSet (List<Asset> list) {
    this.images = list.map((item) { 
      return CustomAsset(item.identifier, item.name, item.originalWidth, item.originalHeight);
    }).toList();
  }

  List<Asset> getAssets() {
    return images.map((item) { 
      return Asset(item.identifier, item.name, item.originalWidth, item.originalHeight);
    }).toList();
  }
}