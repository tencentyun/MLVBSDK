package com.tencent.qcloud.xiaozhibo.play;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.MLVBCommonDef;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.TCLiveRoomMgr;
import com.tencent.qcloud.xiaozhibo.common.activity.ErrorDialogFragment;
import com.tencent.qcloud.xiaozhibo.common.utils.TCBeautyHelper;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCFrequeControl;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.widget.TCInputTextMsgDialog;
import com.tencent.qcloud.xiaozhibo.common.widget.TCSwipeAnimationController;
import com.tencent.qcloud.xiaozhibo.common.widget.TCUserAvatarListAdapter;
import com.tencent.qcloud.xiaozhibo.common.widget.TCVideoWidget;
import com.tencent.qcloud.xiaozhibo.common.widget.TCVideoWidgetList;
import com.tencent.qcloud.xiaozhibo.common.widget.beautysetting.BeautyDialogFragment;
import com.tencent.qcloud.xiaozhibo.common.widget.danmaku.TCDanmuMgr;
import com.tencent.qcloud.xiaozhibo.common.widget.like.TCHeartLayout;
import com.tencent.qcloud.xiaozhibo.im.TCChatEntity;
import com.tencent.qcloud.xiaozhibo.im.TCChatMsgListAdapter;
import com.tencent.qcloud.xiaozhibo.im.TCSimpleUserInfo;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.mainui.list.TCLiveListFragment;
import com.tencent.qcloud.xiaozhibo.videopublish.TCVideoPublisherActivity;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLog;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.ugc.TXRecordCommon;
import com.umeng.socialize.ShareAction;
import com.umeng.socialize.UMShareAPI;
import com.umeng.socialize.UMShareListener;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMWeb;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

import master.flame.danmaku.controller.IDanmakuView;

/**
 * Created by RTMP on 2016/8/4
 */
public class TCLivePlayerActivity extends Activity implements IMLVBLiveRoomListener, View.OnClickListener, TCInputTextMsgDialog.OnTextSendListener {
    private static final String TAG = TCLivePlayerActivity.class.getSimpleName();

    protected TXCloudVideoView mTXCloudVideoView;
    private TCInputTextMsgDialog mInputTextMsgDialog;
    private ListView mListViewMsg;

    private ArrayList<TCChatEntity> mArrayListChatEntity = new ArrayList<>();
    private TCChatMsgListAdapter mChatMsgListAdapter;

    protected Handler mHandler = new Handler();

    private ImageView mHeadIcon;
    private ImageView mRecordBall;
    private TextView mtvPuserName;
    private TextView mMemberCount;

    private String mPusherAvatar;

    private long mCurrentMemberCount = 0;
    private long mTotalMemberCount = 0;
    private long mHeartCount = 0;

    private boolean mPlaying = false;
    private String mPusherNickname;
    protected String mPusherId;
    protected String mPlayUrl = "http://2527.vod.myqcloud.com/2527_000007d04afea41591336f60841b5774dcfd0001.f0.flv";
    private String mGroupId = "";
    private String mFileId = "";
    protected String mUserId = "";
    protected String mNickname = "";
    protected String mHeadPic = "";
    private String mTimeStamp = "";

    //头像列表控件
    private RecyclerView mUserAvatarList;
    private TCUserAvatarListAdapter mAvatarListAdapter;

    //点赞动画
    private TCHeartLayout mHeartLayout;
    //点赞频率控制
    private TCFrequeControl mLikeFrequeControl;

    //弹幕
    private TCDanmuMgr  mDanmuMgr;
    private IDanmakuView mDanmuView;

    //手势动画
    private RelativeLayout mControllLayer;
    private TCSwipeAnimationController mTCSwipeAnimationController;
    protected ImageView mBgImageView;

    //分享相关
    private UMImage mImage = null;
    private SHARE_MEDIA mShare_meidia = SHARE_MEDIA.WEIXIN;
    private String mShareUrl = TCConstants.SVR_LivePlayShare_URL;
    private String mCoverUrl = "";
    private String mTitle = ""; //标题

    //log相关
    protected boolean mShowLog = false;

    //录制相关
    private boolean mRecording = false;
    private ProgressBar     mRecordProgress = null;
    private long mStartRecordTimeStamp = 0;

    protected MLVBLiveRoom mLiveRoom;

    //连麦相关
    private static final long LINKMIC_INTERVAL = 3*1000;

    private boolean             mIsBeingLinkMic         = false;

    private Button              mBtnLinkMic;
    private Button              mBtnSwitchCamera;
    private ImageView           mImgViewRecordVideo;
    private View                mLayoutRecordVideo;

    private long                mLastLinkMicTime = 0;
    private List<AnchorInfo>    mPusherList         = new ArrayList<>();
    private TCVideoWidgetList   mPlayerList;

    //美颜
    private TCBeautyHelper mBeautyHepler;

    private ErrorDialogFragment mErrDlgFragment = new ErrorDialogFragment();

    private long                mStartPushPts;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mStartPushPts = System.currentTimeMillis();

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.activity_live_play);

        Intent intent = getIntent();

        mPusherId = intent.getStringExtra(TCConstants.PUSHER_ID);
        mPlayUrl = intent.getStringExtra(TCConstants.PLAY_URL);
        mGroupId = intent.getStringExtra(TCConstants.GROUP_ID);
        mPusherNickname = intent.getStringExtra(TCConstants.PUSHER_NAME);
        mPusherAvatar = intent.getStringExtra(TCConstants.PUSHER_AVATAR);
        mHeartCount = Long.decode(intent.getStringExtra(TCConstants.HEART_COUNT));
        mCurrentMemberCount = Long.decode(intent.getStringExtra(TCConstants.MEMBER_COUNT));
        mFileId = intent.getStringExtra(TCConstants.FILE_ID);
        mTimeStamp = intent.getStringExtra(TCConstants.TIMESTAMP);
        mTitle = intent.getStringExtra(TCConstants.ROOM_TITLE);
        mUserId = TCUserMgr.getInstance().getUserId();
        mNickname = TCUserMgr.getInstance().getNickname();
        mHeadPic = TCUserMgr.getInstance().getHeadPic();

        if (TextUtils.isEmpty(mNickname)) {
            mNickname = mUserId;
        }
        mLiveRoom = TCLiveRoomMgr.getLiveRoom(this);

        initView();

        mLiveRoom.setSelfProfile(mNickname, mHeadPic);

        startPlay();

        mCoverUrl = getIntent().getStringExtra(TCConstants.COVER_PIC);
        TCUtils.blurBgPic(this, mBgImageView, mCoverUrl, R.drawable.bg);

        initSharePara();

        mPlayerList = new TCVideoWidgetList(this, null);

        //在这里停留，让列表界面卡住几百毫秒，给sdk一点预加载的时间，形成秒开的视觉效果
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onAnchorEnter(final AnchorInfo pusherInfo) {
        if (pusherInfo == null || pusherInfo.userID == null) {
            return;
        }

        final TCVideoWidget videoView = mPlayerList.applyVideoView(pusherInfo.userID);
        if (videoView == null) {
            return;
        }

        if (mPusherList != null) {
            boolean exist = false;
            for (AnchorInfo item: mPusherList) {
                if (pusherInfo.userID.equalsIgnoreCase(item.userID)) {
                    exist = true;
                    break;
                }
            }
            if (exist == false) {
                mPusherList.add(pusherInfo);
            }
        }

        videoView.startLoading();
        mLiveRoom.startRemoteView(pusherInfo, videoView.videoView, new IMLVBLiveRoomListener.PlayCallback() {
            @Override
            public void onBegin() {
                videoView.stopLoading(false); //推流成功，stopLoading 小主播隐藏踢人的button
            }

            @Override
            public void onError(int errCode, String errInfo) {
                videoView.stopLoading(false);
                onDoAnchorExit(pusherInfo);
            }

            @Override
            public void onEvent(int event, Bundle param) {
                report(event);
            }
        }); //开启远端视频渲染
    }

    @Override
    public void onAnchorExit(AnchorInfo pusherInfo) {
        onDoAnchorExit(pusherInfo);
    }

    private void onDoAnchorExit(AnchorInfo pusherInfo) {
        if (mPusherList != null) {
            Iterator<AnchorInfo> it = mPusherList.iterator();
            while (it.hasNext()) {
                AnchorInfo item = it.next();
                if (pusherInfo.userID.equalsIgnoreCase(item.userID)) {
                    it.remove();
                    break;
                }
            }
        }

        mLiveRoom.stopRemoteView(pusherInfo);//关闭远端视频渲染
        mPlayerList.recycleVideoView(pusherInfo.userID);
    }

    /**
     * 收到观众进房通知
     *
     * @param audienceInfo 进房观众信息
     */
    @Override
    public void onAudienceEnter(AudienceInfo audienceInfo) {

    }

    /**
     * 收到观众退房通知
     *
     * @param audienceInfo 退房观众信息
     */
    @Override
    public void onAudienceExit(AudienceInfo audienceInfo) {

    }

    @Override
    public void onRequestJoinAnchor(AnchorInfo anchorInfo, String reason) {

    }

    @Override
    public void onKickoutJoinAnchor() {
        Toast.makeText(getApplicationContext(), "不好意思，您被主播踢开",Toast.LENGTH_LONG).show();
        stopLinkMic();
    }

    @Override
    public void onRequestRoomPK(AnchorInfo anchorInfo) {

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
        stopLinkMic();
        showErrorAndQuit(TCConstants.ERROR_MSG_LIVE_STOPPED);
    }

    @Override
    public void onError(int errorCode, String errorMessage, Bundle extraInfo) {
        if (errorCode == MLVBCommonDef.LiveRoomErrorCode.ERROR_IM_FORCE_OFFLINE) { // IM 被强制下线。
            Intent intent = new Intent();
            intent.setAction(TCConstants.EXIT_APP);
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        } else {
            showErrorAndQuit(TCConstants.ERROR_RTMP_PLAY_FAILED);
        }
    }

    /**
     * 警告回调
     *
     * @param warningCode 错误码 TRTCWarningCode
     * @param warningMsg  警告信息
     * @param extraInfo   额外信息，如警告发生的用户，一般不需要关注，默认是本地错误
     */
    @Override
    public void onWarning(int warningCode, String warningMsg, Bundle extraInfo) {

    }

    @Override
    public void onDebugLog(String log) {
        Log.d(TAG, log);
    }

    /**
     * 小直播ELK上报内容
     * @param event
     */
    private void report(int event) {
        switch (event) {
            case TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), 0, "视频播放成功", null);
                break;
            case TXLiveConstants.PLAY_ERR_NET_DISCONNECT :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), -1, "网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放", null);
                break;
            case TXLiveConstants.PLAY_ERR_GET_RTMP_ACC_URL_FAIL :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), -2, "获取加速拉流地址失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_FILE_NOT_FOUND :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), -3, "播放文件不存在", null);
                break;
            case TXLiveConstants.PLAY_ERR_HEVC_DECODE_FAIL :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), -4, "H265解码失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_HLS_KEY :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), -5, "HLS解码Key获取失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_GET_PLAYINFO_FAIL :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), -6, "获取点播文件信息失败", null);
                break;

        }
    }

    protected void initView() {
        RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.rl_play_root);

        relativeLayout.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return mTCSwipeAnimationController.processEvent(event);
            }
        });

        mControllLayer = (RelativeLayout) findViewById(R.id.rl_controllLayer);
        mTCSwipeAnimationController = new TCSwipeAnimationController(this);
        mTCSwipeAnimationController.setAnimationView(mControllLayer);

        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.video_view);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);
        mListViewMsg = (ListView) findViewById(R.id.im_msg_listview);
        mListViewMsg.setVisibility(View.VISIBLE);
        mHeartLayout = (TCHeartLayout) findViewById(R.id.heart_layout);
        mtvPuserName = (TextView) findViewById(R.id.tv_broadcasting_time);
        mtvPuserName.setText(TCUtils.getLimitString(mPusherNickname, 10));
        mRecordBall = (ImageView) findViewById(R.id.iv_record_ball);
        mRecordBall.setVisibility(View.GONE);

        mUserAvatarList = (RecyclerView) findViewById(R.id.rv_user_avatar);
        mUserAvatarList.setVisibility(View.VISIBLE);
        mAvatarListAdapter = new TCUserAvatarListAdapter(this, mPusherId);
        mUserAvatarList.setAdapter(mAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mUserAvatarList.setLayoutManager(linearLayoutManager);

        mInputTextMsgDialog = new TCInputTextMsgDialog(this, R.style.InputDialog);
        mInputTextMsgDialog.setmOnTextSendListener(this);

        mHeadIcon = (ImageView) findViewById(R.id.iv_head_icon);
        showHeadIcon(mHeadIcon, mPusherAvatar);
        mMemberCount = (TextView) findViewById(R.id.tv_member_counts);

        mCurrentMemberCount++;
        mMemberCount.setText(String.format(Locale.CHINA,"%d",mCurrentMemberCount));
        mChatMsgListAdapter = new TCChatMsgListAdapter(this, mListViewMsg, mArrayListChatEntity);
        mListViewMsg.setAdapter(mChatMsgListAdapter);

        mDanmuView = (IDanmakuView) findViewById(R.id.danmakuView);
        mDanmuView.setVisibility(View.VISIBLE);
        mDanmuMgr = new TCDanmuMgr(this);
        mDanmuMgr.setDanmakuView(mDanmuView);

        mBgImageView = (ImageView) findViewById(R.id.background);
        mBgImageView.setScaleType(ImageView.ScaleType.CENTER_CROP);

        mBtnLinkMic = (Button) findViewById(R.id.btn_linkmic);
        mBtnLinkMic.setVisibility(View.VISIBLE);
        mBtnLinkMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsBeingLinkMic == false) {
                    long curTime = System.currentTimeMillis();
                    if (curTime < mLastLinkMicTime + LINKMIC_INTERVAL) {
                        Toast.makeText(getApplicationContext(), "太频繁啦，休息一下！", Toast.LENGTH_SHORT).show();
                    } else {
                        mLastLinkMicTime = curTime;
                        startLinkMic();
                    }
                } else {
                    stopLinkMic();
                    startPlay();
                }
            }
        });

        mBtnSwitchCamera = (Button) findViewById(R.id.btn_switch_cam);
        mBtnSwitchCamera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsBeingLinkMic) {
                    mLiveRoom.switchCamera();
                }
            }
        });

        //美颜功能
        mBeautyHepler = new TCBeautyHelper(mLiveRoom);
        mLayoutRecordVideo = findViewById(R.id.layout_record);
        mImgViewRecordVideo = (ImageView) findViewById(R.id.btn_record);
        mImgViewRecordVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                if (mIsBeingLinkMic) {
                    if (mBeautyHepler.isAdded())
                        mBeautyHepler.dismiss();
                    else
                        mBeautyHepler.show(getFragmentManager(), "");
//                } else {
//                    showRecordUI();
//                }
            }
        });

    }

    private void showHeadIcon(ImageView view, String avatar) {
        TCUtils.showPicWithUrl(this,view,avatar,R.drawable.face);
    }

    protected void startPlay() {
        if (mPlaying) return;
        mLiveRoom.setListener(this);
        mLiveRoom.enterRoom(mGroupId, mTXCloudVideoView, new IMLVBLiveRoomListener.EnterRoomCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                showErrorAndQuit(TCConstants.ERROR_MSG_JOIN_GROUP_FAILED + errCode);
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), -10001, "进入LiveRoom失败", null);
            }

            @Override
            public void onSuccess() {
                mBgImageView.setVisibility(View.GONE);
                mLiveRoom.sendRoomCustomMsg(String.valueOf(TCConstants.IMCMD_ENTER_LIVE), "", null);
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY, TCUserMgr.getInstance().getUserId(), 10000, "进入LiveRoom成功", null);
            }
        });
        mPlaying = true;
    }

    protected void stopPlay(boolean clearLastFrame) {
        if (mPlaying && mLiveRoom != null) {
            mLiveRoom.sendRoomCustomMsg(String.valueOf(TCConstants.IMCMD_EXIT_LIVE), "", null);
            mLiveRoom.exitRoom(new IMLVBLiveRoomListener.ExitRoomCallback() {
                @Override
                public void onError(int errCode, String errInfo) {
                    TXLog.w(TAG, "exit room error : "+errInfo);
                }

                @Override
                public void onSuccess() {
                    TXLog.d(TAG, "exit room success ");
                }
            });
            mPlaying = false;
            mLiveRoom.setListener(null);
        }
    }

    /**
     * 发消息弹出框
     */
    private void showInputMsgDialog() {
        WindowManager windowManager = getWindowManager();
        Display display = windowManager.getDefaultDisplay();
        WindowManager.LayoutParams lp = mInputTextMsgDialog.getWindow().getAttributes();

        lp.width = (display.getWidth()); //设置宽度
        mInputTextMsgDialog.getWindow().setAttributes(lp);
        mInputTextMsgDialog.setCancelable(true);
        mInputTextMsgDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        mInputTextMsgDialog.show();
    }

    protected void showErrorAndQuit(String errorMsg) {
        stopPlay(true);

        Intent rstData = new Intent();
        rstData.putExtra(TCConstants.ACTIVITY_RESULT,errorMsg);
        setResult(TCLiveListFragment.START_LIVE_PLAY,rstData);

        if (!mErrDlgFragment.isAdded() && !this.isFinishing()) {
            Bundle args = new Bundle();
            args.putString("errorMsg", errorMsg);
            mErrDlgFragment.setArguments(args);
            mErrDlgFragment.setCancelable(false);

            //此处不使用用.show(...)的方式加载dialogfragment，避免IllegalStateException
            FragmentTransaction transaction = getFragmentManager().beginTransaction();
            transaction.add(mErrDlgFragment, "loading");
            transaction.commitAllowingStateLoss();
        }
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_back:
                Intent rstData = new Intent();
                long memberCount = mCurrentMemberCount - 1;
                rstData.putExtra(TCConstants.MEMBER_COUNT, memberCount>=0 ? memberCount:0);
                rstData.putExtra(TCConstants.HEART_COUNT, mHeartCount);
                rstData.putExtra(TCConstants.PUSHER_ID, mPusherId);
                setResult(0,rstData);
                stopPlay(true);
                finish();
                break;
            case R.id.btn_like:
                if (mHeartLayout != null) {
                    mHeartLayout.addFavor();
                }

                //点赞发送请求限制
                if (mLikeFrequeControl == null) {
                    mLikeFrequeControl = new TCFrequeControl();
                    mLikeFrequeControl.init(2, 1);
                }
                if (mLikeFrequeControl.canTrigger()) {
                    mHeartCount++;
                    mLiveRoom.setCustomInfo(MLVBCommonDef.CustomFieldOp.INC, "praise", 1, null);
                    //向ChatRoom发送点赞消息
                    mLiveRoom.sendRoomCustomMsg(String.valueOf(TCConstants.IMCMD_PRAISE), "", null);
                }
                break;
            case R.id.btn_message_input:
                showInputMsgDialog();
                break;
            case R.id.btn_share:
                showShareDialog();
                break;
            case R.id.btn_log:
                showLog();
            break;
            case R.id.btn_record:
                break;
            case R.id.record:
                break;
            case R.id.retry_record:
                break;
            case R.id.close_record:
                break;
            default:
                break;
        }
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
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mDanmuMgr != null) {
            mDanmuMgr.destroy();
            mDanmuMgr = null;
        }

        stopPlay(true);

        mPlayerList.recycleVideoView();
        mPlayerList = null;
        stopLinkMic();

        hideNoticeToast();


        long endPushPts = System.currentTimeMillis();
        long diff = (endPushPts - mStartPushPts) / 1000 ;
        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_LIVE_PLAY_DURATION, TCUserMgr.getInstance().getUserId(), diff, "直播播放时长", null);
    }

    private void notifyMsg(final TCChatEntity entity) {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
//                if(entity.getType() == TCConstants.PRAISE) {
//                    if(mArrayListChatEntity.contains(entity))
//                        return;
//                }
                if (mArrayListChatEntity.size() > 1000)
                {
                    while (mArrayListChatEntity.size() > 900)
                    {
                        mArrayListChatEntity.remove(0);
                    }
                }

                mArrayListChatEntity.add(entity);
                mChatMsgListAdapter.notifyDataSetChanged();
            }
        });
    }

    public void handleMemberJoinMsg(TCSimpleUserInfo userInfo) {
        //更新头像列表 返回false表明已存在相同用户，将不会更新数据
        if (!mAvatarListAdapter.addItem(userInfo))
            return;

        mCurrentMemberCount++;
        mTotalMemberCount++;
        mMemberCount.setText(String.format(Locale.CHINA,"%d",mCurrentMemberCount));

        //左下角显示用户加入消息
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.nickname))
            entity.setContext(userInfo.userid + "加入直播");
        else
            entity.setContext(userInfo.nickname + "加入直播");
        entity.setType(TCConstants.MEMBER_ENTER);
        notifyMsg(entity);
    }

    public void handleMemberQuitMsg(TCSimpleUserInfo userInfo) {
        if(mCurrentMemberCount > 0)
            mCurrentMemberCount--;
        else
            Log.d(TAG, "接受多次退出请求，目前人数为负数");

        mMemberCount.setText(String.format(Locale.CHINA,"%d",mCurrentMemberCount));

        mAvatarListAdapter.removeItem(userInfo.userid);

        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.nickname))
            entity.setContext(userInfo.userid + "退出直播");
        else
            entity.setContext(userInfo.nickname + "退出直播");
        entity.setType(TCConstants.MEMBER_EXIT);
        notifyMsg(entity);
    }

    public void handlePraiseMsg(TCSimpleUserInfo userInfo) {
        TCChatEntity entity = new TCChatEntity();

        entity.setSenderName("通知");
        if (TextUtils.isEmpty(userInfo.nickname))
            entity.setContext(userInfo.userid + "点了个赞");
        else
            entity.setContext(userInfo.nickname + "点了个赞");
        if (mHeartLayout != null) {
            mHeartLayout.addFavor();
        }
        mHeartCount++;

        entity.setType(TCConstants.MEMBER_ENTER);
        notifyMsg(entity);
    }

    public void handleDanmuMsg(TCSimpleUserInfo userInfo, String text) {
        handleTextMsg(userInfo, text);
        if (mDanmuMgr != null) {
            mDanmuMgr.addDanmu(userInfo.headpic, userInfo.nickname, text);
        }
    }

    public void handleTextMsg(TCSimpleUserInfo userInfo, String text) {
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName(userInfo.nickname);
        entity.setContext(text);
        entity.setType(TCConstants.TEXT_TYPE);

        notifyMsg(entity);
    }

    /**
     * TextInputDialog发送回调
     * @param msg 文本信息
     * @param danmuOpen 是否打开弹幕
     */
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

        //消息回显
        TCChatEntity entity = new TCChatEntity();
        entity.setSenderName("我:");
        entity.setContext(msg);
        entity.setType(TCConstants.TEXT_TYPE);
        notifyMsg(entity);

        if (danmuOpen) {
            if (mDanmuMgr != null) {
                mDanmuMgr.addDanmu(mHeadPic, mNickname, msg);
            }
            mLiveRoom.sendRoomCustomMsg(String.valueOf(TCConstants.IMCMD_DANMU), msg, new IMLVBLiveRoomListener.SendRoomCustomMsgCallback() {
                @Override
                public void onError(int errCode, String errInfo) {
                    Log.w(TAG, "sendRoomDanmuMsg error: "+errInfo);
                }

                @Override
                public void onSuccess() {
                    Log.d(TAG, "sendRoomDanmuMsg success");
                }
            });
        } else {
            mLiveRoom.sendRoomTextMsg(msg, new IMLVBLiveRoomListener.SendRoomTextMsgCallback() {
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

    private void initSharePara() {
        try {
            mShareUrl = mShareUrl + "?sdkappid=" + java.net.URLEncoder.encode(String.valueOf(TCUserMgr.getInstance().getSDKAppID()), "utf-8")
                    + "&acctype=" + java.net.URLEncoder.encode(TCUserMgr.getInstance().getAccountType(), "utf-8")
                    + "&userid=" +java.net.URLEncoder.encode(mPusherId, "utf-8")
                    + "&type=" + java.net.URLEncoder.encode(String.valueOf(1), "utf-8")
                    + "&fileid=" + java.net.URLEncoder.encode(String.valueOf(mFileId), "utf-8")
                    + "&ts=" + java.net.URLEncoder.encode(String.valueOf(mTimeStamp), "utf-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        if (mCoverUrl == null || mCoverUrl.isEmpty()) {
            mImage= new UMImage(TCLivePlayerActivity.this.getApplicationContext(), R.drawable.bg);
        } else {
            mImage= new UMImage(TCLivePlayerActivity.this.getApplicationContext(), mCoverUrl);
        }
    }

    /**
     * 展示分享界面
     */
    private void showShareDialog() {

        View view = getLayoutInflater().inflate(R.layout.share_dialog, null);
        final AlertDialog mDialog = new AlertDialog.Builder(this,R.style.ConfirmDialogStyle).create();
        mDialog.show();// 显示创建的AlertDialog，并显示，必须放在Window设置属性之前

        Window window =mDialog.getWindow();
        if (window != null) {
            window.setContentView(view);//这一步必须指定，否则不出现弹窗
            WindowManager.LayoutParams mParams = window.getAttributes();
            mParams.width = android.view.WindowManager.LayoutParams.MATCH_PARENT;
            mParams.height = android.view.WindowManager.LayoutParams.WRAP_CONTENT;
            window.setGravity(Gravity.BOTTOM); // 此处可以设置dialog显示的位置
            window.setBackgroundDrawableResource(android.R.color.white);
            window.setAttributes(mParams);
        }

        Button btn_wx = (Button) view.findViewById(R.id.btn_share_wx);
        Button btn_circle = (Button) view.findViewById(R.id.btn_share_circle);
        Button btn_qq = (Button) view.findViewById(R.id.btn_share_qq);
        Button btn_qzone = (Button) view.findViewById(R.id.btn_share_qzone);
        Button btn_wb = (Button) view.findViewById(R.id.btn_share_wb);
        Button btn_cancle = (Button) view.findViewById(R.id.btn_share_cancle);

        btn_wx.setOnClickListener(mShareBtnClickListen);
        btn_circle.setOnClickListener(mShareBtnClickListen);
        btn_qq.setOnClickListener(mShareBtnClickListen);
        btn_qzone.setOnClickListener(mShareBtnClickListen);
        btn_wb.setOnClickListener(mShareBtnClickListen);
        btn_cancle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mDialog.dismiss();
            }
        });
    }

    private View.OnClickListener mShareBtnClickListen = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch (view.getId()) {
                case R.id.btn_share_wx:
                    mShare_meidia = SHARE_MEDIA.WEIXIN;
                    break;
                case R.id.btn_share_circle:
                    mShare_meidia = SHARE_MEDIA.WEIXIN_CIRCLE;
                    break;
                case R.id.btn_share_qq:
                    mShare_meidia = SHARE_MEDIA.QQ;
                    break;
                case R.id.btn_share_qzone:
                    mShare_meidia = SHARE_MEDIA.QZONE;
                    break;
                case R.id.btn_share_wb:
                    mShare_meidia = SHARE_MEDIA.SINA;
                    break;
                default:
                    break;
            }

            ShareAction shareAction = new ShareAction(TCLivePlayerActivity.this);

            UMWeb web = new UMWeb(mShareUrl);
            web.setThumb(mImage);
            web.setTitle(mTitle);
            shareAction.withMedia(web);
            shareAction.withText(mtvPuserName.getText() + "正在直播");
            shareAction.setCallback(umShareListener);
            shareAction.setPlatform(mShare_meidia).share();
        }
    };

    private UMShareListener umShareListener = new UMShareListener() {
        @Override
        public void onStart(SHARE_MEDIA platform) {
            Log.d("plat","platform" + platform);
        }

        @Override
        public void onResult(SHARE_MEDIA platform) {
            Log.d("plat","platform"+platform);
            Toast.makeText(TCLivePlayerActivity.this, platform + " 分享成功啦", Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onError(SHARE_MEDIA platform, Throwable t) {
            Toast.makeText(TCLivePlayerActivity.this,"分享失败"+t.getMessage(),Toast.LENGTH_LONG).show();
        }

        @Override
        public void onCancel(SHARE_MEDIA platform) {
            Toast.makeText(TCLivePlayerActivity.this,platform + " 分享取消了", Toast.LENGTH_SHORT).show();
        }
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /** attention to this below ,must add this**/
        UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);
        com.umeng.socialize.utils.Log.d("result","onActivityResult");
    }

    protected void showLog() {
        mShowLog = !mShowLog;
        if (mTXCloudVideoView != null) {
            mTXCloudVideoView.showLog(mShowLog);
        }
        ImageView liveLog = (ImageView) findViewById(R.id.btn_log);
        if (mShowLog) {
            if (liveLog != null) liveLog.setBackgroundResource(R.drawable.icon_log_on);
        } else {
            if (liveLog != null) liveLog.setBackgroundResource(R.drawable.icon_log_off);
        }

        mPlayerList.showLog(mShowLog);
    }

    private void showTooShortToast() {
        if (mRecordProgress != null) {
            int statusBarHeight = 0;
            int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
            if (resourceId > 0) {
                statusBarHeight = getResources().getDimensionPixelSize(resourceId);
            }

            int[] position = new int[2];
            mRecordProgress.getLocationOnScreen(position);
            Toast toast = Toast.makeText(this, "至少录到这里", Toast.LENGTH_SHORT);
            toast.setGravity(Gravity.TOP|Gravity.LEFT, position[0], position[1] - statusBarHeight - 110);
            toast.show();
        }
    }

    private void joinPusher() {
        TCVideoWidget videoView = mPlayerList.getFirstRoomView();
        videoView.setUsed(true);
        videoView.userID = mUserId;

        mLiveRoom.startLocalPreview(true, videoView.videoView);
        mLiveRoom.setCameraMuteImage(BitmapFactory.decodeResource(getResources(), R.drawable.pause_publish));
        BeautyDialogFragment.BeautyParams beautyParams = mBeautyHepler.getParams();
        mLiveRoom.setBeautyStyle(beautyParams.mBeautyStyle, beautyParams.mBeautyProgress, beautyParams.mWhiteProgress, beautyParams.mRuddyProgress);
        mLiveRoom.joinAnchor(new IMLVBLiveRoomListener.JoinAnchorCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                stopLinkMic();
                mBtnLinkMic.setEnabled(true);
                mIsBeingLinkMic = false;
                mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
                Toast.makeText(TCLivePlayerActivity.this, "连麦失败：" + errInfo, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onSuccess() {
                mBtnLinkMic.setEnabled(true);
                mIsBeingLinkMic = true;
                if (mBtnSwitchCamera != null) {
                    mBtnSwitchCamera.setVisibility(View.VISIBLE);
                }
            }
        });
    }

    private void startLinkMic() {
        if (mIsBeingLinkMic) {
            return;
        }

        mBtnLinkMic.setEnabled(false);
        mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_off);

        showNoticeToast("等待主播接受......");

        //开始连麦，不允许录制小视频
        mImgViewRecordVideo.setEnabled(false);

        mLiveRoom.requestJoinAnchor("", new IMLVBLiveRoomListener.RequestJoinAnchorCallback() {
            @Override
            public void onAccept() {
                hideNoticeToast();
                Toast.makeText(TCLivePlayerActivity.this, "主播接受了您的连麦请求，开始连麦", Toast.LENGTH_SHORT).show();

                if (TCUtils.checkRecordPermission(TCLivePlayerActivity.this)) {
                    joinPusher();
                }

                if (mImgViewRecordVideo != null) {
                    mImgViewRecordVideo.setBackgroundResource(R.drawable.icon_beauty_drawable);
                    mLayoutRecordVideo.setVisibility(View.VISIBLE);
                    mImgViewRecordVideo.setEnabled(true);
                }

            }

            @Override
            public void onReject(String reason) {
                mBtnLinkMic.setEnabled(true);
                hideNoticeToast();
                Toast.makeText(TCLivePlayerActivity.this, reason, Toast.LENGTH_SHORT).show();
                mImgViewRecordVideo.setEnabled(true);
                mIsBeingLinkMic = false;
                mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
            }

            @Override
            public void onTimeOut() {
                mBtnLinkMic.setEnabled(true);
                mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
                hideNoticeToast();
                Toast.makeText(TCLivePlayerActivity.this, "连麦请求超时，主播没有做出回应", Toast.LENGTH_SHORT).show();
                mImgViewRecordVideo.setEnabled(true);
            }

            @Override
            public void onError(int code, String errInfo) {
                Toast.makeText(TCLivePlayerActivity.this, "连麦请求发生错误，"+errInfo, Toast.LENGTH_SHORT).show();
                hideNoticeToast();
                mBtnLinkMic.setEnabled(true);
                mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
                if (mImgViewRecordVideo != null) {
                    mImgViewRecordVideo.setBackgroundResource(R.drawable.video);
                    mLayoutRecordVideo.setVisibility(View.GONE);
                    mImgViewRecordVideo.setEnabled(true);
                }
            }
        });
    }

    private synchronized void stopLinkMic() {
        if (!mIsBeingLinkMic) return;

        mIsBeingLinkMic = false;

        //启用连麦Button
        if (mBtnLinkMic != null) {
            mBtnLinkMic.setEnabled(true);
            mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_on);
        }

        //隐藏切换摄像头Button
        if (mBtnSwitchCamera != null) {
            mBtnSwitchCamera.setVisibility(View.INVISIBLE);
        }

        //结束连麦，允许录制小视频
        if (mImgViewRecordVideo != null) {
            mImgViewRecordVideo.setBackgroundResource(R.drawable.video);
            mLayoutRecordVideo.setVisibility(View.GONE);
            mImgViewRecordVideo.setEnabled(true);
        }

        mLiveRoom.stopLocalPreview();
        mLiveRoom.quitJoinAnchor(new IMLVBLiveRoomListener.QuitAnchorCallback() {
            @Override
            public void onError(int errCode, String errInfo) {

            }

            @Override
            public void onSuccess() {

            }
        });

        if (mPlayerList != null) {
            mPlayerList.recycleVideoView(mUserId);
            mPusherList.clear();
        }
    }

    private Toast mNoticeToast;
    private Timer mNoticeTimer;

    private void showNoticeToast(String text) {
        if (mNoticeToast == null) {
            mNoticeToast = Toast.makeText(getApplicationContext(), text, Toast.LENGTH_LONG);
        }

        if (mNoticeTimer == null) {
            mNoticeTimer = new  Timer();
        }

        mNoticeToast.setText(text);
        mNoticeTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                mNoticeToast.show();
            }
        }, 0, 3000);

    }

    private void hideNoticeToast() {
        if (mNoticeToast != null) {
            mNoticeToast.cancel();
            mNoticeToast = null;
        }
        if (mNoticeTimer != null) {
            mNoticeTimer.cancel();
            mNoticeTimer = null;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case 100:
                for (int ret : grantResults) {
                    if (ret != PackageManager.PERMISSION_GRANTED) {
                        return;
                    }
                }
                joinPusher();
                break;
            default:
                break;
        }
    }
}
