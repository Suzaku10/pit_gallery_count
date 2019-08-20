import 'dart:async';

import 'package:flutter/services.dart';

class PitGalleryCount {
  static const MethodChannel _channel = const MethodChannel('pit_gallery_count');

  static Future<int> getGalleryCount() async {
    final int galleryCount = await _channel.invokeMethod("getGalleryCount");
    return galleryCount;
  }

  static Future<List<GalleryResultModel>> getImageList(
      {int countImage, SortColumn imageSortBy, SortType sortTypeBy}) async {
    String sortBy = getSortColumnString(imageSortBy);
    String sortType = getSortingType(sortTypeBy);

    var result = await _channel.invokeMethod("getImageList", {"countImage": countImage, "sortBy": sortBy, "sortType": sortType});
    List<GalleryResultModel> finalResult = [];

    for (int i = 0; i < result.length; i++) {
      finalResult.add(GalleryResultModel.fromJson(Map<String, dynamic>.from(result[i])));
    }

    return finalResult;
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

class GalleryResultModel {
  final String imageName;
  final String imagePath;
  final int imageSize;
  final int imageDateTaken;
  final int imageDateAdded;
  final int imageDateModified;
  final double imageLongitude;
  final double imageLatitude;

  GalleryResultModel(
      {this.imageName,
      this.imagePath,
      this.imageSize,
      this.imageDateTaken,
      this.imageDateAdded,
      this.imageDateModified,
      this.imageLongitude,
      this.imageLatitude});

  @override
  String toString() {
    return "{imageName : ${this.imageName}, imageLatitude: ${this.imageLatitude}, imageLongitude: ${this.imageLongitude}, imageDateTaken :${this.imageDateTaken}, imageDateModified :${this.imageDateModified}, imageDateAdded :${this.imageDateAdded}}";
  }

  factory GalleryResultModel.fromJson(Map<String, dynamic> json) {
    return GalleryResultModel(
        imageName: json["_display_name"] as String,
        imagePath: json["_data"] as String,
        imageSize: int.tryParse(json["_size"] ?? "0"),
        imageLatitude: double.tryParse(json["latitude"] ?? "0.0"),
        imageLongitude: double.tryParse(json["longitude"] ?? "0.0"),
        imageDateModified: int.tryParse(json["date_modified"] ?? "0"),
        imageDateAdded: int.tryParse(json["date_added"] ?? "0"),
        imageDateTaken: int.tryParse(json["datetaken"] ?? "0") ~/ 1000);
  }
}
