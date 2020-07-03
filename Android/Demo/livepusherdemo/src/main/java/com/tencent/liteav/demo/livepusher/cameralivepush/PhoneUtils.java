package com.tencent.liteav.demo.livepusher.cameralivepush;

import android.content.Context;
import android.provider.Settings;

public class PhoneUtils {

    /**
     * 判断系统 "自动旋转" 设置功能是否打开
     *
     * @return false---Activity可根据重力感应自动旋转
     */
    public static boolean isActivityCanRotation(Context context) {
        int flag = Settings.System.getInt(context.getContentResolver(), Settings.System.ACCELEROMETER_ROTATION, 0);
        return flag != 0;
    }
}
