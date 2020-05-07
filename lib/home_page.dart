import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_choice.dart';

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

  getValues() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.containsKey("dateDay"))
        selectedDate = DateTime.parse(prefs.getString("dateDay"));
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked_date = await showDatePicker(
        context: context,
        initialDate: selectedDate.add(Duration(minutes: 5)),
        firstDate: _now,
        lastDate: DateTime(_now.year + 100));

    final TimeOfDay picked_time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
    );

    final DateTime picked = picked_date.add(Duration(hours: picked_time.hour, minutes: picked_time.minute));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        secondsLeft = selectedDate.difference(_now).inMinutes;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("dateDay", selectedDate.toString());
    }
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

  @override
  Widget build(BuildContext context) {
    getValues();

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
                                  "Date: ",
                                  style: mainText,
                                ),
                                FlatButton(
                                  onPressed: () => _selectDate(context),
                                  padding: EdgeInsets.all(3.0),
                                  color: Color(0x7fa2a2a2),
                                  child: Text(
                                    "${new DateFormat.yMd().format(selectedDate)} ${new DateFormat.Hm().format(selectedDate)}",
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
              ImageChoice(
                prefName: "photoPath",
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