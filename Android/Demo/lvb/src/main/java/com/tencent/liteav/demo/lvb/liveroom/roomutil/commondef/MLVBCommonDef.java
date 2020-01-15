package com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef;

public class MLVBCommonDef {
    public enum CustomFieldOp{
        SET/*设置*/, INC/*加计数*/, DEC/*减计数*/
    }

    public interface LiveRoomErrorCode {
        //推流和拉流错误码，请查看 TXLiteAVCode.h
        //IM 错误码，请查看 https://cloud.tencent.com/document/product/269/1671

        /******************************************
         *
         * LiveRoom错误码
         *
         *****************************************/
        int OK = 0;
// { 后台错误码
        /*msg处理错误*/
        int ERROR_CODE_INVALID_MSG = 200100;
        int ERROR_CODE_INVALID_JSON = 200101;
        /*参数校验错误*/
        int ERROR_CODE_INCOMPLETE_PARAM = 201000;
        int ERROR_CODE_INCOMPLETE_LOGIN_PARAM = 201001;
        int ERROR_CODE_NO_USERID = 201002;
        int ERROR_CODE_USERID_NOT_EQUAL = 201003;
        int ERROR_CODE_NO_ROOMID = 201004;
        int ERROR_CODE_NO_COUNT = 201005;
        int ERROR_CODE_NO_MERGE_STREAM_PARAM = 201006;
        int ERROR_CODE_OPERATION_EMPTY = 201007;
        int ERROR_CODE_UNSUPPORT_OPERATION = 201008;
        int ERROR_CODE_SET_FIELD_VALUE_EMPTY = 201009;
        /*鉴权错误*/
        int ERROR_CODE_VERIFY = 202000;
        int ERROR_CODE_VERIFY_FAILED = 202001;
        int ERROR_CODE_CONNECTED_TO_IM_SERVER = 202002;
        int ERROR_CODE_INVALID_RSP = 202003;
        int ERROR_CODE_LOGOUT = 202004;
        int ERROR_CODE_APPID_RELATION = 202005;
        /*房间操作错误*/
        int ERROR_CODE_ROOM_MGR = 203000;
        int ERROR_CODE_GET_ROOM_ID = 203001;
        int ERROR_CODE_CREATE_ROOM = 203002;
        int ERROR_CODE_DESTROY_ROOM = 203003;
        int ERROR_CODE_GET_ROOM_LIST = 203004;
        int ERROR_CODE_UPDATE_ROOM_MEMBER = 203005;
        int ERROR_CODE_ENTER_ROOM = 203006;
        int ERROR_CODE_ROOM_PUSHER_TOO_MUCH = 203007;
        int ERROR_CODE_INVALID_PUSH_URL = 203008;
        int ERROR_CODE_ROOM_NAME_TOO_LONG = 203009;
        int ERROR_CODE_USER_NOT_IN_ROOM = 203010;

        /*pusher操作错误*/
        int ERROR_CODE_PUSHER_MGR = 204000;
        int ERROR_CODE_GET_PUSH_URL = 204001;
        int ERROR_CODE_GET_PUSHERS = 204002;
        int ERROR_CODE_LEAVE_ROOM = 204003;
        int ERROR_CODE_GET_PUSH_AND_ACC_URL = 204004;

        /*观众操作错误*/
        int ERROR_CODE_AUDIENCE_MGR = 205000;
        int ERROR_CODE_AUDIENCE_NUM_FULL = 205001;
        int ERROR_CODE_ADD_AUDIENCE = 205002;
        int ERROR_CODE_DEL_AUDIENCE = 205003;
        int ERROR_CODE_GET_AUDIENCES = 205004;

        /*心跳处理错误*/
        int ERROR_CODE_HEARTBEAT = 206000;
        int ERROR_CODE_SET_HEARTBEAT = 206001;
        int ERROR_CODE_DEL_HEARTBEAT = 206002;
        /*其他错误*/
        int ERROR_CODE_OTHER = 207000;
        int ERROR_CODE_DB_FAILED = 207001;
        int ERROR_CODE_MIX_FAILED = 207002;
        int ERROR_CODE_SET_CUSTOM_FIELD = 207003;
        int ERROR_CODE_GET_CUSTOM_FIELD = 207004;
        int ERROR_CODE_UNSUPPORT_ACTION = 207005;
        int ERROR_CODE_UNSUPPORT_ROOM_TYPE = 207006;

// } 后台错误码

// { 客户端错误码
        int ERROR_NOT_LOGIN = -1; //未登录
        int ERROR_NOT_IN_ROOM = -2; //未进直播房间
        int ERROR_PUSH = -3; //推流错误
        int ERROR_PARAMETERS_INVALID = -4; //参数错误
        int ERROR_LICENSE_INVALID = -5; //license 校验失败
        int ERROR_PLAY = -6; //播放错误
        int ERROR_IM_FORCE_OFFLINE = -7; // IM 被强制下线（例如：多端登录）
// } 客户端错误码

        // @}
    }
}
