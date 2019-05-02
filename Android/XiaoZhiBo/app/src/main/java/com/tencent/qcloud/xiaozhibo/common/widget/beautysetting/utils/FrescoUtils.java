/**
 * Created by apc on 15/10/30.
 */
package com.tencent.qcloud.xiaozhibo.common.widget.beautysetting.utils;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;

public class FrescoUtils {
    private static final String TAG = FrescoUtils.class.getSimpleName();

    public static final String FRESCO_SCHEME_ASSETS = "asset:///"; /** Be careful, it's different */
    private static final String FRESCO_SCHEME_STORAGE = "file://";
    private static final String FRESCO_SCHEME_CONTENT = "content://";
    private static final String FRESCO_SCHEME_RES = "res://";

    /**
     * Fresco URL 转换方法，把图片地址转换成 Fresco 支持的格式
     * @param url
     * @return
     */
    public static Uri getUri(String url, Context context) {
        if (TextUtils.isEmpty(url)) {
            return null;
        }
        if (url.startsWith(VideoUtil1.RES_PREFIX_ASSETS)) {
            url = FRESCO_SCHEME_ASSETS + VideoFileUtil1.checkAssetsPhoto(context, url.substring(VideoUtil1.RES_PREFIX_ASSETS.length()));
        } else if (url.startsWith(VideoUtil1.RES_PREFIX_STORAGE)) {
            url = FRESCO_SCHEME_STORAGE + VideoFileUtil1.checkPhoto(url);
        } else if (url.startsWith(VideoUtil1.RES_PREFIX_HTTP) || url.startsWith(VideoUtil1.RES_PREFIX_HTTPS)) {

        }
        return Uri.parse(url);
    }

    public static Uri getUriByRes(int resId) {
        Uri uri = Uri.parse(FRESCO_SCHEME_RES + "drawable/" + resId);
        return uri;
    }
}
