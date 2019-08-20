import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pit_gallery_count/pit_gallery_count.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _galleryCount = 0;
  List<GalleryResultModel> res;

  @override
  void initState() {
    super.initState();
    getTotalImage();
  }

  Future<void> getTotalImage() async {
    int galleryCount;
    try {
      galleryCount = await PitGalleryCount.getGalleryCount();
      res = await PitGalleryCount.getImageList(imageSortBy: SortColumn.imageName, sortTypeBy: SortType.asc);
      print("${res.runtimeType} ${res}");
    } on PlatformException {
      galleryCount = -1;
      print("disni");
    }

    if (!mounted) return;

    setState(() {
      _galleryCount = galleryCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Text("Total Image on device :${_galleryCount}\n\n ${res}")),
    );
  }
}
