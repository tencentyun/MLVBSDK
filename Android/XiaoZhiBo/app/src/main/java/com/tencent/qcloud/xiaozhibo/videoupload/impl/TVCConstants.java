package com.tencent.qcloud.xiaozhibo.videoupload.impl;

/**
 * 视频上传常量定义
 */
public class TVCConstants {
    public static final String TVCVERSION = "1.0.7.1";

    //网络类型
    public static final int NETTYPE_NONE = 0;
    public static final int NETTYPE_WIFI = 1;
    public static final int NETTYPE_4G   = 2;
    public static final int NETTYPE_3G   = 3;
    public static final int NETTYPE_2G   = 4;

    
    /************************************************ 客户端错误码 **********************************/
    /**
     * 成功
     */
    public static final int NO_ERROR = 0;

    /**
     * UGC请求上传失败
     */
    public static final int ERR_UGC_REQUEST_FAILED = 1001;

    /**
     * UGC请求信息解析失败
     */
    public static final int ERR_UGC_PARSE_FAILED = 1002;

    /**
     * COS上传视频失败
     */
    public static final int ERR_UPLOAD_VIDEO_FAILED = 1003;

    /**
     * COS上传封面失败
     */
    public static final int ERR_UPLOAD_COVER_FAILED = 1004;

    /**
     * UGC结束上传请求失败
     */
    public static final int ERR_UGC_FINISH_REQUEST_FAILED = 1005;

    /**
     * UGC结束上传响应错误
     */
    public static final int ERR_UGC_FINISH_RESPONSE_FAILED = 1006;

    /**
     * 客户端正忙(对象无法处理更多请求)
     */
    public static final int ERR_CLIENT_BUSY = 1007;

    public static final int ERR_FILE_NOEXIT = 1008;

    /**
     * 视频正在上传中
     */
    public static final int ERR_UGC_PUBLISHING = 1009;

    public static final int ERR_UGC_INVALID_PARAM = 1010;

    /**
     * 视频上传secretID错误，已经废弃，不会抛出
     */
    public static final int ERR_UGC_INVALID_SECRETID = 1011;

    /**
     * 视频上传signature错误
     */
    public static final int ERR_UGC_INVALID_SIGNATURE = 1012;

    /**
     * 视频文件的路径错误
     */
    public static final int ERR_UGC_INVALID_VIDOPATH = 1013;
    /**
     * 当前路径下视频文件不存在
     */
    public static final int ERR_UGC_INVALID_VIDEO_FILE = 1014;

    /**
     * 视频上传文件名太长或含有特殊字符
     */
    public static final int ERR_UGC_FILE_NAME = 1015;

    /**
     * 视频文件封面路径不对
     */
    public static final int ERR_UGC_INVALID_COVER_PATH = 1016;

    /**
     * 用户取消操作
     */
    public static final int ERR_USER_CANCEL = 1017;

    /**
     * 直接上传失败
     */
    public static final int ERR_UPLOAD_VOD = 1018;

    /************************************************ COS 错误码 ***********************************/
    /**
     * 秒传成功
     */
    public static final int FAST_SUCCESS = -20001;
    /**
     * 任务取消
     */

    public static final int CANCELED = -20002;
    /**
     * 任务暂停
     */
    public static final int PAUSED = -20003;
    /**
     * 文件不存在
     */
    public static final int FILE_NOT_EXIST = -20004;
    /**
     * 服务器回包为空
     */
    public static final int RESPONSE_IS_NULL = -20007;
    /**
     * 请求超时
     */
    public static final int REQUEST_TIMEOUT = -20008;
    /**
     * appid为空
     */
    public static final int APPID_NULL = -20009;
    /**
     * bucket为空
     */
    public static final int BUCKET_NULL = -20010;
    /**
     * COS远程路径为空
     */
    public static final int COSPATH_NULL = -20011;
    /**
     * COS目录中含有保留字符
     */
    public static final int COSPATH_ILLEGAL = -20012;
    /**
     * dest_fileId为空
     */
    public static final int DEST_FILEID_NULL = -20013;
    /**
     * bucket_authority为空
     */
    public static final int AUTHORITY_BUCKET_NULL = -20014;
    /**
     * 网络不可用
     */
    public static final int NETWORK_NOT_AVAILABLE = -20015;
    /**
     * Out Of Memory
     */
    public static final int OOM = -21001;
    /**
     * IO异常
     */
    public static final int IO_EXCEPTION = -22000;
    /**
     * 其他
     */
    public static final int OTHER = -25000;


    /************************************************ 数据上报定义 **********************************/
    public static int UPLOAD_EVENT_ID_REQUEST_UPLOAD    =   10001;  //UGC请求上传
    public static int UPLOAD_EVENT_ID_COS_UPLOAD        =   20001;  //UGC调用cos上传
    public static int UPLOAD_EVENT_ID_UPLOAD_RESULT     =   10002;  //UGC结束上传
    public static int UPLOAD_EVENT_ID_VOD_UPLOAD        =   30001;  //直接上传到vod
}
