/*
 * Module:   MLVBLiveRoom
 *
 * Function: 腾讯云移动直播 - 连麦直播间（MLVBLiveRoom）
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MLVBLiveRoomDelegate.h"
#import "MLVBLiveRoomDef.h"
#import "RoomUtil.h"

/** 腾讯云移动直播 - 连麦直播间
 *
 * 基于腾讯云直播（LVB）、点播（VOD） 和 云通讯（IM）三大 PAAS 服务组合而成，支持：
 *
 * - 主播创建新的直播间开播，观众进入直播间观看。
 * - 主播和观众进行视频连麦互动。
 * - 两个不同房间的主播 PK 互动。
 * - 每一个直播间都有一个不限制房间人数的聊天室，支持发送各种文本消息和自定义消息，自定义消息可用于实现弹幕、点赞和礼物。
 *
 * 连麦直播间（MLVBLiveRoom）是一个开源的 Class，依赖两个腾讯云的闭源 SDK：
 *
 * - LiteAVSDK: 使用了其中的 TXLivePusher 和 TXLivePlayer 两个组件，前者用于推流，后者用于拉流。
 * - IM SDK: 使用 IM SDK 的 AVChatroom 用于实现直播聊天室的功能，同时，主播间的连麦流程也是依靠 IM 消息串联起来的。
 *
 * 参考文档：[直播连麦（LiveRoom）](https://cloud.tencent.com/document/product/454/14606)
 */
@interface MLVBLiveRoom : NSObject


/////////////////////////////////////////////////////////////////////////////////
//
//                      MLVBLiveRoom 基础函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - MLVBLiveRoom 基础函数
/// @name SDK 基础函数
/// @{

/**
 * 获取 MLVBLiveRoom 单例对象
 *
 * @return MLVBLiveRoom 实例
 *
 * @note 可以调用 MLVBLiveRoom#destroySharedInstance() 销毁单例对象
 */
+ (instancetype)sharedInstance;

/**
 * 销毁 MLVBLiveRoom 单例对象
 *
 * @note 销毁实例后，外部缓存的 MLVBLiveRoom 实例不能再使用，需要重新调用 MLVBLiveRoom#sharedInstance 获取新实例
 */
+ (void)destorySharedInstance;

/**
 * MLVBLiveRoom 事件回调
 * 您可以通过 MLVBLiveRoomDelegate 获得 MLVBLiveRoom 的各种状态通知
 *
 * @note 默认是在 Main Queue 中回调，如果需要自定义回调线程，可使用 delegateQueue。
 */
@property (nonatomic, weak) id<MLVBLiveRoomDelegate> delegate;

/**
 * 设置驱动回调函数的 GCD 队列
 */
@property (nonatomic, copy) dispatch_queue_t delegateQueue;

/**
 * 登录
 *
 * @param loginInfo 登录信息
 * @param completion 登录结果回调
 */
- (void)loginWithInfo:(MLVBLoginInfo *)loginInfo completion:(void(^)(int errCode, NSString *errMsg))completion;

/**
 * 登出
 */
-(void)logout;


/**
 * 修改个人信息
 *
 * @param userName 昵称
 * @param avatarURL 头像地址
 */
-(void)setSelfProfile:(NSString *)userName avatarURL:(NSString*)avatarURL completion:(void(^)(int code, NSString *msg))completion;

/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      房间相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 房间相关接口函数
/// @name 房间相关接口函数
/// @{

/**
 * 获取房间列表
 *
 * 该接口支持分页获取房间列表，可以用 index 和 count 两个参数控制列表分页的逻辑，
 * - index = 0 & count = 10代表获取第一页的10个房间。
 * - index = 11 & count = 10代表获取第二页的10个房间。
 *
 * @param index   房间开始索引，从0开始计算。
 * @param count   希望后台返回的房间个数。
 * @param completion 获取房间列表的结果回调。
 */
- (void)getRoomList:(int)index count:(int)count completion:(void(^)(int errCode, NSString *errMsg, NSArray<MLVBRoomInfo *> *roomInfoArray))completion;

/**
 * 获取观众列表
 *
 * 当有观众进房时，后台会将其信息加入到指定房间的观众列表中，调入该函数即可返回指定房间的观众列表
 *
 * @note 观众列表最多只保存30人，因为对于常规的 UI 展示来说这已经足够，保存更多除了浪费存储空间，也会拖慢列表返回的速度。
 *
 * @param roomID 房间标识。
 * @param completion 获取观众列表的结果回调。
 */
- (void)getAudienceList:(NSString *)roomID completion:(void(^)(int errCode, NSString *errMsg, NSArray<MLVBAudienceInfo *> *audienceInfoArray))completion;


/**
 * 创建房间（主播调用）
 *
 * 主播开播的正常调用流程是：
 * 1.【主播】调用 startLocalPreview() 打开摄像头预览，此时可以调整美颜参数。
 * 2.【主播】调用 createRoom 创建直播间，房间创建成功与否会通过 completion 通知给主播。
 *
 * @param roomID 房间标识，推荐做法是用主播的 userID 作为房间的 roomID，这样省去了后台映射的成本。room ID 可以填空，此时由后台生成。
 * @param roomInfo 房间信息（非必填），用于房间描述的信息，比如房间名称，允许使用 JSON 格式作为房间信息。
 * @param completion 创建房间的结果回调
 */
- (void)createRoom:(NSString *)roomID roomInfo:(NSString *)roomInfo completion:(void(^)(int errCode, NSString *errMsg))completion;

/**
 * 进入房间（观众调用）
 *
 * 观众观看直播的正常调用流程是：
 * 1.【观众】调用 getRoomList() 刷新最新的直播房间列表，并通过 completion 回调拿到房间列表。
 * 2.【观众】选择一个直播间以后，调用 enterRoom() 进入该房间。
 *
 * @param roomID 房间标识
 * @param view 承载视频画面的控件
 * @param completion 进入房间的结果回调
 *
 */
- (void)enterRoom:(NSString *)roomID view:(UIView *)view completion:(void(^)(int errCode, NSString *errMsg))completion;

/**
 * 离开房间
 *
 * @param completion 离开房间的结果回调
 */
- (void)exitRoom:(void(^)(int errCode, NSString *errMsg))completion;

/**
 * 设置当前房间的扩展信息字段
 *
 * 有时候您需要为当前房间设置一些扩展字段，比如“点赞人数”、“是否正在连麦”等等，这些字段我们很难全都预先定义好，所以提供了如下三种操作接口：
 * - SET：设置，value 可以是数值或者字符串，比如“是否正在连麦”等。
 * - INC：增加，value 只能是整数，比如“点赞人数”，“人气指数”等，都可以使用该操作接口。
 * - DEC：减少，value 只能是整数，比如“点赞人数”，“人气指数”等，都可以使用该操作接口。
 *
 * @param op 执行动作
 * @param key 自定义键
 * @param value 数值
 * @param completion 操作完成的回调
 *
 * @note op 为 MLVBCustomFieldOpSet 或者 MLVBCustomFieldOpDec 时，value 需要是一个数字
 */
- (void)setCustomInfo:(MLVBCustomFieldOp)op key:(NSString *)key value:(NSString *)value completion:(void(^)(int errCode, NSString *custom))completion;

/**
 * 获取当前房间的扩展信息字段
 *
 * @param completion 获取自定义值回调
 */
- (void)getCustomInfo:(void(^)(int errCode, NSString *errMsg, NSString *value))completion;

/// @}



/////////////////////////////////////////////////////////////////////////////////
//
//                      主播和观众连麦
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 主播和观众连麦
/// @name 主播和观众连麦
/// @{

/**
 * 观众请求连麦
 *
 * 主播和观众的连麦流程可以简单描述为如下几个步骤：
 * 1. 【观众】调用 requestJoinAnchor 向主播发起连麦请求。
 * 2. 【主播】会收到 MLVBLiveRoomDelegate#onRequestJoinAnchor 的回调通知。
 * 3. 【主播】调用 reponseJoinAnchor 确定是否接受观众的连麦请求。
 * 4. 【观众】会收到 requestJoinAnchor 传入的回调通知，可以得知请求是否被同意。
 * 5. 【观众】如果请求被同意，则调用 startLocalPreview 开启本地摄像头，如果 App 还没有取得摄像头和麦克风权限，会触发 UI 提示。
 * 6. 【观众】然后调用 joinAnchor 正式进入连麦状态。
 * 7. 【主播】一旦观众进入连麦状态，主播就会收到 MLVBLiveRoomDelegate#onAnchorEnter 通知。
 * 8. 【主播】主播调用 startRemoteView 就可以看到连麦观众的视频画面。
 * 9. 【观众】如果直播间里已经有其他观众正在跟主播进行连麦，那么新加入的这位连麦观众也会收到 MLVBLiveRoomDelegate#onAnchorJoin 通知，用于展示（startRemoteView）其他连麦者的视频画面。
 *
 * @param reason 连麦原因
 * @param completion 主播响应回调
 * @see MLVBLiveRoomDelegate#onRequestJoinAnchor(AnchorInfo, String)
 */
- (void)requestJoinAnchor:(NSString *)reason completion:(void(^)(int errCode, NSString *errMsg))completion;

/**
 * 主播处理连麦请求
 *
 * 主播在收到 MLVBLiveRoomDelegate#onRequestJoinAnchor() 回调之后会需要调用此接口来处理观众的连麦请求。
 *
 * @param userID 观众 ID
 * @param agree YES：同意；NO：拒绝。
 * @param reason 同意/拒绝连麦的原因描述。
 */
- (void)responseJoinAnchor:(NSString *)userID agree:(BOOL)agree reason:(NSString *)reason;

/**
 * 进入连麦状态
 *
 * 进入连麦成功后，主播和其他连麦观众会收到 MLVBLiveRoomDelegate#onAnchorEnter 通知
 *
 * @param completion 进入连麦的结果回调
 */
- (void)joinAnchor:(void(^)(int errCode, NSString *errMsg))completion;

/**
 * 观众退出连麦
 *
 * 退出连麦成功后，主播和其他连麦观众会收到 MLVBLiveRoomDelegate#onAnchorExit 通知
 *
 * @param completion 退出连麦的结果回调
 */
- (void)quitJoinAnchor:(void(^)(int errCode, NSString *errMsg))completion;

/**
 * 主播踢除连麦观众
 *
 * 主播调用此接口踢除连麦观众后，被踢连麦观众会收到 MLVBLiveRoomDelegate#onKickoutJoinAnchor 回调通知
 *
 * @param userID 连麦小主播 ID
 *
 * @see MLVBLiveRoomDelegate#onKickoutJoinAnchor()
 */
- (void)kickoutJoinAnchor:(NSString *)userID;
/// @}

#pragma mark - 主播跨房间 PK
/// @name 主播跨房间 PK
/// @{

/**
 * 请求跨房 PK
 *
 * 主播和主播之间可以跨房间 PK，两个正在直播中的主播 A 和 B，他们之间的跨房 PK 流程如下：
 * 1. 【主播 A】调用 requestRoomPK() 向主播 B 发起连麦请求。
 * 2. 【主播 B】会收到 MLVBLiveRoomDelegate#onRequestRoomPK(AnchorInfo) 回调通知。
 * 3. 【主播 B】调用 responseRoomPK() 确定是否接受主播 A 的 PK 请求。
 * 4. 【主播 B】如果接受了主播 A 的要求，可以直接调用 startRemoteView() 来显示主播 A 的视频画面。
 * 5. 【主播 A】会通过传入的 completion 收到回调通知，可以得知请求是否被同意。
 * 6. 【主播 A】如果请求被同意，则可以调用 startRemoteView() 显示主播 B 的视频画面。
 *
 * @param userID 被邀约主播 ID
 * @param completion 请求跨房 PK 的结果回调
 *
 * @see MLVBLiveRoomDelegate#onRequestRoomPK(AnchorInfo)
 */
- (void)requestRoomPK:(NSString *)userID completion:(void(^)(int errCode, NSString *errMsg, NSString *streamUrl))completion;

/**
 * 响应跨房 PK 请求
 *
 * 主播响应其他房间主播的 PK 请求，发起 PK 请求的主播会收到 MLVBLiveRoomDelegate.onRequestRoomPK 回调通知。
 *
 * @param anchor 发起 PK 请求的主播
 * @param agree YES：同意；NO：拒绝
 * @param reason 同意或拒绝 PK 的原因描述。
 */
- (void)responseRoomPK:(MLVBAnchorInfo *)anchor agree:(BOOL)agree reason:(NSString *)reason;

/**
 * 退出跨房 PK
 *
 * 当两个主播中的任何一个退出跨房 PK 状态后，另一个主播会收到 MLVBLiveRoomDelegate#onQuitRoomPK 回调通知。
 *
 * @param completion 退出跨房 PK 的结果回调
 */
- (void)quitRoomPK:(void(^)(int errCode, NSString *errMsg))completion;
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      视频相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 视频相关接口函数
/// @name 视频相关接口函数
/// @{

/**
 * 开启本地视频的预览画面
 *
 * @param frontCamera YES：前置摄像头；NO：后置摄像头。
 * @param view 承载视频画面的控件
 */
- (void)startLocalPreview:(BOOL)frontCamera view:(UIView *)view;

/**
 * 停止本地视频采集及预览
 */
- (void)stopLocalPreview;

/**
 * 启动渲染远端视频画面
 *
 * @param anchorInfo 对方的用户信息
 * @param view 承载视频画面的控件
 * @param onPlayBegin   播放器开始回调
 * @param onPlayError   播放出错回调
 * @param onPlayEvent   其它播放事件回调
 *
 * @note 在 onUserVideoAvailable 回调时，调用这个接口
 */
- (void)startRemoteView:(MLVBAnchorInfo *)anchorInfo view:(UIView *)view onPlayBegin:(IPlayBegin)onPlayBegin onPlayError:(IPlayError)onPlayError playEvent:(IPlayEventBlock)onPlayEvent;

/**
 * 停止渲染远端视频画面
 *
 * @param anchor 对方的用户
 */
- (void)stopRemoteView:(MLVBAnchorInfo *)anchor;

/**
 * 设置观众端镜像效果
 *
 * 由于前置摄像头采集的画面是取自手机的观察视角,如果将采集到的画面直接展示给观众，是完全没有问题的。
 * 但如果将采集到的画面也直接显示给主播,则会跟主播照镜子时的体验完全相反，会让主播感觉到很奇怪。
 * 因此,SDK 会默认开启本地摄像头预览画面的镜像效果，让主播直播时跟照镜子时保持一个体验效果。
 *
 * setMirror 所影响的则是观众端看到的视频效果,如果想要保持观众端看到的效果跟主播端保持一致，需要开启镜像；
 * 如果想要让观众端看到正常的未经处理过的画面（比如主播弹吉他的时候有类似需求），则可以关闭镜像。
 *
 * @note 仅当前使用前置摄像头时,setMirror 接口才会生效，在使用后置摄像头时此接口无效。
 *
 * @param isMirror YES：播放端看到的是镜像画面；NO：播放端看到的是非镜像画面。
 */
- (void)setMirror:(BOOL)isMirror;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      音频相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 音频相关接口函数
/// @name 音频相关接口函数
/// @{

/**
 * 是否屏蔽本地音频
 *
 * @param mute YES：屏蔽；NO：开启
 */
- (void)muteLocalAudio:(BOOL)mute;

/**
 * 设置指定用户是否静音
 *
 * @param userID 对方的用户标识
 * @param mute YES：静音；NO：非静音
 */
- (void)muteRemoteAudio:(NSString *)userID mute:(BOOL) mute;

/**
 * 设置所有远端用户是否静音
 *
 * @param mute YES：静音；NO：非静音
 */
-(void)muteAllRemoteAudio:(BOOL)mute;

/// @}

/////////////////////////////////////////////////////////////////////////////////
//
//                      摄像头相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 摄像头相关接口函数
/// @name 摄像头相关接口函数
/// @{
/**
 * 切换前后摄像头
 */
- (void)switchCamera;

/**
 * 主播屏蔽摄像头期间需要显示的等待图片
 *
 * 当主播屏蔽摄像头，或者由于 App 切入后台无法使用摄像头的时候，我们需要使用一张等待图片来提示观众“主播暂时离开，请不要走开”。
 *
 * @param image 等待图片
 */
- (void)setCameraMuteImage:(UIImage*)image;

/**
 * 调整焦距
 *
 * @param distance 焦距大小，取值范围1 - 5
 *
 * @note 当为1的时候为最远视角（正常镜头），当为5的时候为最近视角（放大镜头），这里最大值推荐为5，超过5后视频数据会变得模糊不清
 */
- (void)setZoom:(CGFloat)distance;


/**
 * 打开闪关灯。
 *
 * @param bEnable YES：打开；NO：关闭
 * @return YES：打开成功；NO：打开失败
 */
- (BOOL)enableTorch:(BOOL)bEnable;

/**
 * 设置手动对焦区域
 *
 * SDK 默认使用摄像头自动对焦功能，您也可以通过 TXLivePushConfig 中的 touchFocus 选项关闭自动对焦，改用手动对焦。
 * 改用手动对焦之后，需要由主播自己点击摄像头预览画面上的某个区域，来手动指导摄像头对焦。
 *
 */
- (void)setFocusPosition:(CGPoint)touchPoint;

/// @}

#pragma mark - 美颜滤镜相关接口函数
/// @name 美颜滤镜相关接口函数
/// @{

/**
 * 设置美颜、美白、红润效果级别
 *
 * @param beautyStyle    美颜风格，三种美颜风格：0 ：光滑；1：自然；2：天天 P 图版美颜（商用企业版有效，普通版本设置此选项无效）。
 * @param beautyLevel    美颜级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显。
 * @param whitenessLevel 美白级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显。
 * @param ruddinessLevel 红润级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显。
 */
- (void)setBeautyStyle:(TX_Enum_Type_BeautyStyle)beautyStyle
           beautyLevel:(float)beautyLevel
        whitenessLevel:(float)whitenessLevel
        ruddinessLevel:(float)ruddinessLevel;

/**
 * 设置指定素材滤镜特效
 *
 * @param image 指定素材，即颜色查找表图片。
 *
 * @note 滤镜素材请使用 png 格式，不能使用 jpg 格式，友情提示，Windows 里直接改文件的后缀名不能改变图片的格式，需要用 Photoshop 进行转换。
 */
- (void)setFilter:(UIImage *)image;

/**
 * 设置滤镜浓度
 *
 * @param specialValue 从0到1，越大滤镜效果越明显，默认取值0.5
 */
- (void)setSpecialRatio:(float)specialValue;

/**
 * 设置大眼级别（商用企业版有效，普通版本设置此参数无效）
 *
 * @param eyeScaleLevel 大眼等级取值为 0 - 9。取值为0时代表关闭美颜效果。默认值：0
 */
- (void)setEyeScaleLevel:(float)eyeScaleLevel;

/**
 * 设置瘦脸级别（商用企业版有效，普通版本设置此参数无效）
 *
 * @param faceScaleLevel 瘦脸级别取值范围 0 - 9； 0 表示关闭 1 - 9值越大 效果越明显。
 */
- (void)setFaceScaleLevel:(float)faceScaleLevel;

/**
 * 设置 V 脸级别（商用企业版有效，其它版本设置此参数无效）。
 *
 * @param faceVLevel V 脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setFaceVLevel:(float)faceVLevel;

/**
 * 设置下巴拉伸或收缩（商用企业版有效，其它版本设置此参数无效）。
 *
 * @param chinLevel 下巴拉伸或收缩级别，取值范围 -9 - 9；0 表示关闭，小于0表示收缩，大于0表示拉伸。
 */
- (void)setChinLevel:(float)chinLevel;

/**
 * 设置短脸级别（商用企业版有效，其它版本设置此参数无效）。
 *
 * @param faceShortlevel 短脸级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setFaceShortLevel:(float)faceShortlevel;

/**
 * 设置瘦鼻级别（商用企业版有效，其它版本设置此参数无效）。
 *
 * @param noseSlimLevel 瘦鼻级别，取值范围0 - 9；0表示关闭，1 - 9值越大，效果越明显。
 */
- (void)setNoseSlimLevel:(float)noseSlimLevel;

/**
 * 设置绿幕背景视频（商用企业版有效，其它版本设置此参数无效）。
 *
 * @note 此处的绿幕功能并非智能抠背，它需要被拍摄者的背后有一块绿色的幕布来辅助产生特效。
 *
 * @param file 视频文件路径。支持 MP4；nil 表示关闭特效。
 */
- (void)setGreenScreenFile:(NSURL *)file;

/**
 * 选择使用哪一款 AI 动效挂件（商用企业版有效，其它版本设置此参数无效）。
 *
 * @param tmplName 动效名称
 * @param tmplDir 动效所在目录
 */
- (void)selectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir;
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      消息发送接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 消息发送接口函数
/// @name 消息发送接口函数
/// @{

/**
 * 发送文本消息
 *
 * @param message 文本消息
 * @param completion 发送结果回调
 *
 * @see MLVBLiveRoomDelegate#onRecvRoomTextMsg
 */
- (void)sendRoomTextMsg:(NSString *)message completion:(void (^)(int errCode, NSString *errMsg))completion;

/**
 * 发送自定义文本消息
 *
 * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
 * @param message 文本消息
 * @param completion 发送结果回调
 *
 * @see MLVBLiveRoomDelegate#onRecvRoomCustomMsg
 */
- (void)sendRoomCustomMsg:(NSString *)cmd msg:(NSString *)message completion:(void (^)(int errCode, NSString *errMsg))completion;;
/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      背景混音相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 背景混音相关接口函数
/// @name 背景混音相关接口函数
/// @{

/**
 * 播放背景音乐
 *
 * @param path 音乐文件路径，一定要是 app 对应的 document 目录下面的路径，否则文件会读取失败。
 *
 * @return YES：成功；NO：失败。
 */
- (BOOL)playBGM:(NSString *)path;

/**
 * 播放背景音乐（高级版本）
 *
 * @param path 音乐文件路径，一定要是 app 对应的 document 目录下面的路径，否则文件会读取失败。
 * @param beginNotify 音乐播放开始的回调通知。
 * @param progressNotify 音乐播放的进度通知，单位毫秒。
 * @param completeNotify 音乐播放结束的回调通知。
 *
 * @return YES：成功；NO：失败。
 */
-    (BOOL)playBGM:(NSString *)path
   withBeginNotify:(void (^)(NSInteger errCode))beginNotify
withProgressNotify:(void (^)(NSInteger progressMS, NSInteger durationMS))progressNotify
 andCompleteNotify:(void (^)(NSInteger errCode))completeNotify;

/**
 * 停止播放背景音乐
 */
- (BOOL)stopBGM;

/**
 * 暂停播放背景音乐
 */
- (BOOL)pauseBGM;

/**
 * 继续播放背景音乐
 */
- (BOOL)resumeBGM;

/**
 * 获取音乐文件总时长，单位毫秒
 *
 * @param path 音乐文件路径，如果 path 为 nil，那么返回当前正在播放的背景音乐时长
 *

 * @return 成功返回时长，单位毫秒，失败返回-1
 */
- (int)getMusicDuration:(NSString *)path;

/**
 * 设置麦克风的音量大小，播放背景音乐混音时使用，用来控制麦克风音量大小
 *
 * @param volume 音量大小，1.0 为正常音量，建议值为0.0 - 2.0。
 */
- (BOOL)setMicVolume:(float)volume;




/**
 * 设置背景音乐的音量大小，播放背景音乐混音时使用，用来控制背景音音量大小
 *
 * @param volume 音量大小，1.0为正常音量，建议值为0.0 - 2.0。
 */
- (BOOL)setBGMVolume:(float)volume;


/**
 * 调整背景音乐的音调高低
 *
 * @param pitch 音调，默认值是0.0f，范围是：-1 - 1 之间的浮点数。
 *
 * @return YES：成功；NO：失败。
 */
- (BOOL)setBGMPitch:(float)pitch;

/**
 *  设置背景音的播放位置
 *
 *  @param position 播放位置，默认值是0；范围是 0 - 1。
 */
- (BOOL)setBGMPosition:(float)position;

/**
 * 设置混响效果
 *
 * @param reverbType 混响类型，详见 “TXLiveSDKTypeDef.h” 中的 TXReverbType 定义。
 * @return YES：成功；NO：失败。
 */
- (BOOL)setReverbType:(TXReverbType)reverbType;

/**
 * 设置变声类型
 *
 * @param voiceChangerType 混响类型，详见 “TXLiveSDKTypeDef.h” 中的 voiceChangerType 定义。
 * @return YES：成功；NO：失败。
 */
- (BOOL)setVoiceChangerType:(TXVoiceChangerType)voiceChangerType;

/// @}


/////////////////////////////////////////////////////////////////////////////////
//
//                      调试相关接口函数
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark - 调试相关接口函数
/// @name 调试相关接口函数
/// @{

/**
 * 在渲染 view 上显示播放或推流状态统计及事件消息浮层
 */
- (void)showVideoDebugLog:(BOOL)isShow;

/// @}

@end
