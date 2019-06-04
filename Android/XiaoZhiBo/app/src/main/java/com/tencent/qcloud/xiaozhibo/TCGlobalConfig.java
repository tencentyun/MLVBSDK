package com.tencent.qcloud.xiaozhibo;

/**
 * Module:   TCGlobalConfig
 *
 * Function: App 的全局类
 *
 * 主要是记录一些重要的变量
 *
 */
public class TCGlobalConfig {
    /**
     * 小直播后台服务器地址
     *
     * 小直播 App 单靠一套客户端源码还不能正常运行，需要一个简单的帐号管理服务器，用于提供登录和注册的服务。
     * 同时，我们还在该后台上开发了“精彩回放”的功能，也就是过往的直播会被录制下来存入“回放列表”。
     * 由于直播的录制和存储都是腾讯云实现的，所以该服务器的作用仅仅是记录历史视频文件的列表，并提供给小直播 App 进行拉取和查询。
     *
     * 详情请参考：https://www.qcloud.com/document/product/454/7999
     */
    public static final String APP_SVR_URL = ""; //如果您的服务器没有部署https证书，这里需要用http

    /**
     * bugly 组件的 AppId
     *
     * bugly sdk 系腾讯提供用于 APP Crash 收集和分析的组件。
     */
    public static final String BUGLY_APPID = "1400012894";
}
