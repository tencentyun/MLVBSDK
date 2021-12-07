package com.tencent.mlvb.common;

import android.net.Uri;
import android.text.TextUtils;

import com.tencent.mlvb.debug.GenerateTestUserSig;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * MLVB 移动直播地址生成
 * 详情请参考：「https://cloud.tencent.com/document/product/454/7915」
 * <p>
 * <p>
 * Generating Streaming URLs
 * See [https://cloud.tencent.com/document/product/454/7915].
 */
public class URLUtils {

    public static final String WEBRTC      = "webrtc://";
    public static final String RTMP        = "rtmp://";
    public static final String HTTP        = "http://";
    public static final String TRTC        = "trtc://";
    public static final String TRTC_DOMAIN = "cloud.tencent.com";
    public static final String APP_NAME    = "live";

    /**
     * 生成推流地址
     * Generating Publishing URLs
     *
     * @param streamId
     * @param userId
     * @param type 0:RTC  1：RTMP
     * @return
     */
    public static String generatePushUrl(String streamId, String userId, int type){
        String pushUrl = "";
        if(type == 0){
            pushUrl = TRTC + TRTC_DOMAIN + "/push/" + streamId + "?sdkappid=" + GenerateTestUserSig.SDKAPPID + "&userid=" + userId + "&usersig=" + GenerateTestUserSig.genTestUserSig(userId);
        }else if(type == 1){
            pushUrl = RTMP + GenerateTestUserSig.PUSH_DOMAIN + File.separator + APP_NAME + File.separator + streamId + GenerateTestUserSig.getSafeUrl(streamId);
        }
        return pushUrl;
    }

    /**
     * 生成拉流地址
     * Generating Playback URLs
     *
     * @param streamId
     * @param userId
     * @param type type 0:RTC  1：RTMP 2:WEBRTC
     * @return
     */
    public static String generatePlayUrl(String streamId, String userId, int type){
        String playUrl = "";
        if(type == 0){
            playUrl = TRTC + TRTC_DOMAIN + "/play/" + streamId + "?sdkappid=" + GenerateTestUserSig.SDKAPPID + "&userid=" + userId + "&usersig=" + GenerateTestUserSig.genTestUserSig(userId);
        }else if(type == 1){
            playUrl = HTTP + GenerateTestUserSig.PLAY_DOMAIN + File.separator + APP_NAME + File.separator + streamId + ".flv";
        }else if(type == 2){
            playUrl = WEBRTC + GenerateTestUserSig.PLAY_DOMAIN + File.separator + APP_NAME + File.separator + streamId;
        }
        return playUrl;
    }
}
