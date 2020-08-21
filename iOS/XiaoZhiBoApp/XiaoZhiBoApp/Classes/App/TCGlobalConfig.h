/**
 * Module:   TCGlobalConfig
 *
 * Function: 小直播 的全局配置类
 *
 * 1. LiteAVSDK Licence
 * 2. 计算腾讯云 UserSig 的 SDKAppId、加密密钥、签名过期时间
 * 3. 小直播后台服务器地址
 * 4. App 主色调
 * 5. 是否启用连麦
 */

#ifndef TCGlobalConfig_h
#define TCGlobalConfig_h

/**
 *  1. LiteAVSDK Licence。 用于直播推流鉴权。
 *
 *  获取License，请参考官网指引 https://cloud.tencent.com/document/product/454/34750
 */
static NSString * const LICENCE_URL = @"";
static NSString * const LICENCE_KEY = @"";


/**
 * 2.1 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
 *
 * 进入腾讯云直播[控制台-直播SDK-应用管理](https://console.cloud.tencent.com/live/license/appmanage ) 创建应用，即可看到 SDKAppId，
 * 它是腾讯云用于区分客户的唯一标识。
 */
static const int SDKAPPID = 0;

/**
 * 2.2 计算签名用的加密密钥，获取步骤如下：
 *
 * step1. 进入腾讯云直播[控制台-直播SDK-应用管理](https://console.cloud.tencent.com/live/license/appmanage )，如果还没有应用就创建一个，
 * step2. 单击您的应用，进入"应用管理"页面。
 * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中。
 *        如果提示"请先添加管理员才能生成公私钥"，点击"编辑"，输入管理员名称，如"admin"，点"确定"添加管理员。然后再查看密钥。
 *
 * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
 * 文档：https://cloud.tencent.com/document/product/647/17275#Server
 */
static NSString * const SECRETKEY = @"";

/**
 * 2.3 签名过期时间，建议不要设置的过短
 * <p>
 * 时间单位：秒
 * 默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
 */
static const int EXPIRETIME = 604800;


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
 *     要么填写后台服务器地址（@link #kHttpServerAddr），要么填写 {@link #SDKAPPID} 和 {@link #SECRETKEY}。
 
 * 详情请参考：
 */
#define kHttpServerAddr                     @""


/**
 *  4. App 主色调。
 */
#define kMainColor                           RGB(0x22,0x2B,0x48)


/**
 *  5. 是否启用连麦。
 *
 *  由于连麦功能使用了比较昂贵的 BGP 专用线路，所以是按照通话时长进行收费的。最初级的体验包包含 3000 分钟的连麦时长，只需要 9.8 元。
 *  购买链接：https://buy.cloud.tencent.com/mobilelive?urlctr=yes&micconn=3000m##
 */
#define kEnableLinkMic                      NO

#endif /* TCGlobalConfig_h */
