import 'dart:async';

import 'package:flutter/services.dart';

class PitGalleryCount {
  static const MethodChannel _channel = const MethodChannel('pit_gallery_count');

  static Future<int> getGalleryCount() async {
    final int galleryCount = await _channel.invokeMethod("getGalleryCount");
    return galleryCount;
  }

  static Future<List<dynamic>> getImageList({List<ImageData> imageData, int size, ImageData imageSortBy}) async {
    List<String> params = [];
    for (int i = 0; i < imageData.length; i++) {
      params.add(getImageDataString(imageData[i]));
    }

    String sortBy = getImageDataString(imageSortBy);
    var result = await _channel
        .invokeMethod("getImageList", {"imageData": params, "size": size, "sortBy": sortBy});

    return result;
  }
}

enum ImageData { dateTaken, imageName, imageSize, imageLatitude, imageLongitude, imageRaw, imageId }

String getImageDataString(ImageData imageData) {
  String imageDataString;
  switch (imageData) {
    case ImageData.dateTaken:
      imageDataString = "dateTaken";
      break;

    case ImageData.imageName:
      imageDataString = "imageName";
      break;

    case ImageData.imageSize:
      imageDataString = "imageSize";
      break;

    case ImageData.imageLatitude:
      imageDataString = "imageLatitude";
      break;

    case ImageData.imageLongitude:
      imageDataString = "imageLongitude";
      break;

    case ImageData.imageRaw:
      imageDataString = "imageRaw";
      break;

    case ImageData.imageId:
      imageDataString = "imageId";
      break;
  }
  return imageDataString;
}
