package com.padimas.pitgallerycount;

import android.database.Cursor;
import android.provider.MediaStore;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** PitGalleryCountPlugin */
public class PitGalleryCountPlugin implements MethodCallHandler {
  public PitGalleryCountPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  Registrar registrar;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "pit_gallery_count");
    channel.setMethodCallHandler(new PitGalleryCountPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getGalleryCount")) {
      int count = getGalleryCount();
      result.success(count);
    } else {
      result.notImplemented();
    }
  }

  public int getGalleryCount() {
    int count = 0;
    try {
      final String[] columns = { MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID };
      final String orderBy = MediaStore.Images.Media._ID;
      //Stores all the images from the gallery in Cursor
      Cursor cursor = registrar.context().getContentResolver().query(
              MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
              null, orderBy);
      //Total number of images
      if (cursor != null){
        count = cursor.getCount();
        cursor.close();
      }
    }
    catch(Exception e) {
      Log.d("Error", "getGalleryCount:" + e.getLocalizedMessage());
      count = -1;
    }
    return count;
  }
}
