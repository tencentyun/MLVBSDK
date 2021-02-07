package com.tencent.liteav.demo.liveroom.roomutil.im;

import android.content.Context;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMCustomElem;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMTextElem;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMSimpleMsgListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.demo.liveroom.R;

import java.util.ArrayList;
import java.util.FormatFlagsConversionMismatchException;
import java.util.List;


/**
 * Created by jac on 2017/11/4.
 * Copyright © 2013-2017 Tencent Cloud. All Rights Reserved.
 */
public class IMMessageMgr {
    private static final String TAG = "IMMessageMgr";

    private Context                         mContext;
    private Handler                         mHandler;

    private static boolean                  mConnectSuccess = false;
    private boolean                         mLoginSuccess = false;

    private String                          mSelfUserID;
    private String                          mSelfUserSig;
    private String                          mGroupID;
    private IMMessageLoginCallback          mIMLoginListener;
    private IMMessageCallback               mMessageListener;
    private MLiveRoomSimpleMsgListener      mSimpleListener;
    private MLiveRoomGroupListener          mGroupListener;
    /**
     * 函数级公共Callback定义
     */
    public interface Callback{
        void onError(int code, String errInfo);
        void onSuccess(Object ...args);
    }

    /**
     * 模块回调Listener定义
     */
    public interface IMMessageListener {

        /**
         * IM连接成功
         */
        void onConnected();

        /**
         * IM断开连接
         */
        void onDisconnected();

        /**
         * IM群组里推流者成员变化通知
         */
        void onPusherChanged();

        /**
         * 收到群文本消息
         */
        void onGroupTextMessage(String groupID, String senderID, String userName, String headPic, String message);

        /**
         * 收到自定义的群消息
         */
        void onGroupCustomMessage(String groupID, String senderID, String message);

        /**
         * 收到自定义的C2C消息
         */
        void onC2CCustomMessage(String sendID, String cmd, String message);

        /**
         * IM群组销毁回调
         */
        void onGroupDestroyed(final String groupID);

        /**
         * 日志回调
         */
        void onDebugLog(String log);

        /**
         * 用户进群通知
         *
         * @param groupID 群标识
         * @param users   进群用户信息列表
         */
        void onGroupMemberEnter(String groupID, List<V2TIMGroupMemberInfo> users);

        /**
         * 用户退群通知
         *
         * @param groupID 群标识
         * @param users   退群用户信息列表
         */
        void onGroupMemberExit(String groupID, V2TIMGroupMemberInfo users);


        /**
         * 用户被强制下线通知
         */
        void onForceOffline();
    }

    public IMMessageMgr(final Context context) {
        this.mContext = context.getApplicationContext();
        this.mHandler = new Handler(this.mContext.getMainLooper());
        this.mMessageListener = new IMMessageCallback(null);
        mSimpleListener = new MLiveRoomSimpleMsgListener();
        mGroupListener = new MLiveRoomGroupListener();
    }

    /**
     * 设置回调
     *
     * @param listener
     */
    public void setIMMessageListener(IMMessageListener listener) {
        this.mMessageListener.setListener(listener);
    }

    /**
     * 初始化
     *
     * @param userID   用户ID
     * @param userSig  签名
     * @param appID    appID
     * @param callback
     */
    public void initialize(final String userID, final String userSig, final int appID, final Callback callback) {
        if (userID == null || userSig == null) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_parameter_error_hint));
            if (callback != null) {
                callback.onError(-1, mContext.getString(R.string.mlvb_parameter_error));
            }
            return;
        }

        this.mSelfUserID = userID;
        this.mSelfUserSig = userSig;

        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                V2TIMSDKConfig config = new V2TIMSDKConfig();
                config.setLogLevel(V2TIMSDKConfig.V2TIM_LOG_DEBUG);
                boolean isInitIMSDK = V2TIMManager.getInstance().initSDK(mContext, appID, config, new V2TIMSDKListener() {
                    @Override
                    public void onConnecting() {
                    }

                    @Override
                    public void onConnectSuccess() {
                        mMessageListener.onConnected();
                        mConnectSuccess = true;
                    }

                    @Override
                    public void onConnectFailed(int code, String error) {
                        printDebugLog("disconnect: %s(%d)", error, code);
                        if (mLoginSuccess) {
                            if (mMessageListener != null) {
                                mMessageListener.onDisconnected();
                            }
                        } else {
                            if (callback != null) {
                                callback.onError(code, error);
                            }
                        }
                        mConnectSuccess = false;
                    }

                    @Override
                    public void onKickedOffline() {
                        if (mMessageListener != null){
                            mMessageListener.onForceOffline();
                        }
                    }

                    @Override
                    public void onUserSigExpired() {
                        if (mMessageListener != null){
                            mMessageListener.onForceOffline();
                        }

                    }
                });

                if (isInitIMSDK) {
                    login(new Callback() {
                        @Override
                        public void onError(int code, String errInfo) {
                            printDebugLog("login failed: %s(%d)", errInfo, code);
                            mLoginSuccess = false;
                            callback.onError(code, mContext.getString(R.string.mlvb_im_login_fail));
                        }

                        @Override
                        public void onSuccess(Object... args) {
                            printDebugLog("login success");
                            mLoginSuccess = true;
                            mConnectSuccess = true;
                            callback.onSuccess();
                        }
                    });
                } else {
                    printDebugLog("init failed");
                    callback.onError(-1, mContext.getString(R.string.mlvb_im_init_fail));
                }
            }
        });
    }

    public void runOnHandlerThread(Runnable runnable) {
        Handler handler = mHandler;
        if (handler != null) {
            handler.post(runnable);
        } else {
            Log.e(TAG, "runOnHandlerThread -> Handler == null");
        }
    }

    /**
     * 反初始化
     */
    public void unInitialize() {
        mContext = null;
        mHandler = null;

        if (mIMLoginListener != null) {
            mIMLoginListener.clean();
            mIMLoginListener = null;
        }
        if (mMessageListener != null) {
            mMessageListener.setListener(null);
        }

        logout(null);
    }

    /**
     * 加入IM群组
     *
     * @param groupId  群ID
     * @param callback
     */
    public void joinGroup(final String groupId, final Callback callback) {
        if (!mLoginSuccess) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_im_no_init_hint));
            if (callback != null) {
                callback.onError(-1, mContext.getString(R.string.mlvb_im_no_init));
            }
            return;
        }

        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                V2TIMManager.getInstance().joinGroup(groupId, "who care?", new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        printDebugLog(mContext.getString(R.string.mlvb_join_group_fail), groupId, s, i);
                        if (i == 10010) {
                            s = mContext.getString(R.string.mlvb_room_disbanded);
                        }
                        callback.onError(i, s);
                    }

                    @Override
                    public void onSuccess() {
                        V2TIMManager.getInstance().addSimpleMsgListener(mSimpleListener);
                        V2TIMManager.getInstance().setGroupListener(mGroupListener);

                        printDebugLog(mContext.getString(R.string.mlvb_join_group_suceess), groupId);
                        mGroupID = groupId;
                        callback.onSuccess();
                    }
                });
            }
        });
    }

    /**
     * 退出IM群组
     *
     * @param groupId  群ID
     * @param callback
     */
    public void quitGroup(final String groupId, final Callback callback) {
        if (!mLoginSuccess) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_im_no_init_hint));
            if (callback != null) {
                callback.onError(-1, mContext.getString(R.string.mlvb_im_no_init));
            }
            return;
        }

        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                V2TIMManager.getInstance().quitGroup(groupId, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        if (i == 10010) {
                            printDebugLog(mContext.getString(R.string.mlvb_group_disband), groupId);
                            onSuccess();
                        } else {
                            printDebugLog(mContext.getString(R.string.mlvb_group_quit_fail), groupId, s, i);
                            callback.onError(i, s);
                        }
                    }

                    @Override
                    public void onSuccess() {
                        V2TIMManager.getInstance().removeSimpleMsgListener(mSimpleListener);
                        V2TIMManager.getInstance().setGroupListener(null);

                        printDebugLog(mContext.getString(R.string.mlvb_group_quit_success), groupId);
                        mGroupID = groupId;
                        callback.onSuccess();
                    }
                });
            }
        });
    }

    public void createGroup(final String groupId, final String groupName, final Callback callback) {
        if (!mLoginSuccess) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_im_no_init));
            if (callback != null) {
                callback.onError(-1, mContext.getString(R.string.mlvb_im_no_init));
            }
            return;
        }
        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                V2TIMManager.getInstance().createGroup(V2TIMManager.GROUP_TYPE_AVCHATROOM, groupId, groupName, new V2TIMValueCallback<String>(){
                    @Override
                    public void onError(int i, String s) {
                        printDebugLog(mContext.getString(R.string.mlvb_group_create_fail), groupId, s, i);
                        if (i == 10036) {
                            String createRoomErrorMsg = mContext.getString(R.string.mlvb_group_create_hint);
                            TXCLog.e(TAG, createRoomErrorMsg);
                            printDebugLog(createRoomErrorMsg);
                        }
                        if (i == 10025) {
                            mGroupID = groupId;
                        }
                        callback.onError(i, s);
                    }

                    @Override
                    public void onSuccess(String s) {
                        V2TIMManager.getInstance().addSimpleMsgListener(mSimpleListener);
                        V2TIMManager.getInstance().setGroupListener(mGroupListener);

                        printDebugLog(mContext.getString(R.string.mlvb_group_create_success), groupId);
                        mGroupID = groupId;
                        callback.onSuccess();
                    }
                });
            }
        });
    }

    /**
     * 销毁IM群组
     *
     * @param groupId  群ID
     * @param callback
     */
    public void destroyGroup(final String groupId, final Callback callback) {
        if (!mLoginSuccess) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_im_no_init));
            if (callback != null) {
                callback.onError(-1, mContext.getString(R.string.mlvb_im_no_init));
            }
            return;
        }

        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                V2TIMManager.getInstance().dismissGroup(groupId, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        printDebugLog(mContext.getString(R.string.mlvb_group_destroy_fail), groupId, s, i);
                        callback.onError(i, s);
                    }

                    @Override
                    public void onSuccess() {
                        V2TIMManager.getInstance().removeSimpleMsgListener(mSimpleListener);
                        V2TIMManager.getInstance().setGroupListener(null);
                        printDebugLog(mContext.getString(R.string.mlvb_group_destroy_success), groupId);
                        mGroupID = groupId;
                        callback.onSuccess();
                    }
                });
            }
        });
    }

    /**
     * 发送IM群文本消息
     *
     * @param userName 发送者用户名
     * @param headPic  发送者头像
     * @param text     文本内容
     * @param callback
     */
    public void sendGroupTextMessage(final @NonNull String userName, final @NonNull String headPic, final @NonNull String text, final Callback callback) {
        if (!mLoginSuccess) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_im_no_init));
            if (callback != null) {
                callback.onError(-1, mContext.getString(R.string.mlvb_im_no_init));
            }
            return;
        }

        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                TIMMessage message = new TIMMessage();
                try {
                    CommonJson<UserInfo> txtHeadMsg = new CommonJson<UserInfo>();
                    txtHeadMsg.cmd = "CustomTextMsg";
                    txtHeadMsg.data = new UserInfo();
                    txtHeadMsg.data.nickName = userName;
                    txtHeadMsg.data.headPic = headPic;
                    String strCmdMsg = new Gson().toJson(txtHeadMsg, new TypeToken<CommonJson<UserInfo>>() {
                    }.getType());

                    TIMCustomElem customElem = new TIMCustomElem();
                    customElem.setData(strCmdMsg.getBytes("UTF-8"));

                    TIMTextElem textElem = new TIMTextElem();
                    textElem.setText(text);

                    message.addElement(customElem);
                    message.addElement(textElem);
                } catch (Exception e) {
                    printDebugLog(mContext.getString(R.string.mlvb_group_send_fail_hint), mGroupID);
                    if (callback != null) {
                        callback.onError(-1, mContext.getString(R.string.mlvb_group_send_fail));
                    }
                    return;
                }

                TIMConversation conversation = TIMManager.getInstance().getConversation(TIMConversationType.Group, mGroupID);
                conversation.sendMessage(message, new TIMValueCallBack<TIMMessage>() {
                    @Override
                    public void onError(int i, String s) {
                        printDebugLog(mContext.getString(R.string.mlvb_group_send_fail_hint_s_d), mGroupID, s, i);
                        if (callback != null) {
                            callback.onError(i, s);
                        }
                    }

                    @Override
                    public void onSuccess(TIMMessage timMessage) {
                        printDebugLog(mContext.getString(R.string.mlvb_group_send_success));
                        if (callback != null) {
                            callback.onSuccess();
                        }
                    }
                });
            }
        });
    }

    /**
     * 发送自定义群消息
     *
     * @param content  自定义消息的内容
     * @param callback
     */
    public void sendGroupCustomMessage(final @NonNull String content, final Callback callback) {
        if (!mLoginSuccess) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_im_no_init));
            if (callback != null)
                callback.onError(-1, mContext.getString(R.string.mlvb_im_no_init));
            return;
        }

        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {

                V2TIMManager.getInstance().sendGroupCustomMessage(content.getBytes(), mGroupID, V2TIMMessage.V2TIM_PRIORITY_NORMAL, new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onError(int i, String s) {
                        printDebugLog(mContext.getString(R.string.mlvb_custom_group_msg_send_s_d), mGroupID, s, i);
                        if (callback != null) {
                            callback.onError(i, s);
                        }
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        printDebugLog(mContext.getString(R.string.mlvb_custom_group_msg_success));
                        if (callback != null) {
                            callback.onSuccess();
                        }
                    }
                });
            }
        });
    }

    /**
     * 发送CC（端到端）自定义消息
     *
     * @param toUserID 接收者userID
     * @param content  自定义消息的内容
     * @param callback
     */
    public void sendC2CCustomMessage(final @NonNull String toUserID, final @NonNull String content, final Callback callback) {
        if (!mLoginSuccess) {
            mMessageListener.onDebugLog(mContext.getString(R.string.mlvb_im_no_init));
            if (callback != null)
                callback.onError(-1, mContext.getString(R.string.mlvb_im_no_init));
            return;
        }

        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {

                V2TIMManager.getInstance().sendC2CCustomMessage(content.getBytes(), toUserID,  new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onError(int i, String s) {
                        printDebugLog(mContext.getString(R.string.mlvb_custom_msg_fail_s_d), toUserID, s, i);
                        if (callback != null)
                            callback.onError(i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        printDebugLog(mContext.getString(R.string.mlvb_custom_msg_success));

                        if (callback != null)
                            callback.onSuccess();
                    }
                });
            }
        });
    }

    public void getGroupMembers(final String groupId, final int maxSize, final V2TIMValueCallback<List<V2TIMUserFullInfo>> cb) {
        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                V2TIMManager.getGroupManager().getGroupMemberList(groupId, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_MEMBER, 0,
                        new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
                            @Override
                            public void onError(int code, String desc) {
                            }

                            @Override
                            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                                ArrayList<String> users = new ArrayList<>();
                                int count = 0;
                                for (V2TIMGroupMemberFullInfo info : v2TIMGroupMemberInfoResult.getMemberInfoList()) {
                                    if (count < maxSize) {
                                        users.add(info.getUserID());
                                        count++;
                                    } else {
                                        break;
                                    }
                                }
                                V2TIMManager.getInstance().getUsersInfo(users, cb);

                            }
                        });

            }
        });
    }

    public void setSelfProfile(final String nickname, final String faceURL) {
        if (nickname == null && faceURL == null) {
            return;
        }
        this.runOnHandlerThread(new Runnable() {
            @Override
            public void run() {
                V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
                v2TIMUserFullInfo.setNickname(nickname);
                v2TIMUserFullInfo.setFaceUrl(faceURL);
                V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
                    @Override
                    public void onError(int code, String desc) {
                        Log.e(TAG, "modifySelfProfile failed: " + code + " desc" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        Log.e(TAG, "modifySelfProfile success");
                    }
                });
            }
        });
    }

    public void getUserProfile(final ArrayList<String> userIDs, final V2TIMValueCallback<List<V2TIMUserFullInfo>> cb) {
        V2TIMManager.getInstance().getUsersInfo(userIDs, cb);
    }


    private void onRecvC2COrGroupCustomMessage(final TXUserInfo txUserInfo, byte[] customData) {
        String data = new String(customData);
        Log.i(TAG, "im msg dump, sender id:" +  txUserInfo.userId + " data:" + data);
        if (!TextUtils.isEmpty(data)) {
            try {
                CommonJson<Object> commonJson = new Gson().fromJson(data, new TypeToken<CommonJson<Object>>() {}.getType());
                if (commonJson.cmd != null) {
                    if (commonJson.cmd.equalsIgnoreCase("linkmic") || commonJson.cmd.equalsIgnoreCase("pk")) {
                        mMessageListener.onC2CCustomMessage(txUserInfo.userId, commonJson.cmd, new Gson().toJson(commonJson.data));
                    } else if (commonJson.cmd.equalsIgnoreCase("CustomCmdMsg")) {
                        mMessageListener.onGroupCustomMessage(mGroupID, txUserInfo.userId, new Gson().toJson(commonJson.data));
                    } else if (commonJson.cmd.equalsIgnoreCase("notifyPusherChange")) {
                        mMessageListener.onPusherChanged();
                    }
                }
            } catch (JsonSyntaxException e) {
                Log.e(TAG, "im msg parse json error: " + e.toString());
            }
        }
    }

    private void login(final Callback cb) {
        if (mSelfUserID == null || mSelfUserSig == null) {
            if (cb != null) {
                cb.onError(-1, mContext.getString(R.string.mlvb_no_user_id));
            }
            return;
        }

        Log.i(TAG, "start login: userId = " + this.mSelfUserID);

        final long loginStartTS = System.currentTimeMillis();

        mIMLoginListener = new IMMessageLoginCallback(loginStartTS, cb);

        V2TIMManager.getInstance().login(this.mSelfUserID, this.mSelfUserSig, mIMLoginListener);
    }

    private void logout(final Callback callback) {
        if (!mLoginSuccess) {
            return;
        }

        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "logout fail, code:" + i + " msg:" + s);
            }

            @Override
            public void onSuccess() {
                Log.e(TAG, "logout im success.");
            }
        });
    }

    private void printDebugLog(String format, Object... args) {
        String log;
        try {
            log = String.format(format, args);
            Log.e(TAG, log);
            if (mMessageListener != null) {
                mMessageListener.onDebugLog(log);
            }
        } catch (FormatFlagsConversionMismatchException e) {
            e.printStackTrace();
        }
    }

    /**
     * 辅助类 IM Login Listener
     */
    private class IMMessageLoginCallback implements V2TIMCallback {
        private long loginStartTS;
        private Callback callback;

        public IMMessageLoginCallback(long ts, Callback cb) {
            loginStartTS = ts;
            callback = cb;
        }

        public void clean() {
            loginStartTS = 0;
            callback = null;
        }

        @Override
        public void onError(int i, String s) {
            if (callback != null) {
                callback.onError(i, s);
            }
        }

        @Override
        public void onSuccess() {
            printDebugLog("login success, time cost %.2f secs", (System.currentTimeMillis() - loginStartTS) / 1000.0);
            if (callback != null) {
                callback.onSuccess();
            }
        }
    }

    ;

    /**
     * 辅助类 IM Message Listener
     */
    private class IMMessageCallback implements IMMessageListener {
        private IMMessageListener listener;

        public IMMessageCallback(IMMessageListener listener) {
            this.listener = listener;
        }

        public void setListener(IMMessageListener listener) {
            this.listener = listener;
        }

        @Override
        public void onConnected() {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onConnected();
                    }
                }
            });
        }

        @Override
        public void onDisconnected() {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onDisconnected();
                    }
                }
            });
        }

        @Override
        public void onPusherChanged() {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onPusherChanged();
                    }
                }
            });
        }

        @Override
        public void onGroupDestroyed(final String groupID) {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onGroupDestroyed(groupID);
                    }
                }
            });
        }

        @Override
        public void onDebugLog(final String line) {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onDebugLog("[IM] " + line);
                    }
                }
            });
        }

        @Override
        public void onGroupMemberEnter(final String groupID, final List<V2TIMGroupMemberInfo> users) {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onGroupMemberEnter(groupID, users);
                    }
                }
            });
        }

        @Override
        public void onGroupMemberExit(final String groupID, final V2TIMGroupMemberInfo users) {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onGroupMemberExit(groupID, users);
                    }
                }
            });
        }

        @Override
        public void onForceOffline() {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onForceOffline();
                    }
                }
            });
        }

        @Override
        public void onGroupTextMessage(final String roomID, final String senderID, final String userName, final String headPic, final String message) {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onGroupTextMessage(roomID, senderID, userName, headPic, message);
                    }
                }
            });
        }

        @Override
        public void onGroupCustomMessage(final String groupID, final String senderID, final String message) {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onGroupCustomMessage(groupID, senderID, message);
                    }
                }
            });
        }

        @Override
        public void onC2CCustomMessage(final String senderID, final String cmd, final String message) {
            runOnHandlerThread(new Runnable() {
                @Override
                public void run() {
                    if (listener != null) {
                        listener.onC2CCustomMessage(senderID, cmd, message);
                    }
                }
            });
        }
    }

    private class MLiveRoomSimpleMsgListener extends V2TIMSimpleMsgListener {

        public void onRecvC2CTextMessage(String msgID, V2TIMUserInfo sender, String text) {
        }

        public void onRecvC2CCustomMessage(String msgID, V2TIMUserInfo sender, byte[] customData) {
            TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();
            onRecvC2COrGroupCustomMessage(txUserInfo, customData);
        }

        @Override
        public void onRecvGroupTextMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, String text) {
            Log.d(TAG, "onRecvGroupTextMessage, sender id:" +  sender.getUserID() + " text:" + text);
            mMessageListener.onGroupTextMessage(groupID, sender.getUserID(), sender.getNickName(), sender.getFaceUrl(), text);
        }

        @Override
        public void onRecvGroupCustomMessage(String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData) {
            TXUserInfo txUserInfo = new TXUserInfo();
            txUserInfo.userId = sender.getUserID();
            txUserInfo.userName = sender.getNickName();
            txUserInfo.avatarURL = sender.getFaceUrl();
            onRecvC2COrGroupCustomMessage(txUserInfo, customData);
        }
    }

    private class MLiveRoomGroupListener extends V2TIMGroupListener {
        @Override
        public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
            if (memberList != null && memberList.size() > 0) {
                mMessageListener.onGroupMemberEnter(groupID, memberList);
            }
        }

        @Override
        public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
            mMessageListener.onGroupMemberExit(groupID, member);
        }


        @Override
        public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
            if (mMessageListener != null){
                mMessageListener.onGroupDestroyed(groupID);
            }
        }

        @Override
        public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
            super.onGroupInfoChanged(groupID, changeInfos);
        }
    }

    private static class CommonJson<T> {
        String cmd;
        T      data;
    }

    private static final class UserInfo {
        String nickName;
        String headPic;
    }
}
