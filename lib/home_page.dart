import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _now = DateTime.now();
  DateTime selectedDate = DateTime.now();
  int secondsLeft = 0;
  File galleryFile;

  TextStyle mainText = TextStyle(
      fontSize: 26.0,
      color: Color(0xfff7f7f7),
  );

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.add(Duration(minutes: 5)),
        firstDate: _now,
        lastDate: DateTime(_now.year + 100));
    if (picked != null && picked != selectedDate)
      setState(() async {
        selectedDate = picked;
        secondsLeft = selectedDate.difference(_now).inMinutes;

        final prefs = await SharedPreferences.getInstance();
        prefs.setString("dateDay", selectedDate.toString());
      });
  }

  // Tick the clock
  @override
  void initState() {
    getValues();

    Timer.periodic(Duration(milliseconds: 500), (v) {
      if (this.mounted) {
        setState(() {
          _now = DateTime.now();
          secondsLeft = selectedDate.difference(_now).inSeconds;
        });
      }
    });
    super.initState();
  }

  getValues() async {
    final prefs = await SharedPreferences.getInstance();
    galleryFile = File(prefs.getString("photoPath"));
    selectedDate = DateTime.parse(prefs.getString("dateDay"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black26,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 25, 0, 0),
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "Today: ${new DateFormat.yMd().format(_now)}",
                                  style: mainText,
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "Date day:",
                                  style: mainText,
                                ),
                                FlatButton(
                                  onPressed: () => _selectDate(context),
                                  padding: EdgeInsets.all(3.0),
                                  color: Color(0x7fa2a2a2),
                                  child: Text(
                                    new DateFormat.yMd().format(selectedDate),
                                    style: mainText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                              title: Text("Camera/Gallery"),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () async {
                                    log("Flag1");
                                    final File file = await ImagePicker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setString("photoPath", file.path);
                                    setState(() {
                                      log(galleryFile.path);
                                      galleryFile = file;
                                    });
                                  },
                                  child: const Text('Pick From Gallery'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () async {
                                    final File file = await ImagePicker.pickImage(
                                      source: ImageSource.camera,
                                    );
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setString("photoPath", file.path);
                                    setState(() {
                                      galleryFile = file;
                                    });
                                  },
                                  child: const Text('Take A New Picture'),
                                ),
                              ]);
                        });
                  },
                  child: Container(
                    color: Colors.black26,
                    child: Row(
                      children: <Widget>[
                        if(galleryFile != null)
                          Expanded(
                            child:
                              Image.file(
                              galleryFile,
                              fit: BoxFit.cover,
                              ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 5, 0, 50),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Time left: ${secondsLeft ~/ (24 * 60 * 60)} days ${(secondsLeft ~/ 3600) % 24}h ${(secondsLeft ~/ 60) % 60}m",
                      style: mainText,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
      backgroundColor: Color(0xfffc69a1),
    );
  }
}