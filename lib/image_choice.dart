import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'models/profile.dart';
import 'image.dart';

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

  final int _maxImages = 5;

  final TextStyle mainText = TextStyle(
    fontSize: 26.0,
    color: Color(0xfff7f7f7),
  );

  @override
  void initState() {
    super.initState();
  }

  @override Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: PageScrollPhysics(),
        children: <Widget>[] + 
          imageWidgets() +
          <Widget>[
            addImageWidget(),
          ],
      ),
    );
  }

  List<Widget> imageWidgets() {
    List<Widget> renderedImages = List<Widget>();

    for (int i = 0; i < mainProfile.images.length; i++) {
      print("Render $i");

      renderedImages.add(
        ImageWidget(
          image: File(mainProfile.images[i]),
          index: i,
          mainProfile: mainProfile,
        )
      );
    }

    return renderedImages;
  }

  Widget addImageWidget() {
    Future<void> addImage() async {
      void closeWindow(File file) async {
        if (file != null) {
          setState(() {
            mainProfile.images.add(file.path);
            mainProfile.save();
          });
        }
      }
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Add Image"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () async {
                  final File file = await ImagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  closeWindow(file);
                  Navigator.pop(context);
                },
                child: const Text('Choose From Gallery'),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  final File file = await ImagePicker.pickImage(
                    source: ImageSource.camera,
                  );
                  closeWindow(file);
                  Navigator.pop(context);
                },
                child: const Text('Take A New Picture'),
              ),
            ]
          );
        }
      );
    }

    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      color: Colors.black26,
      child: GestureDetector(
        onLongPress: () => addImage(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (mainProfile.images.length < _maxImages)
              Icon(
                Icons.add_a_photo,
                size: 100,
                color: Color(0xfff7f7f7),
              ),
            if (mainProfile.images.length < _maxImages)
              Text(
                "Hold to add\nan image", 
                textAlign: TextAlign.center,
                style: mainText,
              ),
            if (mainProfile.images.length >= _maxImages)
              Icon(
                Icons.block,
                size: 100,
                color: Color(0xfff7f7f7),
              ),
            if (mainProfile.images.length >= _maxImages)
              Text(
                "Images limit reached", 
                style: mainText,
              ),
          ]
        ),
      ),
    );
  }
}