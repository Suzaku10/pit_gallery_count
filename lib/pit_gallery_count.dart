import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PitGalleryCount {
  static const MethodChannel _channel = const MethodChannel('pit_gallery_count');

  static Future<int> getGalleryCount() async {
    final int galleryCount = await _channel.invokeMethod("getGalleryCount");
    return galleryCount;
  }

  static Future<List<GalleryWithUint8List>> getImageListWithByteData(
      {int countImage, SortColumn imageSortBy, SortType sortTypeBy, int maxSize}) async {
    String sortBy = getSortColumnString(imageSortBy);
    String sortType = getSortingType(sortTypeBy);
    Completer<List<GalleryWithUint8List>> completer = Completer();

    var result =
        await _channel.invokeMethod("getImageList", {"countImage": countImage, "sortBy": sortBy, "sortType": sortType});

    List<GalleryWithUint8List> finalResult = [];

    for (int i = 0; i < result.length; i++) {
      finalResult.add(GalleryWithUint8List.fromJson(Map<String, dynamic>.from(result[i])));
    }

    if(finalResult.isEmpty) return finalResult;

    finalResult.forEach((item) {
      getAlbumOriginal(item.imagePath, (assetId, message) {
        item.dataByteImage = message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes);

        var itemContainsNull = finalResult.firstWhere((item) => item.dataByteImage == null, orElse: ()=> null);
        if(itemContainsNull == null) completer.complete(finalResult);

      }, maxSize: maxSize);
    });

    return completer.future;
  }

  static Future<dynamic> getAlbumOriginal(String assetId, Function callback, {int maxSize}) async {
    assert(assetId != null);

    BinaryMessages.setMessageHandler('pit_gallery_count/$assetId', (ByteData message) {
      callback(assetId, message);
      BinaryMessages.setMessageHandler('pit_gallery_count/$assetId', null);
    });

    Map<String, dynamic> param = <String, dynamic>{"assetId": assetId};
    if (maxSize != 0) param.putIfAbsent("maxSize", () => maxSize);

    var thumbnails = await _channel.invokeMethod("getAlbumOriginal", param);
    return thumbnails;
  }

  static Future<File> convertByteDataToFile(Uint8List byteData, {String path = "image_count"}) async {
    final String _timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = "${extDir.path}/$path";

    bool exist = await Directory(dirPath).exists();

    if(!exist) await Directory(dirPath).create(recursive: true);

    final String filePath = '$dirPath/${_timestamp}.jpg';
    File file = await File(filePath).writeAsBytes(byteData);

    return file;
  }

  static Future<bool> clearTempFile({String path = "image_count"}) async {
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = "${extDir.path}/$path";
    final dir = Directory(dirPath);

    dir.deleteSync(recursive: true);
    bool exist = await Directory(dirPath).exists();

    return !exist;
  }
}

enum SortType { asc, desc }

enum SortColumn { dateTaken, imageName, imageSize, imageLatitude, imageLongitude, imagePath, imageDateModified }

String getSortingType(SortType sortType) {
  String getSortingTypeString = "";
  switch (sortType) {
    case SortType.asc:
      getSortingTypeString = "ASC";
      break;
    case SortType.desc:
      getSortingTypeString = "DESC";
      break;
  }
  return getSortingTypeString;
}

String getSortColumnString(SortColumn sortColumn) {
  String sortColumnString;
  switch (sortColumn) {
    case SortColumn.dateTaken:
      sortColumnString = "imageDateTaken";
      break;

    case SortColumn.imageName:
      sortColumnString = "imageName";
      break;

    case SortColumn.imageSize:
      sortColumnString = "imageSize";
      break;

    case SortColumn.imageLatitude:
      sortColumnString = "imageLatitude";
      break;

    case SortColumn.imageLongitude:
      sortColumnString = "imageLongitude";
      break;

    case SortColumn.imagePath:
      sortColumnString = "imagePath";
      break;

    case SortColumn.imageDateModified:
      sortColumnString = "imageDateModified";
      break;
  }
  return sortColumnString;
}

class GalleryWithUint8List {
  final String imageName;
  final String imagePath;
  final int imageSize;
  final int imageDateTaken;
  final int imageDateAdded;
  final int imageDateModified;
  final double imageLongitude;
  final double imageLatitude;
  Uint8List dataByteImage;

  GalleryWithUint8List(
      {this.imageName,
      this.imagePath,
      this.imageSize,
      this.imageDateTaken,
      this.imageDateAdded,
      this.imageDateModified,
      this.imageLongitude,
      this.imageLatitude,
      this.dataByteImage});

  factory GalleryWithUint8List.fromJson(Map<String, dynamic> json) {
    return GalleryWithUint8List(
        imageName: json["_display_name"] as String,
        imagePath: json["_data"] as String,
        imageSize: int.tryParse(json["_size"] ?? "0"),
        imageLatitude: double.tryParse(json["latitude"] ?? "0.0"),
        imageLongitude: double.tryParse(json["longitude"] ?? "0.0"),
        imageDateModified: int.tryParse(json["date_modified"] ?? "0"),
        imageDateAdded: int.tryParse(json["date_added"] ?? "0"),
        imageDateTaken: int.tryParse(json["datetaken"] ?? "0") ~/ 1000,
        dataByteImage: null);
  }
}

