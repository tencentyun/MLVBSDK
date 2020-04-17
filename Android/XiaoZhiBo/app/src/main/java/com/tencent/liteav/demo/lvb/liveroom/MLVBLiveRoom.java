package com.tencent.liteav.demo.lvb.liveroom;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;

import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.LoginInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.MLVBCommonDef;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePusher;
import com.tencent.rtmp.ui.TXCloudVideoView;

/*
 * Module:   MLVBLiveRoom
 *
 * Function: 腾讯云移动直播 - 连麦直播间（MLVBLiveRoom）
 *
 */

/** 腾讯云移动直播 - 连麦直播间
 *
 * 基于腾讯云直播（LVB）、点播（VOD） 和 云通讯（IM）三大 PAAS 服务组合而成，支持：
 * - 主播创建新的直播间开播，观众进入直播间观看。
 * - 主播和观众进行视频连麦互动。
 * - 两个不同房间的主播 PK 互动。
 * - 一个直播间都有一个不限制房间人数的聊天室，支持发送各种文本消息和自定义消息，自定义消息可用于实现弹幕、点赞和礼物。
 *
 * 连麦直播间（MLVBLiveRoom）是一个开源的 Class，依赖两个腾讯云的闭源 SDK：
 * - LiteAVSDK: 使用了其中的 TXLivePusher 和 TXLivePlayer 两个组件，前者用于推流，后者用于拉流。
 * - IM SDK: 使用 IM SDK 的 AVChatroom 用于实现直播聊天室的功能，同时，主播间的连麦流程也是依靠 IM 消息串联起来的。
 *
 * 参考文档：https://cloud.tencent.com/document/product/454/14606
 *
 **/
public abstract class MLVBLiveRoom {

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      MLVBLiveRoom 基础函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    /// @name SDK 基础函数
    /// @{

    /**
     * 获取 MLVBLiveRoom 单例对象
     *
     * @param context  Android 上下文，内部会转为 ApplicationContext 用于系统 API 调用
     * @return MLVBLiveRoom 实例
     *
     * @note 可以调用 {@link MLVBLiveRoom#destroySharedInstance()} 销毁单例对象
     */
    public static MLVBLiveRoom sharedInstance(Context context) {
        return MLVBLiveRoomImpl.sharedInstance(context);
    }

    /**
     * 销毁 MLVBLiveRoom 单例对象
     *
     * @note 销毁实例后，外部缓存的 MLVBLiveRoom 实例不能再使用，需要重新调用 {@link MLVBLiveRoom#sharedInstance(Context)} 获取新实例
     */
    public static void destroySharedInstance() {
        MLVBLiveRoomImpl.destroySharedInstance();
    }

    /**
     * 设置回调接口
     *
     * 您可以通过 IMLVBLiveRoomListener 获得 MLVBLiveRoom 的各种状态通知
     *
     * @param listener 回调接口
     *
     * @note 默认是在 Main Thread 中回调，如果需要自定义回调线程，可使用 {@link MLVBLiveRoom#setListenerHandler(Handler)}
     */
    public abstract void setListener(IMLVBLiveRoomListener listener);

    /**
     * 设置驱动回调的线程
     *
     * @param listenerHandler 线程
     */
    public abstract void setListenerHandler(Handler listenerHandler);

    /**
     * 登录
     *
     * @param loginInfo 登录信息
     * @param callback 登录结果回调
     *
     * @see  {@link IMLVBLiveRoomListener.LoginCallback}
     */
    public abstract void login(final LoginInfo loginInfo, final IMLVBLiveRoomListener.LoginCallback callback);

    /**
     * 退出登录
     */
    public abstract void logout();

    /**
     * 修改个人信息
     *
     * @param userName 昵称
     * @param avatarURL 头像地址
     */
    public abstract void setSelfProfile(String userName, String avatarURL);

    /// @}

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      房间相关接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 房间相关接口函数
    /// @{

    /**
     * 获取房间列表
	 *
	 * 该接口支持分页获取房间列表，可以用 index 和 count 两个参数控制列表分页的逻辑，
	 * - index = 0 & count = 10 代表获取第一页的10个房间。
	 * - index = 11 & count = 10 代表获取第二页的10个房间。
     *
     * @param index   房间开始索引，从0开始计算。
     * @param count   希望后台返回的房间个数。
     * @param callback 获取房间列表的结果回调。
     */
    public abstract void getRoomList(int index, int count, final IMLVBLiveRoomListener.GetRoomListCallback callback);

    /**
     * 获取观众列表
     *
     * 当有观众进房时，后台会将其信息加入到指定房间的观众列表中，调入该函数即可返回指定房间的观众列表
	 *
	 * @note 观众列表最多只保存30人，因为对于常规的 UI 展示来说这已经足够，保存更多除了浪费存储空间，也会拖慢列表返回的速度。
     *
     * @param callback 获取观众列表的结果回调。
     */
    public abstract void getAudienceList(IMLVBLiveRoomListener.GetAudienceListCallback callback);

	/**
     * 创建房间（主播调用）
	 *
	 * 主播开播的正常调用流程是：
	 * 1.【主播】调用 startLocalPreview() 打开摄像头预览，此时可以调整美颜参数。
	 * 2.【主播】调用 createRoom 创建直播间，房间创建成功与否会通过 {@link IMLVBLiveRoomListener.CreateRoomCallback} 通知给主播。
     *
     * @param roomID 房间标识，推荐做法是用主播的 userID 作为房间的 roomID，这样省去了后台映射的成本。room ID 可以填空，此时由后台生成。
     * @param roomInfo 房间信息（非必填），用于房间描述的信息，比如房间名称，允许使用 JSON 格式作为房间信息。
     * @param callback 创建房间的结果回调
     */
    public abstract void createRoom(final String roomID, final String roomInfo, final IMLVBLiveRoomListener.CreateRoomCallback callback);

	 /**
     * 进入房间（观众调用）
	 *
	 * 观众观看直播的正常调用流程是：
	 * 1.【观众】调用 getRoomList() 刷新最新的直播房间列表，并通过 {@link IMLVBLiveRoomListener.GetRoomListCallback} 回调拿到房间列表。
	 * 2.【观众】选择一个直播间以后，调用 enterRoom() 进入该房间。
     *
     * @param roomID 房间标识
	 * @param view 承载视频画面的控件
     * @param callback 进入房间的结果回调
     *
     */
    public abstract void enterRoom(final String roomID, final TXCloudVideoView view, final IMLVBLiveRoomListener.EnterRoomCallback callback);

    /**
     * 离开房间
     *
     * @param callback 离开房间的结果回调
     */
    public abstract void exitRoom(IMLVBLiveRoomListener.ExitRoomCallback callback);

    /**
     * 设置自定义信息
     *
     * 有时候您可能需要为房间产生一些额外的信息，此接口可以将这些信息缓存到服务器。
     *
     * @param op 执行动作，定义请查看 {@link MLVBCommonDef.CustomFieldOp}
     * @param key 自定义键
     * @param value 数值
     * @param callback  设置自定义信息完成的回调
     *
     * @note - op 为 {@link MLVBCommonDef.CustomFieldOp#SET} 时，value 可以是 String 或者 Integer 类型
     *       - op 为 {@link MLVBCommonDef.CustomFieldOp#INC} 时，value 是 Integer 类型
     *       - op 为 {@link MLVBCommonDef.CustomFieldOp#DEC} 时，value 是 Integer 类型
     */
    public abstract void setCustomInfo(final MLVBCommonDef.CustomFieldOp op, final String key, final Object value, final IMLVBLiveRoomListener.SetCustomInfoCallback callback);

    /**
     * 获取自定义信息
     *
     * @param callback 获取自定义信息回调
     */
    public abstract void getCustomInfo(final IMLVBLiveRoomListener.GetCustomInfoCallback callback);
    /// @}

	
	/////////////////////////////////////////////////////////////////////////////////
    //
    //                      主播和观众连麦
    //
    /////////////////////////////////////////////////////////////////////////////////
	/// @name 主播和观众连麦
    /// @{

	/**
     * 观众请求连麦
	 * 
	 * 主播和观众的连麦流程可以简单描述为如下几个步骤：
	 * 1. 【观众】调用 requestJoinAnchor() 向主播发起连麦请求。
	 * 2. 【主播】会收到 {@link IMLVBLiveRoomListener#onRequestJoinAnchor(AnchorInfo, String)} 的回调通知。
	 * 3. 【主播】调用 responseJoinAnchor() 确定是否接受观众的连麦请求。
	 * 4. 【观众】会收到 {@link IMLVBLiveRoomListener.RequestJoinAnchorCallback} 回调通知，可以得知请求是否被同意。
	 * 5. 【观众】如果请求被同意，则调用 startLocalPreview() 开启本地摄像头，如果 App 还没有取得摄像头和麦克风权限，会触发 UI 提示。
	 * 6. 【观众】然后调用 joinAnchor() 正式进入连麦状态。
     * 7. 【主播】一旦观众进入连麦状态，主播就会收到 {@link IMLVBLiveRoomListener#onAnchorEnter(AnchorInfo)} 通知。
	 * 8. 【主播】主播调用 startRemoteView() 就可以看到连麦观众的视频画面。
	 * 9. 【观众】如果直播间里已经有其他观众正在跟主播进行连麦，那么新加入的这位连麦观众也会收到 onAnchorJoin() 通知，用于展示（startRemoteView）其他连麦者的视频画面。
     *
     *
     * @param reason 连麦原因
     * @param callback 请求连麦的回调
     *
     * @see {@link IMLVBLiveRoomListener#onRequestJoinAnchor(AnchorInfo, String)}
     */
    public abstract void requestJoinAnchor(String reason, IMLVBLiveRoomListener.RequestJoinAnchorCallback callback);

    /**
     * 主播处理连麦请求
     *
	 * 主播在收到 {@link IMLVBLiveRoomListener#onRequestJoinAnchor(AnchorInfo, String)} 回调之后会需要调用此接口来处理观众的连麦请求。
     *
     * @param userID 观众 ID
     * @param agree true：同意；false：拒绝
     * @param reason 同意/拒绝连麦的原因描述
     *
     * @return 0：响应成功；非0：响应失败
     */
    public abstract int responseJoinAnchor(String userID, boolean agree, String reason);

	/**
     * 进入连麦状态
     *
     * 进入连麦成功后，主播和其他连麦观众会收到 {@link IMLVBLiveRoomListener#onAnchorEnter(AnchorInfo)} 通知
     *
     * @param callback 进入连麦的结果回调
     *
     */
    public abstract void joinAnchor(final IMLVBLiveRoomListener.JoinAnchorCallback callback);

    /**
     * 观众退出连麦
     *
     * 退出连麦成功后，主播和其他连麦观众会收到 {@link IMLVBLiveRoomListener#onAnchorExit(AnchorInfo)} 通知
     *
     * @param callback 退出连麦的结果回调
     */
    public abstract void quitJoinAnchor(final IMLVBLiveRoomListener.QuitAnchorCallback callback);

    /**
     * 主播踢除连麦观众
     *
     * 主播调用此接口踢除连麦观众后，被踢连麦观众会收到 {@link IMLVBLiveRoomListener#onKickoutJoinAnchor()} 回调通知
     *
     * @param userID 连麦观众 ID
     *
     * @see {@link IMLVBLiveRoomListener#onKickoutJoinAnchor()}
     */
    public abstract void kickoutJoinAnchor(String userID);
	/// @}
	
	
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      主播跨房间 PK
    //
    /////////////////////////////////////////////////////////////////////////////////
    /// @name 主播跨房间 PK
    /// @{

    /**
     * 请求跨房 PK
	 *
	 * 主播和主播之间可以跨房间 PK，两个正在直播中的主播 A 和 B，他们之间的跨房 PK 流程如下：
	 * 1. 【主播 A】调用 requestRoomPK() 向主播 B 发起连麦请求。
	 * 2. 【主播 B】会收到 {@link IMLVBLiveRoomListener#onRequestRoomPK(AnchorInfo)} 回调通知。
	 * 3. 【主播 B】调用 responseRoomPK() 确定是否接受主播 A 的 PK 请求。
	 * 4. 【主播 B】如果接受了主播 A 的要求，可以直接调用 startRemoteView() 来显示主播 A 的视频画面。
	 * 5. 【主播 A】会收到 {@link IMLVBLiveRoomListener.RequestRoomPKCallback} 回调通知，可以得知请求是否被同意。
	 * 6. 【主播 A】如果请求被同意，则可以调用 startRemoteView() 显示主播 B 的视频画面。
     *
     * @param userID 被邀约主播 ID
     * @param callback 请求跨房 PK 的结果回调
     *
     * @see {@link IMLVBLiveRoomListener#onRequestRoomPK(AnchorInfo)}
     */
    public abstract void requestRoomPK(String userID, final IMLVBLiveRoomListener.RequestRoomPKCallback callback);

    /**
     * 响应跨房 PK 请求
     *
     * 主播响应其他房间主播的 PK 请求，发起 PK 请求的主播会收到 {@link IMLVBLiveRoomListener.RequestRoomPKCallback} 回调通知。
     *
     * @param userID 发起 PK 请求的主播 ID
     * @param agree true：同意；false：拒绝
     * @param reason 同意/拒绝 PK 的原因描述
     *
     * @return 0：响应成功；非0：响应失败
     */
    public abstract int responseRoomPK(String userID, boolean agree, String reason);

    /**
     * 退出跨房 PK
	 *
	 * 当两个主播中的任何一个退出跨房 PK 状态后，另一个主播会收到 {@link IMLVBLiveRoomListener#onQuitRoomPK(AnchorInfo)} 回调通知。
     *
     * @param callback 退出跨房 PK 的结果回调
     */
    public abstract void quitRoomPK(final IMLVBLiveRoomListener.QuitRoomPKCallback callback);
    /// @}

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    视频相关接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    /// @name 视频相关接口函数
    /// @{
    /**
     * 开启本地视频的预览画面
     *
     * @param frontCamera YES：前置摄像头；NO：后置摄像头。
     * @param view 承载视频画面的控件
     */
    public abstract void startLocalPreview(boolean frontCamera, TXCloudVideoView view);

    /**
     * 停止本地视频采集及预览
     */
    public abstract void stopLocalPreview();

    /**
     * 启动渲染远端视频画面
     *
     * @param anchorInfo 对方的用户信息
     * @param view 承载视频画面的控件
     * @param callback   播放器监听器
     *
     * @note 在 onUserVideoAvailable 回调时，调用这个接口
     */
    public abstract void startRemoteView(final AnchorInfo anchorInfo, final TXCloudVideoView view, final IMLVBLiveRoomListener.PlayCallback callback);

    /**
     * 停止渲染远端视频画面
     *
     * @param anchorInfo 对方的用户信息
     */
    public abstract void stopRemoteView(final AnchorInfo anchorInfo);

    /**
     * 启动录屏。
     *
     */
    public abstract void startScreenCapture();

    /**
     * 结束录屏。
     *
     */
    public abstract void stopScreenCapture();
    /// @}

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                    音频相关接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    /// @name 音频相关接口函数
    /// @{

    /**
     * 是否屏蔽本地音频
     *
     * @param mute true：屏蔽 false：开启
     */
    public abstract void muteLocalAudio(boolean mute);

    /**
     * 设置指定用户是否静音
     *
     * @param userID 对方的用户标识
     * @param mute true：静音 false：非静音
     */
    public abstract void muteRemoteAudio(String userID, boolean mute);

    /**
     * 设置所有远端用户是否静音
     *
     * @param mute true：静音 false：非静音
     */
    public abstract void muteAllRemoteAudio(boolean mute);

    /// @}


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      摄像头相关接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    /// @name 摄像头相关接口函数
    /// @{

    /**
     * 切换摄像头
     */
    public abstract void switchCamera();

    /**
     * 设置摄像头缩放因子（焦距）
     *
     * @param distance 取值范围 1 - 5 ，当为1的时候为最远视角（正常镜头），当为5的时候为最近视角（放大镜头），这里最大值推荐为5，超过5后视频数据会变得模糊不清
     */
    public abstract boolean setZoom(int distance);

    /**
     * 开关闪光灯
     *
     * @param enable true：开启；false：关闭
     */
    public abstract boolean enableTorch(boolean enable);
	
	/**
     * 主播屏蔽摄像头期间需要显示的等待图片
	 *
	 * 当主播屏蔽摄像头，或者由于 App 切入后台无法使用摄像头的时候，我们需要使用一张等待图片来提示观众“主播暂时离开，请不要走开”。
     *
     * @param bitmap 位图
     */
    public abstract void setCameraMuteImage(Bitmap bitmap);

    /**
     * 主播屏蔽摄像头期间需要显示的等待图片
	 *
	 * 当主播屏蔽摄像头，或者由于 App 切入后台无法使用摄像头的时候，我们需要使用一张等待图片来提示观众“主播暂时离开，请不要走开”。
     *
     * @param id 设置默认显示图片的资源文件
     */
    public abstract void setCameraMuteImage(final int id);

    /// @}

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      美颜滤镜相关接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    /// @name 美颜滤镜相关接口函数
    /// @{

    public abstract TXBeautyManager getBeautyManager();

    /**
     * 设置美颜、美白、红润效果级别
     *
     * @param beautyStyle 美颜风格，三种美颜风格：0 ：光滑；1：自然；2：朦胧
     * @param beautyLevel 美颜级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显
     * @param whitenessLevel 美白级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显
     * @param ruddinessLevel 红润级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显
     */
    @Deprecated
    public abstract boolean setBeautyStyle(int beautyStyle , int beautyLevel, int whitenessLevel, int ruddinessLevel);

    /**
     * 设置指定素材滤镜特效
     *
     * @param image 指定素材，即颜色查找表图片。注意：一定要用 png 格式！！！
     */
    @Deprecated
    public abstract void setFilter(Bitmap image);

    /**
     * 设置滤镜浓度
     *
     * @param concentration 从0到1，越大滤镜效果越明显，默认取值0.5
     */
    @Deprecated
    public abstract void setFilterConcentration(float concentration);

    /**
     * 添加水印，height 不用设置，sdk 内部会根据水印宽高比自动计算 height
     *
     * @param image 水印图片 null 表示清除水印
     * @param x     归一化水印位置的 X 轴坐标，取值[0，1]
     * @param y     归一化水印位置的 Y 轴坐标，取值[0，1]
     * @param width 归一化水印宽度，取值[0，1]
     *
     */
    public abstract void setWatermark(Bitmap image, float x, float y, float width);

    /**
     * 设置动效贴图
     *
     * @param filePaht 动态贴图文件路径
     */
    @Deprecated
    public abstract void setMotionTmpl(String filePaht);

    /**
     * 设置绿幕文件
     *
     * 目前图片支持 jpg/png，视频支持 mp4/3gp 等 Android 系统支持的格式
     *
     * @param file 绿幕文件位置，支持两种方式：
     *             1.资源文件放在 assets 目录，path 直接取文件名
     *             2.path 取文件绝对路径
     * @return false：调用失败；true：调用成功
     *
     * @note API 要求18
     */
    @Deprecated
    public abstract boolean setGreenScreenFile(String file);

    /**
     * 设置大眼效果
     *
     * @param level 大眼等级取值为 0 ~ 9。取值为0时代表关闭美颜效果。默认值：0
     */
    @Deprecated
    public abstract void setEyeScaleLevel(int level);

    /**
     * 设置 V 脸（特权版本有效，普通版本设置此参数无效）
     *
     * @param level V 脸级别取值范围 0 ~ 9。数值越大，效果越明显。默认值：0
     */
    @Deprecated
    public abstract void setFaceVLevel(int level);

    /**
     * 设置瘦脸效果
     *
     * @param level 瘦脸等级取值为 0 ~ 9。取值为0时代表关闭美颜效果。默认值：0
     */
    @Deprecated
    public abstract void setFaceSlimLevel(int level);

    /**
     * 设置短脸（特权版本有效，普通版本设置此参数无效）
     *
     * @param level 短脸级别取值范围 0 ~ 9。 数值越大，效果越明显。默认值：0
     */
    @Deprecated
    public abstract void setFaceShortLevel(int level);

    /**
     * 设置下巴拉伸或收缩（特权版本有效，普通版本设置此参数无效）
     *
     * @param chinLevel 下巴拉伸或收缩级别取值范围 -9 ~ 9。数值越大，拉伸越明显。默认值：0
     */
    @Deprecated
    public abstract void setChinLevel(int chinLevel);

    /**
     * 设置瘦鼻（特权版本有效，普通版本设置此参数无效）
     *
     * @param noseSlimLevel 瘦鼻级别取值范围 0 ~ 9。数值越大，效果越明显。默认值：0
     */
    @Deprecated
    public abstract void setNoseSlimLevel(int noseSlimLevel);

    /**
     * 调整曝光
     *
     * @param value 曝光比例，表示该手机支持最大曝光调整值的比例，取值范围从-1 - 1。
     *              负数表示调低曝光，-1是最小值；正数表示调高曝光，1是最大值；0表示不调整曝光
     */
    public abstract void setExposureCompensation(float value);

    /// @}

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      消息发送接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    /// @name 消息发送接口函数
    /// @{

    /**
     * 发送文本消息
     *
     * @param message 文本消息
     * @param callback 发送结果回调
     *
     * @see {@link IMLVBLiveRoomListener#onRecvRoomTextMsg(String, String, String, String, String)}
     */
    public abstract void sendRoomTextMsg(String message, final IMLVBLiveRoomListener.SendRoomTextMsgCallback callback);

    /**
     * 发送自定义文本消息
     *
     * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
     * @param message 文本消息
     * @param callback 发送结果回调
     * @see {@link IMLVBLiveRoomListener#onRecvRoomCustomMsg(String, String, String, String, String, String)}
     */
    public abstract void sendRoomCustomMsg(String cmd, String message, final IMLVBLiveRoomListener.SendRoomCustomMsgCallback callback);

    /// @}

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      背景混音相关接口函数
    //
    /////////////////////////////////////////////////////////////////////////////////

    /// @name 背景混音相关接口函数
    /// @{

    /**
     * 播放背景音乐
     *
     * @param path 背景音乐文件路径
     * @return true：播放成功；false：播放失败
     */
    public abstract boolean playBGM(String path);

    /**
     * 设置背景音乐的回调接口
     *
     * @param notify 回调接口
     */
    public abstract void setBGMNofify(TXLivePusher.OnBGMNotify notify);

    /**
     * 停止播放背景音乐
     */
    public abstract void stopBGM();

    /**
     * 暂停播放背景音乐
     */
    public abstract void pauseBGM();

    /**
     * 继续播放背景音乐
     */
    public abstract void resumeBGM();

    /**
     * 获取音乐文件总时长
     *
     * @param path 音乐文件路径，如果 path 为空，那么返回当前正在播放的 music 时长
     *
     * @return 成功返回时长，单位毫秒，失败返回-1
     */
    public abstract int getBGMDuration(String path);

    /**
     * 设置麦克风的音量大小，播放背景音乐混音时使用，用来控制麦克风音量大小
     *
     * @param volume: 音量大小，100为正常音量，建议值为0 - 200
     */
    public abstract void setMicVolumeOnMixing(int volume);

    /**
     * 设置背景音乐的音量大小，播放背景音乐混音时使用，用来控制背景音音量大小
     *
     * @param volume 音量大小，100为正常音量，建议值为0 - 200，如果需要调大背景音量可以设置更大的值
     */
    public abstract void setBGMVolume(int volume);

    /**
     * 设置混响效果
     *
     * @param reverbType 混响类型，详见
     *                      {@link TXLiveConstants#REVERB_TYPE_0 } (关闭混响)
     *                      {@link TXLiveConstants#REVERB_TYPE_1 } (KTV)
     *                      {@link TXLiveConstants#REVERB_TYPE_2 } (小房间)
     *                      {@link TXLiveConstants#REVERB_TYPE_3 } (大会堂)
     *                      {@link TXLiveConstants#REVERB_TYPE_4 } (低沉)
     *                      {@link TXLiveConstants#REVERB_TYPE_5 } (洪亮)
     *                      {@link TXLiveConstants#REVERB_TYPE_6 } (磁性)
     */
    public abstract void setReverbType(int reverbType);

    /**
     * 设置变声类型
     *
     * @param voiceChangerType 变声类型，详见 TXVoiceChangerType
     */
    public abstract void setVoiceChangerType(int voiceChangerType);

    /**
     * 设置背景音乐的音调。
     *
     * 该接口用于混音处理，比如将背景音乐与麦克风采集到的声音混合后播放。
     *
     * @param pitch 音调，0为正常音调，范围是 -1 - 1。
     */
    public abstract void setBGMPitch(float pitch);

    /**
     * 指定背景音乐的播放位置
     *
     * @note 请尽量避免频繁地调用该接口，因为该接口可能会再次读写 BGM 文件，耗时稍高。
     *       例如：当配合进度条使用时，请在进度条拖动完毕的回调中调用，而避免在拖动过程中实时调用。
     *
     * @param position 背景音乐的播放位置，单位ms。
     *
     * @return 结果是否成功，true：成功；false：失败。
     */
    public abstract boolean setBGMPosition(int position);

    /// @}
}
