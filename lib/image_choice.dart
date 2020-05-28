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
  int _activeImageIndex = 0;

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
          child: PageView.builder(
            onPageChanged: _setActiveImage,
            itemCount: mainProfile.images.length + 1,
            itemBuilder: _getImageWidget,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildDots(_activeImageIndex)
            ),
          ),
        )
      ],
    );
  }

  void _setActiveImage(int index) {
    setState(() {
      _activeImageIndex = index;
    });
  }

  Widget _getImageWidget(BuildContext context, int index) {
    if (index < mainProfile.images.length)
      return ImageWidget(
        image: File(mainProfile.images[index]),
        index: index,
        mainProfile: mainProfile,
        key: Key(mainProfile.images[index]),
      );
    else
      return _addImageWidget();
  }

  Widget _addImageWidget() {
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
          height: 12.0,
          width: 12.0,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xcf080808), width: 1),
            borderRadius: BorderRadius.circular(8.0)
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
          height: 14.0,
          width: 14.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
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

    for(int i = 0; i < mainProfile.images.length + 1; ++i) {
      dots.add(
        i == index ? _activePhoto(): _inactivePhoto()
      );
    }

    if (mainProfile.images.length > 0)
      return dots;
    else
      return List<Widget>();
  }
}