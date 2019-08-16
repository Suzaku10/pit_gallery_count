# PIT Gallery Count

Use this Plugin for count a image in gallery

*Note*: This plugin is still under development, and some Components might not be available yet or still has so many bugs.

## Installation

First, add `pit_gallery_count` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```
pit_gallery_count: ^0.1.0+1
```

## Important

this plugin depends on other plugins, you must have a permission to use this plugin, you can use `pit_permission` plugin or other permission plugin.

You must add this permission in AndroidManifest.xml for Android

```
for read Storage = <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

And you must add this on info.plist for IOS

### For read storage
```
 <key>NSPhotoLibraryUsageDescription</key>
 <string>${PRODUCT_NAME} Need To Access Your Photo</string>
```

## Example for Get Gallery Count
```
     int galleryCount = await PitGalleryCount.getGalleryCount();
```

## Example for Get Image List
```
   List<ImageData> params = [ImageData.imageName, ImageData.dateTaken, ImageData.imageSize];
   List<dynamic> res = await PitGalleryCount.getImageList(imageData: params);
```