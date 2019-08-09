package com.tencent.liteav.demo.common.utils;

/**
 * Created by hans on 2017/10/23.
 */

import android.content.Context;
import android.util.DisplayMetrics;

/**
 * ScreenUtils
 */
public class ScreenUtils {
    /**
     * 获取屏幕宽
     *
     * @return
     */
    public static int getScreenWidth(Context context) {
        if (context == null) return 0;
        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        return dm.widthPixels;
    }

    /**
     * 获取屏幕高度
     *
     * @return
     */
    public static int getScreenHeight(Context context) {
        if (context == null) return 0;
        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        return dm.heightPixels;
    }

    public static float dp2px(Context context, float dp) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return dp * scale + 0.5f;
    }

    public static float sp2px(Context context, float sp) {
        final float scale = context.getResources().getDisplayMetrics().scaledDensity;
        return sp * scale;
    }

    public static int getStatusBarHeight(Context context) {
        int statusBarHeight1 = -1;
        //获取status_bar_height资源的ID
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            //根据资源ID获取响应的尺寸值
            statusBarHeight1 = context.getResources().getDimensionPixelSize(resourceId);
        }
        return statusBarHeight1;
    }
}
