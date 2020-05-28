import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import 'image_choice.dart';
import 'models/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextStyle mainText = TextStyle(
    fontSize: 25.0,
    color: Color(0xfff7f7f7),
  );

  Profile mainProfile;
  DateTime _now = DateTime.now();

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
        images: new List<String>(),
      );
      profilesBox.add(mainProfile);
    }
    else {
      mainProfile = profilesBox.getAt(0);
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Color.alphaBlend(Colors.black26, Color(0xfffc69a1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: datePicker()
              ),
              Flexible(
                flex: 20,
                fit: FlexFit.tight,
                child: ImageChoice(
                  mainProfile: mainProfile,
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: timeLeft()
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xdffc69a1),
    );
  }

  Widget datePicker() {
    String _meetDate = new DateFormat.yMd().format(mainProfile.dateGet);
    String _meetTime = new DateFormat.Hm().format(mainProfile.dateGet);

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
              title: Text("Date error"),
              content: Text("You can't choose meeting time before rn"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
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

    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Row(
          children: <Widget>[
            Text(
              "Date: ",
              style: mainText,
            ),
            FlatButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              onPressed: () => _selectDate(context),
              padding: EdgeInsets.all(3.0),
              color: Color(0x7fa2a2a2),
              splashColor: Color(0x7f898989),
              child: Text(
                "$_meetDate $_meetTime",
                style: mainText,
              ),
            ),
          ],
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

    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      child: Row(
        children: <Widget>[
          Text(
            "Time left: ${_days}d ${_hours}h ${_minutes}m",
            style: mainText,
          ),
        ],
      ),
    );
  }
}