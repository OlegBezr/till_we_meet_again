import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:carousel_pro/carousel_pro.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ImageChoice extends StatefulWidget {
  ImageChoice({this.photoPref});

  final String photoPref;

  @override
  _ImageChoiceState createState() => _ImageChoiceState(photoPref: photoPref,);
}

class _ImageChoiceState extends State<ImageChoice> {
  _ImageChoiceState({this.photoPref});

  String photoPref;
  List<Asset> images = List<Asset>();
  int _maxImages = 5;

  getValues() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      for (int i = 0; i < _maxImages; i++) {
        if (prefs.containsKey(photoPref + "Name" + i.toString())) {
          String id = prefs.getString(photoPref + "Id" + i.toString());
          String name = prefs.getString(photoPref + "Name" + i.toString());
          int width = prefs.getInt(photoPref + "Width" + i.toString());
          int height = prefs.getInt(photoPref + "Height" + i.toString());

          images.add(
            Asset(id, name, width, height)
          );
        }
      }
    });
  }

  saveValues() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      for (int i = 0; i < images.length; i++) {
        prefs.setString(photoPref + "Id" + i.toString(), images[i].identifier);
        prefs.setString(photoPref + "Name" + i.toString(), images[i].name);
        prefs.setInt(photoPref + "Width" + i.toString(), images[i].originalWidth);
        prefs.setInt(photoPref + "Height" + i.toString(), images[i].originalHeight);
      }

      for (int i = images.length; i < _maxImages; i++) {
        prefs.remove(photoPref + "Id" + i.toString());
        prefs.remove(photoPref + "Name" + i.toString());
        prefs.remove(photoPref + "Width" + i.toString());
        prefs.remove(photoPref + "Height" + i.toString());
      }
    });
  }

  Future<void> pickImages() async {
    List<Asset> result = images;

    try {
      result = await MultiImagePicker.pickImages(
        maxImages: _maxImages,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat"
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Choose photos",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    }
    catch (error) {
      result = images;
    }

    saveValues();

    setState(() {
      images = result;
    });
  }

  @override
  void initState() {
    getValues();
    super.initState();
  }

  @override Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onLongPress: pickImages,
        child: Container(
          color: Colors.black26,
          child: Row(
            children: <Widget>[
              if(images.length != 0)
                Expanded(
                  child:
                    GestureDetector(
                      onLongPress: pickImages,
                      child: Carousel(
                        autoplay: false,
                        images: images.map((item) => AssetThumbImageProvider(item, width: item.originalWidth, height: item.originalHeight)).toList(),
                      ),
                    ),
                ),
              if(images.length == 0)
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