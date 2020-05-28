import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType()
class Profile extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  List<String> images;

  Profile({this.date, this.images});

  DateTime get dateGet {
    if (date == null)
      return DateTime.now();
    else
      return date;
  }
}