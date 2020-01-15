package com.tencent.liteav.demo.lvb.common.utils;

import android.annotation.TargetApi;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.opengl.GLES20;
import android.os.StatFs;

import java.io.File;

public class VideoDeviceUtil {
    private static final String TAG = VideoDeviceUtil.class.getSimpleName();
    public static final int MIN_STORAGE_SIZE = 52428800;

    public VideoDeviceUtil() {
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

    @TargetApi(18)
    public static long getAvailableSize(StatFs statFs) {
        long availableBytes;
        if(VideoUtil.hasJellyBeanMR2()) {
            availableBytes = statFs.getAvailableBytes();
        } else {
            availableBytes = (long)statFs.getAvailableBlocks() * (long)statFs.getBlockSize();
        }

        return availableBytes;
    }

    public static boolean isExternalStorageSpaceEnough(long fileSize) {
        return true;
    }

    public static File getExternalFilesDir(Context context, String folder) {
        if (context == null)
            return null;

        File dir = context.getExternalFilesDir("");

        if (dir == null) {
            return null;
        }
        String path = dir.getAbsolutePath();

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
