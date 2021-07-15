package com.nama.utils;

import android.content.Context;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * 文件 IO 工具类
 *
 * @author Richie on 2020.07.07
 */
public final class IOUtils {
    private static
    final String TAG = "IOUtils";

    private IOUtils() {
    }

    /**
     * 从 assets 文件夹或者本地磁盘读文件，一般在 IO 线程调用
     *
     * @param context
     * @param path
     * @return
     */
    public static byte[] readFile(Context context, String path) {
        InputStream is = null;
        IOException ioe = null;
        try {
            is = context.getAssets().open(path);
        } catch (IOException e1) {
            ioe = e1;
            // open assets failed, then try sdcard
            try {
                is = new FileInputStream(path);
            } catch (IOException e2) {
                ioe = e2;
            }
        }
        if (ioe != null) {
            LogUtils.warn(TAG, ioe);
        }
        if (is != null) {
            try {
                byte[] buffer = new byte[is.available()];
                int length = is.read(buffer);
                LogUtils.verbose(TAG, "readFile. path: %s , length: %d Byte", path, length);
                is.close();
                return buffer;
            } catch (IOException e3) {
                LogUtils.warn(TAG, "readFile: e3", e3);
            }
        }
        return null;
    }

}
