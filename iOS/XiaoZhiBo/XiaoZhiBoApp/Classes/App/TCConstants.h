//
//  TCConstants.h
//  TCLVBIMDemo
//
//  Created by realingzhou on 16/8/22.
//  Copyright © 2016年 tencent. All rights reserved.
//

#ifndef TCConstants_h
#define TCConstants_h

//Http配置
// 请参考 https://cloud.tencent.com/document/product/454/15187 填写您的“小直播”服务器接口地址
#define kHttpServerAddr                     @""

//数据上报
#define DEFAULT_ELK_HOST                     @""

//bugly组件Appid，bugly为腾讯提供的用于App Crash收集和分析的组件
#define BUGLY_APP_ID                         @"i1400012894"

//录屏需要用到此配置,请改成您的工程配置文件中的app groups的配置
#define APP_GROUP                            @"group.com.tencent.fx.rtmpdemo"

//直播分享页面的跳转地址，分享到微信、手Q后点击观看将会跳转到这个地址，请参考https://www.qcloud.com/document/product/454/8046 文档部署html5的代码后，替换成相应的页面地址
#define kLivePlayShareAddr                   @"http://imgcache.qq.com/open/qcloud/video/share/xiaozhibo.html"
//设置第三方平台的appid和appsecrect，大部分平台进行分享操作需要在第三方平台创建应用并提交审核，通过后拿到appid和appsecrect并填入这里，具体申请方式请参考http://dev.umeng.com/social/android/operation
//有关友盟组件更多资料请参考这里：http://dev.umeng.com/social/ios/quick-integration
#define kWeiXin_Share_ID                     @"wx6ae3374db9733fcc"
#define kWeiXin_Share_Secrect                @"757aeae22603e87b7843de8c4b3c3e99"

#define kSina_WeiBo_Share_ID                 @"612079538"
#define kSina_WeiBo_Share_Secrect            @"9165e82c540363d19ece52535026600d"

#define kQQZone_Share_ID                     @"101360044"
#define kQQZone_Share_Secrect                @"a78d337fc7ad4dae29272160beddab88"


//**********************************************************************

#define kHttpTimeout                         30

//错误码
#define kError_InvalidParam                            -10001
#define kError_ConvertJsonFailed                       -10002
#define kError_HttpError                               -10003

//IMSDK群组相关错误码
#define kError_GroupNotExist                            10010  //该群已解散
#define kError_HasBeenGroupMember                       10013  //已经是群成员

//错误信息
#define  kErrorMsgNetDisconnected  @"网络异常，请检查网络"

//直播端错误信息
#define  kErrorMsgCreateGroupFailed  @"创建直播房间失败,Error:"
#define  kErrorMsgGetPushUrlFailed  @"拉取直播推流地址失败,Error:"
#define  kErrorMsgOpenCameraFailed  @"无法打开摄像头，需要摄像头权限"
#define  kErrorMsgOpenMicFailed  @"无法打开麦克风，需要麦克风权限"
#define  kErrorMsgPushClosed  @"推流断开"

//播放端错误信息
#define kErrorMsgGroupNotExit @"直播已结束，加入失败"
#define kErrorMsgJoinGroupFailed @"加入房间失败，Error:"
#define kErrorMsgLiveStopped @"直播已结束"
#define kErrorMsgRtmpPlayFailed @"视频流播放失败，Error:"

//是否展示log按钮，测试的时候打开，正式发布的时候关闭
#define ENABLE_LOG 0

//提示语
#define  kTipsMsgStopPush  @"当前正在直播，是否退出直播？"

#ifndef POD_PITU
#define POD_PITU 0
#endif

#ifndef YOUTU_AUTH
#define YOUTU_AUTH 0
#endif


#endif /* TCConstants_h */
