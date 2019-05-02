package com.tencent.liteav.demo.common.utils;

/**
 * 静态函数
 */
public class TCConstants {

    /**
     * UGC小视频录制信息
     */
    public static final String VIDEO_RECORD_TYPE = "type";
    public static final String VIDEO_RECORD_RESULT = "result";
    public static final String VIDEO_RECORD_DESCMSG = "descmsg";
    public static final String VIDEO_RECORD_VIDEPATH = "path";
    public static final String VIDEO_RECORD_COVERPATH = "coverpath";
    public static final String VIDEO_RECORD_DURATION = "duration";
    public static final String VIDEO_RECORD_RESOLUTION = "resolution";

    public static final String RECORD_CONFIG_MAX_DURATION = "record_config_max_duration";
    public static final String RECORD_CONFIG_MIN_DURATION = "record_config_min_duration";
    public static final String RECORD_CONFIG_ASPECT_RATIO = "record_config_aspect_ratio";
    public static final String RECORD_CONFIG_RECOMMEND_QUALITY = "record_config_recommend_quality";
    public static final String RECORD_CONFIG_HOME_ORIENTATION = "record_config_home_orientation";
    public static final String RECORD_CONFIG_RESOLUTION = "record_config_resolution";
    public static final String RECORD_CONFIG_BITE_RATE = "record_config_bite_rate";
    public static final String RECORD_CONFIG_FPS = "record_config_fps";
    public static final String RECORD_CONFIG_GOP = "record_config_gop";
    public static final String RECORD_CONFIG_NEED_EDITER = "record_config_go_editer";
    public static final String RECORD_CONFIG_TOUCH_FOCUS = "record_config_touch_focus";
    public static final String RECORD_CONFIG_1080P = "record_config_1080p";

    /**
     * UGC 编辑的的参数
     */
    public static final String VIDEO_EDITER_PATH = "key_video_editer_path"; // 路径的key
    public static final String VIDEO_EDITER_IMPORT = "key_video_editer_import";

    public static final int VIDEO_RECORD_TYPE_PUBLISH = 1;   // 推流端录制
    public static final int VIDEO_RECORD_TYPE_PLAY = 2;   // 播放端录制
    public static final int VIDEO_RECORD_TYPE_UGC_RECORD = 3;   // 短视频录制
    public static final int VIDEO_RECORD_TYPE_EDIT = 4;   // 短视频编辑

    public static final String DEFAULT_ELK_HOST = "";
    /**
     * 用户可见的错误提示语
     */
    public static final String ERROR_MSG_NET_DISCONNECTED = "网络异常，请检查网络";

    // UGCEditer
    public static final String ACTION_UGC_SINGLE_CHOOSE = "com.tencent.qcloud.xiaozhibo.single";
    public static final String ACTION_UGC_MULTI_CHOOSE = "com.tencent.qcloud.xiaozhibo.multi";

    public static final String INTENT_KEY_SINGLE_CHOOSE = "single_video";
    public static final String INTENT_KEY_MULTI_CHOOSE = "multi_video";
    public static final String INTENT_KEY_MULTI_PIC_CHOOSE = "multi_pic";
    public static final String INTENT_KEY_MULTI_PIC_LIST = "pic_list"; // 图片列表

    public static final String INTENT_KEY_TX_VIDEO_INFO = "key_tx_video_info";

    public static final String DEFAULT_MEDIA_PACK_FOLDER = "txrtmp";      // UGC编辑器输出目录

    // 上传常量
    public static final String PLAYER_DEFAULT_VIDEO = "play_default_video";
    public static final String PLAYER_VIDEO_ID = "video_id";
    public static final String PLAYER_VIDEO_NAME = "video_name";

    // 短视频licence名称
    public static final String UGC_LICENCE_NAME = "TXUgcSDK.licence";

    // 点播的信息
    public static final int VOD_APPID = 1256468886;
    public static final String VOD_APPKEY = "1973fcc2b70445af8b51053d4f9022bb";

    //
    public static final int REQUEST_CODE_PASTER = 1;
    public static final int REQUEST_CODE_WORD   = 2;

    //ELK上报事件
    public static final String ELK_ACTION_CHANGE_RESOLUTION = "change_resolution";
    public static final String ELK_ACTION_TIMESHIFT = "timeshift";
    public static final String ELK_ACTION_FLOATMOE = "floatmode";
    public static final String ELK_ACTION_LIVE_TIME = "superlive";
    public static final String ELK_ACTION_VOD_TIME = "supervod";
    public static final String ELK_ACTION_CHANGE_SPEED = "change_speed";
    public static final String ELK_ACTION_MIRROR = "mirror";
    public static final String ELK_ACTION_SOFT_DECODE = "soft_decode";
    public static final String ELK_ACTION_HW_DECODE = "hw_decode";
    public static final String ELK_ACTION_IMAGE_SPRITE = "image_sprite";
    public static final String ELK_ACTION_PLAYER_POINT = "player_point";

}
