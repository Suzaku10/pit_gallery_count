package com.padimas.pitgallerycount;

import android.database.Cursor;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;

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
        this.registrar = registrar;
    }

    Registrar registrar;

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
            List<String> imageData = call.argument("imageData");
            Integer size = call.argument("size");
            String sortBy = call.argument("sortBy");
            List<Map<String, Object>> res = getImageList(imageData, size == null ? 0 : size, sortBy);
            result.success(res);
        } else {
            result.notImplemented();
        }
    }

    public int getGalleryCount() {
        int count = 0;
        try {
            final String[] columns = {MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID};
            final String orderBy = MediaStore.Images.Media._ID;
            Cursor cursor = registrar.context().getContentResolver().query(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
                    null, orderBy);
            if (cursor != null) {
                count = cursor.getCount();
                cursor.close();
            }
        } catch (Exception e) {
            Log.d("Error", "getGalleryCount:" + e.getLocalizedMessage());
            count = -1;
        }
        return count;
    }

    public List<Map<String, Object>> getImageList(List<String> imageDataList, int size, String sortBy) {
        List<Map<String, Object>> list = new ArrayList<>();
        String[] columns = new String[imageDataList.size()];

        for (int i = 0; i < imageDataList.size(); i++) {
            columns[i] = getImageDataString(imageDataList.get(i));
        }

        String[] defaultColumns = {MediaStore.Images.Media._ID, MediaStore.Images.Media.DATA, MediaStore.Images.Media.DISPLAY_NAME, MediaStore.Images.Media.SIZE, MediaStore.Images.Media.DATE_TAKEN, MediaStore.Images.Media.LATITUDE, MediaStore.Images.Media.LONGITUDE};
        String[] projections = columns.length != 0 ? columns : defaultColumns;

        try {
            final String orderBy = sortBy == null ? projections[0] : projections.equals(getImageDataString(sortBy)) ? getImageDataString(sortBy) : projections[0];
            Cursor cursor = registrar.context().getContentResolver().query(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, projections, null,
                    null, orderBy);
            if (cursor != null) {
                for (cursor.moveToFirst(); size == 0 ? !cursor.isAfterLast() : cursor.getPosition() < size; cursor.moveToNext()) {
                    Map<String, Object> result = new HashMap<>();
                    for (int i = 0; i < imageDataList.size(); i++) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            result.putIfAbsent(imageDataList.get(i), cursor.getString(i));
                        } else {
                            result.put(imageDataList.get(i), cursor.getString(i));
                        }
                    }
                    list.add(result);
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.d("Error", "getGalleryCount:" + e.getLocalizedMessage());
        }
        return list;
    }

    private String getImageDataString(String imageData) {
        String mediaStoreData = "";

        switch (imageData) {
            case "imageRaw":
                mediaStoreData = MediaStore.Images.Media.DATA;
                break;

            case "dateTaken":
                mediaStoreData = MediaStore.Images.Media.DATE_TAKEN;
                break;

            case "imageSize":
                mediaStoreData = MediaStore.Images.Media.SIZE;
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
            case "imageId":
                mediaStoreData = MediaStore.Images.Media._ID;
                break;

        }
        return mediaStoreData;
    }
}
