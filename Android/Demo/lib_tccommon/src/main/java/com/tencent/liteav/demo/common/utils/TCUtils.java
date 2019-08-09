package com.tencent.liteav.demo.common.utils;

import android.annotation.TargetApi;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class TCUtils {
    /**
     * 时间格式化
     */
    public static String formattedTime(long second) {
        String hs, ms, ss, formatTime;

        long h, m, s;
        h = second / 3600;
        m = (second % 3600) / 60;
        s = (second % 3600) % 60;
        if (h < 10) {
            hs = "0" + h;
        } else {
            hs = "" + h;
        }

        if (m < 10) {
            ms = "0" + m;
        } else {
            ms = "" + m;
        }

        if (s < 10) {
            ss = "0" + s;
        } else {
            ss = "" + s;
        }
        if (h > 0) {
            formatTime = hs + ":" + ms + ":" + ss;
        } else {
            formatTime = ms + ":" + ss;
        }
        return formatTime;
    }

    public static String duration(long durationMs) {
        long duration = durationMs / 1000;
        long h = duration / 3600;
        long m = (duration - h * 3600) / 60;
        long s = duration - (h * 3600 + m * 60);

        String durationValue;

        if (h == 0) {
            durationValue = asTwoDigit(m) + ":" + asTwoDigit(s);
        } else {
            durationValue = asTwoDigit(h) + ":" + asTwoDigit(m) + ":" + asTwoDigit(s);
        }
        return durationValue;
    }

    public static String asTwoDigit(long digit) {
        String value = "";

        if (digit < 10) {
            value = "0";
        }

        value += String.valueOf(digit);
        return value;
    }

    /**
     * Get a file path from a Uri. This will get the the path for Storage Access
     * Framework Documents, as well as the _data field for the MediaStore and
     * other file-based ContentProviders.<br>
     * <br>
     * Callers should check whether the path is local before assuming it
     * represents a local file.
     *
     * @param context The context.
     * @param uri     The Uri to query.
     */
    @TargetApi(19)
    public static String getPath(final Context context, final Uri uri) {
        final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;

        // DocumentProvider
        if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
            // ExternalStorageProvider
            if (isExternalStorageDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                }

                // TODO handle non-primary volumes
            }
            // DownloadsProvider
            else if (isDownloadsDocument(uri)) {

                final String id = DocumentsContract.getDocumentId(uri);
                final Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));

                return getDataColumn(context, contentUri, null, null);
            }
            // MediaProvider
            else if (isMediaDocument(uri)) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{
                        split[1]
                };

                if (contentUri != null)
                    return getDataColumn(context, contentUri, selection, selectionArgs);
            }
        }
        // MediaStore (and general)
        else if ("content".equalsIgnoreCase(uri.getScheme())) {

            // Return the remote address
            if (isGooglePhotosUri(uri))
                return uri.getLastPathSegment();

            return getDataColumn(context, uri, null, null);
        }
        // File
        else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }

        return null;
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    public static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is Google Photos.
     */
    public static boolean isGooglePhotosUri(Uri uri) {
        return "com.google.android.apps.photos.content".equals(uri.getAuthority());
    }

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context       The context.
     * @param uri           The Uri to query.
     * @param selection     (Optional) Filter used in the query.
     * @param selectionArgs (Optional) Selection arguments used in the query.
     * @return The value of the _data column, which is typically a file path.
     */
    public static String getDataColumn(Context context, Uri uri, String selection,
                                       String[] selectionArgs) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {
                column
        };

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                    null);
            if (cursor != null && cursor.moveToFirst()) {

                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }

//    public static String getStreamIDByStreamUrl(String strStreamUrl) {
//        if (strStreamUrl == null || strStreamUrl.length() == 0) {
//            return null;
//        }
//
//        String strStreamUrlLowerCase = strStreamUrl.toLowerCase();
//
//        //推流地址格式：rtmp://8888.livepush.myqcloud.com/live/8888_test_12345_test?txSecret=aaaa&txTime=bbbb
//        //拉流地址格式：rtmp://8888.liveplay.myqcloud.com/live/8888_test_12345_test
//        //            http://8888.liveplay.myqcloud.com/live/8888_test_12345_test.flv
//        //            http://8888.liveplay.myqcloud.com/live/8888_test_12345_test.m3u8
//
//        String strLive = "/live/";
//        int index = strStreamUrlLowerCase.indexOf(strLive);
//        if (index == -1) {
//            return null;
//        }
//
//        String strSubString = strStreamUrl.substring(index + strLive.length());
//        String [] strArrays = strSubString.split("[?.]");
//        if (strArrays.length > 0) {
//            return strArrays[0];
//        }
//
//        return null;
//    }

    public static String getStreamIDByStreamUrl(String strStreamUrl) {
        if (strStreamUrl == null || strStreamUrl.length() == 0) {
            return null;
        }

        //推流地址格式：rtmp://8888.livepush.myqcloud.com/path/8888_test_12345_test?txSecret=aaaa&txTime=bbbb
        //拉流地址格式：rtmp://8888.liveplay.myqcloud.com/path/8888_test_12345_test
        //            http://8888.liveplay.myqcloud.com/path/8888_test_12345_test.flv
        //            http://8888.liveplay.myqcloud.com/path/8888_test_12345_test.m3u8


        String subString = strStreamUrl;

        {
            //1 截取第一个 ？之前的子串
            int index = subString.indexOf("?");
            if (index != -1) {
                subString = subString.substring(0, index);
            }
            if (subString == null || subString.length() == 0) {
                return null;
            }
        }

        {
            //2 截取最后一个 / 之后的子串
            int index = subString.lastIndexOf("/");
            if (index != -1) {
                subString = subString.substring(index + 1);
            }

            if (subString == null || subString.length() == 0) {
                return null;
            }
        }

        {
            //3 截取第一个 . 之前的子串
            int index = subString.indexOf(".");
            if (index != -1) {
                subString = subString.substring(0, index);
            }
            if (subString == null || subString.length() == 0) {
                return null;
            }
        }

        return subString;
    }

    public static String getParamsFromStreamUrl(String paramName, String streamUrl) {
        if (paramName == null || paramName.length() == 0 || streamUrl == null || streamUrl.length() == 0) {
            return null;
        }
        paramName = paramName.toLowerCase();
        String[] strArrays = streamUrl.split("[?&]");
        for (String strItem : strArrays) {
            if (strItem.indexOf("=") != -1) {
                String[] array = strItem.split("[=]");
                if (array.length == 2) {
                    String name = array[0];
                    String value = array[1];
                    if (name != null) {
                        name = name.toLowerCase();
                        if (name.equalsIgnoreCase(paramName)) {
                            return value;
                        }
                    }
                }
            }
        }

        return null;
    }

    public static String getMD5Encryption(String originString)
            throws UnsupportedEncodingException {
        String result = "";
        if (originString != null) {
            try {
                // 指定加密的方式为MD5
                MessageDigest md = MessageDigest.getInstance("MD5");
                // 进行加密运算
                byte bytes[] = md.digest(originString.getBytes());
                StringBuilder sb = new StringBuilder(40);
                for (byte b : bytes) {
                    if ((b & 0xff) >> 4 == 0) {
                        sb.append("0").append(Integer.toHexString(b & 0xff));
                    } else {
                        sb.append(Integer.toHexString(b & 0xff));
                    }
                }
                result = sb.toString();
            } catch (NoSuchAlgorithmException e) {
                e.printStackTrace();
            }
        }
        return result;
    }
}
