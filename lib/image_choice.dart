import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:carousel_pro/carousel_pro.dart';

import 'models/profile.dart';

class ImageChoice extends StatefulWidget {
  ImageChoice({this.mainProfile});

  final Profile mainProfile;

  @override
  _ImageChoiceState createState() {
    return _ImageChoiceState(mainProfile: mainProfile,);
  }
}

class _ImageChoiceState extends State<ImageChoice> {
  _ImageChoiceState({this.mainProfile});

  Profile mainProfile;
  int _maxImages = 5;

  Future<void> pickImages() async {
    List<Asset> result = mainProfile.getAssets();

    try {
      result = await MultiImagePicker.pickImages(
        maxImages: _maxImages,
        enableCamera: true,
        selectedAssets: mainProfile.getAssets(),
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
      result = mainProfile.getAssets();
    }

    setState(() {
      mainProfile.imagesSet = result;
    });
  }

  @override Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onLongPress: pickImages,
        child: Container(
          color: Colors.black26,
          child: Row(
            children: <Widget>[
              if(mainProfile.images.length != 0)
                Expanded(
                  child:
                    GestureDetector(
                      onLongPress: pickImages,
                      child: Carousel(
                        autoplay: false,
                        images: mainProfile.getRenderImages(),
                      ),
                    ),
                ),
              if(mainProfile.images.length == 0)
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