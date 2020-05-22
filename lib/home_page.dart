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

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: mainProfile.dateGet,
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
        hour: mainProfile.dateGet.hour, 
        minute: mainProfile.dateGet.minute,
      ),
    );

    final DateTime picked = pickedDate.add(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));
    if (picked.isBefore(_now)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Date error", style: mainText),
            content: Text("You can't choose meeting time before rn", style: TextStyle(color: Colors.white70),),
            actions: [
              FlatButton(
                child: Text(
                  "Ok", 
                  style: mainText,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            backgroundColor: Color(0xfffc69a1),
          );
        }
      );
    }
    else if (picked != null && picked != mainProfile.date) {
      setState(() {
        mainProfile.date = picked;
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
            datePicker(),
            ImageChoice(
              mainProfile: mainProfile,
            ),
            timeLeft(),
          ],
        ),
      ),
      backgroundColor: Color(0xfffc69a1),
    );
  }

  Widget datePicker() {
    String _today = DateFormat.yMd().format(_now);
    String _meetDate = new DateFormat.yMd().format(mainProfile.dateGet);
    String _meetTime = new DateFormat.Hm().format(mainProfile.dateGet);

    return Container(
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
                        "Today: $_today",
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
                          "$_meetDate $_meetTime",
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
    );
  }

  Widget timeLeft() {
    int _seconds = mainProfile.dateGet.difference(_now).inSeconds;

    if (mainProfile.dateGet.isBefore(_now)) {
      _seconds = 0;
    }

    int _days = _seconds ~/ (24 * 60 * 60);
    int _hours = (_seconds ~/ 3600) % 24;
    int _minutes= (_seconds ~/ 60) % 60;

    return Padding(
      padding: EdgeInsets.fromLTRB(5, 5, 0, 50),
      child: Row(
        children: <Widget>[
          Text(
            "Time left: $_days days ${_hours}h ${_minutes}m",
            style: mainText,
          ),
        ],
      ),
    );
  }
}