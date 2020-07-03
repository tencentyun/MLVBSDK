package com.tencent.liteav.demo.liveplayer.utils;

public class Constants {
    /**
     * 腾讯云直播拉流Demo提供的默认URL
     */
    public static final String NORMAL_PLAY_URL = "http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv";

    /**
     * 腾讯云直播拉流文档URL
     */
    public static final String LIVE_PLAYER_DOCUMENT_URL = "https://cloud.tencent.com/document/product/454/7886";

    /**
     * 腾讯云直播拉流超低时延播放文档URL
     */
    public static final String LIVE_PLAYER_REAL_TIME_PLAY_DOCUMENT_URL = "https://cloud.tencent.com/document/product/454/7886#RealTimePlay";

    /**
     * 超低时延测试RTMP URL
     */
    public static final String RTMP_ACC_TEST_URL = "https://lvb.qcloud.com/weapp/utils/get_test_rtmpaccurl";

    /**
     * MainActivity启动LivePlayerActivity时传递的Activity Type的KEY
     */
    public static final String INTENT_ACTIVITY_TYPE = "TYPE";

    /**
     * MainActivity启动LivePlayerActivity时传递过来的Activity Title的KEY
     */
    public static final String INTENT_ACTIVITY_TITLE = "TITLE";

    /**
     * QRCodeScanActivity完成扫描后，传递过来的结果的KEY
     */
    public static final String INTENT_SCAN_RESULT = "SCAN_RESULT";
}

