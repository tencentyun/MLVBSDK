package com.tencent.liteav.demo.livepusher.camerapush.ui;

public class Constants {

    public static final String URL_PRODUCT_DOCUMENT = "https://cloud.tencent.com/document/product/454/7885";   // 产品介绍链接
    public static final String URL_FETCH_PUSH_URL = "https://lvb.qcloud.com/weapp/utils/get_test_pushurl";

    /**
     * QRCodeScanActivity完成扫描后，传递过来的结果的KEY
     */
    public static final String INTENT_SCAN_RESULT   = "SCAN_RESULT";

    /**
     * LivePlayerURLActivity设置页面传递给LivePlayerActivity的直播地址
     */
    public static final String INTENT_URL_PUSH      = "intent_url_push";
    public static final String INTENT_URL_PLAY_RTMP = "intent_url_play_rtmp";
    public static final String INTENT_URL_PLAY_FLV  = "intent_url_play_flv";
    public static final String INTENT_URL_PLAY_HLS  = "intent_url_play_hls";
    public static final String INTENT_URL_PLAY_ACC  = "intent_url_play_acc";

    public static final String URL_PUSH        = "url_push";       // RTMP 推流地址
    public static final String URL_PLAY_RTMP   = "url_play_rtmp";  // RTMP 播放地址
    public static final String URL_PLAY_FLV    = "url_play_flv";   // FLA  播放地址
    public static final String URL_PLAY_HLS    = "url_play_hls";   // HLS  播放地址
    public static final String URL_PLAY_ACC    = "url_play_acc";   // RTMP 加速流地址

    public static final int PLAY_STATUS_SUCCESS           = 0;
    public static final int PLAY_STATUS_INVALID_URL       = -1;
    public static final int PLAY_STATUS_INVALID_PLAY_TYPE = -3;
    public static final int PLAY_STATUS_INVALID_RTMP_URL  = -4;
    public static final int PLAY_STATUS_LICENSE_ERROR     = -5;
}
