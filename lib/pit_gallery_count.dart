import 'dart:async';

import 'package:flutter/services.dart';

class PitGalleryCount {
  static const MethodChannel _channel =
      const MethodChannel('pit_gallery_count');

  static Future<int> getGalleryCount() async {
    final int galleryCount = await _channel.invokeMethod("getGalleryCount");
    return galleryCount;
  }
}
