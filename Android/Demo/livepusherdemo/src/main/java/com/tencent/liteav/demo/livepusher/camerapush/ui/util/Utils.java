package com.tencent.liteav.demo.livepusher.camerapush.ui.util;

import android.text.TextUtils;

public class Utils {

    /**
     * 判断推流地址是否合法。
     *
     * @param pushUrl 推流地址；
     * @return True，如果推流地址合法；false，如果推流地址不合法
     */
    public static boolean checkLegalForPushUrl(String pushUrl) {
        if (TextUtils.isEmpty(pushUrl)) {
            return false;
        }
        if (pushUrl.trim().toLowerCase().startsWith("rtmp://")) {
            return true;
        }
        if (pushUrl.trim().toLowerCase().startsWith("trtc://")) {
            return true;
        }
        return false;
    }

    private Utils(){}
}
