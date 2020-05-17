import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiple_image_picker/multiple_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageChoice extends StatefulWidget {
  ImageChoice({this.prefName});

  final String prefName;

  @override
  _ImageChoiceState createState() => _ImageChoiceState(prefName: prefName,);
}

class _ImageChoiceState extends State<ImageChoice> {
  _ImageChoiceState({this.prefName});

  String prefName;
  File _galleryFile;

  getValues() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.containsKey(prefName))
        _galleryFile = File(prefs.getString(prefName));
    });
  }

  @override Widget build(BuildContext context) {
    getValues();

    return Expanded(
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
                          final File file = await ImagePicker.pickImage(
                            source: ImageSource.gallery,
                          );

                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString(prefName, file.path);

                          setState(() {
                            _galleryFile = file;
                          });

                          Navigator.pop(context);
                        },
                        child: const Text('Pick From Gallery'),
                      ),
                      SimpleDialogOption(
                        onPressed: () async {
                          final File file = await ImagePicker.pickImage(
                            source: ImageSource.camera,
                          );

                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString(prefName, file.path);

                          setState(() {
                            _galleryFile = file;
                          });

                          Navigator.pop(context);
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
              if(_galleryFile != null)
                Expanded(
                  child:
                  Image.file(
                    _galleryFile,
                    fit: BoxFit.cover,
                  ),
                ),
              if(_galleryFile == null)
                Expanded(
                  child: Icon(
                    Icons.camera_alt,
                    size: 100,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}