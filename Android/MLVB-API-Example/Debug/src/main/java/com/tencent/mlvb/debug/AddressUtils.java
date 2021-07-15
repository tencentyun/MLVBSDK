package com.tencent.mlvb.debug;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * MLVB 移动直播地址生成
 *
 * 详情请参考：「https://cloud.tencent.com/document/product/454/7915」
 *
 *
 * Generating Streaming URLs
 *
 * See [https://cloud.tencent.com/document/product/454/7915].
 */
public class AddressUtils {

    public static final String WEBRTC      = "webrtc://";
    public static final String RTMP        = "rtmp://";
    public static final String PUSH_DOMAIN = "PLACEHOLDER";
    public static final String PLAY_DOMAIN = "PLACEHOLDER";
    public static final String KEY         = "PLACEHOLDER";
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
            pushUrl = "trtc://cloud.tencent.com/push/" + streamId + "?sdkappid=" + GenerateTestUserSig.SDKAPPID + "&userid=" + userId + "&usersig=" + GenerateTestUserSig.genTestUserSig(userId);
        }else if(type == 1){
            pushUrl = RTMP + PUSH_DOMAIN + File.separator + APP_NAME + File.separator  + streamId + getSafeUrl(streamId);
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
            playUrl = "trtc://cloud.tencent.com/play/" + streamId + "?sdkappid=" + GenerateTestUserSig.SDKAPPID + "&userid=" + userId + "&usersig=" + GenerateTestUserSig.genTestUserSig(userId);
        }else if(type == 1){
            playUrl = RTMP + PLAY_DOMAIN + File.separator + APP_NAME + File.separator  + streamId;
        }else if(type == 2){
            playUrl = WEBRTC + PLAY_DOMAIN + File.separator + APP_NAME + File.separator  + streamId;
        }
        return playUrl;
    }

    private static final char[] DIGITS_LOWER =
            {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    public static String getSafeUrl(String streamName) {
        long txTime = System.currentTimeMillis()/1000 + 60 * 60;
        String input = new StringBuilder().
                append(KEY).
                append(streamName).
                append(Long.toHexString(txTime).toUpperCase()).toString();
        String txSecret = null;
        try {
            MessageDigest messageDigest = MessageDigest.getInstance("MD5");
            txSecret  = byteArrayToHexString(
                    messageDigest.digest(input.getBytes("UTF-8")));
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return    new StringBuilder().
                    append("?txSecret=").
                    append(txSecret).
                    append("&").
                    append("txTime=").
                    append(Long.toHexString(txTime).toUpperCase()).
                    toString();
    }

    private static String byteArrayToHexString(byte[] data) {
        char[] out = new char[data.length << 1];
        for (int i = 0, j = 0; i < data.length; i++) {
            out[j++] = DIGITS_LOWER[(0xF0 & data[i]) >>> 4];
            out[j++] = DIGITS_LOWER[0x0F & data[i]];
        }
        return new String(out);
    }
}
