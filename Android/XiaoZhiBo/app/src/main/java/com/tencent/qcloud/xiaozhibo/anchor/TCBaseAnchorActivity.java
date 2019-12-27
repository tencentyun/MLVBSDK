package com.tencent.qcloud.xiaozhibo.anchor;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.FragmentTransaction;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.Display;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.MLVBCommonDef;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.TCGlobalConfig;
import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.ui.ErrorDialogFragment;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.widget.TCInputTextMsgDialog;
import com.tencent.qcloud.xiaozhibo.common.widget.TCSwipeAnimationController;
import com.tencent.qcloud.xiaozhibo.common.widget.danmaku.TCDanmuMgr;
import com.tencent.qcloud.xiaozhibo.common.widget.like.TCHeartLayout;
import com.tencent.qcloud.xiaozhibo.common.msg.TCChatEntity;
import com.tencent.qcloud.xiaozhibo.common.msg.TCChatMsgListAdapter;
import com.tencent.qcloud.xiaozhibo.common.msg.TCSimpleUserInfo;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.rtmp.TXLog;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

import master.flame.danmaku.controller.IDanmakuView;

/**
 * Module:   TCBaseAnchorActivity
 * <p>
 * Function: 主播推流的页面
 *
 * 1. MLVB 组件的使用，创建或者销毁房间：{@link TCBaseAnchorActivity#startPublish()}; 以及相关事件回调监听
 *
 * 2. 处理消息接收到的文本信息：{@link TCBaseAnchorActivity#onRecvRoomTextMsg(String, String, String, String, String)}
 */
public class TCBaseAnchorActivity extends Activity implements IMLVBLiveRoomListener, View.OnClickListener, TCInputTextMsgDialog.OnTextSendListener {
    private static final String TAG = TCBaseAnchorActivity.class.getSimpleName();

    // 消息列表相关
    private ListView                    mLvMessage;             // 消息控件
    private TCInputTextMsgDialog        mInputTextMsgDialog;    // 消息输入框
    private TCChatMsgListAdapter        mChatMsgListAdapter;    // 消息列表的Adapter
    private ArrayList<TCChatEntity>     mArrayListChatEntity;   // 消息内容

    private ErrorDialogFragment         mErrDlgFragment;        // 错误提示弹窗
    private TCHeartLayout               mHeartLayout;           // 点赞动画的布局

    protected TCSwipeAnimationController mTCSwipeAnimationController;  // 动画控制类

    private String                      mTitle;                 // 直播标题
    private String                      mCoverPicUrl;           // 直播封面图
    private String                      mAvatarPicUrl;          // 个人头像地址
    private String                      mNickName;              // 个人昵称
    private String                      mUserId;                // 个人用户id
    private String                      mLocation;              // 个人定位地址
    protected long                      mTotalMemberCount = 0;  // 总进房观众数量
    protected long                      mCurrentMemberCount = 0;// 当前观众数量
    protected long                      mHeartCount = 0;        // 点赞数量

    private TCDanmuMgr                  mDanmuMgr;              // 弹幕管理类

    protected MLVBLiveRoom              mLiveRoom;              // MLVB 组件类

    protected Handler mMainHandler = new Handler(Looper.getMainLooper());


    // 定时的 Timer 去更新开播时间
    private Timer                           mBroadcastTimer;        // 定时的 Timer
    private BroadcastTimerTask              mBroadcastTimerTask;    // 定时任务
    protected long                          mSecond = 0;            // 开播的时间，单位为秒
    private long                            mStartPushPts;          // 开始直播的时间，用于 ELK 上报统计。 您可以不关注

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mStartPushPts = System.currentTimeMillis();
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        Intent intent = getIntent();
        mUserId = intent.getStringExtra(TCConstants.USER_ID);
        mTitle = intent.getStringExtra(TCConstants.ROOM_TITLE);
        mCoverPicUrl = intent.getStringExtra(TCConstants.COVER_PIC);
        mAvatarPicUrl = intent.getStringExtra(TCConstants.USER_HEADPIC);
        mNickName = intent.getStringExtra(TCConstants.USER_NICK);
        mLocation = intent.getStringExtra(TCConstants.USER_LOC);

        mArrayListChatEntity = new ArrayList<>();
        mErrDlgFragment = new ErrorDialogFragment();
        mLiveRoom = MLVBLiveRoom.sharedInstance(this);

        initView();
        if (TextUtils.isEmpty(mNickName)) {
            mNickName = mUserId;
        }
        mLiveRoom.setSelfProfile(mNickName, mAvatarPicUrl);
        startPublish();
    }

    /**
     * 特别注意，以下几个 findViewById 由于是依赖于子类
     * {@link TCCameraAnchorActivity}
     * 的布局，所以id要保持一致。 若id发生改变，此处id也要同时修改
     */
    protected void initView() {
        RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.rl_root);
        relativeLayout.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return mTCSwipeAnimationController.processEvent(event);
            }
        });

        RelativeLayout controllLayer = (RelativeLayout) findViewById(R.id.anchor_rl_controllLayer);
        mTCSwipeAnimationController = new TCSwipeAnimationController(this);
        mTCSwipeAnimationController.setAnimationView(controllLayer);

        mLvMessage = (ListView) findViewById(R.id.im_msg_listview);
        mHeartLayout = (TCHeartLayout) findViewById(R.id.heart_layout);

        mInputTextMsgDialog = new TCInputTextMsgDialog(this, R.style.InputDialog);
        mInputTextMsgDialog.setmOnTextSendListener(this);

        mChatMsgListAdapter = new TCChatMsgListAdapter(this, mLvMessage, mArrayListChatEntity);
        mLvMessage.setAdapter(mChatMsgListAdapter);

        IDanmakuView danmakuView = (IDanmakuView) findViewById(R.id.anchor_danmaku_view);
        mDanmuMgr = new TCDanmuMgr(this);
        mDanmuMgr.setDanmakuView(danmakuView);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_close:
                showExitInfoDialog("当前正在直播，是否退出直播？", false);
                break;
            case R.id.btn_message_input:
                showInputMsgDialog();
                break;
            default:
                break;
        }
    }


    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      Activity声明周期相关
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */

    @Override
    public void onBackPressed() {
        showExitInfoDialog("当前正在直播，是否退出直播？", false);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mDanmuMgr != null) {
            mDanmuMgr.resume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mDanmuMgr != null) {
            mDanmuMgr.pause();
        }
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopTimer();
        if (mDanmuMgr != null) {
            mDanmuMgr.destroy();
            mDanmuMgr = null;
        }
        stopPublish();
        long endPushPts = System.currentTimeMillis();
        long diff = (endPushPts - mStartPushPts) / 1000;
        TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_CAMERA_PUSH_DURATION, TCUserMgr.getInstance().getUserId(), diff, "摄像头推流时长", null);
    }

    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      开始和停止推流相关
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */
    protected void startPublish() {
        mLiveRoom.setListener(this);
        mLiveRoom.setCameraMuteImage(BitmapFactory.decodeResource(getResources(), R.drawable.pause_publish));
        String roomInfo = mTitle;
        try {
            roomInfo = new JSONObject()
                    .put("title", mTitle)
                    .put("frontcover", mCoverPicUrl)
                    .put("location", mLocation)
                    .toString();
        } catch (JSONException e) {
            roomInfo = mTitle;
        }
        mLiveRoom.createRoom("", roomInfo, new IMLVBLiveRoomListener.CreateRoomCallback() {
            @Override
            public void onSuccess(String roomId) {
                Log.w(TAG, String.format("创建直播间%s成功", roomId));
                onCreateRoomSuccess();
            }

            @Override
            public void onError(int errCode, String e) {
                Log.w(TAG, String.format("创建直播间错误, code=%s,error=%s", errCode, e));
                showErrorAndQuit(errCode, "创建直播房间失败,Error:" + e);
            }
        });
    }

    /**
     * 创建直播间成功
     */
    protected void onCreateRoomSuccess() {
        startTimer();
        // 填写了后台服务器地址
        if (!TextUtils.isEmpty(TCGlobalConfig.APP_SVR_URL)) {
            try {
                JSONObject body = new JSONObject().put("userid", mUserId)
                        .put("title", mTitle)
                        .put("frontcover", mCoverPicUrl)
                        .put("location", mLocation);
                TCHTTPMgr.getInstance().requestWithSign(TCGlobalConfig.APP_SVR_URL + "/upload_room", body, null);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    protected void stopPublish() {
        mLiveRoom.exitRoom(new ExitRoomCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "exitRoom Success");
            }

            @Override
            public void onError(int errCode, String e) {
                Log.e(TAG, "exitRoom failed, errorCode = " + errCode + " errMessage = " + e);
            }
        });

        mLiveRoom.setListener(null);
    }

    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      MLVB 组件回调
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onAnchorEnter(AnchorInfo pusherInfo) {

    }

    @Override
    public void onAnchorExit(AnchorInfo pusherInfo) {

    }

    @Override
    public void onAudienceEnter(AudienceInfo audienceInfo) {

    }

    @Override
    public void onAudienceExit(AudienceInfo audienceInfo) {

    }

    @Override
    public void onRequestJoinAnchor(AnchorInfo pusherInfo, String reason) {

    }

    @Override
    public void onKickoutJoinAnchor() {

    }

    @Override
    public void onRequestRoomPK(AnchorInfo pusherInfo) {

    }

    @Override
    public void onQuitRoomPK(AnchorInfo anchorInfo) {

    }

    @Override
    public void onRecvRoomTextMsg(String roomID, String userID, String userName, String userAvatar, String message) {
        TCSimpleUserInfo userInfo = new TCSimpleUserInfo(userID, userName, userAvatar);
        handleTextMsg(userInfo, message);
    }

    @Override
    public void onRecvRoomCustomMsg(String roomID, String userID, String userName, String userAvatar, String cmd, String message) {
        TCSimpleUserInfo userInfo = new TCSimpleUserInfo(userID, userName, userAvatar);
        int type = Integer.valueOf(cmd);
        switch (type) {
            case TCConstants.IMCMD_ENTER_LIVE:
                handleMemberJoinMsg(userInfo);
                break;
            case TCConstants.IMCMD_EXIT_LIVE:
                handleMemberQuitMsg(userInfo);
                break;
            case TCConstants.IMCMD_PRAISE:
                handlePraiseMsg(userInfo);
                break;
            case TCConstants.IMCMD_PAILN_TEXT:
                handleTextMsg(userInfo, message);
                break;
            case TCConstants.IMCMD_DANMU:
                handleDanmuMsg(userInfo, message);
                break;
            default:
                break;
        }
    }

    @Override
    public void onRoomDestroy(String roomID) {
        TXLog.w(TAG, "room closed");
        showErrorAndQuit(0, "房间已解散");
    }

    @Override
    public void onError(int errorCode, String errorMessage, Bundle extraInfo) {
        if (errorCode == MLVBCommonDef.LiveRoomErrorCode.ERROR_IM_FORCE_OFFLINE) {
            TCUtils.showKickOut(TCBaseAnchorActivity.this);
        } else {
            showErrorAndQuit(errorCode, errorMessage);
        }
    }

    @Override
    public void onWarning(int warningCode, String warningMsg, Bundle extraInfo) {

    }

    @Override
    public void onDebugLog(String log) {
        Log.d(TAG, log);
    }


    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      处理接收到的各种信息
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */
    protected void handleTextMsg(TCSimpleUserInfo userInfo, String text) {
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName(userInfo.nickname);
        entity.setContent(text);
        entity.setType(TCConstants.TEXT_TYPE);
        notifyMsg(entity);
    }

    /**
     * 处理观众加入信息
     *
     * @param userInfo
     */
    protected void handleMemberJoinMsg(TCSimpleUserInfo userInfo) {
        mTotalMemberCount++;
        mCurrentMemberCount++;
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.nickname))
            entity.setContent(userInfo.userid + "加入直播");
        else
            entity.setContent(userInfo.nickname + "加入直播");
        entity.setType(TCConstants.MEMBER_ENTER);
        notifyMsg(entity);
    }

    /**
     * 处理观众退出信息
     *
     * @param userInfo
     */
    protected void handleMemberQuitMsg(TCSimpleUserInfo userInfo) {
        if (mCurrentMemberCount > 0)
            mCurrentMemberCount--;
        else
            Log.d(TAG, "接受多次退出请求，目前人数为负数");

        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.nickname))
            entity.setContent(userInfo.userid + "退出直播");
        else
            entity.setContent(userInfo.nickname + "退出直播");
        entity.setType(TCConstants.MEMBER_EXIT);
        notifyMsg(entity);
    }

    /**
     * 处理点赞信息
     *
     * @param userInfo
     */
    protected void handlePraiseMsg(TCSimpleUserInfo userInfo) {
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.nickname))
            entity.setContent(userInfo.userid + "点了个赞");
        else
            entity.setContent(userInfo.nickname + "点了个赞");

        mHeartLayout.addFavor();
        mHeartCount++;

        //todo：修改显示类型
        entity.setType(TCConstants.PRAISE);
        notifyMsg(entity);
    }

    /**
     * 处理弹幕信息
     *
     * @param userInfo
     * @param text
     */
    protected void handleDanmuMsg(TCSimpleUserInfo userInfo, String text) {
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName(userInfo.nickname);
        entity.setContent(text);
        entity.setType(TCConstants.TEXT_TYPE);
        notifyMsg(entity);

        if (mDanmuMgr != null) {
            mDanmuMgr.addDanmu(userInfo.avatar, userInfo.nickname, text);
        }
    }


    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      发送文本信息
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */
    /**
     * 发消息弹出框
     */
    private void showInputMsgDialog() {
        WindowManager windowManager = getWindowManager();
        Display display = windowManager.getDefaultDisplay();
        WindowManager.LayoutParams lp = mInputTextMsgDialog.getWindow().getAttributes();
        lp.width = (int) (display.getWidth()); //设置宽度
        mInputTextMsgDialog.getWindow().setAttributes(lp);
        mInputTextMsgDialog.setCancelable(true);
        mInputTextMsgDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        mInputTextMsgDialog.show();
    }


    @Override
    public void onTextSend(String msg, boolean danmuOpen) {
        if (msg.length() == 0)
            return;
        try {
            byte[] byte_num = msg.getBytes("utf8");
            if (byte_num.length > 160) {
                Toast.makeText(this, "请输入内容", Toast.LENGTH_SHORT).show();
                return;
            }
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return;
        }

        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("我:");
        entity.setContent(msg);
        entity.setType(TCConstants.TEXT_TYPE);
        notifyMsg(entity);

        // 发送弹幕或发送房间信息
        if (danmuOpen) {
            if (mDanmuMgr != null) {
                mDanmuMgr.addDanmu(TCUserMgr.getInstance().getAvatar(), TCUserMgr.getInstance().getNickname(), msg);
            }
            mLiveRoom.sendRoomCustomMsg(String.valueOf(TCConstants.IMCMD_DANMU), msg, new SendRoomCustomMsgCallback() {
                @Override
                public void onError(int errCode, String errInfo) {
                    Log.w(TAG, "sendRoomDanmuMsg error: " + errInfo);
                }

                @Override
                public void onSuccess() {
                    Log.d(TAG, "sendRoomDanmuMsg success");
                }
            });
        } else {
            mLiveRoom.sendRoomTextMsg(msg, new SendRoomTextMsgCallback() {
                @Override
                public void onError(int errCode, String errInfo) {
                    Log.d(TAG, "sendRoomTextMsg error:");
                }

                @Override
                public void onSuccess() {
                    Log.d(TAG, "sendRoomTextMsg success:");
                }
            });
        }
    }


    private void notifyMsg(final TCChatEntity entity) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mArrayListChatEntity.size() > 1000) {
                    while (mArrayListChatEntity.size() > 900) {
                        mArrayListChatEntity.remove(0);
                    }
                }
                mArrayListChatEntity.add(entity);
                mChatMsgListAdapter.notifyDataSetChanged();
            }
        });
    }


    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      弹窗相关
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */

    /**
     * 显示直播结果的弹窗
     *
     * 如：观看数量、点赞数量、直播时长数
     */
    protected void showPublishFinishDetailsDialog() {
        //确认则显示观看detail
        FinishDetailDialogFragment dialogFragment = new FinishDetailDialogFragment();
        Bundle args = new Bundle();
        args.putString("time", TCUtils.formattedTime(mSecond));
        args.putString("heartCount", String.format(Locale.CHINA, "%d", mHeartCount));
        args.putString("totalMemberCount", String.format(Locale.CHINA, "%d", mTotalMemberCount));
        dialogFragment.setArguments(args);
        dialogFragment.setCancelable(false);
        if (dialogFragment.isAdded())
            dialogFragment.dismiss();
        else
            dialogFragment.show(getFragmentManager(), "");
    }

    /**
     * 显示确认消息
     *
     * @param msg     消息内容
     * @param isError true错误消息（必须退出） false提示消息（可选择是否退出）
     */
    public void showExitInfoDialog(String msg, Boolean isError) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this, R.style.ConfirmDialogStyle);
        builder.setCancelable(true);
        builder.setTitle(msg);

        if (!isError) {
            builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                    stopPublish();
                    showPublishFinishDetailsDialog();
                }
            });
            builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            });
        } else {
            //当情况为错误的时候，直接停止推流
            stopPublish();
            builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                    showPublishFinishDetailsDialog();
                }
            });
        }
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
        alertDialog.setCanceledOnTouchOutside(false);
    }

    /**
     * 显示错误并且退出直播的弹窗
     *
     * @param errorCode
     * @param errorMsg
     */
    protected void showErrorAndQuit(int errorCode, String errorMsg) {
        stopTimer();
        stopPublish();
        if (!mErrDlgFragment.isAdded() && !this.isFinishing()) {
            Bundle args = new Bundle();
            args.putInt("errorCode", errorCode);
            args.putString("errorMsg", errorMsg);
            mErrDlgFragment.setArguments(args);
            mErrDlgFragment.setCancelable(false);
            FragmentTransaction transaction = getFragmentManager().beginTransaction();
            transaction.add(mErrDlgFragment, "loading");
            transaction.commitAllowingStateLoss();
        }
    }

    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      开播时长相关
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */
    protected void onBroadcasterTimeUpdate(long second) {

    }

    /**
     * 记时器
     */
    private class BroadcastTimerTask extends TimerTask {
        public void run() {
            //Log.i(TAG, "timeTask ");
            ++mSecond;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    onBroadcasterTimeUpdate(mSecond);
                }
            });
        }
    }

    private void startTimer() {
        //直播时间
        if (mBroadcastTimer == null) {
            mBroadcastTimer = new Timer(true);
            mBroadcastTimerTask = new BroadcastTimerTask();
            mBroadcastTimer.schedule(mBroadcastTimerTask, 1000, 1000);
        }
    }

    private void stopTimer() {
        //直播时间
        if (null != mBroadcastTimer) {
            mBroadcastTimerTask.cancel();
        }
    }

}
