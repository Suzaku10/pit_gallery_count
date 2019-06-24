# example/README.md
```
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

  @override
  void initState() {
    super.initState();
    getTotalImage();
  }

  Future<void> getTotalImage() async {
    int galleryCount;
    try {
      galleryCount = await PitGalleryCount.getGalleryCount();
    } on PlatformException {
      galleryCount = -1;
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
        body: Center(
          child: Text('Total Image on your device: $_galleryCount\n'),
        ),
      ),
    );
  }
}
```