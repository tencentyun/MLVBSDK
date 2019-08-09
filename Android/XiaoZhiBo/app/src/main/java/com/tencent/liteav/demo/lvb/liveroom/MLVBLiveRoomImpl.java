package com.tencent.liteav.demo.lvb.liveroom;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.View;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.tencent.imsdk.TIMUserProfile;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.LoginInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.MLVBCommonDef;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.RoomInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.http.HttpRequests;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.http.HttpResponse;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.im.IMMessageMgr;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.ITXLivePushListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.TXLivePushConfig;
import com.tencent.rtmp.TXLivePusher;
import com.tencent.rtmp.ui.TXCloudVideoView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import static com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.MLVBCommonDef.LiveRoomErrorCode;

public class MLVBLiveRoomImpl extends MLVBLiveRoom implements HttpRequests.HeartBeatCallback, IMMessageMgr.IMMessageListener {

    protected static final String TAG = MLVBLiveRoomImpl.class.getName();
    protected static final int              LIVEROOM_ROLE_NONE      = 0;
    protected static final int              LIVEROOM_ROLE_PUSHER    = 1;
    protected static final int              LIVEROOM_ROLE_PLAYER    = 2;

    protected static MLVBLiveRoomImpl       mInstance = null;
//    protected static final String         mServerDomain = "http://150.109.42.33:5601/weapp/live_room"; //RoomService后台域名
    protected static final String           mServerDomain = "https://liveroom.qcloud.com/weapp/live_room"; //RoomService后台域名

    protected Context                       mAppContext = null;
    protected IMLVBLiveRoomListener         mListener = null;
    protected int                           mSelfRoleType           = LIVEROOM_ROLE_NONE;

    protected boolean                       mJoinPusher             = false;

    protected boolean                       mBackground             = false;

    protected TXLivePlayer                  mTXLivePlayer;

    protected TXLivePlayConfig              mTXLivePlayConfig;
    protected Handler                       mListenerHandler = null;
    protected HttpRequests                  mHttpRequest = null;           //HTTP CGI请求相关
    protected IMMessageMgr                  mIMMessageMgr;          //IM SDK相关
    protected LoginInfo                     mSelfAccountInfo;
    protected StreamMixturer                mStreamMixturer; //混流类
    protected HeartBeatThread               mHeartBeatThread;       //心跳
    protected String                        mCurrRoomID;
    protected int                           mRoomStatusCode = 0;
    protected ArrayList<RoomInfo>           mRoomList = new ArrayList<>();
    protected TXLivePusher mTXLivePusher;
    protected TXLivePushListenerImpl        mTXLivePushListener;
    protected String                        mSelfPushUrl;
    protected String                        mSelfAccelerateURL;
    protected HashMap<String, PlayerItem>   mPlayers = new LinkedHashMap<>();
    protected HashMap<String, AnchorInfo>   mPushers = new LinkedHashMap<>();
    private IMLVBLiveRoomListener.RequestJoinAnchorCallback mJoinAnchorCallback;
    private Runnable                        mJoinAnchorTimeoutTask;
    private IMLVBLiveRoomListener.RequestRoomPKCallback mRequestPKCallback = null;
    private Runnable                        mRequestPKTimeoutTask = null;
    private AnchorInfo                      mPKAnchorInfo = null;

    //观众列表最大长度
    private static final int                MAX_MEMBER_SIZE = 20;
    //更新观众列表的频率，防止观众进房太多导致的刷新频率太高
    private static final int                REFRESH_AUDIENCE_INTERVAL_MS = 2000;
    private long                            mLastEnterAudienceTimeMS = 0;
    private long                            mLastExitAudienceTimeMS = 0;
    //观众列表
    private LinkedHashMap<String/*userID*/, AudienceInfo> mAudiences = null;


    private static final int                LIVEROOM_CAMERA_PREVIEW = 0;
    private static final int                LIVEROOM_SCREEN_PREVIEW = 1;
    private int                             mPreviewType = LIVEROOM_CAMERA_PREVIEW;

    protected boolean                       mScreenAutoEnable       = true;
    private boolean                         mHasAddAnchor = false;

    private static final int                STREAM_MIX_MODE_JOIN_ANCHOR = 0;
    private static final int                STREAM_MIX_MODE_PK = 1;
    private int                             mMixMode = STREAM_MIX_MODE_JOIN_ANCHOR;

    private long                            mTimeDiff = 0; //客户端和服务器时间差，用户连麦和PK请求超时处理

    public static MLVBLiveRoom sharedInstance(Context context) {
        synchronized (MLVBLiveRoomImpl.class) {
            if (mInstance == null) {
                mInstance = new MLVBLiveRoomImpl(context);
            }
            return mInstance;
        }
    }

    public static void destroySharedInstance() {
        synchronized (MLVBLiveRoomImpl.class) {
            if (mInstance != null) {
                mInstance.destroy();
                mInstance = null;
            }
        }
    }

    /**
     * 设置回调接口
     *
     * 您可以通过 IMLVBLiveRoomListener 获得 MLVBLiveRoom 的各种状态通知
     *
     * @param listener 回调接口
     * @note 默认是在 Main Thread中回调，如果需要自定义回调线程，可使用 {@link MLVBLiveRoom#setListenerHandler(Handler)}
     */
    @Override
    public void setListener(IMLVBLiveRoomListener listener) {
        TXCLog.i(TAG, "API -> setListener");
        mListener = listener;
    }

    /**
     * 设置驱动回调的线程
     *
     * @param listenerHandler 线程
     */
    @Override
    public void setListenerHandler(Handler listenerHandler) {
        TXCLog.i(TAG, "API -> setListenerHandler");
        if (listenerHandler != null) {
            mListenerHandler = listenerHandler;
        } else {
            mListenerHandler = new Handler(mAppContext.getMainLooper());
        }
    }

    /**
     * 登录
     *
     * @param loginInfo 登录信息
     * @param callback  登录结果回调
     * @see {@link IMLVBLiveRoomListener.LoginCallback}
     */
    @Override
    public void login(final LoginInfo loginInfo, final IMLVBLiveRoomListener.LoginCallback callback) {
        TXCLog.i(TAG, "API -> login:" + loginInfo.sdkAppID + ":" + loginInfo.userID + ":" + loginInfo.userName + ":" + loginInfo.userSig);
        mSelfAccountInfo = loginInfo;

        if (mHttpRequest != null) {
            mHttpRequest.cancelAllRequests();
        }
        mHttpRequest = new HttpRequests(mServerDomain);
        mHttpRequest.setHeartBeatCallback(this);

        if (mIMMessageMgr == null) {
            mIMMessageMgr = new IMMessageMgr(mAppContext);
            mIMMessageMgr.setIMMessageListener(this);
        }

        //RoomService登录
        mHttpRequest.login(loginInfo.sdkAppID, loginInfo.userID, loginInfo.userSig, "Android", new HttpRequests.OnResponseCallback<HttpResponse.LoginResponse>() {
            @Override
            public void onResponse(final int retcode, final String retmsg, final HttpResponse.LoginResponse data) {
                if (retcode == 0) {
                    mTimeDiff = System.currentTimeMillis() - data.timestamp;
                    // 初始化IM SDK，内部完成login
                    IMMessageMgr imMessageMgr = mIMMessageMgr;
                    if (imMessageMgr != null) {
                        imMessageMgr.initialize(mSelfAccountInfo.userID, mSelfAccountInfo.userSig, (int) mSelfAccountInfo.sdkAppID, new IMMessageMgr.Callback() {
                            @Override
                            public void onError(final int code, final String errInfo) {
                                String msg = "[IM] 初始化失败[" + errInfo + ":" + code + "]";
                                TXCLog.e(TAG, msg);
                                callbackOnThread(mListener, msg);
                                callbackOnThread(callback, "onError", code, msg);
                            }

                            @Override
                            public void onSuccess(Object... args) {
                                //设置IM的个人信息
                                String msg = String.format("[LiveRoom] 登录成功, userID {%s}, userName {%s} " + "sdkAppID {%s}", mSelfAccountInfo.userID, mSelfAccountInfo.userName, mSelfAccountInfo.sdkAppID);
                                IMMessageMgr imMessageMgr = mIMMessageMgr;
                                if (imMessageMgr != null) {
                                    imMessageMgr.setSelfProfile(loginInfo.userName, loginInfo.userAvatar);
                                }
                                TXCLog.d(TAG, msg);
                                callbackOnThread(mListener, "onDebugLog", msg);
                                callbackOnThread(callback, "onSuccess");
                            }
                        });
                    }
                } else {
                    String msg = "[LiveRoom] RoomService登录失败[" + retmsg + ":" + retcode + "]";
                    TXCLog.e(TAG, msg);
                    callbackOnThread(mListener, "onDebugLog", msg);
                    callbackOnThread(callback, "onError", retcode, msg);
                }
            }
        });
    }

    /**
     * 退出登录
     */
    @Override
    public void logout() {
        TXCLog.i(TAG, "API -> logout");
        callbackOnThread(mListener, "onDebugLog", "[LiveRoom] 注销");
        if (mHttpRequest != null) {
            mHttpRequest.logout(new HttpRequests.OnResponseCallback<HttpResponse>() {
                @Override
                public void onResponse(int retcode, String retmsg, HttpResponse data) {
                    mHttpRequest.cancelAllRequests();
                }
            });
        }

        if (mIMMessageMgr != null) {
            mIMMessageMgr.setIMMessageListener(null);
            mIMMessageMgr.unInitialize();
            mIMMessageMgr = null;
        }

        mHeartBeatThread.stopHeartbeat();
    }

    /**
     * 修改个人信息
     *
     * @param userName  昵称
     * @param avatarURL 头像地址
     */
    @Override
    public void setSelfProfile(String userName, String avatarURL) {
        if (mSelfAccountInfo != null) {
            mSelfAccountInfo.userName = userName;
            mSelfAccountInfo.userAvatar = avatarURL;
        }
        IMMessageMgr imMessageMgr = mIMMessageMgr;
        if (imMessageMgr != null) {
            imMessageMgr.setSelfProfile(userName, avatarURL);
        }
    }

    /**
     * 获取房间列表
     *
     * 该接口支持分页获取房间列表，可以用 index 和 count 两个参数控制列表分页的逻辑，
     * - index = 0 & count = 10 代表获取第一页的10个房间。
     * - index = 11 & count = 10 代表获取第二页的10个房间。
     *
     * @param index    房间开始索引，从0开始计算。
     * @param count    希望后台返回的房间个数。
     * @param callback 获取房间列表的结果回调。
     */
    @Override
    public void getRoomList(int index, int count, final IMLVBLiveRoomListener.GetRoomListCallback callback) {
        TXCLog.i(TAG, "API -> getRoomList:" + index + ":" + count);
        if (mHttpRequest == null && callback != null) {
            callbackOnThread(callback, "onError", LiveRoomErrorCode.ERROR_NOT_LOGIN, "[LiveRoom] getRoomList失败[Http 未初始化，请确保已经login]");
            return;
        }

        mHttpRequest.getRoomList(index, count, new HttpRequests.OnResponseCallback<HttpResponse.RoomList>() {
            @Override
            public void onResponse(final int retcode, final String retmsg, HttpResponse.RoomList data) {
                if (retcode != HttpResponse.CODE_OK || data == null || data.rooms == null){
                    callbackOnThread(callback, "onError", retcode, "[LiveRoom] getRoomList 失败[" + retmsg + "]");
                }else {
                    final ArrayList<RoomInfo> arrayList = new ArrayList<>(data.rooms.size());
                    arrayList.addAll(data.rooms);
                    mRoomList = arrayList;
                    callbackOnThread(callback, "onSuccess", arrayList);
                }
            }
        });
    }

    /**
     * 获取观众列表
     *
     * 当有观众进房时，后台会将其信息加入到指定房间的观众列表中，调入该函数即可返回指定房间的观众列表
     *
     * @param callback 获取观众列表的结果回调。
     * @note 观众列表最多只保存30人，因为对于常规的 UI 展示来说这已经足够，保存更多除了浪费存储空间，也会拖慢列表返回的速度。
     */
    @Override
    public void getAudienceList(final IMLVBLiveRoomListener.GetAudienceListCallback callback) {
        TXCLog.i(TAG, "API -> getAudienceList");
        if (mCurrRoomID == null || mCurrRoomID.length() > 0) {
            callbackOnThread(callback, "onError", LiveRoomErrorCode.ERROR_NOT_IN_ROOM, "[LiveRoom] getAudienceList 失败[房间号为空]");
            return;
        }
        if (mAudiences != null) {
            final ArrayList<AudienceInfo> audienceList = new ArrayList<>();
            for (Map.Entry<String, AudienceInfo> item : mAudiences.entrySet()) {
                audienceList.add(item.getValue());
            }
            callbackOnThread(callback, "onSuccess", audienceList);
        } else {
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.getGroupMembers(mCurrRoomID, MAX_MEMBER_SIZE, new TIMValueCallBack<List<TIMUserProfile>>() {
                    @Override
                    public void onError(final int i, final String s) {
                        callbackOnThread(callback, "onError", i, "[IM] 获取群成员失败[" + s + "]");
                    }

                    @Override
                    public void onSuccess(List<TIMUserProfile> timUserProfiles) {
                        for (TIMUserProfile userProfile : timUserProfiles) {
                            AudienceInfo audienceInfo = new AudienceInfo();
                            audienceInfo.userID = userProfile.getIdentifier();
                            audienceInfo.userName = userProfile.getNickName();
                            audienceInfo.userAvatar = userProfile.getFaceUrl();
                            mAudiences.put(userProfile.getIdentifier(), audienceInfo);
                        }

                        final ArrayList<AudienceInfo> audienceList = new ArrayList<>();
                        for (Map.Entry<String, AudienceInfo> item : mAudiences.entrySet()) {
                            audienceList.add(item.getValue());
                        }
                        callbackOnThread(callback, "onSuccess", audienceList);
                    }
                });
            }
        }
    }

    /**
     * 创建房间（主播调用）
     *
     * 主播开播的正常调用流程是：
     * 1.【主播】调用 startLocalPreview() 打开摄像头预览，此时可以调整美颜参数。
     * 2.【主播】调用 createRoom 创建直播间，房间创建成功与否会通过 {@link IMLVBLiveRoomListener.CreateRoomCallback} 通知给主播。
     *
     * @param roomID   房间标识，推荐做法是用主播的 userID 作为房间的 roomID，这样省去了后台映射的成本。room ID 可以填空，此时由后台生成。
     * @param roomInfo 房间信息（非必填），用于房间描述的信息，比如房间名称，允许使用 JSON 格式作为房间信息。
     * @param callback 创建房间的结果回调
     */
    @Override
    public void createRoom(final String roomID, final String roomInfo, final IMLVBLiveRoomListener.CreateRoomCallback callback) {
        TXCLog.i(TAG, "API -> createRoom:" + roomID + ":" + roomInfo);
        mSelfRoleType = LIVEROOM_ROLE_PUSHER;

        //1. 在应用层调用startLocalPreview，启动本地预览

        //2. 请求CGI:get_push_url，异步获取到推流地址pushUrl
        mHttpRequest.getPushUrl(mSelfAccountInfo.userID, roomID, new HttpRequests.OnResponseCallback<HttpResponse.PushUrl>() {
            @Override
            public void onResponse(int retcode, String retmsg, HttpResponse.PushUrl data) {
                if (retcode == HttpResponse.CODE_OK && data != null && data.pushURL != null) {
                    final String pushURL = data.pushURL;
                    mSelfPushUrl = data.pushURL;
                    mSelfAccelerateURL = data.accelerateURL;

                    //3.开始推流
                    startPushStream(pushURL, TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION, new StandardCallback() {
                        @Override
                        public void onError(int errCode, String errInfo) {
                            callbackOnThread(callback, "onError", errCode, errInfo);
                        }

                        @Override
                        public void onSuccess() {
                            //推流过程中，可能会重复收到PUSH_EVT_PUSH_BEGIN事件，onSuccess可能会被回调多次，如果已经创建的房间，直接返回
                            if (mCurrRoomID != null && mCurrRoomID.length() > 0) {
                                return;
                            }

                            if (mTXLivePusher != null) {
                                TXLivePushConfig config = mTXLivePusher.getConfig();
                                config.setVideoEncodeGop(2);
                                mTXLivePusher.setConfig(config);
                            }

                            mBackground = false;
                            //4.推流成功，请求CGI:create_room，获取roomID、roomSig
                            doCreateRoom(roomID, roomInfo, new StandardCallback() {
                                @Override
                                public void onError(int errCode, String errInfo) {
                                    callbackOnThread(callback, "onError", errCode, errInfo);
                                }

                                @Override
                                public void onSuccess() {

                                    //5.请求CGI：add_pusher，加入房间
                                    addAnchor(mCurrRoomID, pushURL, new StandardCallback() {
                                        @Override
                                        public void onError(int errCode, String errInfo) {
                                            callbackOnThread(callback, "onError", errCode, errInfo);
                                        }

                                        @Override
                                        public void onSuccess() {
                                            //6.创建IM群
                                            createIMGroup(mCurrRoomID, mCurrRoomID, new StandardCallback() {
                                                @Override
                                                public void onError(int errCode, String errInfo) {
                                                    if (errCode == 10025) {
                                                        //群组 ID 已被使用，并且操作者为群主，可以直接使用
                                                        Log.w(TAG, "[IM] 群组 " + mCurrRoomID + " 已被使用，并且操作者为群主，可以直接使用");
                                                        mJoinPusher = true;
                                                        mHeartBeatThread.startHeartbeat(); //启动心跳
                                                        mStreamMixturer.setMainVideoStream(pushURL);
                                                        callbackOnThread(callback, "onSuccess", mCurrRoomID);
                                                    } else {
                                                        callbackOnThread(callback, "onError", errCode, errInfo);
                                                    }
                                                }

                                                @Override
                                                public void onSuccess() {
                                                    mJoinPusher = true;
                                                    mHeartBeatThread.startHeartbeat(); //启动心跳
                                                    mStreamMixturer.setMainVideoStream(pushURL);
                                                    callbackOnThread(callback, "onSuccess", mCurrRoomID);
                                                }
                                            });
                                        }
                                    });
                                }
                            });
                        }
                    });

                }
                else {
                    callbackOnThread(callback, "onError", retcode, "[LiveRoom] 创建房间失败[获取推流地址失败]");
                }
            }
        });
    }

    /**
     * 进入房间（观众调用）
     *
     * 观众观看直播的正常调用流程是：
     * 1.【观众】调用 getRoomList() 刷新最新的直播房间列表，并通过 {@link IMLVBLiveRoomListener.GetRoomListCallback} 回调拿到房间列表。
     * 2.【观众】选择一个直播间以后，调用 enterRoom() 进入该房间。
     *
     * @param roomID   房间标识
     * @param view     承载视频画面的控件
     * @param callback 进入房间的结果回调
     */
    @Override
    public void enterRoom(final String roomID, final TXCloudVideoView view, final IMLVBLiveRoomListener.EnterRoomCallback callback) {
        TXCLog.i(TAG, "API -> enterRoom:" + roomID);
        if (roomID == null || roomID.length() == 0) {
            callbackOnThread(callback, "onError", LiveRoomErrorCode.ERROR_PARAMETERS_INVALID, "[LiveRoom] 进房失败[房间号为空]");
            return;
        }
        mSelfRoleType = LIVEROOM_ROLE_PLAYER;
        mCurrRoomID = roomID;

        //1.IM进群
        jionIMGroup(roomID, new StandardCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                callbackOnThread(callback, "onError", errCode, errInfo);
            }

            @Override
            public void onSuccess() {
                //2.在主线程播放CDN流
                Handler handler = new Handler(mAppContext.getMainLooper());
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (view != null) {
                            view.setVisibility(View.VISIBLE);
                        }
                        String mixedPlayUrl = getMixedPlayUrlByRoomID(roomID);
                        if (mixedPlayUrl != null && mixedPlayUrl.length() > 0) {
                            int playType = getPlayType(mixedPlayUrl);
                            mTXLivePlayer.setPlayerView(view);
                            mTXLivePlayer.startPlay(mixedPlayUrl, playType);

                            if (mHttpRequest != null) {
                                String userInfo = "";
                                try {
                                    userInfo = new JSONObject()
                                            .put("userName", mSelfAccountInfo.userName)
                                            .put("userAvatar", mSelfAccountInfo.userAvatar)
                                            .toString();
                                } catch (JSONException e) {
                                    userInfo = "";
                                }
                                mHttpRequest.addAudience(roomID, mSelfAccountInfo.userID, userInfo, null);
                            }
                            callbackOnThread(callback, "onSuccess");
                        } else {
                            callbackOnThread(callback, "onError", LiveRoomErrorCode.ERROR_PLAY, "[LiveRoom] 未找到CDN播放地址");
                        }
                    }
                });
            }
        });
    }

    /**
     * 离开房间
     *
     * @param callback 离开房间的结果回调
     */
    @Override
    public void exitRoom(IMLVBLiveRoomListener.ExitRoomCallback callback) {
        TXCLog.i(TAG, "API -> exitRoom");
        //1. 结束心跳
        mHeartBeatThread.stopHeartbeat();

        // 停止 BGM
        stopBGM();
        
        if (mSelfRoleType == LIVEROOM_ROLE_PUSHER) {
            //2. 如果是大主播，则销毁群
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.destroyGroup(mCurrRoomID, new IMMessageMgr.Callback() {
                    @Override
                    public void onError(int code, String errInfo) {
                        TXCLog.e(TAG, "[IM] 销毁群失败:" + code + ":" + errInfo);
                    }

                    @Override
                    public void onSuccess(Object... args) {
                        TXCLog.d(TAG, "[IM] 销毁群成功");
                    }
                });
            }

        } else {
            //通知房间内其他主播
            notifyPusherChange();

            //2. 调用IM的quitGroup
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.quitGroup(mCurrRoomID, new IMMessageMgr.Callback() {
                    @Override
                    public void onError(int code, String errInfo) {
                        TXCLog.e(TAG, "[IM] 退群失败:" + code + ":" + errInfo);
                    }

                    @Override
                    public void onSuccess(Object... args) {
                        TXCLog.d(TAG, "[IM] 退群成功");
                    }
                });
            }
        }

        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                //3. 结束本地推流
                if (mPreviewType == LIVEROOM_CAMERA_PREVIEW) {
                    stopLocalPreview();
                } else {
                    stopScreenCapture();
                }
                unInitLivePusher();

                //4. 结束所有加速流的播放
                cleanPlayers();

                //5. 结束普通流播放
                if (mTXLivePlayer != null) {
                    mTXLivePlayer.stopPlay(true);
                    mTXLivePlayer.setPlayerView(null);
                }

                quitRoomPK(null);
            }
        };

        if (Looper.myLooper() != mAppContext.getMainLooper()) {
            Handler handler = new Handler(mAppContext.getMainLooper());
            handler.post(runnable);
        } else {
            runnable.run();
        }

        //6. 退出房间：请求CGI:delete_pusher，把自己从房间成员列表里删除
        if (mHasAddAnchor) {
            mHasAddAnchor = false;
            mHttpRequest.delPusher(mCurrRoomID, mSelfAccountInfo.userID, new HttpRequests.OnResponseCallback<HttpResponse>() {
                @Override
                public void onResponse(int retcode, String retmsg, HttpResponse data) {
                    if (retcode == HttpResponse.CODE_OK) {
                        TXCLog.d(TAG, "退群成功");
                        callbackOnThread(mListener, "onDebugLog", "[LiveRoom] 退群成功");
                    } else {
                        callbackOnThread(mListener, "onDebugLog", String.format("[LiveRoom] 退群失败：%s(%d)", retmsg, retcode));
                        TXCLog.e(TAG, String.format("解散群失败：%s(%d)", retmsg, retcode));
                    }
                }
            });
        }


        if (mSelfRoleType == LIVEROOM_ROLE_PLAYER && mHttpRequest != null) {
            mHttpRequest.delAudience(mCurrRoomID, mSelfAccountInfo.userID, null);
        }

        mJoinPusher = false;
        mSelfRoleType = LIVEROOM_ROLE_NONE;
        mCurrRoomID   = "";
        mPushers.clear();

        mStreamMixturer.resetMergeState();

        callbackOnThread(callback, "onSuccess");
    }

    /**
     * 设置自定义信息
     *
     * 有时候您可能需要为房间产生一些额外的信息，此接口可以将这些信息缓存到服务器。
     *
     * @param op 执行动作，定义请查看 {@link MLVBCommonDef.CustomFieldOp}
     * @param key 自定义键
     * @param value 数值
     *
     * @note op 为 {@link MLVBCommonDef.CustomFieldOp#SET} 时，value 可以是 String 或者 Integer 类型
     *       op 为 {@link MLVBCommonDef.CustomFieldOp#INC} 时，value 是 Integer 类型
     *       op 为 {@link MLVBCommonDef.CustomFieldOp#DEC} 时，value 是 Integer 类型
     */
    public void setCustomInfo(final MLVBCommonDef.CustomFieldOp op, final String key, final Object value, final IMLVBLiveRoomListener.SetCustomInfoCallback callback) {
        TXCLog.i(TAG, "API -> setCustomInfo:" + op + ":" + key);
        if ((op == MLVBCommonDef.CustomFieldOp.SET && !((value instanceof String) || (value instanceof Integer)))
                || (op == MLVBCommonDef.CustomFieldOp.INC && !(value instanceof Integer))
                || (op == MLVBCommonDef.CustomFieldOp.DEC && !(value instanceof Integer))) {
            String msg = "[LiveRoom] setCustomInfo失败[op和value类型不匹配]";
            callbackOnThread(callback, "onError", LiveRoomErrorCode.ERROR_PARAMETERS_INVALID, msg);
            return;
        }
        String strOp = "";
        if (op == MLVBCommonDef.CustomFieldOp.SET) {
            strOp = "set";
        } else if (op == MLVBCommonDef.CustomFieldOp.INC) {
            strOp = "inc";
        } else if (op == MLVBCommonDef.CustomFieldOp.DEC) {
            strOp = "del";
        }
        mHttpRequest.setCustomInfo(mCurrRoomID, key, strOp, value, new HttpRequests.OnResponseCallback<HttpResponse>() {
            @Override
            public void onResponse(final int retcode, @Nullable final String retmsg, @Nullable HttpResponse data) {
                if (retcode == HttpResponse.CODE_OK) {
                    callbackOnThread(callback, "onSuccess");
                } else {
                    callbackOnThread(callback, "onError", retcode, "[LiveRoom] setCustomInfo失败[" + retmsg + ":" + retcode + "]");
                }
            }
        });
    }

    /**
     * 获取自定义信息
     *
     * @param callback 获取自定义信息回调
     */
    public void getCustomInfo(final IMLVBLiveRoomListener.GetCustomInfoCallback callback) {
        TXCLog.i(TAG, "API -> getCustomInfo");
        mHttpRequest.getCustomInfo(mCurrRoomID, new HttpRequests.OnResponseCallback<HttpResponse.GetCustomInfoResponse>() {
            @Override
            public void onResponse(final int retcode, @Nullable final String retmsg, @Nullable HttpResponse.GetCustomInfoResponse data) {
                if (retcode == HttpResponse.CODE_OK) {
                    final Map<String, Object> customList = new HashMap<>();
                    if (data.custom != null && data.custom.length() > 0) {
                        try {
                            JSONObject customObj = new JSONObject(data.custom);
                            Iterator<String> keys = customObj.keys();
                            while (keys.hasNext()) {
                                String key = keys.next();
                                Object value = customObj.get(key);
                                customList.put(key, value);
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                    callbackOnThread(callback, "onGetCustomInfo", customList);
                } else {
                    callbackOnThread(callback, "onError", retcode, "[LiveRoom] getCustomInfo失败[" + retmsg + ":" + retcode + "]");
                }
            }
        });
    }

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
     * 9. 【观众】如果直播间里已经有其他观众正在跟主播进行连麦，那么新加入的这位连麦观众也会收到 onAnchorEnter() 通知，用于展示（startRemoteView）其他连麦者的视频画面。
     *
     * @param reason   连麦原因
     * @param callback
     * @see {@link IMLVBLiveRoomListener#onRequestJoinAnchor(AnchorInfo, String)}
     */
    @Override
    public void requestJoinAnchor(String reason, final IMLVBLiveRoomListener.RequestJoinAnchorCallback callback) {
        TXCLog.i(TAG, "API -> requestJoinAnchor:" + reason);
        try {
            CommonJson<JoinAnchorRequest> request = new CommonJson<>();
            request.cmd = "linkmic";
            request.data = new JoinAnchorRequest();
            request.data.type = "request";
            request.data.roomID = mCurrRoomID;
            request.data.userID = mSelfAccountInfo.userID;
            request.data.userName = mSelfAccountInfo.userName;
            request.data.userAvatar = mSelfAccountInfo.userAvatar;
            request.data.reason = reason;
            request.data.timestamp = System.currentTimeMillis() - mTimeDiff;

            mJoinAnchorCallback = callback;

            if (mJoinAnchorTimeoutTask == null) {
                mJoinAnchorTimeoutTask = new Runnable() {
                    @Override
                    public void run() {
                        callbackOnThread(new Runnable() {
                            @Override
                            public void run() {
                                if (mJoinAnchorCallback != null) {
                                    mJoinAnchorCallback.onTimeOut();
                                    mJoinAnchorCallback = null;
                                }
                            }
                        });
                    }
                };
            }

            mListenerHandler.removeCallbacks(mJoinAnchorTimeoutTask);
            //10秒收不到主播同意/拒绝连麦的响应，则回调超时
            mListenerHandler.postDelayed(mJoinAnchorTimeoutTask, 10 * 1000);

            String content = new Gson().toJson(request, new TypeToken<CommonJson<JoinAnchorRequest>>(){}.getType());
            String toUserID = getRoomCreator(mCurrRoomID);
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.sendC2CCustomMessage(toUserID, content, new IMMessageMgr.Callback() {
                    @Override
                    public void onError(final int code, final String errInfo) {
                        callbackOnThread(new Runnable() {
                            @Override
                            public void run() {
                                if (mJoinAnchorCallback != null) {
                                    mJoinAnchorCallback.onError(code, "[IM] 请求连麦失败[" + errInfo + ":" + code + "]");
                                }
                            }
                        });
                    }

                    @Override
                    public void onSuccess(Object... args) {

                    }
                });
            }

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 主播处理连麦请求
     *
     * 主播在收到 {@link IMLVBLiveRoomListener#onRequestJoinAnchor(AnchorInfo, String)} 回调之后会需要调用此接口来处理观众的连麦请求。
     *
     * @param userID 观众ID
     * @param agree  true：同意；false：拒绝
     * @param reason 同意/拒绝连麦的原因描述
     *
     * @return 0：响应成功；非0：响应失败
     */
    @Override
    public int responseJoinAnchor(String userID, boolean agree, String reason) {
        TXCLog.i(TAG, "API -> responseJoinAnchor:" + userID + ":" + agree + ":" + reason);
        if (mPlayers.size() > 0 && mMixMode == STREAM_MIX_MODE_PK) {
            TXCLog.e(TAG, "当前在PK状态。请先停止PK，再进行连麦");
            return -1;
        }
        try {
            if (agree) {
                mMixMode = STREAM_MIX_MODE_JOIN_ANCHOR;
            }
            CommonJson<JoinAnchorResponse> response = new CommonJson<>();
            response.cmd = "linkmic";
            response.data = new JoinAnchorResponse();
            response.data.type = "response";
            response.data.result = agree?"accept":"reject";
            response.data.reason = reason;
            response.data.roomID = mCurrRoomID;
            response.data.timestamp = System.currentTimeMillis() - mTimeDiff;
            String content = new Gson().toJson(response, new TypeToken<CommonJson<JoinAnchorResponse>>(){}.getType());
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.sendC2CCustomMessage(userID, content, new IMMessageMgr.Callback() {
                    @Override
                    public void onError(final int code, final String errInfo) {

                    }

                    @Override
                    public void onSuccess(Object... args) {

                    }
                });
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 观众进入连麦状态
     *
     * 进入连麦成功后，主播和其他连麦观众会收到 {@link IMLVBLiveRoomListener#onAnchorEnter(AnchorInfo)} 通知
     *
     * @param callback 进入连麦的结果回调
     */
    @Override
    public void joinAnchor(final IMLVBLiveRoomListener.JoinAnchorCallback callback) {
        TXCLog.i(TAG, "API -> joinAnchor");
        if (mCurrRoomID == null || mCurrRoomID.length() == 0) {
            callbackOnThread(callback, "onError", LiveRoomErrorCode.ERROR_NOT_IN_ROOM, "[LiveRoom] 观众进入连麦失败[房间号为空，请确认是否已经进房]");
            return;
        }

        //1.在应用层调用startLocalPreview

        //2. 请求CGI:get_pushers，异步获取房间里所有正在推流的成员
        updateAnchors(true, new UpdateAnchorsCallback() {
            @Override
            public void onUpdateAnchors(int retcode, List<AnchorInfo> addAnchors, List<AnchorInfo> delAnchors, HashMap<String, AnchorInfo> mergedAnchors, AnchorInfo roomCreator) {
                //3.结束播放大主播的普通流，改为播放加速流
                if (retcode == 0) {
                    String accelerateURL = roomCreator.accelerateURL;
                    if (accelerateURL != null && accelerateURL.length() > 0) {
                        mTXLivePlayer.stopPlay(true);
                        mTXLivePlayer.startPlay(accelerateURL, TXLivePlayer.PLAY_TYPE_LIVE_RTMP_ACC);
                    } else {
                        TXCLog.e(TAG, "观众连麦获取不到加速流地址");
                    }
                }
            }
        });

        //4. 请求CGI:get_push_url，异步获取到推流地址pushUrl
        mHttpRequest.getPushUrl(mSelfAccountInfo.userID, mCurrRoomID, new HttpRequests.OnResponseCallback<HttpResponse.PushUrl>() {
            @Override
            public void onResponse(int retcode, String retmsg, final HttpResponse.PushUrl data) {
                if (retcode == HttpResponse.CODE_OK && data != null && data.pushURL != null) {
                    mSelfPushUrl = data.pushURL;
                    mSelfAccelerateURL = data.accelerateURL;
                    //5. 开始推流
                    startPushStream(data.pushURL, TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER, new StandardCallback() {
                        @Override
                        public void onError(final int code, final String info) {
                            callbackOnThread(callback, "onError", code, info);
                        }

                        @Override
                        public void onSuccess() {
                            mBackground = false;
                            //6. 推流成功，请求CGI:add_pusher，把自己加入房间成员列表
                            addAnchor(mCurrRoomID, data.pushURL, new StandardCallback() {
                                @Override
                                public void onError(final int code, final String info) {
                                    callbackOnThread(callback, "onError", code, info);
                                }

                                @Override
                                public void onSuccess() {
                                    mJoinPusher = true;
                                    mHeartBeatThread.startHeartbeat();// 开启心跳
                                    callbackOnThread(callback, "onSuccess");

                                    //通知房间内其他主播
                                    notifyPusherChange();
                                }
                            });
                        }
                    });
                } else {
                    callbackOnThread(callback, "onError", retcode, "[LiveRoom] 获取推流地址失败[" + retmsg + ":" + retcode + "]");
                }
            }
        });
    }

    /**
     * 观众退出连麦
     *
     * 退出连麦成功后，主播和其他连麦观众会收到 {@link IMLVBLiveRoomListener#onAnchorExit(AnchorInfo)} 通知
     *
     * @param callback 退出连麦的结果回调
     */
    @Override
    public void quitJoinAnchor(final IMLVBLiveRoomListener.QuitAnchorCallback callback) {
        TXCLog.i(TAG, "API -> quitJoinAnchor");
        Handler handler = new Handler(mAppContext.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                //1. 结束本地预览
                if (mPreviewType == LIVEROOM_CAMERA_PREVIEW) {
                    stopLocalPreview();
                } else {
                    stopScreenCapture();
                }
                unInitLivePusher();

                //2. 结束所有加速流的播放
                cleanPlayers();

                //3. 结束播放大主播的加速流，改为播放普通流
                mTXLivePlayer.stopPlay(true);
                if (!mBackground) {
                    String mixedPlayUrl = getMixedPlayUrlByRoomID(mCurrRoomID);
                    if (mixedPlayUrl != null && mixedPlayUrl.length() > 0) {
                        int playType = getPlayType(mixedPlayUrl);
                        mTXLivePlayer.startPlay(mixedPlayUrl, playType);
                    }
                }
            }
        });

        //4. 结束心跳
        mHeartBeatThread.stopHeartbeat();

        //5. 请求CGI:delete_pusher，把自己从主播列表里删除
        if (mHasAddAnchor) {
            mHasAddAnchor = false;
            mHttpRequest.delPusher(mCurrRoomID, mSelfAccountInfo.userID, new HttpRequests.OnResponseCallback<HttpResponse>() {
                @Override
                public void onResponse(int retcode, String retmsg, HttpResponse data) {
                    if (retcode == HttpResponse.CODE_OK) {
                        TXCLog.d(TAG, "结束连麦成功");
                        callbackOnThread(mListener, "onDebugLog", "[LiveRoom] 结束连麦成功");
                    } else {
                        TXCLog.e(TAG, String.format("结束连麦失败：%s(%d)", retmsg, retcode));
                        callbackOnThread(mListener, "onDebugLog", String.format("[LiveRoom] 结束连麦失败：%s(%d)", retmsg, retcode));
                    }

                    //通知房间内其他主播
                    notifyPusherChange();
                }
            });
        }

        mJoinPusher = false;

        mPushers.clear();

        callbackOnThread(callback, "onSuccess");
    }

    /**
     * 主播踢除连麦观众
     *
     * 主播调用此接口踢除连麦观众后，被踢连麦观众会收到 {@link IMLVBLiveRoomListener#onKickoutJoinAnchor()} 回调通知
     *
     * @param userID 连麦观众ID
     * @see {@link IMLVBLiveRoomListener#onKickoutJoinAnchor()}
     */
    @Override
    public void kickoutJoinAnchor(String userID) {
        TXCLog.i(TAG, "API -> kickoutJoinAnchor:" + userID);
        try {
            CommonJson<KickoutResponse> response = new CommonJson<>();
            response.cmd = "linkmic";
            response.data = new KickoutResponse();
            response.data.type = "kickout";
            response.data.roomID = mCurrRoomID;
            response.data.timestamp = System.currentTimeMillis() - mTimeDiff;
            String content = new Gson().toJson(response, new TypeToken<CommonJson<KickoutResponse>>(){}.getType());
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.sendC2CCustomMessage(userID, content, new IMMessageMgr.Callback() {
                @Override
                public void onError(final int code, final String errInfo) {

                }

                @Override
                public void onSuccess(Object... args) {

                }
            });
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 请求跨房PK
     *
     * 主播和主播之间可以跨房间 PK，两个正在直播中的主播 A 和 B，他们之间的跨房 PK 流程如下：
     * 1. 【主播 A】调用 requestRoomPK() 向主播 B 发起连麦请求。
     * 2. 【主播 B】会收到 {@link IMLVBLiveRoomListener#onRequestRoomPK(AnchorInfo)} 回调通知。
     * 3. 【主播 B】调用 responseRoomPK() 确定是否接受主播 A 的 PK 请求。
     * 4. 【主播 B】如果接受了主播 A 的要求，可以直接调用 startRemoteView() 来显示主播 A 的视频画面。
     * 5. 【主播 A】会收到 {@link IMLVBLiveRoomListener.RequestRoomPKCallback} 回调通知，可以得知请求是否被同意。
     * 6. 【主播 A】如果请求被同意，则可以调用 startRemoteView() 显示主播 B 的视频画面。
     *
     * @param userID   被邀约主播ID
     * @param callback 请求跨房PK的结果回调
     * @see {@link IMLVBLiveRoomListener#onRequestRoomPK(AnchorInfo)}
     */
    @Override
    public void requestRoomPK(String userID, final IMLVBLiveRoomListener.RequestRoomPKCallback callback) {
        TXCLog.i(TAG, "API -> requestRoomPK:" + userID);
        try {
            CommonJson<PKRequest> request = new CommonJson<>();
            request.cmd = "pk";
            request.data = new PKRequest();
            request.data.type = "request";
            request.data.action = "start";
            request.data.roomID = mCurrRoomID;
            request.data.userID = mSelfAccountInfo.userID;
            request.data.userName = mSelfAccountInfo.userName;
            request.data.userAvatar = mSelfAccountInfo.userAvatar;
            request.data.accelerateURL = mSelfAccelerateURL;
            request.data.timestamp = System.currentTimeMillis() - mTimeDiff;

            mRequestPKCallback = callback;

            if (mRequestPKTimeoutTask == null) {
                mRequestPKTimeoutTask = new Runnable() {
                    @Override
                    public void run() {
                        callbackOnThread(new Runnable() {
                            @Override
                            public void run() {
                                if (mRequestPKCallback != null) {
                                    mRequestPKCallback.onTimeOut();
                                    mRequestPKCallback = null;
                                }
                            }
                        });
                    }
                };
            }

            mListenerHandler.removeCallbacks(mRequestPKTimeoutTask);
            //10秒收不到主播同意/拒绝 PK 的响应，则回调超时
            mListenerHandler.postDelayed(mRequestPKTimeoutTask, 10 * 1000);

            mPKAnchorInfo = new AnchorInfo(userID, "", "", "");

            String content = new Gson().toJson(request, new TypeToken<CommonJson<PKRequest>>(){}.getType());
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.sendC2CCustomMessage(userID, content, new IMMessageMgr.Callback() {
                    @Override
                    public void onError(final int code, final String errInfo) {
                        callbackOnThread(callback, "onError", code, "[IM] 请求PK失败[" + errInfo + ":" + code + "]");
                    }

                    @Override
                    public void onSuccess(Object... args) {

                    }
                });
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 响应跨房 PK 请求
     *
     * 主播响应其他房间主播的 PK 请求，发起 PK 请求的主播会收到 {@link IMLVBLiveRoomListener.RequestRoomPKCallback} 回调通知。
     *
     * @param userID 发起 PK 请求的主播 ID
     * @param agree  true：同意；false：拒绝
     * @param reason 同意/拒绝PK的原因描述
     *
     * @return 0：响应成功；非0：响应失败
     */
    @Override
    public int responseRoomPK(String userID, boolean agree, String reason) {
        TXCLog.i(TAG, "API -> responseRoomPK:" + userID + ":" + agree + ":" + reason);
        if (mPlayers.size() > 0 && mMixMode == STREAM_MIX_MODE_JOIN_ANCHOR) {
            TXCLog.e(TAG, "当前在连麦状态。请先停止连麦，再进行PK");
            return -1;
        }
        try {
            if (agree) {
                mMixMode = STREAM_MIX_MODE_PK;
            }
            CommonJson<PKResponse> response = new CommonJson<>();
            response.cmd = "pk";
            response.data = new PKResponse();
            response.data.type = "response";
            response.data.result = agree?"accept":"reject";
            response.data.reason= reason;
            response.data.roomID = mCurrRoomID;
            response.data.accelerateURL = mSelfAccelerateURL;
            response.data.timestamp = System.currentTimeMillis() - mTimeDiff;

            String content = new Gson().toJson(response, new TypeToken<CommonJson<PKResponse>>(){}.getType());
            IMMessageMgr imMessageMgr = mIMMessageMgr;
            if (imMessageMgr != null) {
                imMessageMgr.sendC2CCustomMessage(userID, content, new IMMessageMgr.Callback() {
                @Override
                public void onError(final int code, final String errInfo) {

                }

                @Override
                public void onSuccess(Object... args) {

                }
            });
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 退出跨房 PK
     *
     * 当两个主播中的任何一个退出跨房 PK 状态后，另一个主播会收到 {@link IMLVBLiveRoomListener#onQuitRoomPK(AnchorInfo)} 回调通知。
     *
     * @param callback 退出跨房 PK 的结果回调
     */
    @Override
    public void quitRoomPK(final IMLVBLiveRoomListener.QuitRoomPKCallback callback) {
        TXCLog.i(TAG, "API -> quitRoomPK");
        try {
            if (mPKAnchorInfo != null && mPKAnchorInfo.userID != null && mPKAnchorInfo.userID.length() > 0) {
                CommonJson<PKRequest> request = new CommonJson<>();
                request.cmd = "pk";
                request.data = new PKRequest();
                request.data.type = "request";
                request.data.action = "stop";
                request.data.roomID = mCurrRoomID;
                request.data.userID = mSelfAccountInfo.userID;
                request.data.userName = mSelfAccountInfo.userName;
                request.data.userAvatar = mSelfAccountInfo.userAvatar;
                request.data.accelerateURL = "";
                request.data.timestamp = System.currentTimeMillis() - mTimeDiff;

                String content = new Gson().toJson(request, new TypeToken<CommonJson<PKRequest>>() {}.getType());
                IMMessageMgr imMessageMgr = mIMMessageMgr;
                if (imMessageMgr != null) {
                    imMessageMgr.sendC2CCustomMessage(mPKAnchorInfo.userID, content, new IMMessageMgr.Callback() {
                    @Override
                    public void onError(final int code, final String errInfo) {
                        callbackOnThread(callback, "onError", code, "[IM] 退出PK失败[" + errInfo + ":" + code + "]");
                    }

                    @Override
                    public void onSuccess(Object... args) {
                        callbackOnThread(callback, "onSuccess");
                    }
                });
                }
            } else {
                TXCLog.e(TAG, "获取不到 PK 主播信息，请确认是否已经跨房 PK");
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 开启本地视频的预览画面
     *
     * @param frontCamera YES：前置摄像头；NO：后置摄像头。
     * @param view        承载视频画面的控件
     */
    @Override
    public void startLocalPreview(boolean frontCamera, TXCloudVideoView view) {
        TXCLog.i(TAG, "API -> startLocalPreview:" + frontCamera);
        initLivePusher(frontCamera);
        if (mTXLivePusher != null) {
            if (view != null) {
                view.setVisibility(View.VISIBLE);
            }
            mTXLivePusher.startCameraPreview(view);
        }
        mPreviewType = LIVEROOM_CAMERA_PREVIEW;
    }

    /**
     * 停止本地视频采集及预览
     */
    @Override
    public void stopLocalPreview() {
        TXCLog.i(TAG, "API -> stopLocalPreview");
        if (mTXLivePusher != null) {
            mTXLivePusher.stopCameraPreview(false);
        }
//        unInitLivePusher();
    }

    /**
     * 启动渲染远端视频画面
     *
     * @param anchorInfo 对方的用户信息
     * @param view       承载视频画面的控件
     * @param callback   播放器监听器
     *
     * @note 在 onUserVideoAvailable 回调时，调用这个接口
     */
    @Override
    public void startRemoteView(final AnchorInfo anchorInfo, final TXCloudVideoView view, final IMLVBLiveRoomListener.PlayCallback callback) {
        TXCLog.i(TAG, "API -> startRemoteView:" + anchorInfo.userID + ":" + anchorInfo.accelerateURL);
        //主线程启动播放
        Handler handler = new Handler(mAppContext.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (mPlayers.containsKey(anchorInfo.userID)) {
                    PlayerItem pusherPlayer = mPlayers.get(anchorInfo.userID);
                    if (pusherPlayer.player.isPlaying()) {
                        //已经在播放
                        return;
                    } else {
                        pusherPlayer = mPlayers.remove(anchorInfo.userID);
                        pusherPlayer.destroy();
                    }
                }

                if (mSelfRoleType == LIVEROOM_ROLE_PUSHER) {
                    if (mPlayers.size() == 0) {
                        if (mTXLivePusher != null) {
                            if (mMixMode == STREAM_MIX_MODE_PK) {
                                //PK
                                mTXLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER, true, true);
                                TXLivePushConfig config = mTXLivePusher.getConfig();
                                config.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640);
                                config.setAutoAdjustBitrate(false);
                                config.setVideoBitrate(800);
                                mTXLivePusher.setConfig(config);
                            } else {
                                //连麦，设置推流Quality为VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER
                                mTXLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER, true, false);
                            }
                        }
                    }
                }

                final TXLivePlayer player = new TXLivePlayer(mAppContext);

                view.setVisibility(View.VISIBLE);
                player.setPlayerView(view);
                player.enableHardwareDecode(true);
                player.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);

                PlayerItem anchorPlayer = new PlayerItem(view, anchorInfo, player);
                mPlayers.put(anchorInfo.userID, anchorPlayer);

                player.setPlayListener(new ITXLivePlayListener() {
                    @Override
                    public void onPlayEvent(final int event, final Bundle param) {
                        if (event == TXLiveConstants.PLAY_EVT_PLAY_BEGIN) {
                            if (mSelfRoleType == LIVEROOM_ROLE_PUSHER) {
                                //主播进行混流
                                if (mMixMode == STREAM_MIX_MODE_PK) {
                                    mStreamMixturer.addPKVideoStream(anchorInfo.accelerateURL);
                                } else {
                                    mStreamMixturer.addSubVideoStream(anchorInfo.accelerateURL);
                                }
                            }
                            callbackOnThread(callback, "onBegin");
                        }
                        else if (event == TXLiveConstants.PLAY_EVT_PLAY_END || event == TXLiveConstants.PLAY_ERR_NET_DISCONNECT){
                            callbackOnThread(callback, "onError", event, "[LivePlayer] 播放异常[" + param.getString(TXLiveConstants.EVT_DESCRIPTION) + "]");

                            //结束播放
//                        if (mPlayers.containsKey(anchorInfo.userID)) {
//                            PlayerItem item = mPlayers.remove(anchorInfo.userID);
//                            if (item != null) {
//                                item.destroy();
//                            }
//                        }
                        }
                        else {
                            callbackOnThread(callback, "onEvent", event, param);
                        }
                    }

                    @Override
                    public void onNetStatus(Bundle status) {

                    }
                });

                int result = player.startPlay(anchorInfo.accelerateURL, TXLivePlayer.PLAY_TYPE_LIVE_RTMP_ACC);
                if (result != 0){
                    TXCLog.e(TAG, String.format("[BaseRoom] 播放成员 {%s} 地址 {%s} 失败", anchorInfo.userID, anchorInfo.accelerateURL));
                }
            }
        });
    }

    /**
     * 停止渲染远端视频画面
     *
     * @param anchorInfo 对方的用户信息
     */
    @Override
    public void stopRemoteView(final AnchorInfo anchorInfo) {
        TXCLog.i(TAG, "API -> stopRemoteView:" + anchorInfo.userID);
        if (anchorInfo == null || anchorInfo.userID == null) {
            return;
        }
        Handler handler = new Handler(mAppContext.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (mPlayers.containsKey(anchorInfo.userID)){
                    PlayerItem pusherPlayer = mPlayers.remove(anchorInfo.userID);
                    pusherPlayer.destroy();
                }

                if (mPushers.containsKey(anchorInfo.userID)) {
                    mPushers.remove(anchorInfo.userID);
                }

                if (mSelfRoleType == LIVEROOM_ROLE_PUSHER) {
                    //主播混流删除一路
                    if (mMixMode == STREAM_MIX_MODE_PK) {
                        mStreamMixturer.delPKVideoStream(anchorInfo.accelerateURL);
                    } else {
                        mStreamMixturer.delSubVideoStream(anchorInfo.accelerateURL);
                    }
                    if (mPlayers.size() == 0) {
                        //没有播放流了，切换推流回直播模式
                        if (mTXLivePusher != null) {
                            mTXLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION, false, false);
                            TXLivePushConfig config = mTXLivePusher.getConfig();
                            config.setVideoEncodeGop(2);
                            mTXLivePusher.setConfig(config);
                        }
                    }
                }
            }
        });
    }

    /**
     * 启动录屏。
     *
     */
    public synchronized void startScreenCapture() {
        TXCLog.i(TAG, "API -> startScreenCapture");
        initLivePusher(true);
        if (mTXLivePusher != null) {
            mTXLivePusher.startScreenCapture();
        }
        mPreviewType = LIVEROOM_SCREEN_PREVIEW;
    }

    /**
     * 结束录屏。
     *
     */
    public synchronized void stopScreenCapture() {
        TXCLog.i(TAG, "API -> stopScreenCapture");
        if (mTXLivePusher != null) {
            mTXLivePusher.stopScreenCapture();
        }
    }

    /**
     * 是否屏蔽本地音频
     *
     * @param mute true:屏蔽 false:开启
     */
    @Override
    public void muteLocalAudio(boolean mute) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setMute(mute);
        }
    }

    /**
     * 设置背景音乐的回调接口
     *
     * @param notify 回调接口
     */
    public void setBGMNofify(TXLivePusher.OnBGMNotify notify) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setBGMNofify(notify);
        }
    }

    /**
     * 设置指定用户是否静音
     *
     * @param userID 对方的用户标识
     * @param mute   true:静音 false:非静音
     */
    @Override
    public void muteRemoteAudio(String userID, boolean mute) {
        if (mPlayers.containsKey(userID)){
            PlayerItem pusherPlayer = mPlayers.get(userID);
            pusherPlayer.player.setMute(mute);
        } else if (userID == getRoomCreator(mCurrRoomID)) {
            //大主播
            mTXLivePlayer.setMute(mute);
        }
    }

    /**
     * 设置所有远端用户是否静音
     *
     * @param mute true:静音 false:非静音
     */
    @Override
    public void muteAllRemoteAudio(boolean mute) {
        for (Map.Entry<String, PlayerItem> entry : mPlayers.entrySet()) {
            entry.getValue().player.setMute(mute);
        }
        if (mTXLivePlayer != null && mTXLivePlayer.isPlaying()) {
            mTXLivePlayer.setMute(mute);
        }
    }

    /**
     * 切换摄像头
     */
    @Override
    public void switchCamera() {
        if (mTXLivePusher != null) {
            mTXLivePusher.switchCamera();
        }
    }

    /**
     * 设置摄像头缩放因子（焦距）
     *
     * @param distance 取值范围 1 - 5 ，当为1的时候为最远视角（正常镜头），当为5的时候为最近视角（放大镜头），这里最大值推荐为5，超过5后视频数据会变得模糊不清
     *
     * @return false：调用失败；true：调用成功
     */
    @Override
    public boolean setZoom(int distance) {
        if (mTXLivePusher != null) {
            return mTXLivePusher.setZoom(distance);
        }
        return false;
    }

    /**
     * 开关闪光灯
     *
     * @param enable true：开启；false：关闭
     *
     * @return false：调用失败；true：调用成功
     */
    @Override
    public boolean enableTorch(boolean enable) {
        if (mTXLivePusher != null) {
            return mTXLivePusher.turnOnFlashLight(enable);
        }
        return false;
    }

    /**
     * 主播屏蔽摄像头期间需要显示的等待图片
     *
     * 当主播屏蔽摄像头，或者由于 App 切入后台无法使用摄像头的时候，我们需要使用一张等待图片来提示观众“主播暂时离开，请不要走开”。
     *
     * @param bitmap 位图
     */
    @Override
    public void setCameraMuteImage(Bitmap bitmap) {
        if (mTXLivePusher != null) {
            TXLivePushConfig config = mTXLivePusher.getConfig();
            config.setPauseImg(bitmap);
            config.setPauseFlag(TXLiveConstants.PAUSE_FLAG_PAUSE_VIDEO | TXLiveConstants.PAUSE_FLAG_PAUSE_AUDIO);
            mTXLivePusher.setConfig(config);
        }
    }

    /**
     * 主播屏蔽摄像头期间需要显示的等待图片
     *
     * 当主播屏蔽摄像头，或者由于 App 切入后台无法使用摄像头的时候，我们需要使用一张等待图片来提示观众“主播暂时离开，请不要走开”。
     *
     * @param id 设置默认显示图片的资源文件
     */
    @Override
    public void setCameraMuteImage(int id) {
        Bitmap bitmap = BitmapFactory.decodeResource(mAppContext.getResources(), id);
        if (mTXLivePusher != null) {
            TXLivePushConfig config = mTXLivePusher.getConfig();
            config.setPauseImg(bitmap);
            config.setPauseFlag(TXLiveConstants.PAUSE_FLAG_PAUSE_VIDEO | TXLiveConstants.PAUSE_FLAG_PAUSE_AUDIO);
            mTXLivePusher.setConfig(config);
        }
    }

    /**
     * 设置美颜、美白、红润效果级别
     *
     * @param beautyStyle    美颜风格，三种美颜风格：0 ：光滑；1：自然；2：朦胧
     * @param beautyLevel    美颜级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显
     * @param whitenessLevel 美白级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显
     * @param ruddinessLevel 红润级别，取值范围 0 - 9； 0 表示关闭， 1 - 9值越大，效果越明显
     */
    @Override
    public boolean setBeautyStyle(int beautyStyle, int beautyLevel, int whitenessLevel, int ruddinessLevel) {
        if (mTXLivePusher != null) {
            return mTXLivePusher.setBeautyFilter(beautyStyle, beautyLevel, whitenessLevel, ruddinessLevel);
        }
        return false;
    }

    /**
     * 设置指定素材滤镜特效
     *
     * @param image 指定素材，即颜色查找表图片。注意：一定要用 png 格式！！！
     */
    @Override
    public void setFilter(Bitmap image) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setFilter(image);
        }
    }

    /**
     * 设置滤镜浓度
     *
     * @param concentration 从0到1，越大滤镜效果越明显，默认取值0.5
     */
    @Override
    public void setFilterConcentration(float concentration) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setSpecialRatio(concentration);
        }
    }

    /**
     * 添加水印，height 不用设置，sdk 内部会根据水印宽高比自动计算 height
     *
     * @param image      水印图片 null 表示清除水印
     * @param x          归一化水印位置的 X 轴坐标，取值[0,1]
     * @param y          归一化水印位置的 Y 轴坐标，取值[0,1]
     * @param width      归一化水印宽度，取值[0,1]
     */
    @Override
    public void setWatermark(Bitmap image, float x, float y, float width) {
        if (mTXLivePusher != null) {
            TXLivePushConfig config = mTXLivePusher.getConfig();
            config.setWatermark(image, x, y, width);
            mTXLivePusher.setConfig(config);
        }
    }

    /**
     * 设置动效贴图
     *
     * @param filePath 动态贴图文件路径
     */
    @Override
    public void setMotionTmpl(String filePath) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setMotionTmpl(filePath);
        }
    }

    /**
     * 设置绿幕文件
     *
     * 目前图片支持jpg/png，视频支持mp4/3gp等Android系统支持的格式
     *
     * @param file 绿幕文件位置，支持两种方式：
     *             1.资源文件放在assets目录，path直接取文件名
     *             2.path取文件绝对路径
     *
     * @return false：调用失败；true：调用成功
     * @note API要求18
     */
    @Override
    public boolean setGreenScreenFile(String file) {
        if (mTXLivePusher != null) {
            return mTXLivePusher.setGreenScreenFile(file);
        }
        return false;
    }

    /**
     * 设置大眼效果
     *
     * @param level 大眼等级取值为 0 ~ 9。取值为0时代表关闭美颜效果。默认值：0
     */
    @Override
    public void setEyeScaleLevel(int level) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setEyeScaleLevel(level);
        }
    }

    /**
     * 设置V脸（特权版本有效，普通版本设置此参数无效）
     *
     * @param level V脸级别取值范围 0 ~ 9。数值越大，效果越明显。默认值：0
     */
    @Override
    public void setFaceVLevel(int level) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setFaceVLevel(level);
        }
    }

    /**
     * 设置瘦脸效果
     *
     * @param level 瘦脸等级取值为 0 ~ 9。取值为0时代表关闭美颜效果。默认值：0
     */
    @Override
    public void setFaceSlimLevel(int level) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setFaceSlimLevel(level);
        }
    }

    /**
     * 设置短脸（特权版本有效，普通版本设置此参数无效）
     *
     * @param level 短脸级别取值范围 0 ~ 9。 数值越大，效果越明显。默认值：0
     */
    @Override
    public void setFaceShortLevel(int level) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setFaceShortLevel(level);
        }
    }

    /**
     * 设置下巴拉伸或收缩（特权版本有效，普通版本设置此参数无效）
     *
     * @param chinLevel 下巴拉伸或收缩级别取值范围 -9 ~ 9。数值越大，拉伸越明显。默认值：0
     */
    @Override
    public void setChinLevel(int chinLevel) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setChinLevel(chinLevel);
        }
    }

    /**
     * 设置瘦鼻（特权版本有效，普通版本设置此参数无效）
     *
     * @param noseSlimLevel 瘦鼻级别取值范围 0 ~ 9。数值越大，效果越明显。默认值：0
     */
    @Override
    public void setNoseSlimLevel(int noseSlimLevel) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setNoseSlimLevel(noseSlimLevel);
        }
    }

    /**
     * 调整曝光
     *
     * @param value 曝光比例，表示该手机支持最大曝光调整值的比例，取值范围从-1 - 1。
     *              负数表示调低曝光，-1是最小值；正数表示调高曝光，1是最大值；0表示不调整曝光
     */
    public void setExposureCompensation(float value) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setExposureCompensation(value);
        }
    }

    /**
     * 发送文本消息
     *
     * @param message 文本消息
     * @param callback 发送消息的结果回调
     * @see {@link IMLVBLiveRoomListener#onRecvRoomTextMsg(String, String, String, String, String)}
     */
    @Override
    public void sendRoomTextMsg(String message, final IMLVBLiveRoomListener.SendRoomTextMsgCallback callback) {
        IMMessageMgr imMessageMgr = mIMMessageMgr;
        if (imMessageMgr != null) {
            imMessageMgr.sendGroupTextMessage(mSelfAccountInfo.userName, mSelfAccountInfo.userAvatar, message, new IMMessageMgr.Callback() {
                @Override
                public void onError(final int code, final String errInfo) {
                    String msg = "[IM] 消息发送失败[" + errInfo + ":" + code + "]";
                    TXCLog.e(TAG, msg);
                    callbackOnThread(callback, "onError", code, msg);
                }

                @Override
                public void onSuccess(Object... args) {
                    callbackOnThread(callback, "onSuccess");
                }
            });
        }
    }

    /**
     * 发送自定义文本消息
     *
     * @param cmd     命令字，由开发者自定义，主要用于区分不同消息类型
     * @param message 文本消息
     * @param callback 发送消息的结果回调
     * @see {@link IMLVBLiveRoomListener#onRecvRoomCustomMsg(String, String, String, String, String, String)}
     */
    @Override
    public void sendRoomCustomMsg(String cmd, String message, final IMLVBLiveRoomListener.SendRoomCustomMsgCallback callback) {
        CommonJson<CustomMessage> customMessage = new CommonJson<>();
        customMessage.cmd = "CustomCmdMsg";
        customMessage.data = new CustomMessage();
        customMessage.data.userName = mSelfAccountInfo.userName;
        customMessage.data.userAvatar = mSelfAccountInfo.userAvatar;
        customMessage.data.cmd = cmd;
        customMessage.data.msg = message ;
        final String content = new Gson().toJson(customMessage, new TypeToken<CommonJson<CustomMessage>>(){}.getType());
        IMMessageMgr imMessageMgr = mIMMessageMgr;
        if (imMessageMgr != null) {
            imMessageMgr.sendGroupCustomMessage(content, new IMMessageMgr.Callback() {
                @Override
                public void onError(int code, String errInfo) {
                    String msg = "[IM] 自定义消息发送失败[" + errInfo + ":" + code + "]";
                    TXCLog.e(TAG, msg);
                    callbackOnThread(callback, "onError", code, msg);
                }

                @Override
                public void onSuccess(Object... args) {
                    callbackOnThread(callback, "onSuccess");
                }
            });
        }
    }

    /**
     * 播放背景音乐
     *
     * @param path 背景音乐文件路径
     * @return true：播放成功；false：播放失败
     */
    @Override
    public boolean playBGM(String path) {
        if (mTXLivePusher != null) {
            return mTXLivePusher.playBGM(path);
        }
        return false;
    }

    /**
     * 停止播放背景音乐
     */
    @Override
    public void stopBGM() {
        if (mTXLivePusher != null) {
            mTXLivePusher.stopBGM();
        }
    }

    /**
     * 暂停播放背景音乐
     */
    @Override
    public void pauseBGM() {
        if (mTXLivePusher != null) {
            mTXLivePusher.pauseBGM();
        }
    }

    /**
     * 继续播放背景音乐
     */
    @Override
    public void resumeBGM() {
        if (mTXLivePusher != null) {
            mTXLivePusher.resumeBGM();
        }
    }

    /**
     * 获取音乐文件总时长
     *
     * @param path 音乐文件路径，如果 path 为空，那么返回当前正在播放的 music 时长
     * @return 成功返回时长，单位毫秒，失败返回-1
     */
    @Override
    public int getBGMDuration(String path) {
        if (mTXLivePusher != null) {
            return mTXLivePusher.getMusicDuration(path);
        }
        return 0;
    }

    /**
     * 设置麦克风的音量大小，播放背景音乐混音时使用，用来控制麦克风音量大小
     *
     * @param volume : 音量大小，100为正常音量，建议值为0 - 200
     */
    @Override
    public void setMicVolumeOnMixing(int volume) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setMicVolume(volume/100.0f);
        }
    }

    /**
     * 设置背景音乐的音量大小，播放背景音乐混音时使用，用来控制背景音音量大小
     *
     * @param volume 音量大小，100为正常音量，建议值为0 - 200，如果需要调大背景音量可以设置更大的值
     */
    @Override
    public void setBGMVolume(int volume) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setBGMVolume(volume/100.0f);
        }
    }

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
    @Override
    public void setReverbType(int reverbType) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setReverb(reverbType);
        }
    }

    /**
     * 设置变声类型
     *
     * @param voiceChangerType 变声类型，详见 TXVoiceChangerType
     */
    @Override
    public void setVoiceChangerType(int voiceChangerType) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setVoiceChangerType(voiceChangerType);
        }
    }

    /**
     * 设置背景音乐的音调。
     *
     * 该接口用于混音处理,比如将背景音乐与麦克风采集到的声音混合后播放。
     *
     * @param pitch 音调，0为正常音量，范围是 -1 - 1。
     */
    public void setBGMPitch(float pitch) {
        if (mTXLivePusher != null) {
            mTXLivePusher.setBGMPitch(pitch);
        }
    }

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
    public boolean setBGMPosition(int position) {
        if (mTXLivePusher != null) {
            return mTXLivePusher.setBGMPosition(position);
        }
        return false;
    }

    protected MLVBLiveRoomImpl(Context context) {
        if (context == null) {
            throw new InvalidParameterException("MLVBLiveRoom初始化错误：context不能为空！");
        }
        mAppContext = context.getApplicationContext();
        mListenerHandler = new Handler(mAppContext.getMainLooper());
        mStreamMixturer = new StreamMixturer();
        mHeartBeatThread = new HeartBeatThread();

        mTXLivePlayConfig = new TXLivePlayConfig();
        mTXLivePlayer = new TXLivePlayer(context);
        mTXLivePlayConfig.setAutoAdjustCacheTime(true);
        mTXLivePlayConfig.setMaxAutoAdjustCacheTime(2.0f);
        mTXLivePlayConfig.setMinAutoAdjustCacheTime(2.0f);
        mTXLivePlayer.setConfig(mTXLivePlayConfig);
        mTXLivePlayer.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);
        mTXLivePlayer.setPlayListener(new ITXLivePlayListener() {
            @Override
            public void onPlayEvent(final int event, final Bundle param) {
                if (event == TXLiveConstants.PLAY_ERR_NET_DISCONNECT) {
                    String msg = "[LivePlayer] 拉流失败[" + param.getString(TXLiveConstants.EVT_DESCRIPTION) + "]";
                    TXCLog.e(TAG, msg);
                    callbackOnThread(mListener, "onDebugLog", msg);
                    callbackOnThread(mListener, "onError", event, msg, param);
                } else if (event == TXLiveConstants.PLAY_EVT_CHANGE_RESOLUTION) {
                    int width = param.getInt(TXLiveConstants.EVT_PARAM1, 0);
                    int height = param.getInt(TXLiveConstants.EVT_PARAM2, 0);
                    if (width > 0 && height > 0) {
                        float ratio = (float) height / width;
                        //pc上混流后的宽高比为4:5，这种情况下填充模式会把左右的小主播窗口截掉一部分，用适应模式比较合适
                        if (ratio > 1.3f) {
                            mTXLivePlayer.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);
                        } else {
                            mTXLivePlayer.setRenderMode(TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION);
                        }
                    }
                }
            }

            @Override
            public void onNetStatus(Bundle status) {

            }
        });
    }

    private void destroy() {
        //TODO
        mHeartBeatThread.quit();
    }



    protected void startPushStream(final String url, final int videoQuality, final StandardCallback callback){
        //在主线程开启推流
        Handler handler = new Handler(mAppContext.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (mTXLivePusher != null && mTXLivePushListener != null) {
                    mTXLivePushListener.setCallback(callback);
                    mTXLivePusher.setVideoQuality(videoQuality, false, false);
                    int ret = mTXLivePusher.startPusher(url);
                    if (ret == -5) {
                        String msg = "[LiveRoom] 推流失败[license 校验失败]";
                        TXCLog.e(TAG, msg);
                        if (callback != null) callback.onError(LiveRoomErrorCode.ERROR_LICENSE_INVALID, msg);
                    }
                } else {
                    String msg = "[LiveRoom] 推流失败[TXLivePusher未初始化，请确保已经调用startLocalPreview]";
                    TXCLog.e(TAG, msg);
                    if (callback != null) callback.onError(LiveRoomErrorCode.ERROR_PUSH, msg);
                }
            }
        });
    }

    protected void doCreateRoom(final String roomID, String roomInfo, final StandardCallback callback){
        mHttpRequest.createRoom(roomID, mSelfAccountInfo.userID, roomInfo,
                new HttpRequests.OnResponseCallback<HttpResponse.CreateRoom>() {
                    @Override
                    public void onResponse(int retcode, String retmsg, HttpResponse.CreateRoom data) {
                        if (retcode != HttpResponse.CODE_OK || data == null || data.roomID == null) {
                            String msg = "[LiveRoom] 创建房间错误[" + retmsg + ":" + retcode + "]";
                            TXCLog.e(TAG, msg);
                            callback.onError(retcode, msg);
                        } else {
                            TXCLog.d(TAG, "[LiveRoom] 创建直播间 ID[" + data.roomID + "] 成功 ");
                            mCurrRoomID = data.roomID;
                            callback.onSuccess();
                        }
                    }//onResponse
                });
    }

    protected void addAnchor(final String roomID, final String pushURL, final StandardCallback callback) {
        mHasAddAnchor = true;
        mHttpRequest.addPusher(roomID,
                mSelfAccountInfo.userID,
                mSelfAccountInfo.userName,
                mSelfAccountInfo.userAvatar,
                pushURL, new HttpRequests.OnResponseCallback<HttpResponse>() {
                    @Override
                    public void onResponse(int retcode, String retmsg, HttpResponse data) {
                        if (retcode == HttpResponse.CODE_OK) {
                            TXCLog.d(TAG, "[LiveRoom] add pusher 成功");
                            callback.onSuccess();
                        } else {
                            String msg = "[LiveRoom] add pusher 失败[" + retmsg + ":" + retcode + "]";
                            TXCLog.e(TAG, msg);
                            callback.onError(retcode, msg);
                        }
                    }
                });
    }

    protected void createIMGroup(final String groupId, final String groupName, final StandardCallback callback) {
        IMMessageMgr imMessageMgr = mIMMessageMgr;
        if (imMessageMgr != null) {
            imMessageMgr.createGroup(groupId, "AVChatRoom", groupName, new IMMessageMgr.Callback() {
                @Override
                public void onError(int code, String errInfo) {
                    String msg = "[IM] 创建群失败[" + errInfo + ":" + code + "]";
                    TXCLog.e(TAG, "msg");
                    callback.onError(code, msg);
                }

                @Override
                public void onSuccess(Object... args) {
                    callback.onSuccess();
                }
            });
        }
    }

    protected void jionIMGroup(final String roomID, final StandardCallback callback){
        IMMessageMgr imMessageMgr = mIMMessageMgr;
        if (imMessageMgr != null) {
            imMessageMgr.jionGroup(roomID, new IMMessageMgr.Callback() {
                @Override
                public void onError(int code, String errInfo) {
                    String msg = "[IM] 进群失败[" + errInfo + ":" + code + "]";
                    TXCLog.e(TAG, msg);
                    callback.onError(code, msg);
                }

                @Override
                public void onSuccess(Object... args) {
                    callback.onSuccess();
                }
            });
        }
    }

    private void notifyPusherChange() {
        //通知房间内其他主播
        CommonJson<AnchorInfo> msg = new CommonJson<>();
        msg.cmd = "notifyPusherChange";
        msg.data = new AnchorInfo();
        msg.data.userID = mSelfAccountInfo.userID;
        String content = new Gson().toJson(msg, new TypeToken<CommonJson<AnchorInfo>>(){}.getType());
        IMMessageMgr imMessageMgr = mIMMessageMgr;
        if (imMessageMgr != null) {
            imMessageMgr.sendGroupCustomMessage(content, new IMMessageMgr.Callback() {
                @Override
                public void onError(int code, String errInfo) {
                    TXCLog.e(TAG, "[IM] 发送房间列表更新通知失败[" + errInfo + ":" + code + "]");
                }

                @Override
                public void onSuccess(Object... args) {
                    TXCLog.d(TAG, "发送房间列表更新通知成功");
                }
            });
        }
    }

    protected void cleanPlayers() {
        synchronized (this) {
            for (Map.Entry<String, PlayerItem> entry : mPlayers.entrySet()) {
                entry.getValue().destroy();
            }
            mPlayers.clear();
        }
    }

    protected void updateAnchors(final boolean excludeRoomCreator, final UpdateAnchorsCallback callback){
        mHttpRequest.getPushers(mCurrRoomID, new HttpRequests.OnResponseCallback<HttpResponse.PusherList>() {
            @Override
            public void onResponse(final int retcode, String retmsg, final HttpResponse.PusherList data) {
                callbackOnThread(new Runnable() {
                    @Override
                    public void run() {
                        if (retcode == HttpResponse.CODE_OK) {
                            if (data != null) {
                                mRoomStatusCode = data.roomStatusCode;
                            }
                            parsePushers(excludeRoomCreator, data, callback);
                        } else {
                            TXCLog.e(TAG, "更新主播列表失败");
                            callbackOnThread(mListener, "onDebugLog", "[LiveRoom] 获取主播列表失败");
                            if (callback != null) {
                                callback.onUpdateAnchors(-1, null, null, null, null);
                            }
                        }
                    }
                });
            }
        });
    }

    protected void parsePushers(final boolean excludeRoomCreator, final HttpResponse.PusherList data, UpdateAnchorsCallback callback) {
        if (data != null && data.pushers != null && data.pushers.size() > 0) {
            AnchorInfo roomCreator = new AnchorInfo();
            List<AnchorInfo> anchorList = data.pushers;
            if (excludeRoomCreator) {
                if (anchorList != null && anchorList.size() > 0) {
                    Iterator<AnchorInfo> it = anchorList.iterator();
                    while (it.hasNext()) {
                        AnchorInfo anchor = it.next();
                        // 从房间成员列表里过滤过大主播（房间创建者）
                        if (anchor.userID != null) {
                            if (anchor.userID.equalsIgnoreCase(getRoomCreator(mCurrRoomID))) {
                                roomCreator = anchor;
                                it.remove();
                                break;
                            }
                        }
                    }
                }
            }

            final List<AnchorInfo> addAnchors = new ArrayList<>();
            final List<AnchorInfo> delAnchors = new ArrayList<>();
            HashMap<String, AnchorInfo> mergedAnchors = new HashMap<String, AnchorInfo>();

            //合并主播列表，区分哪些是新增，哪些退房
            mergerAnchors(anchorList, addAnchors, delAnchors, mergedAnchors);

            //回调主播(大主播和连麦观众)进退房通知
            callbackOnThread(new Runnable() {
                @Override
                public void run() {
                    IMLVBLiveRoomListener listener = mListener;
                    if (listener != null) {
                        for (AnchorInfo member : addAnchors) {
                            listener.onDebugLog(String.format("[LiveRoom] onPusherJoin, UserID {%s} PlayUrl {%s}", member.userID, member.accelerateURL));
                            listener.onAnchorEnter(member);
                        }
                        for (AnchorInfo member : delAnchors) {
                            listener.onDebugLog(String.format("[LiveRoom] onPusherQuit, UserID {%s} PlayUrl {%s}", member.userID, member.accelerateURL));
                            listener.onAnchorExit(member);
                        }
                    }
                }
            });

//            //混流
//            mixtureStream(addAnchors, delAnchors);

//            if (mSelfRoleType == LIVEROOM_ROLE_PUSHER) {
//                if (mPushers.size() == 0 && mergedAnchors.size() > 0) {
//                    //开始连麦，设置推流Quality为VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER
//                    if (mTXLivePusher != null) {
//                        mTXLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER, true, false);
//                    }
//                }
//                if (mPushers.size() > 0 && mergedAnchors.size() == 0) {
//                    //停止连麦，恢复推流Quality为VIDEO_QUALITY_HIGH_DEFINITION
//                    if (mTXLivePusher != null) {
//                        mTXLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION, false, false);
//                        TXLivePushConfig config = mTXLivePusher.getConfig();
//                        config.setVideoEncodeGop(5);
//                        mTXLivePusher.setConfig(config);
//                    }
//                }
//            }


            callbackOnThread(mListener, "onDebugLog", String.format("[LiveRoom] 更新主播列表 new(%d), remove(%d)", addAnchors.size(), delAnchors.size()));

            if (callback != null) {
                callback.onUpdateAnchors(0, addAnchors, delAnchors, mergedAnchors, roomCreator);
            }

            mPushers = mergedAnchors;
        }
        else {
            TXCLog.e(TAG, "更新主播列表返回空数据");
            if (callback != null) {
                callback.onUpdateAnchors(-1, null, null, null, null);
            }
        }
    }

    protected void mergerAnchors(List<AnchorInfo> anchors, List<AnchorInfo> addAnchors, List<AnchorInfo> delAnchors, HashMap<String, AnchorInfo> mergedAnchors){
        if (anchors == null) {
            //主播列表为空，意味着所有主播都已经退房
            if (delAnchors != null) {
                delAnchors.clear();
                for (Map.Entry<String, AnchorInfo> entry : mPushers.entrySet()) {
                    delAnchors.add(entry.getValue());
                }
            }
            mPushers.clear();
            return;
        }

        for (AnchorInfo member : anchors) {
            if (member.userID != null && (!member.userID.equals(mSelfAccountInfo.userID))){
                if (!mPushers.containsKey(member.userID)) {
                    if (addAnchors != null) {
                        addAnchors.add(member);
                    }
                }
                mergedAnchors.put(member.userID, member);
            }
        }

        if (delAnchors != null) {
            for (Map.Entry<String, AnchorInfo> entry : mPushers.entrySet()) {
                if (!mergedAnchors.containsKey(entry.getKey())) {
                    delAnchors.add(entry.getValue());
                }
            }
        }
    }

    protected void mixtureStream(List<AnchorInfo> addAnchors, List<AnchorInfo> delAnchors) {
        for (AnchorInfo member : addAnchors) {
            mStreamMixturer.addSubVideoStream(member.accelerateURL);
        }
        for (AnchorInfo member : delAnchors) {
            mStreamMixturer.delSubVideoStream(member.accelerateURL);
        }
    }

    protected String getMixedPlayUrlByRoomID(String roomID) {
        for (RoomInfo item : mRoomList) {
            if (item.roomID != null && item.roomID.equalsIgnoreCase(roomID)) {
                return item.mixedPlayURL;
            }
        }
        return null;
    }

    protected int getPlayType(String playUrl) {
        int playType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;
        if (playUrl.startsWith("rtmp://")) {
            playType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;
        } else if ((playUrl.startsWith("http://") || playUrl.startsWith("https://")) && playUrl.contains(".flv")) {
            playType = TXLivePlayer.PLAY_TYPE_LIVE_FLV;
        }
        return playType;
    }

    protected String getRoomCreator(String roomID) {
        for (RoomInfo item: mRoomList) {
            if (roomID.equalsIgnoreCase(item.roomID)) {
                return item.roomCreator;
            }
        }
        return null;
    }


    protected void initLivePusher(boolean frontCamera) {
        if (mTXLivePusher == null) {
            TXLivePushConfig config = new TXLivePushConfig();
            config.setFrontCamera(frontCamera);
            config.enableScreenCaptureAutoRotate(mScreenAutoEnable);// 是否开启屏幕自适应
            config.setPauseFlag(TXLiveConstants.PAUSE_FLAG_PAUSE_VIDEO | TXLiveConstants.PAUSE_FLAG_PAUSE_AUDIO);
            mTXLivePusher = new TXLivePusher(mAppContext);
            mTXLivePusher.setConfig(config);
            mTXLivePusher.setBeautyFilter(TXLiveConstants.BEAUTY_STYLE_SMOOTH, 5, 3, 2);
            mTXLivePushListener = new TXLivePushListenerImpl();
            mTXLivePusher.setPushListener(mTXLivePushListener);
        }
    }

    protected void unInitLivePusher() {
        if (mTXLivePusher != null) {
            mSelfPushUrl = "";
            mTXLivePushListener = null;
            mTXLivePusher.setPushListener(null);
            if (mPreviewType == LIVEROOM_CAMERA_PREVIEW) {
                mTXLivePusher.stopCameraPreview(true);
            } else {
                mTXLivePusher.stopScreenCapture();
            }
            mTXLivePusher.stopPusher();
            mTXLivePusher = null;
        }
    }

    private void onRecvLinkMicMessage(final String message) {
        try {
            final JoinAnchorRequest request = new Gson().fromJson(message, JoinAnchorRequest.class);
            if (request != null && request.type.equalsIgnoreCase("request")) {
                if (isCmdTimeOut(request.timestamp)) {
                    TXCLog.e(TAG, "[LiveRoom] 请求连麦信令超时");
                    return;
                }
                if (request.roomID.equalsIgnoreCase(mCurrRoomID)) {
                    if (mPushers.containsKey(request.userID)) {
                        //观众已经加入连麦
                        return;
                    }
                    if (mListener == null) {
                        TXCLog.w(TAG, "no deal with link mic request message. listener = null. msg = " + message);
                        return;
                    }
                    AnchorInfo info = new AnchorInfo(request.userID, request.userName, request.userAvatar, "");
                    callbackOnThread(mListener, "onDebugLog", String.format("[LiveRoom] 收到连麦请求, UserID {%s} UserName {%s}", request.userID, request.userName));
                    callbackOnThread(mListener, "onRequestJoinAnchor", info, request.reason);
                }
                return;
            }

            final JoinAnchorResponse response = new Gson().fromJson(message, JoinAnchorResponse.class);
            if (response != null && response.type.equalsIgnoreCase("response")) {
                if (isCmdTimeOut(response.timestamp)) {
                    TXCLog.e(TAG, "[LiveRoom] 响应连麦请求信令超时");
                    return;
                }
                if (mJoinAnchorCallback == null) {
                    TXCLog.w(TAG, "no deal with join anchor response message. mJoinAnchorCallback = null. msg = " + message);
                    return;
                }
                if (response.roomID.equalsIgnoreCase(mCurrRoomID)) {
                    String result = response.result;
                    if (result != null) {
                        if (result.equalsIgnoreCase("accept")) {
                            callbackOnThread(new Runnable() {
                                @Override
                                public void run() {
                                    mJoinAnchorCallback.onAccept();
                                    mJoinAnchorCallback = null;
                                    mListenerHandler.removeCallbacks(mJoinAnchorTimeoutTask);
                                }
                            });
                            return;
                        } else if (result.equalsIgnoreCase("reject")) {
                            callbackOnThread(new Runnable() {
                                @Override
                                public void run() {
                                    mJoinAnchorCallback.onReject(response.reason);
                                    mJoinAnchorCallback = null;
                                    mListenerHandler.removeCallbacks(mJoinAnchorTimeoutTask);
                                }
                            });
                            return;
                        }
                    }
                    callbackOnThread(new Runnable() {
                        @Override
                        public void run() {
                            mJoinAnchorCallback.onError(LiveRoomErrorCode.ERROR_PARAMETERS_INVALID, "[LiveRoom] 无法识别的连麦响应[" + message + "]");
                            mJoinAnchorCallback = null;
                            mListenerHandler.removeCallbacks(mJoinAnchorTimeoutTask);
                        }
                    });
                }
                return;
            }

            KickoutResponse kickreq = new Gson().fromJson(message, KickoutResponse.class);
            if (kickreq != null && kickreq.type.equalsIgnoreCase("kickout")) {
                if (isCmdTimeOut(kickreq.timestamp)) {
                    TXCLog.e(TAG, "[LiveRoom] 踢人请求信令超时");
                    return;
                }
                if (kickreq.roomID.equalsIgnoreCase(mCurrRoomID)) {
                    if (mListener == null) {
                        TXCLog.w(TAG, "no deal with kickout message. listener = null. msg = " + message);
                        return;
                    }
                    callbackOnThread(mListener, "onDebugLog", "[LiveRoom] 被主播踢出连麦");
                    callbackOnThread(mListener, "onKickoutJoinAnchor");
                }
                return;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void onRecvPKMessage(final String message) {
        try {
            final PKRequest request = new Gson().fromJson(message, PKRequest.class);
            if (request != null && request.type.equalsIgnoreCase("request")) {
                if (mListener == null) {
                    TXCLog.w(TAG, "can not deal with PK reqeust. mListener = null");
                    return;
                }
                if (request.action.equalsIgnoreCase("start")) {
                    if (mPKAnchorInfo == null) {
                        mPKAnchorInfo = new AnchorInfo(request.userID, request.userName, request.userAvatar, request.accelerateURL);
                    }
                    AnchorInfo info = new AnchorInfo(request.userID, request.userName, request.userAvatar, request.accelerateURL);
                    callbackOnThread(mListener, "onDebugLog", String.format("[LiveRoom] 收到PK请求, UserID {%s} UserName {%s}", request.userID, request.userName));
                    callbackOnThread(mListener, "onRequestRoomPK", info);
                } else if (request.action.equalsIgnoreCase("stop")) {
                    callbackOnThread(mListener, "onDebugLog", String.format("[LiveRoom] 对方主播停止PK, UserID {%s} UserName {%s}", request.userID, request.userName));
                    callbackOnThread(mListener, "onQuitRoomPK", mPKAnchorInfo);
                }
                return;
            }

            final PKResponse response = new Gson().fromJson(message, PKResponse.class);
            if (response != null && response.type.equalsIgnoreCase("response")) {
                if (mRequestPKCallback == null) {
                    TXCLog.w(TAG, "can not deal with PK response. mRequestPKCallback = null");
                    return;
                }
                String result = response.result;
                if (result != null) {
                    if (result.equalsIgnoreCase("accept")) {
                        mMixMode = STREAM_MIX_MODE_PK;
                        mPKAnchorInfo.accelerateURL = response.accelerateURL;
                        callbackOnThread(new Runnable() {
                            @Override
                            public void run() {
                                mRequestPKCallback.onAccept(mPKAnchorInfo);
                                mRequestPKCallback = null;
                                mListenerHandler.removeCallbacks(mRequestPKTimeoutTask);
                            }
                        });
                        return;
                    }
                    else if (result.equalsIgnoreCase("reject")) {
                        callbackOnThread(new Runnable() {
                            @Override
                            public void run() {
                                mRequestPKCallback.onReject(response.reason);
                                mRequestPKCallback = null;
                                mListenerHandler.removeCallbacks(mRequestPKTimeoutTask);
                            }
                        });
                        return;
                    }
                }
                callbackOnThread(new Runnable() {
                    @Override
                    public void run() {
                        String msg = "[LiveRoom] 无法识别的 PK 响应[" + message + "]";
                        TXCLog.e(TAG, msg);
                        mRequestPKCallback.onError(LiveRoomErrorCode.ERROR_PARAMETERS_INVALID, msg);
                        mRequestPKCallback = null;
                        mListenerHandler.removeCallbacks(mRequestPKTimeoutTask);
                    }
                });
                return;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private boolean isCmdTimeOut(long remoteSendTimeMS) {
        long localSendTimeMS = remoteSendTimeMS + mTimeDiff;
        if (System.currentTimeMillis() > (localSendTimeMS + 10000)) {
            //信令从发送到接收到已经超过10秒，判断为信令超时
            return true;
        }
        return false;
    }

    //////////////////////////////////////////
    //
    // HttpRequests.HeartBeatCallback
    //
    //////////////////////////////////////////

    @Override
    public void onHeartBeatResponse(String data) {
        Gson gson = new Gson();
        HttpResponse.PusherList pusherList = gson.fromJson(data, HttpResponse.PusherList.class);
        if (data.contains("roomStatusCode")) {
            mRoomStatusCode = pusherList.roomStatusCode;
        }
        parsePushers(true, pusherList, null);
    }

    //////////////////////////////////////////
    //
    // IMMessageMgr.IMMessageListener
    //
    //////////////////////////////////////////
    /**
     * IM连接成功
     */
    @Override
    public void onConnected() {
        TXCLog.d(TAG, "[IM] online");
        callbackOnThread(mListener, "onDebugLog", "[IM] online");
    }

    /**
     * IM断开连接
     */
    @Override
    public void onDisconnected() {
        TXCLog.e(TAG, "[IM] offline");
        callbackOnThread(mListener, "onDebugLog", "[IM] offline");
    }

    /**
     * IM群组里推流者成员变化通知
     */
    @Override
    public void onPusherChanged() {
        if (mBackground == false) {
            if (mSelfRoleType == LIVEROOM_ROLE_PUSHER || mJoinPusher) {
                //只有大主播和连麦观众才去更新主播列表
                TXCLog.d(TAG, "收到 IM 通知主播列表更新");
                callbackOnThread(mListener, "onDebugLog", "[LiveRoom] updateAnchors called");
                updateAnchors(true, null);
            }
        }
    }

    /**
     * 收到群文本消息
     *
     * @param groupID
     * @param senderID
     * @param userName
     * @param headPic
     * @param message
     */
    @Override
    public void onGroupTextMessage(final String groupID, final String senderID, final String userName, final String headPic, final String message) {
        callbackOnThread(mListener, "onRecvRoomTextMsg", groupID, senderID, userName, headPic, message);
    }

    /**
     * 收到自定义的群消息
     *
     * @param groupID
     * @param senderID
     * @param message
     */
    @Override
    public void onGroupCustomMessage(final String groupID, final String senderID, String message) {
        final CustomMessage customMessage =  new Gson().fromJson(message, CustomMessage.class);
        callbackOnThread(mListener, "onRecvRoomCustomMsg", groupID, senderID, customMessage.userName, customMessage.userAvatar, customMessage.cmd, customMessage.msg);
    }

    /**
     * 收到自定义的C2C消息
     *
     * @param sendID
     * @param cmd
     * @param message
     */
    @Override
    public void onC2CCustomMessage(String sendID, String cmd, String message) {
        if (cmd.equalsIgnoreCase("linkmic")) {
            onRecvLinkMicMessage(message);
        }
        else if (cmd.equalsIgnoreCase("pk")) {
            onRecvPKMessage(message);
        }
    }

    /**
     * IM群组销毁回调
     *
     * @param groupID
     */
    @Override
    public void onGroupDestroyed(String groupID) {
        callbackOnThread(mListener, "onDebugLog", "[LiveRoom] onGroupDestroyed called , group id is " + groupID);
        callbackOnThread(mListener, "onRoomDestroy", mCurrRoomID);
    }

    /**
     * 日志回调
     *
     * @param log
     */
    @Override
    public void onDebugLog(String log) {
        TXCLog.d(TAG, log);
        callbackOnThread(mListener, "onDebugLog", log);
    }

    @Override
    public void onGroupMemberEnter(String groupID, ArrayList<TIMUserProfile> users) {
        long nowTime = System.currentTimeMillis();
        if ((nowTime - mLastEnterAudienceTimeMS) > REFRESH_AUDIENCE_INTERVAL_MS) {
            mLastEnterAudienceTimeMS = nowTime;
            int memberCount = 0;
            for (TIMUserProfile userProfile : users) {
                if (memberCount < MAX_MEMBER_SIZE) {
                    //最多处理 MAX_MEMBER_SIZE
                    memberCount++;
                    final AudienceInfo audienceInfo = new AudienceInfo();
                    audienceInfo.userID = userProfile.getIdentifier();
                    audienceInfo.userName = userProfile.getNickName();
                    audienceInfo.userAvatar = userProfile.getFaceUrl();
                    if (mAudiences != null) {
                        mAudiences.put(userProfile.getIdentifier(), audienceInfo);
                    }
                    TXCLog.e(TAG, "新用户进群.userID:" + audienceInfo.userID + ", nickname:" + audienceInfo.userName + ", userAvatar:" + audienceInfo.userAvatar);
                    callbackOnThread(mListener, "onAudienceEnter", audienceInfo);
                }
            }
        }
    }

    @Override
    public void onGroupMemberExit(String groupID, ArrayList<TIMUserProfile> users) {
        long nowTime = System.currentTimeMillis();
        if ((nowTime - mLastExitAudienceTimeMS) > REFRESH_AUDIENCE_INTERVAL_MS) {
            mLastExitAudienceTimeMS = nowTime;
            int memberCount = 0;
            for (TIMUserProfile userProfile : users) {
                if (memberCount < MAX_MEMBER_SIZE) {
                    //最多处理 MAX_MEMBER_SIZE
                    memberCount++;
                    final AudienceInfo audienceInfo = new AudienceInfo();
                    audienceInfo.userID = userProfile.getIdentifier();
                    audienceInfo.userName = userProfile.getNickName();
                    audienceInfo.userAvatar = userProfile.getFaceUrl();
                    TXCLog.e(TAG, "用户退群.userID:" + audienceInfo.userID + ", nickname:" + audienceInfo.userName + ", userAvatar:" + audienceInfo.userAvatar);
                    callbackOnThread(mListener, "onAudienceExit", audienceInfo);
                }
            }
        }
    }

    @Override
    public void onForceOffline() {
        callbackOnThread(mListener, "onError", LiveRoomErrorCode.ERROR_IM_FORCE_OFFLINE, "[LiveRoom] IM 被强制下线[请确保已经不要多端登录]", new Bundle());
    }

    private class StreamMixturer {
        private String              mMainStreamId = "";
        private String              mPKStreamId   = "";
        private Vector<String> mSubStreamIds = new Vector<String>();
        private int                 mMainStreamWidth = 540;
        private int                 mMainStreamHeight = 960;

        public StreamMixturer() {

        }

        public void setMainVideoStream(String  streamUrl) {
            mMainStreamId = getStreamIDByStreamUrl(streamUrl);

            Log.e(TAG, "MergeVideoStream: setMainVideoStream " + mMainStreamId);
        }

        public void setMainVideoStreamResolution(int width, int height) {
            if (width > 0 && height > 0) {
                mMainStreamWidth = width;
                mMainStreamHeight = height;
            }
        }

        public void addSubVideoStream(String  streamUrl) {
            if (mSubStreamIds.size() > 3) {
                return;
            }

            String streamId = getStreamIDByStreamUrl(streamUrl);

            Log.e(TAG, "MergeVideoStream: addSubVideoStream " + streamId);

            if (streamId == null || streamId.length() == 0) {
                return;
            }

            for (String item: mSubStreamIds) {
                if (item.equalsIgnoreCase(streamId)) {
                    return;
                }
            }

            mSubStreamIds.add(streamId);
            sendStreamMergeRequest(5);
        }

        public void delSubVideoStream(String  streamUrl) {
            String streamId = getStreamIDByStreamUrl(streamUrl);

            Log.e(TAG, "MergeVideoStream: delSubVideoStream " + streamId);

            boolean bExist = false;
            for (String item: mSubStreamIds) {
                if (item.equalsIgnoreCase(streamId)) {
                    bExist = true;
                    break;
                }
            }

            if (bExist == true) {
                mSubStreamIds.remove(streamId);
                sendStreamMergeRequest(1);
            }
        }

        public void addPKVideoStream(String streamUrl) {
            mPKStreamId = getStreamIDByStreamUrl(streamUrl);
            if (mMainStreamId == null || mMainStreamId.length() == 0 || mPKStreamId == null || mPKStreamId.length() == 0) {
                return;
            }

            Log.e(TAG, "MergeVideoStream: addPKVideoStream " + mPKStreamId);

            final JSONObject requestParam = createPKRequestParam();
            if (requestParam == null) {
                return;
            }

            internalSendRequest(5, true, requestParam);
        }

        public void delPKVideoStream(String streamUrl) {
            mPKStreamId = null;
            if (mMainStreamId == null || mMainStreamId.length() == 0) {
                return;
            }

            String streamId = getStreamIDByStreamUrl(streamUrl);
            Log.e(TAG, "MergeVideoStream: delPKStream");

            final JSONObject requestParam = createPKRequestParam();
            if (requestParam == null) {
                return;
            }

            internalSendRequest(1, true, requestParam);
        }

        public void resetMergeState() {
            Log.e(TAG, "MergeVideoStream: resetMergeState");

            mSubStreamIds.clear();
            mMainStreamId = null;
            mPKStreamId   = null;
            mMainStreamWidth = 540;
            mMainStreamHeight = 960;
        }

        private void sendStreamMergeRequest(final int retryCount) {
            if (mMainStreamId == null || mMainStreamId.length() == 0) {
                return;
            }

            final JSONObject requestParam = createRequestParam();
            if (requestParam == null) {
                return;
            }

            internalSendRequest(retryCount, true, requestParam);
        }

        private void internalSendRequest(final int retryIndex, final boolean runImmediately, final JSONObject requestParam) {
            new Thread() {
                @Override
                public void run() {
                    if (runImmediately == false) {
                        try {
                            sleep(2000, 0);
                        }
                        catch (Exception e) {
                            e.printStackTrace();
                        }
                    }

                    String streamsInfo = "mainStream: " + mMainStreamId;
                    for (int i = 0; i < mSubStreamIds.size(); ++i) {
                        streamsInfo = streamsInfo + " subStream" + i + ": " + mSubStreamIds.get(i);
                    }

                    Log.e(TAG, "MergeVideoStream: send request, " + streamsInfo + " retryIndex: " + retryIndex + "    " + requestParam.toString());
                    if (mHttpRequest != null) {
                        mHttpRequest.mergeStream(mCurrRoomID, mSelfAccountInfo.userID, requestParam, new HttpRequests.OnResponseCallback<HttpResponse.MergeStream>() {
                            @Override
                            public void onResponse(int retcode, String strMessage, HttpResponse.MergeStream result) {
                                Log.e(TAG, "MergeVideoStream: recv response, message = " + (result != null ? "[code = " + result.code + " msg = " + result.message + " merge_code = " + result.merge_code + "]" : "null"));

                                if (result != null && result.code == 0 && result.merge_code == 0) {
                                    return;
                                }
                                else {
                                    int tempRetryIndex = retryIndex - 1;
                                    if (tempRetryIndex > 0) {
                                        internalSendRequest(tempRetryIndex, false, requestParam);
                                    }
                                }
                            }
                        });
                    }
                }
            }.start();
        }

        private JSONObject createRequestParam() {

            JSONObject requestParam = null;

            try {
                // input_stream_list
                JSONArray inputStreamList = new JSONArray();

                // 大主播
                {
                    JSONObject layoutParam = new JSONObject();
                    layoutParam.put("image_layer", 1);

                    JSONObject mainStream = new JSONObject();
                    mainStream.put("input_stream_id", mMainStreamId);
                    mainStream.put("layout_params", layoutParam);

                    inputStreamList.put(mainStream);
                }

                int subWidth  = 160;
                int subHeight = 240;
                int offsetHeight = 90;
                if (mMainStreamWidth < 540 || mMainStreamHeight < 960) {
                    subWidth  = 120;
                    subHeight = 180;
                    offsetHeight = 60;
                }
                int subLocationX = mMainStreamWidth - subWidth;
                int subLocationY = mMainStreamHeight - subHeight - offsetHeight;

                // 小主播
                int layerIndex = 0;
                for (String item : mSubStreamIds) {
                    JSONObject layoutParam = new JSONObject();
                    layoutParam.put("image_layer", layerIndex + 2);
                    layoutParam.put("image_width", subWidth);
                    layoutParam.put("image_height", subHeight);
                    layoutParam.put("location_x", subLocationX);
                    layoutParam.put("location_y", subLocationY - layerIndex * subHeight);

                    JSONObject subStream = new JSONObject();
                    subStream.put("input_stream_id", item);
                    subStream.put("layout_params", layoutParam);

                    inputStreamList.put(subStream);
                    ++layerIndex;
                }

                // para
                JSONObject para = new JSONObject();
                para.put("app_id", "");
                para.put("interface", "mix_streamv2.start_mix_stream_advanced");
                para.put("mix_stream_session_id", mMainStreamId);
                para.put("output_stream_id", mMainStreamId);
                para.put("input_stream_list", inputStreamList);

                // interface
                JSONObject interfaceObj = new JSONObject();
                interfaceObj.put("interfaceName", "Mix_StreamV2");
                interfaceObj.put("para", para);

                // requestParam
                requestParam = new JSONObject();
                requestParam.put("timestamp", System.currentTimeMillis() / 1000);
                requestParam.put("eventId", System.currentTimeMillis() / 1000);
                requestParam.put("interface", interfaceObj);
            }
            catch (Exception e) {
                e.printStackTrace();
            }

            return requestParam;
        }

        private JSONObject createPKRequestParam() {

            if (mMainStreamId == null || mMainStreamId.length() == 0) {
                return null;
            }

            JSONObject requestParam = null;

            try {
                // input_stream_list
                JSONArray inputStreamList = new JSONArray();

                if (mPKStreamId != null && mPKStreamId.length() > 0){
                    // 画布
                    {
                        JSONObject layoutParam = new JSONObject();
                        layoutParam.put("image_layer", 1);
                        layoutParam.put("input_type", 3);
                        layoutParam.put("image_width", 720);
                        layoutParam.put("image_height", 640);

                        JSONObject canvasStream = new JSONObject();
                        canvasStream.put("input_stream_id", mMainStreamId);
                        canvasStream.put("layout_params", layoutParam);

                        inputStreamList.put(canvasStream);
                    }

                    // mainStream
                    {
                        JSONObject layoutParam = new JSONObject();
                        layoutParam.put("image_layer", 2);
                        layoutParam.put("image_width", 360);
                        layoutParam.put("image_height", 640);
                        layoutParam.put("location_x", 0);
                        layoutParam.put("location_y", 0);

                        JSONObject mainStream = new JSONObject();
                        mainStream.put("input_stream_id", mMainStreamId);
                        mainStream.put("layout_params", layoutParam);

                        inputStreamList.put(mainStream);
                    }

                    // subStream
                    {
                        JSONObject layoutParam = new JSONObject();
                        layoutParam.put("image_layer", 3);
                        layoutParam.put("image_width", 360);
                        layoutParam.put("image_height", 640);
                        layoutParam.put("location_x", 360);
                        layoutParam.put("location_y", 0);

                        JSONObject mainStream = new JSONObject();
                        mainStream.put("input_stream_id", mPKStreamId);
                        mainStream.put("layout_params", layoutParam);

                        inputStreamList.put(mainStream);
                    }
                }
                else {
                    JSONObject layoutParam = new JSONObject();
                    layoutParam.put("image_layer", 1);

                    JSONObject canvasStream = new JSONObject();
                    canvasStream.put("input_stream_id", mMainStreamId);
                    canvasStream.put("layout_params", layoutParam);

                    inputStreamList.put(canvasStream);
                }

                // para
                JSONObject para = new JSONObject();
                para.put("app_id", "");
                para.put("interface", "mix_streamv2.start_mix_stream_advanced");
                para.put("mix_stream_session_id", mMainStreamId);
                para.put("output_stream_id", mMainStreamId);
                para.put("input_stream_list", inputStreamList);

                // interface
                JSONObject interfaceObj = new JSONObject();
                interfaceObj.put("interfaceName", "Mix_StreamV2");
                interfaceObj.put("para", para);

                // requestParam
                requestParam = new JSONObject();
                requestParam.put("timestamp", System.currentTimeMillis() / 1000);
                requestParam.put("eventId", System.currentTimeMillis() / 1000);
                requestParam.put("interface", interfaceObj);
            }
            catch (Exception e) {
                e.printStackTrace();
            }

            return requestParam;
        }

        private String getStreamIDByStreamUrl(String strStreamUrl) {
            if (strStreamUrl == null || strStreamUrl.length() == 0) {
                return null;
            }

            //推流地址格式：rtmp://8888.livepush.myqcloud.com/path/8888_test_12345_test?txSecret=aaaa&txTime=bbbb
            //拉流地址格式：rtmp://8888.liveplay.myqcloud.com/path/8888_test_12345_test
            //            http://8888.liveplay.myqcloud.com/path/8888_test_12345_test.flv
            //            http://8888.liveplay.myqcloud.com/path/8888_test_12345_test.m3u8


            String subString = strStreamUrl;

            {
                //1 截取第一个 ？之前的子串
                int index = subString.indexOf("?");
                if (index != -1) {
                    subString = subString.substring(0, index);
                }
                if (subString == null || subString.length() == 0) {
                    return null;
                }
            }

            {
                //2 截取最后一个 / 之后的子串
                int index = subString.lastIndexOf("/");
                if (index != -1) {
                    subString = subString.substring(index + 1);
                }

                if (subString == null || subString.length() == 0) {
                    return null;
                }
            }

            {
                //3 截取第一个 . 之前的子串
                int index = subString.indexOf(".");
                if (index != -1) {
                    subString = subString.substring(0, index);
                }
                if (subString == null || subString.length() == 0) {
                    return null;
                }
            }

            return subString;
        }
    }

    protected class HeartBeatThread extends HandlerThread {
        private Handler handler;
        private boolean running = false;

        public HeartBeatThread() {
            super("HeartBeatThread");
            this.start();
            handler = new Handler(this.getLooper());
        }

        private Runnable heartBeatRunnable = new Runnable() {
            @Override
            public void run() {
                if (mSelfAccountInfo != null && mSelfAccountInfo.userID != null && mSelfAccountInfo.userID.length() > 0 && mCurrRoomID != null && mCurrRoomID.length() > 0) {
                    if (mHttpRequest != null) {
                        mHttpRequest.heartBeat(mSelfAccountInfo.userID, mCurrRoomID, mRoomStatusCode);
                    }
                    if (handler != null) {
                        handler.postDelayed(heartBeatRunnable, 5000);
                    }
                }
            }
        };

        public boolean running() {
            return running;
        }

        public void startHeartbeat(){
            running = true;
            handler.postDelayed(heartBeatRunnable, 1000);
        }

        public void stopHeartbeat(){
            running = false;
            handler.removeCallbacks(heartBeatRunnable);
        }
    }

    private class TXLivePushListenerImpl implements ITXLivePushListener {
        private StandardCallback mCallback = null;

        public void setCallback(StandardCallback callback) {
            mCallback = callback;
        }

        @Override
        public void onPushEvent(final int event, final Bundle param) {
            if (event == TXLiveConstants.PUSH_EVT_PUSH_BEGIN) {
                TXCLog.d(TAG, "推流成功");
                callbackOnThread(mCallback, "onSuccess");
            } else if (event == TXLiveConstants.PUSH_ERR_OPEN_CAMERA_FAIL) {
                String msg = "[LivePusher] 推流失败[打开摄像头失败]";
                TXCLog.e(TAG, msg);
                callbackOnThread(mCallback, "onError", event, msg);
            } else if (event == TXLiveConstants.PUSH_ERR_OPEN_MIC_FAIL) {
                String msg = "[LivePusher] 推流失败[打开麦克风失败]";
                TXCLog.e(TAG, msg);
                callbackOnThread(mCallback, "onError", event, msg);
            } else if (event == TXLiveConstants.PUSH_ERR_NET_DISCONNECT || event == TXLiveConstants.PUSH_ERR_INVALID_ADDRESS) {
                String msg = "[LivePusher] 推流失败[网络断开]";
                TXCLog.e(TAG,msg);
                callbackOnThread(mCallback, "onError", event, msg);
            }
        }

        @Override
        public void onNetStatus(Bundle status) {

        }
    }

    private void callbackOnThread(final Object object, final String methodName, final Object... args) {
        if (object == null || methodName == null || methodName.length() == 0) {
            return;
        }
        mListenerHandler.post(new Runnable() {
            @Override
            public void run() {
                Class objClass = object.getClass();
                while (objClass != null) {
                    Method[] methods = objClass.getDeclaredMethods();
                    for (Method method : methods) {
                        if (method.getName() == methodName) {
                            try {
                                method.invoke(object, args);
                            } catch (IllegalAccessException e) {
                                e.printStackTrace();
                            } catch (InvocationTargetException e) {
                                e.printStackTrace();
                            }
                            return;
                        }
                    }
                    objClass = objClass.getSuperclass();
                }
            }
        });
    }

    private void callbackOnThread(final Runnable runnable) {
        if (runnable == null) {
            return;
        }
        mListenerHandler.post(new Runnable() {
            @Override
            public void run() {
                runnable.run();
            }
        });
    }

    private  class PlayerItem {
        public TXCloudVideoView view;
        public AnchorInfo       anchorInfo;
        public TXLivePlayer     player;

        public PlayerItem(TXCloudVideoView view, AnchorInfo anchorInfo, TXLivePlayer player) {
            this.view = view;
            this.anchorInfo = anchorInfo;
            this.player = player;
        }

        public void resume(){
            this.player.resume();
        }

        public void pause(){
            this.player.pause();
        }

        public void destroy(){
            this.player.stopPlay(true);
            this.view.onDestroy();
        }
    }

    protected class CommonJson<T> {
        public String cmd;
        public T      data;
        public CommonJson() {
        }
    }

    private class JoinAnchorRequest {
        public String type;
        public String roomID;
        public String userID;
        public String userName;
        public String userAvatar;
        public String reason;
        public long timestamp;
    }

    private class JoinAnchorResponse {
        public String type;
        public String roomID;
        public String result;
        public String reason;
        public long timestamp;
    }

    private class KickoutResponse {
        public String type;
        public String roomID;
        public long timestamp;
    }

    private class PKRequest {
        public String type;
        public String action;
        public String roomID;
        public String userID;
        public String userName;
        public String userAvatar;
        public String accelerateURL;
        public long timestamp;
    }

    private class PKResponse {
        public String type;
        public String roomID;
        public String result;
        public String reason;
        public String accelerateURL;
        public long timestamp;
    }

    protected class CustomMessage{
        public String userName;
        public String userAvatar;
        public String cmd;
        public String msg;
    }

    public interface StandardCallback {
        /**
         * @param errCode 错误码
         * @param errInfo 错误信息
         */
        void onError(int errCode, String errInfo);

        void onSuccess();
    }

    protected interface UpdateAnchorsCallback {
        void onUpdateAnchors(int errcode, List<AnchorInfo> addAnchors, List<AnchorInfo> delAnchors, HashMap<String, AnchorInfo> mergedAnchors, AnchorInfo roomCreator);
    }
}
