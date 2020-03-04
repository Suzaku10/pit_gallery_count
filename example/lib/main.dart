import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pit_gallery_count/pit_gallery_count.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _galleryCount = 0;

  List<GalleryWithUint8List> imageList;
  List<File> result;

  @override
  void initState() {
    super.initState();
    getTotalImage();
  }

  Future<void> getTotalImage() async {
    int galleryCount;
    List<GalleryWithUint8List> res;
    List<File> fileList = [];

    try {
      galleryCount = await PitGalleryCount.getGalleryCount();
      res = await PitGalleryCount.getImageListWithByteData(
          countImage: 10, imageSortBy: SortColumn.dateTaken, maxSize: 200);

      for (var item in res) {
        fileList.add(await PitGalleryCount.convertByteDataToFile(item.dataByteImage));
      }
    } on PlatformException {
      galleryCount = -1;
    }

    if (!mounted) return;

    setState(() {
      _galleryCount = galleryCount;
      imageList = res;
      result = fileList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: <Widget>[
              Text("Total Image on device :${_galleryCount}\n\n"),
              FlatButton(
                  onPressed: () async {
                    await PitGalleryCount.clearTempFile();
                  },
                  child: Text("text")),
              Expanded(
                  child: result == null
                      ? Container(color: Colors.black)
                      : SingleChildScrollView(
                          child: Column(
                          children: List.generate(result.length, (index) {
                            return Image.file(result[index]);
                          }),
                        )))
            ],
          )),
    );
  }
}
