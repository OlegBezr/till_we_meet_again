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
    return Stack(
      children: <Widget>[
        Container(
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: PageScrollPhysics(),
            children: <Widget>[] + 
              imageWidgets() +
              <Widget>[
                addImageWidget(),
              ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(height: 50, width: 50, color: Colors.green,),
        )
      ],
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
          key: Key(mainProfile.images[i]),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
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

  Widget _inactivePhoto() {
    return new Container(
      child: new Padding(
        padding: const EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 8.0,
          width: 8.0,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(4.0)
          ),
        ),
      )
    );
  }

  Widget _activePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0.0,
                blurRadius: 2.0
              )
            ]
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDots(int index) {
    List<Widget> dots = [];

    for(int i = 0; i< mainProfile.images.length + 1; ++i) {
      dots.add(
        i == index ? _activePhoto(): _inactivePhoto()
      );
    }

    return dots;
  }
}