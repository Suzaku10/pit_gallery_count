package com.padimas.pitgallerycount;

import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * PitGalleryCountPlugin
 */
public class PitGalleryCountPlugin implements MethodCallHandler {
    public PitGalleryCountPlugin(Registrar registrar) {
        this.context = registrar.context();
    }

    Context context;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "pit_gallery_count");
        channel.setMethodCallHandler(new PitGalleryCountPlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getGalleryCount")) {
            int count = getGalleryCount();
            result.success(count);
        } else if (call.method.equals("getImageList")) {
            Integer size = call.argument("countImage");
            String sortBy = call.argument("sortBy");
            String sortType = call.argument("sortType");
            try {
                List<Map<String, Object>> res = getImageList(size == null ? 0 : size, sortBy, sortType);
                result.success(res);
            } catch (Exception e) {
                e.printStackTrace();
                result.error("error", e.getLocalizedMessage(), e );
            }
        } else {
            result.notImplemented();
        }
    }

    private int getGalleryCount() {
        int count = 0;
        try {
            final String[] columns = {MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID};
            final String orderBy = MediaStore.Images.Media._ID;
            Cursor cursor = context.getContentResolver().query(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
                    null, orderBy);
            if (cursor != null) {
                count = cursor.getCount();
                cursor.close();
            }
        } catch (Exception e) {
            count = -1;
        }
        return count;
    }

    private List<Map<String, Object>> getImageList(int size, String sortBy, String sortType) throws Exception{
        List<Map<String, Object>> list = new ArrayList<>();
        String[] projections = {MediaStore.Images.Media.DATA, MediaStore.Images.Media.DISPLAY_NAME, MediaStore.Images.Media.SIZE, MediaStore.Images.Media.DATE_TAKEN, MediaStore.Images.Media.LATITUDE, MediaStore.Images.Media.LONGITUDE, MediaStore.Images.Media.DATE_MODIFIED, MediaStore.Images.Media.DATE_ADDED};
            final String orderBy = sortBy == null ? null : getSortingColumnString(sortBy) + " " + (sortType == null ? "ASC" : sortType);
            Cursor cursor = context.getContentResolver().query(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, projections, null,
                    null, orderBy);

            if (size != 0) size = size > cursor.getCount() ? cursor.getCount() : size;
            if (cursor != null) {
                for (cursor.moveToFirst(); size == 0 ? !cursor.isAfterLast() : cursor.getPosition() < size; cursor.moveToNext()) {
                    Map<String, Object> result = new HashMap<>();
                    for (int i = 0; i < projections.length; i++) {
                        result.put(projections[i], cursor.getString(i));
                    }
                    list.add(result);
                }
                cursor.close();
            }
        return list;
    }

    private String getSortingColumnString(String sortBy) {
        String mediaStoreData = "";

        switch (sortBy) {
            case "imageDateTaken":
                mediaStoreData = MediaStore.Images.Media.DATE_TAKEN;
                break;

            case "imageDateAdded":
                mediaStoreData = MediaStore.Images.Media.DATE_ADDED;
                break;

            case "imageSize":
                mediaStoreData = MediaStore.Images.Media.SIZE;
                break;

            case "imagePath":
                mediaStoreData = MediaStore.Images.Media.DATA;
                break;

            case "imageLatitude":
                mediaStoreData = MediaStore.Images.Media.LATITUDE;
                break;

            case "imageLongitude":
                mediaStoreData = MediaStore.Images.Media.LONGITUDE;
                break;

            case "imageName":
                mediaStoreData = MediaStore.Images.Media.DISPLAY_NAME;
                break;

            case "imageDateModified":
                mediaStoreData = MediaStore.Images.Media.DATE_MODIFIED;
                break;
        }
        return mediaStoreData;
    }
}
