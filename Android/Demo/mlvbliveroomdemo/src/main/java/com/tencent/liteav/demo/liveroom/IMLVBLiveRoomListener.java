package com.tencent.liteav.demo.liveroom;

import android.os.Bundle;

import com.tencent.liteav.demo.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.liveroom.roomutil.commondef.RoomInfo;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.Map;

/**
 * MLVBLiveRoom 事件回调
 * <p>
 * 包括房间关闭、Debug 事件信息、出错说明等。
 */
public interface IMLVBLiveRoomListener {

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                       错误 & 警告
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 错误回调
     * <p>
     * SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示
     *
     * @param errCode   错误码
     * @param errMsg    错误信息
     * @param extraInfo 额外信息，如错误发生的用户，一般不需要关注，默认是本地错误
     */
    void onError(int errCode, String errMsg, Bundle extraInfo);

    /**
     * 警告回调
     *
     * @param warningCode 错误码 TRTCWarningCode
     * @param warningMsg  警告信息
     * @param extraInfo   额外信息，如警告发生的用户，一般不需要关注，默认是本地错误
     */
    void onWarning(int warningCode, String warningMsg, Bundle extraInfo);

    void onDebugLog(String log);

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      房间事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 房间被销毁的回调
     * <p>
     * 主播退房时，房间内的所有用户都会收到此通知
     *
     * @param roomID 房间 ID
     */
    void onRoomDestroy(String roomID);

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      主播 & 观众的进出事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 收到新主播进房通知
     * <p>
     * 房间内的主播（和连麦中的观众）会收到新主播的进房事件，您可以调用 {@link MLVBLiveRoom#startRemoteView(AnchorInfo, TXCloudVideoView, PlayCallback)} 显示该主播的视频画面。
     *
     * @param anchorInfo 新进房用户信息
     * @note 直播间里的普通观众不会收到主播加入和推出的通知。
     */
    void onAnchorEnter(AnchorInfo anchorInfo);

    /**
     * 收到主播退房通知
     * <p>
     * 房间内的主播（和连麦中的观众）会收到新主播的退房事件，您可以调用 {@link MLVBLiveRoom#stopRemoteView(AnchorInfo)} 关闭该主播的视频画面。
     *
     * @param anchorInfo 退房用户信息
     * @note 直播间里的普通观众不会收到主播加入和推出的通知。
     */
    void onAnchorExit(AnchorInfo anchorInfo);

    /**
     * 收到观众进房通知
     *
     * @param audienceInfo 进房观众信息
     */
    void onAudienceEnter(AudienceInfo audienceInfo);

    /**
     * 收到观众退房通知
     *
     * @param audienceInfo 退房观众信息
     */
    void onAudienceExit(AudienceInfo audienceInfo);


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      主播和观众连麦事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 主播收到观众连麦请求时的回调
     *
     * @param anchorInfo 观众信息
     * @param reason     连麦原因描述
     */
    void onRequestJoinAnchor(AnchorInfo anchorInfo, String reason);

    /**
     * 连麦观众收到被踢出连麦的通知
     * <p>
     * 连麦观众收到被主播踢除连麦的消息，您需要调用 {@link MLVBLiveRoom#kickoutJoinAnchor(String)} 来退出连麦
     */
    void onKickoutJoinAnchor();

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      主播 PK 事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 收到请求跨房 PK 通知
     * <p>
     * 主播收到其他房间主播的 PK 请求
     * 如果同意 PK ，您需要调用 {@link MLVBLiveRoom#startRemoteView(AnchorInfo, TXCloudVideoView, PlayCallback)}  接口播放邀约主播的流
     *
     * @param anchorInfo 发起跨房连麦的主播信息
     */
    void onRequestRoomPK(AnchorInfo anchorInfo);

    /**
     * 收到断开跨房 PK 通知
     */
    void onQuitRoomPK(AnchorInfo anchorInfo);

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      消息事件回调
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 收到文本消息
     *
     * @param roomID     房间 ID
     * @param userID     发送者 ID
     * @param userName   发送者昵称
     * @param userAvatar 发送者头像
     * @param message    文本消息
     */
    void onRecvRoomTextMsg(String roomID, String userID, String userName, String userAvatar, String message);

    /**
     * 收到自定义消息
     *
     * @param roomID     房间 ID
     * @param userID     发送者 ID
     * @param userName   发送者昵称
     * @param userAvatar 发送者头像
     * @param cmd        自定义 cmd
     * @param message    自定义消息内容
     */
    void onRecvRoomCustomMsg(String roomID, String userID, String userName, String userAvatar, String cmd, String message);

    /**
     * 登录结果回调接口
     */
    interface LoginCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 获取房间列表回调接口
     */
    interface GetRoomListCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         *
         * @param roomInfoList 房间列表
         */
        void onSuccess(ArrayList<RoomInfo> roomInfoList);
    }

    /**
     * 获取观众列表回调接口
     * <p>
     * 观众进房时，后台会将其信息加入观众列表中，观众列表最大保存30名观众信息。
     */
    interface GetAudienceListCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         *
         * @param audienceInfoList 观众列表
         */
        void onSuccess(ArrayList<AudienceInfo> audienceInfoList);
    }

    /**
     * 创建房间的结果回调接口
     */
    interface CreateRoomCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         *
         * @param RoomID 房间号标识
         */
        void onSuccess(String RoomID);
    }

    /**
     * 进入房间的结果回调接口
     */
    interface EnterRoomCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 离开房间的结果回调接口
     */
    interface ExitRoomCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 观众请求连麦的结果回调接口
     */
    interface RequestJoinAnchorCallback {
        /**
         * 主播接受连麦
         */
        void onAccept();

        /**
         * 主播拒绝连麦
         *
         * @param reason 拒绝原因
         */
        void onReject(String reason);

        /**
         * 请求超时
         */
        void onTimeOut();

        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);
    }

    /**
     * 进入连麦的结果回调接口
     */
    interface JoinAnchorCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码 RequestRoomPKCallback
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 退出连麦的结果回调接口
     */
    interface QuitAnchorCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 请求跨房 PK 的结果回调接口
     */
    interface RequestRoomPKCallback {
        /**
         * 主播接受连麦
         *
         * @param anchorInfo 被邀请 PK 主播的信息
         */
        void onAccept(AnchorInfo anchorInfo);

        /**
         * 拒绝 PK
         *
         * @param reason 拒绝原因
         */
        void onReject(String reason);

        /**
         * 请求超时
         */
        void onTimeOut();

        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);
    }

    /**
     * 退出跨房 PK 的结果回调接口
     */
    interface QuitRoomPKCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 播放器回调接口
     */
    interface PlayCallback {
        /**
         * 开始回调
         */
        void onBegin();

        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 其他事件回调
         *
         * @param event 事件 ID
         * @param param 事件附加信息
         */
        void onEvent(int event, Bundle param);
    }

    /**
     * 发送文本消息回调接口
     */
    interface SendRoomTextMsgCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */

        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 发送自定义消息回调接口
     */
    interface SendRoomCustomMsgCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 设置自定义信息回调接口
     */
    interface SetCustomInfoCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 成功回调
         */
        void onSuccess();
    }

    /**
     * 获取自定义信息回调接口
     */
    interface GetCustomInfoCallback {
        /**
         * 错误回调
         *
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        /**
         * 获取自定义信息的回调
         *
         * @param customInfo 自定义信息
         */
        void onGetCustomInfo(Map<String, Object> customInfo);
    }
}
