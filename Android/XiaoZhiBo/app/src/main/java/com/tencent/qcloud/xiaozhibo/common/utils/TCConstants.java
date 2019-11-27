package com.tencent.qcloud.xiaozhibo.common.utils;


/**
 * Module:   TCConstants
 *
 * Function: 定义常量的类
 *
 */
public class TCConstants {
    /**
     * 常量字符串
     */
    public static final String USER_ID          = "user_id";
    public static final String USER_NICK        = "user_nick";
    public static final String USER_HEADPIC     = "user_headpic";
    public static final String USER_LOC         = "user_location";

    //主播退出广播字段
    public static final String EXIT_APP         = "EXIT_APP";

    public static final int USER_INFO_MAXLEN    = 20;
    public static final int TV_TITLE_MAX_LEN    = 30;
    public static final int NICKNAME_MAX_LEN    = 20;

    //直播类型
    public static final int RECORD_TYPE_CAMERA = 991;
    public static final int RECORD_TYPE_SCREEN = 992;

    //直播端右下角listview显示type
    public static final int TEXT_TYPE           = 0;
    public static final int MEMBER_ENTER        = 1;
    public static final int MEMBER_EXIT         = 2;
    public static final int PRAISE              = 3;

    public static final int LOCATION_PERMISSION_REQ_CODE = 1;
    public static final int WRITE_PERMISSION_REQ_CODE    = 2;
    public static final int CAMERA_PERMISSION_REQ_CODE    = 3;

    public static final String ROOM_TITLE       = "room_title";
    public static final String COVER_PIC        = "cover_pic";
    public static final String GROUP_ID         = "group_id";
    public static final String PLAY_URL         = "play_url";
    public static final String PLAY_TYPE        = "play_type";
    public static final String PUSHER_AVATAR    = "pusher_avatar";
    public static final String PUSHER_ID        = "pusher_id";
    public static final String PUSHER_NAME        = "pusher_name";
    public static final String MEMBER_COUNT     = "member_count";
    public static final String HEART_COUNT      = "heart_count";
    public static final String FILE_ID          = "file_id";
    public static final String TIMESTAMP        = "timestamp";
    public static final String ACTIVITY_RESULT  = "activity_result";



    /**
     * IM 互动消息类型
     */
    public static final int IMCMD_PAILN_TEXT    = 1;   // 文本消息
    public static final int IMCMD_ENTER_LIVE    = 2;   // 用户加入直播
    public static final int IMCMD_EXIT_LIVE     = 3;   // 用户退出直播
    public static final int IMCMD_PRAISE        = 4;   // 点赞消息
    public static final int IMCMD_DANMU         = 5;   // 弹幕消息


    public static final int MALE    = 0;
    public static final int FEMALE  = 1;


    // ELK统计上报事件
    public static final String ELK_ACTION_INSTALL = "install";
    public static final String ELK_ACTION_START_UP = "startup";
    public static final String ELK_ACTION_STAY_TIME = "stay_time";
    public static final String ELK_ACTION_REGISTER = "register";
    public static final String ELK_ACTION_LOGIN = "login";

    public static final String ELK_ACTION_VOD_PLAY = "vod_play";
    public static final String ELK_ACTION_VOD_PLAY_DURATION = "vod_play_duration";
    public static final String ELK_ACTION_LIVE_PLAY = "live_play";
    public static final String ELK_ACTION_LIVE_PLAY_DURATION = "live_play_duration";

    public static final String ELK_ACTION_CAMERA_PUSH = "camera_push";
    public static final String ELK_ACTION_CAMERA_PUSH_DURATION = "camera_push_duration";
    public static final String ELK_ACTION_SCREEN_PUSH = "screen_push";
    public static final String ELK_ACTION_SCREEN_PUSH_DURATION = "screen_push_duration";
}

