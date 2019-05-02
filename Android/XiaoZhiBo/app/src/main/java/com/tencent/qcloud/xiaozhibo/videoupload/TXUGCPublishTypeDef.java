package com.tencent.qcloud.xiaozhibo.videoupload;

/**
 * Created by yuejiaoli on 2017/7/19.
 */

public class TXUGCPublishTypeDef {
    /**
     * 短视频发布参数定义
     * secretId:腾讯云存储cos服务密钥ID，已经废弃，不用填写
     * signature:signature
     * videoPath:视频路径
     * coverPath：自定义封面
     * resumeUpload：是否启动断点续传，默认开启
     * fileName：视频名称
     */
    public final static class TXPublishParam {
        public String   secretId;                                                //腾讯云存储cos服务密钥ID，已经废弃，不用填写
        public String   signature;                                               //signature
        public String   videoPath;                                              //视频地址
        public String   coverPath;                                              //封面
        public boolean  enableResume = true;                                    //是否启动断点续传，默认开启
		public boolean  enableHttps  = false;                                   //上传是否使用https。默认关闭，走http
        public String   fileName;                                               //视频名称
    }

    /**
     * 短视频发布结果错误码定义，短视频发布流程分为三步
     *    step1: 请求上传文件
     *    step2: 上传文件
     *    step3: 请求发布短视频
     */
    public static final int PUBLISH_RESULT_OK                       = 0;        //发布成功
    public static final int PUBLISH_RESULT_PUBLISH_PREPARE_ERROR    = 1000;     //step0: 准备发布失败
    public static final int PUBLISH_RESULT_UPLOAD_REQUEST_FAILED    = 1001;     //step1: “文件上传请求”发送失败
    public static final int PUBLISH_RESULT_UPLOAD_RESPONSE_ERROR    = 1002;     //step1: “文件上传请求”收到错误响应
    public static final int PUBLISH_RESULT_UPLOAD_VIDEO_FAILED      = 1003;     //step2: “视频文件”上传失败
    public static final int PUBLISH_RESULT_UPLOAD_COVER_FAILED      = 1004;     //step2: “封面文件”上传失败
    public static final int PUBLISH_RESULT_PUBLISH_REQUEST_FAILED   = 1005;     //step3: “短视频发布请求”发送失败
    public static final int PUBLISH_RESULT_PUBLISH_RESPONSE_ERROR   = 1006;     //step3: “短视频发布请求”收到错误响应

    /**
     * 短视频发布结果定义
     */
    public final static class TXPublishResult {
        public int    retCode;                                                  //错误码
        public String descMsg;                                                  //错误描述信息
        public String videoId;                                                  //视频文件Id
        public String videoURL;                                                 //视频播放地址
        public String coverURL;                                                 //封面存储地址

    };

    /**
     * 短视频发布回调定义
     */
    public interface ITXVideoPublishListener {
        /**
         * 短视频发布进度
         */
        void onPublishProgress(long uploadBytes, long totalBytes);

        /**
         * 短视频发布完成
         */
        void onPublishComplete(TXPublishResult result);
    }
}
