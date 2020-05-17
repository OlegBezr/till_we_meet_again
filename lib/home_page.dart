import 'dart:async';
import 'dart:io';
import 'dart:developer';

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
  final TextStyle mainText = TextStyle(
    fontSize: 26.0,
    color: Color(0xfff7f7f7),
  );

  DateTime _now = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  int _secondsLeft = 0;
  File _galleryFile;

  getValues() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.containsKey("dateDay"))
        _selectedDate = DateTime.parse(prefs.getString("dateDay"));
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate.add(Duration(minutes: 5)),
        firstDate: _now,
        lastDate: DateTime(_now.year + 100));

    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute),
    );

    final DateTime picked = pickedDate.add(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _secondsLeft = _selectedDate.difference(_now).inMinutes;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("dateDay", _selectedDate.toString());
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
          _secondsLeft = _selectedDate.difference(_now).inSeconds;
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
                                    "${new DateFormat.yMd().format(_selectedDate)} ${new DateFormat.Hm().format(_selectedDate)}",
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
                      "Time left: ${_secondsLeft ~/ (24 * 60 * 60)} days ${(_secondsLeft ~/ 3600) % 24}h ${(_secondsLeft ~/ 60) % 60}m",
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