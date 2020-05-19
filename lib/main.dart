import 'package:TillWeMeetAgain/models/custom_asset.dart';
import 'package:TillWeMeetAgain/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentsDirectory = 
    await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentsDirectory.path);
  Hive.registerAdapter(ProfileAdapter(), 0);
  Hive.registerAdapter(CustomAssetAdapter(), 1);
  runApp(MyApp());
} 

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError)
              return Text(snapshot.error.toString());
            else
              return HomePage();
          }
          // we still need to return something before the Future completes.
          else
            return Scaffold(
              backgroundColor: Colors.red,
            );
        },
      ),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}