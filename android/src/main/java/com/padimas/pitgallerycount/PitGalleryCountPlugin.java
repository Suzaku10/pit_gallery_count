package com.padimas.pitgallerycount;

import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * PitGalleryCountPlugin
 */
public class PitGalleryCountPlugin implements MethodCallHandler {
    private Context context;
    private BinaryMessenger messenger;
    private ThreadPoolExecutor mDecodeThreadPool;

    public PitGalleryCountPlugin(Registrar registrar) {
        this.context = registrar.context();
        this.messenger = registrar.messenger();

        // A queue of Runnables
        BlockingQueue<Runnable> mDecodeWorkQueue = new LinkedBlockingQueue<Runnable>();
        // Sets the amount of time an idle thread waits before terminating
        int KEEP_ALIVE_TIME = 1;
        // Sets the Time Unit to seconds
        TimeUnit KEEP_ALIVE_TIME_UNIT = TimeUnit.SECONDS;

        mDecodeThreadPool = new ThreadPoolExecutor(
                1,       // Initial pool size
                1,       // Max pool size
                KEEP_ALIVE_TIME,
                KEEP_ALIVE_TIME_UNIT,
                mDecodeWorkQueue);

    }

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
                result.error("error", e.getLocalizedMessage(), e);
            }
        } else if (call.method.equals("getAlbumOriginal")) {
            final String assetId = call.argument("assetId");
            final int maxSize = call.argument("maxSize") == null ? 0 : (int)(call.argument("maxSize"));
            GetImageTask task = new GetImageTask(this.messenger, assetId, maxSize);
            task.executeOnExecutor(mDecodeThreadPool);
            result.success(true);
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

    private List<Map<String, Object>> getImageList(int size, String sortBy, String sortType) throws Exception {
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

    private class GetImageTask extends AsyncTask<String, Void, Void> {
        BinaryMessenger messenger;
        String assetId;
        int maxSize;

        GetImageTask(BinaryMessenger messenger, String assetId, int maxSize) {
            super();
            this.messenger = messenger;
            this.assetId = assetId;
            this.maxSize = maxSize;
        }

        @Override
        protected Void doInBackground(String... strings) {
            File file = new File(this.assetId);

            byte[] bytesArray = null;

            Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());

            if (maxSize != 0) {
                double initialWidth = bitmap.getWidth();
                double initialHeight = bitmap.getHeight();
                int width = initialHeight < initialWidth ? maxSize : (int) (initialWidth / initialHeight * maxSize);
                int height = initialWidth <= initialHeight ? maxSize : (int) (initialHeight / initialWidth * maxSize);
                bitmap = Bitmap.createScaledBitmap(bitmap, width,
                        height, true);
            }

            ByteArrayOutputStream bitmapStream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, bitmapStream);
            bytesArray = bitmapStream.toByteArray();
            bitmap.recycle();

            assert bytesArray != null;
            final ByteBuffer buffer = ByteBuffer.allocateDirect(bytesArray.length);
            buffer.put(bytesArray);
            this.messenger.send("pit_gallery_count/" + assetId, buffer);
            return null;
        }
    }
}
