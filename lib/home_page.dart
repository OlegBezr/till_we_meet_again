import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import 'image_choice.dart';
import 'models/custom_asset.dart';
import 'models/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextStyle mainText = TextStyle(
    fontSize: 26.0,
    color: Color(0xfff7f7f7),
  );

  Profile mainProfile;
  DateTime _now = DateTime.now();
  int _secondsLeft = 0;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: mainProfile.date,
      firstDate: _now.subtract(
        Duration(
          hours: 23, 
          minutes: 59,
        )
      ),
      lastDate: DateTime(_now.year + 100),
    );

    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: mainProfile.date.hour, 
        minute: mainProfile.date.minute,
      ),
    );

    final DateTime picked = pickedDate.add(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));
    if (picked != null && picked != mainProfile.date) {
      setState(() {
        mainProfile.date = picked;
        _secondsLeft = mainProfile.date.difference(_now).inMinutes;
      });

      mainProfile.save();
    }
  }

  // Tick the clock
  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 500), (v) {
      if (this.mounted) {
        setState(() {
          _now = DateTime.now();
          _secondsLeft = mainProfile.date.difference(_now).inSeconds;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profilesBox = Hive.box('profiles');

    if (profilesBox.length == 0) {
      mainProfile = new Profile(
        date: DateTime.now(),
        images: new List<CustomAsset>(),
      );
      profilesBox.add(mainProfile);
    }
    else {
      mainProfile = profilesBox.getAt(0);
    }

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
                                    "${new DateFormat.yMd().format(mainProfile.date)} ${new DateFormat.Hm().format(mainProfile.date)}",
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
                mainProfile: mainProfile,
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