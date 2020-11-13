package com.tencent.liteav.demo.liveplayer.ui;

public class Constants {
    /**
     * 腾讯云直播拉流Demo提供的默认URL
     */
    public static final String NORMAL_PLAY_URL                          = "http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv";

    /**
     * 腾讯云直播拉流文档URL
     */
    public static final String LIVE_PLAYER_DOCUMENT_URL                 = "https://cloud.tencent.com/document/product/454/7886";

    /**
     * 腾讯云直播拉流超低时延播放文档URL
     */
    public static final String LIVE_PLAYER_REAL_TIME_PLAY_DOCUMENT_URL  = "https://cloud.tencent.com/document/product/454/7886#RealTimePlay";

    /**
     * 超低时延测试RTMP URL
     */
    public static final String RTMP_ACC_TEST_URL                        = "https://lvb.qcloud.com/weapp/utils/get_test_rtmpaccurl";

    /**
     * MainActivity启动LivePlayerActivity时传递的Activity Type的KEY
     */
    public static final String INTENT_ACTIVITY_TYPE                     = "TYPE";

    /**
     * QRCodeScanActivity完成扫描后，传递过来的结果的KEY
     */
    public static final String INTENT_SCAN_RESULT                       = "SCAN_RESULT";

    /**
     * LivePlayerURLActivity设置页面传递给LivePlayerActivity的直播地址
     */
    public static final String INTENT_URL                               = "intent_url";

    public static final String URL_PREFIX_HTTP                          = "http://";
    public static final String URL_PREFIX_HTTPS                         = "https://";
    public static final String URL_PREFIX_RTMP                          = "rtmp://";
    public static final String URL_SUFFIX_FLV                           = ".flv";
    public static final String URL_TX_SECRET                            = "txSecret";
    public static final String URL_BIZID                                = "bizid";       //是否为低延迟拉流地址


    public static final int ACTIVITY_TYPE_LIVE_PLAY     = 1;    // 标准直播播放
    public static final int ACTIVITY_TYPE_REALTIME_PLAY = 2;    // 低延时直播播放

    public static final float CACHE_TIME_FAST   = 1.0f;
    public static final float CACHE_TIME_SMOOTH = 5.0f;

    public static final int CACHE_STRATEGY_FAST     = 0;        //极速
    public static final int CACHE_STRATEGY_SMOOTH   = 1;        //流畅
    public static final int CACHE_STRATEGY_AUTO     = 2;        //自动

    public static final int PLAY_STATUS_SUCCESS                 = 0;
    public static final int PLAY_STATUS_EMPTY_URL               = -1;
    public static final int PLAY_STATUS_INVALID_URL             = -2;
    public static final int PLAY_STATUS_INVALID_PLAY_TYPE       = -3;
    public static final int PLAY_STATUS_INVALID_RTMP_URL        = -4;
    public static final int PLAY_STATUS_INVALID_SECRET_RTMP_URL = -5;
}
