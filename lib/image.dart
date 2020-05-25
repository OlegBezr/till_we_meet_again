import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'models/profile.dart';

class ImageWidget extends StatefulWidget {
    ImageWidget({this.image, this.index, this.mainProfile}) {
      if (image == null) {
        mainProfile.images.removeAt(index);
        mainProfile.save();
      }
    }

    final File image;
    final int index;
    final Profile mainProfile;

    @override
    _ImageWidgetState createState() {
      return _ImageWidgetState(image: image, index: index, mainProfile: mainProfile,);
    }
  }

class _ImageWidgetState extends State<ImageWidget> {
  _ImageWidgetState({this.image, this.index, this.mainProfile});

  File image;
  final int index;
  final Profile mainProfile;

  Future<void> pickImage() async {
    void closeWindow(File file) async {
      if (file != null) {
        setState(() {
          image = file;
        });
      }

      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Modify picture"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                final File file = await ImagePicker.pickImage(
                  source: ImageSource.gallery,
                );
                closeWindow(file);
              },
              child: const Text('Choose From Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final File file = await ImagePicker.pickImage(
                  source: ImageSource.camera,
                );
                closeWindow(file);
              },
              child: const Text('Take A New Picture'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                mainProfile.images.removeAt(index);
                mainProfile.save();
              },
              child: const Text('Delete picture'),
            ),
          ]
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => pickImage(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Image.file(
          image,
          key: new UniqueKey(),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}