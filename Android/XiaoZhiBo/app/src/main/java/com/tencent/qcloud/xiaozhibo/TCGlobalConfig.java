package com.tencent.qcloud.xiaozhibo;

/**
 * Module:   TCGlobalConfig
 *
 * Function: app 的全局配置类
 *
 * 主要是记录一些重要的变量
 */

public class TCGlobalConfig {

    /**
     *  1. LiteAVSDK Licence。 用于直播推流鉴权。
     *
     *  获取License，请参考官网指引 https://cloud.tencent.com/document/product/454/34750
     */
    public static final String LICENCE_URL = #设置成您自己账号下直播License的url;
    public static final String LICENCE_KEY = #设置成您自己账号下直播License的key;


    /**
     * 2.1 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
     *
     * 进入腾讯云直播[控制台-直播SDK-应用管理](https://console.cloud.tencent.com/live/license/appmanage) 创建应用，即可看到 SDKAppId，
     * 它是腾讯云用于区分客户的唯一标识。
     */
    public static final int SDKAPPID = #设置成您自己账号下的SDKAppId;

    /**
     * 2.2 计算签名用的加密密钥，获取步骤如下：
     *
     * step1. 进入腾讯云直播[控制台-直播SDK-应用管理](https://console.cloud.tencent.com/live/license/appmanage)，如果还没有应用就创建一个，
     * step2. 单击您的应用，进入"应用管理"页面。
     * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中。
     *        如果提示"请先添加管理员才能生成公私钥"，点击"编辑"，输入管理员名称，如"admin"，点"确定"添加管理员。然后再查看密钥。
     *
     * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
     * 文档：https://cloud.tencent.com/document/product/647/17275#Server
     */
    public static final String SECRETKEY = #设置成您自己账号的加密密钥;

    /**
     * 2.3 签名过期时间，建议不要设置的过短
     * <p>
     * 时间单位：秒
     * 默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
     */
    public static final int EXPIRETIME = 604800;


    /**
     * 3. 小直播后台服务器地址
     *
     * 3.1 您可以不填写后台服务器地址：
     *     小直播 App 单靠客户端源码运行，方便快速跑通体验小直播。
     *     不过在这种模式下运行的“小直播”，没有注册登录、回放列表等功能，仅有基本的直播推拉流、聊天室、连麦等功能。
     *     另外在这种模式下，腾讯云安全签名 UserSig 是使用本地 GenerateTestUserSig 模块计算的，存在 SECRETKEY 被破解的导致腾讯云流量被盗用的风险。
     *
     * 3.2 您可以填写后台服务器地址：
     *     服务器需要您参考文档 https://cloud.tencent.com/document/product/454/15187 自行搭建。
     *     服务器提供注册登录、回放列表、计算 UserSig 等服务。
     *     这种情况下 {@link #SDKAPPID} 和 {@link #SECRETKEY} 可以设置为任意值。
     *
     * 注意：
     *     后台服务器地址（APP_SVR_URL）和 （SDKAPPID，SECRETKEY）一定要填一项。
     *     要么填写后台服务器地址（@link #APP_SVR_URL），要么填写 {@link #SDKAPPID} 和 {@link #SECRETKEY}。
     *
     * 详情请参考：
     */
    public static final String APP_SVR_URL = "";

    /**
     * bugly 组件的 AppId
     *
     * bugly sdk 系腾讯提供用于 APP Crash 收集和分析的组件。
     */
    public static final String BUGLY_APPID = #设置成您自己的BUGLY账号;

}
