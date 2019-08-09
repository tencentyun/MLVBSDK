package com.tencent.liteav.demo.ugccommon;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.MediaStore;


import java.io.File;
import java.util.ArrayList;

public class TCVideoEditerMgr {

    private static final String TAG = "TCVideoEditerMgr";

    public static ArrayList<TCVideoFileInfo> getAllVideo(Context context) {
        ArrayList<TCVideoFileInfo> videos = new ArrayList<TCVideoFileInfo>();
        String[] mediaColumns = new String[]{
                MediaStore.Video.VideoColumns._ID,
                MediaStore.Video.VideoColumns.DATA,
                MediaStore.Video.VideoColumns.DISPLAY_NAME,
                MediaStore.Video.VideoColumns.DURATION
        };
        ContentResolver contentResolver = context.getApplicationContext().getContentResolver();
        Cursor cursor = contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                mediaColumns, null, null, null);

        if (cursor == null) return videos;

        if (cursor.moveToFirst()) {
            do {
                String path = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA));
                File file = new File(path);
                boolean canRead = file.canRead();
                long length = file.length();
                if (!canRead || length == 0) {
                    continue;
                }
                String name = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME));

                long duration = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION));
                if (duration < 0) {
                    duration = 0;
                }

                TCVideoFileInfo fileItem = new TCVideoFileInfo();
                fileItem.setFilePath(path);
                fileItem.setFileName(name);
                fileItem.setDuration(duration);
                fileItem.setFileType(TCVideoFileInfo.FILE_TYPE_VIDEO);

                if (fileItem.getFileName() != null && fileItem.getFileName().endsWith(".mp4")) {
                    videos.add(fileItem);
                }
            }
            while (cursor.moveToNext());
        }
        cursor.close();
        return videos;
    }

    public static ArrayList<TCVideoFileInfo> getAllPictrue(Context context) {
        ArrayList<TCVideoFileInfo> pictureList = new ArrayList<TCVideoFileInfo>();
        String[] mediaColumns = new String[]{
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.DATA,
                MediaStore.Images.Media.DESCRIPTION
        };
        ContentResolver contentResolver = context.getApplicationContext().getContentResolver();

        Cursor cursor = contentResolver.query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, mediaColumns, null, null, null);
        while (cursor.moveToNext()){
            String path = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA));
            File file = new File(path);
            boolean canRead = file.canRead();
            long length = file.length();
            if (!canRead || length == 0) {
                continue;
            }
            TCVideoFileInfo fileItem = new TCVideoFileInfo();
            fileItem.setFilePath(path);
            fileItem.setFileName(cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)));
            fileItem.setFileType(TCVideoFileInfo.FILE_TYPE_PICTURE);
            pictureList.add(fileItem);
        }
        if (cursor != null) {
            cursor.close();
        }
        return pictureList;
    }
}