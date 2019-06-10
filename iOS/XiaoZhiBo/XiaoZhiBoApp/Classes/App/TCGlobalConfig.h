/**
 * Module: TCGlobalConfig
 *
 * Function: 全局配置 & 常量
 */

#ifndef TCGlobalConfig_h
#define TCGlobalConfig_h

// 首次安装和进入小直播，需要有不同的提示，写配置文件
#define hasEnteredXiaoZhiBo   @"_hasEnteredXiaoZhiBo_"
#define isFirstInstallApp     @"_isFirstInstallApp_"


// 请参考 https://cloud.tencent.com/document/product/454/15187 填写您的“小直播”服务器接口地址
#define kHttpServerAddr                     @""

//bugly组件Appid，bugly为腾讯提供的用于App Crash收集和分析的组件
#define BUGLY_APP_ID                         @"i1400012894"

//录屏需要用到此配置,请改成您的工程配置文件中的app groups的配置
#define APP_GROUP                            @"group.com.tencent.fx.rtmpdemo"

//**********************************************************************

#define kHttpTimeout                         30

//错误码
#define kError_InvalidParam                            -10001
#define kError_ConvertJsonFailed                       -10002
#define kError_HttpError                               -10003

//播放端错误信息
#define kErrorMsgLiveStopped @"直播已结束"
#define kErrorMsgRtmpPlayFailed @"视频流播放失败，Error:"
#define kErrorMsgOpenCameraFailed  @"无法打开摄像头，需要摄像头权限"
#define kErrorMsgPushClosed  @"推流断开"

//是否展示log按钮，测试的时候打开，正式发布的时候关闭
#define ENABLE_LOG 0

//提示语
#define  kTipsMsgStopPush  @"当前正在直播，是否退出直播？"

// 如果工程里面没有使用PiTu动效（没有定义POD_PITU)，那就定义为0，这样为了兼容UI显示
#ifndef POD_PITU
#define POD_PITU 0
#endif

#endif /* TCGlobalConfig_h */
