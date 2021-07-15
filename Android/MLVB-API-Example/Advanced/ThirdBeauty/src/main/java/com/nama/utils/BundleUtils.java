package com.nama.utils;

import android.content.Context;
import android.text.TextUtils;

import com.faceunity.wrapper.faceunity;

/**
 * bundle 相关操作工具类
 *
 * @author Richie on 2020.07.07
 */
public final class BundleUtils {
    private static final String TAG = "BundleUtils";

    private BundleUtils() {
    }

    /**
     * 加载 AI 模型资源，不需要 EGL Context，耗时操作，可以异步执行
     *
     * @param context
     * @param bundlePath ai_model.bundle
     * @param type       faceunity.FUAITYPE_XXX
     */
    public static boolean loadAiModel(Context context, String bundlePath, int type) {
        if (isAiModelLoaded(type)) {
            return true;
        }
        byte[] buffer = IOUtils.readFile(context, bundlePath);
        if (buffer != null) {
            int isLoaded = faceunity.fuLoadAIModelFromPackage(buffer, type);
            boolean ret = isLoaded == 1;
            LogUtils.debug(TAG, "loadAiModel. type: %d, isLoaded: %s", type, ret ? "yes" : "no");
            return ret;
        }
        return false;
    }

    /**
     * 释放 AI 模型资源，不需要 EGL Context，对应 loadAiModel 方法
     *
     * @param type
     */
    public static void releaseAiModel(int type) {
        if (isAiModelLoaded(type)) {
            int isReleased = faceunity.fuReleaseAIModel(type);
            LogUtils.debug(TAG, "releaseAiModel. type: %d, isReleased: %s", type, isReleased == 1 ? "yes" : "no");
        }
    }

    /**
     * AI 模型资源是否加载，不需要 EGL Context
     *
     * @param type
     * @return
     */
    public static boolean isAiModelLoaded(int type) {
        return faceunity.fuIsAIModelLoaded(type) == 1;
    }

    /**
     * 加载 bundle 道具，不需要 EGL Context，耗时操作，可以异步执行
     *
     * @param bundlePath bundle 文件路径
     * @return 道具句柄，大于 0 表示加载成功
     */
    public static int loadItem(Context context, String bundlePath) {
        int handle = 0;
        if (!TextUtils.isEmpty(bundlePath)) {
            byte[] buffer = IOUtils.readFile(context, bundlePath);
            if (buffer != null) {
                handle = faceunity.fuCreateItemFromPackage(buffer);
            }
        }
        LogUtils.debug(TAG, "loadItem. bundlePath: %s, itemHandle: %d", bundlePath, handle);
        return handle;
    }

}
