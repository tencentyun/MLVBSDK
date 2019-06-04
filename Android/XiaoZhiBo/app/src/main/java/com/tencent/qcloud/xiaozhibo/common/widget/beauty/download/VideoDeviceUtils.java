package com.tencent.qcloud.xiaozhibo.common.widget.beauty.download;

import android.annotation.TargetApi;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.opengl.GLES20;
import android.os.Environment;
import android.os.StatFs;

import java.io.File;
/**
 * Module:   VideoDeviceUtils
 *
 * Function: 设备属性的检测工具类
 *
 */
public class VideoDeviceUtils {
    private static final String TAG = VideoDeviceUtils.class.getSimpleName();
    public static final int MIN_STORAGE_SIZE = 52428800;

    public VideoDeviceUtils() {
    }

    public static String getGPUInfo() {
        String renderer = GLES20.glGetString(7937);
        String vendor = GLES20.glGetString(7936);
        String version = GLES20.glGetString(7938);
        return renderer + "; " + vendor + "; " + version;
    }

    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivity = (ConnectivityManager)context.getSystemService("connectivity");
        if(connectivity == null) {
            return false;
        } else {
            NetworkInfo networkInfo = connectivity.getActiveNetworkInfo();
            return networkInfo != null && networkInfo.isConnectedOrConnecting();
        }
    }

    public static boolean isExternalStorageAvailable() {
        if(!"mounted".equals(Environment.getExternalStorageState()) && Environment.isExternalStorageRemovable()) {
            return false;
        } else {
            try {
                new StatFs(Environment.getExternalStorageDirectory().getAbsolutePath());
                return true;
            } catch (Exception var1) {
                return false;
            }
        }
    }

    @TargetApi(18)
    public static long getAvailableSize(StatFs statFs) {
        long availableBytes;
        if(VideoFileUtils.hasJellyBeanMR2()) {
            availableBytes = statFs.getAvailableBytes();
        } else {
            availableBytes = (long)statFs.getAvailableBlocks() * (long)statFs.getBlockSize();
        }

        return availableBytes;
    }

    public static boolean isExternalStorageSpaceEnough(long fileSize) {
        File sdcard = Environment.getExternalStorageDirectory();
        StatFs statFs = new StatFs(sdcard.getAbsolutePath());
        return getAvailableSize(statFs) > fileSize;
    }

    private static File getExternalFilesDir(Context context) {
        File file = null;
        file = context.getExternalFilesDir((String)null);
        if(file == null) {
            String filesDir = "/Android/data/" + context.getPackageName() + "/files/";
            file = new File(Environment.getExternalStorageDirectory().getPath() + filesDir);
        }

        return file;
    }

    public static File getExternalFilesDir(Context context, String folder) {
        String path = null;
        if(isExternalStorageAvailable() && isExternalStorageSpaceEnough(52428800L)) {
            path = getExternalFilesDir(context).getPath();
        }

        File file = new File(path + File.separator + folder);

        try {
            if(file.exists() && file.isFile()) {
                file.delete();
            }

            if(!file.exists()) {
                file.mkdirs();
            }
        } catch (Exception var5) {
            ;
        }

        return file;
    }

    public static long getRuntimeRemainSize(int memoryClass) {
        long remainMemory = Runtime.getRuntime().maxMemory() - getHeapAllocatedSizeInKb() * 1024L;
        switch(memoryClass) {
            case 0:
            default:
                break;
            case 1:
                remainMemory /= 1024L;
                break;
            case 2:
                remainMemory /= 1048576L;
        }

        return remainMemory;
    }

    public static long getHeapAllocatedSizeInKb() {
        long heapAllocated = getRuntimeTotalMemory(1) - getRuntimeFreeMemory(1);
        return heapAllocated;
    }

    private static long getRuntimeTotalMemory(int memoryClass) {
        long totalMemory = 0L;
        switch(memoryClass) {
            case 0:
                totalMemory = Runtime.getRuntime().totalMemory();
                break;
            case 1:
                totalMemory = Runtime.getRuntime().totalMemory() / 1024L;
                break;
            case 2:
                totalMemory = Runtime.getRuntime().totalMemory() / 1024L / 1024L;
                break;
            default:
                totalMemory = Runtime.getRuntime().totalMemory();
        }

        return totalMemory;
    }

    private static long getRuntimeFreeMemory(int memoryClass) {
        long freeMemory = 0L;
        switch(memoryClass) {
            case 0:
                freeMemory = Runtime.getRuntime().freeMemory();
                break;
            case 1:
                freeMemory = Runtime.getRuntime().freeMemory() / 1024L;
                break;
            case 2:
                freeMemory = Runtime.getRuntime().freeMemory() / 1024L / 1024L;
                break;
            default:
                freeMemory = Runtime.getRuntime().freeMemory();
        }

        return freeMemory;
    }

    public static class MEMORY_CLASS {
        public static final int IN_B = 0;
        public static final int IN_KB = 1;
        public static final int IN_MB = 2;

        public MEMORY_CLASS() {
        }
    }
}
