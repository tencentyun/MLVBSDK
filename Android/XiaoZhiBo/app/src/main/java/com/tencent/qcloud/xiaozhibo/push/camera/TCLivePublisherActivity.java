package com.tencent.qcloud.xiaozhibo.push.camera;

import android.animation.ObjectAnimator;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCBeautyHelper;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.widget.TCUserAvatarListAdapter;
import com.tencent.qcloud.xiaozhibo.common.widget.TCVideoWidget;
import com.tencent.qcloud.xiaozhibo.common.widget.TCVideoWidgetList;
import com.tencent.qcloud.xiaozhibo.common.widget.beautysetting.BeautyDialogFragment;
import com.tencent.qcloud.xiaozhibo.im.TCSimpleUserInfo;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.push.TCLiveBasePublisherActivity;
import com.tencent.qcloud.xiaozhibo.push.camera.widget.TCAudioControl;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by RTMP on 2016/8/4
 */
public class TCLivePublisherActivity extends TCLiveBasePublisherActivity {
    private static final String TAG = TCLivePublisherActivity.class.getSimpleName();

    public TXCloudVideoView mTXCloudVideoView;

    private TCBeautyHelper mBeautyHepler;
    private Button mFlashView;

    //观众头像列表控件
    private RecyclerView mUserAvatarList;
    private TCUserAvatarListAdapter mAvatarListAdapter;

    //主播信息
    private ImageView mHeadIcon;
    private ImageView mRecordBall;
    private TextView mBroadcastTime;
    private TextView mMemberCount;
    private Timer mBroadcastTimer;
    private BroadcastTimerTask mBroadcastTimerTask;

    private long mSecond = 0;

    private boolean mFlashOn = false;

    private TCAudioControl mAudioCtrl;
    private LinearLayout mAudioPluginLayout;
    private TextView mNetBusyTips;

    //log相关
    protected boolean mShowLog = false;

    //连麦主播
    private boolean                     mPendingRequest = false;
    private TCVideoWidgetList mPlayerList;
    private List<AnchorInfo> mPusherList         = new ArrayList<>();
    private TCVideoWidget.OnRoomViewListener mListener = new TCVideoWidget.OnRoomViewListener() {
        @Override
        public void onKickUser(String userID) {
            if (userID != null) {
                for (AnchorInfo item: mPusherList) {
                    if (userID.equalsIgnoreCase(item.userID)) {
                        onAnchorExit(item);
                        break;
                    }
                }
                mLiveRoom.kickoutJoinAnchor(userID);
            }
        }
    };
    private long mStartPushPts;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_CAMERA_PUSH, TCUserMgr.getInstance().getUserId(), 0, "摄像头推流", null);
        mStartPushPts = System.currentTimeMillis();
    }

    protected void initView() {

        setContentView(R.layout.activity_publish);

        super.initView();

        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.video_view);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);

        mUserAvatarList = (RecyclerView) findViewById(R.id.rv_user_avatar);
        mAvatarListAdapter = new TCUserAvatarListAdapter(this, TCUserMgr.getInstance().getUserId());
        mUserAvatarList.setAdapter(mAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mUserAvatarList.setLayoutManager(linearLayoutManager);

        mFlashView = (Button) findViewById(R.id.flash_btn);

        mBroadcastTime = (TextView) findViewById(R.id.tv_broadcasting_time);
        mBroadcastTime.setText(String.format(Locale.US, "%s", "00:00:00"));
        mRecordBall = (ImageView) findViewById(R.id.iv_record_ball);

        mHeadIcon = (ImageView) findViewById(R.id.iv_head_icon);
        showHeadIcon(mHeadIcon, TCUserMgr.getInstance().getHeadPic());
        mMemberCount = (TextView) findViewById(R.id.tv_member_counts);
        mMemberCount.setText("0");

        //AudioControl
        mAudioCtrl = (TCAudioControl) findViewById(R.id.layoutAudioControlContainer);
        mAudioPluginLayout = (LinearLayout) findViewById(R.id.audio_plugin);
        mAudioCtrl.setPluginLayout(mAudioPluginLayout);

        mNetBusyTips = (TextView) findViewById(R.id.netbusy_tv);

        mBeautyHepler = new TCBeautyHelper(mLiveRoom);
        mPlayerList = new TCVideoWidgetList(this, mListener);
    }

    protected void startPublishImpl() {
        mAudioCtrl.setPusher(mLiveRoom);
        mTXCloudVideoView.setVisibility(View.VISIBLE);

        BeautyDialogFragment.BeautyParams beautyParams = mBeautyHepler.getParams();
        mLiveRoom.startLocalPreview(true, mTXCloudVideoView);
//        mLiveRoom.setPauseImage(BitmapFactory.decodeResource(getResources(), R.drawable.pause_publish));
        mLiveRoom.setBeautyStyle(beautyParams.mBeautyStyle, beautyParams.mBeautyProgress, beautyParams.mWhiteProgress, beautyParams.mRuddyProgress);
        mLiveRoom.setFaceSlimLevel(beautyParams.mFaceLiftProgress);
        mLiveRoom.setEyeScaleLevel(beautyParams.mBigEyeProgress);
        super.startPublishImpl();
    }

    protected void startPublish() {
        if (TCUtils.checkRecordPermission(this)) {
            startPublishImpl();
        }
    }

    protected void stopPublish() {
        super.stopPublish();
        if (mAudioCtrl != null) {
            mAudioCtrl.unInit();
            mAudioCtrl.setPusher(null);
            mAudioCtrl = null;
        }
    }

    protected void onCreateRoomSucess() {
        super.onCreateRoomSucess();
        startRecordAnimation();
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
                videoView.stopLoading(true); //推流成功，stopLoading 大主播显示出踢人的button
            }

            @Override
            public void onError(int errCode, String errInfo) {
                videoView.stopLoading(false);
                onDoAnchorExit(pusherInfo);
            }

            @Override
            public void onEvent(int event, Bundle param) {

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

    @Override
    public void onRequestJoinAnchor(final AnchorInfo pusherInfo, String reason) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setCancelable(true)
                .setTitle("提示")
                .setMessage(pusherInfo.userName + "向您发起连麦请求")
                .setPositiveButton("接受", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mLiveRoom.responseJoinAnchor(pusherInfo.userID, true, "");
                        dialog.dismiss();
                        mPendingRequest = false;
                    }
                })
                .setNegativeButton("拒绝", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mLiveRoom.responseJoinAnchor(pusherInfo.userID, false, "主播拒绝了您的连麦请求");
                        dialog.dismiss();
                        mPendingRequest = false;
                    }
                });

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mPendingRequest == true) {
                    mLiveRoom.responseJoinAnchor(pusherInfo.userID, false, "请稍后，主播正在处理其它人的连麦请求");
                    return;
                }

                if (mPusherList.size() >= 3) {
                    mLiveRoom.responseJoinAnchor(pusherInfo.userID, false, "主播端连麦人数超过最大限制");
                    return;
                }

                final AlertDialog alertDialog = builder.create();
                alertDialog.setCancelable(false);
                alertDialog.setCanceledOnTouchOutside(false);
                alertDialog.show();

                mPendingRequest = true;

                mHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        alertDialog.dismiss();
                        mPendingRequest = false;
                    }
                }, 10000);
            }
        });
    }

    /**
     * 加载主播头像
     *
     * @param view   view
     * @param avatar 头像链接
     */
    private void showHeadIcon(ImageView view, String avatar) {
        TCUtils.showPicWithUrl(this, view, avatar, R.drawable.face);
    }

    private ObjectAnimator mObjAnim;

    /**
     * 开启红点与计时动画
     */
    private void startRecordAnimation() {

        mObjAnim = ObjectAnimator.ofFloat(mRecordBall, "alpha", 1f, 0f, 1f);
        mObjAnim.setDuration(1000);
        mObjAnim.setRepeatCount(-1);
        mObjAnim.start();

        //直播时间
        if (mBroadcastTimer == null) {
            mBroadcastTimer = new Timer(true);
            mBroadcastTimerTask = new BroadcastTimerTask();
            mBroadcastTimer.schedule(mBroadcastTimerTask, 1000, 1000);
        }
    }

    /**
     * 关闭红点与计时动画
     */
    private void stopRecordAnimation() {

        if (null != mObjAnim)
            mObjAnim.cancel();

        //直播时间
        if (null != mBroadcastTimer) {
            mBroadcastTimerTask.cancel();
        }
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
                    if (!mTCSwipeAnimationController.isMoving())
                        mBroadcastTime.setText(TCUtils.formattedTime(mSecond));
                }
            });
//            if (MySelfInfo.getInstance().getIdStatus() == TCConstants.HOST)
//                mHandler.sendEmptyMessage(UPDAT_WALL_TIME_TIMER_TASK);
        }
    }

    private void showNetBusyTips() {
        if (mNetBusyTips.isShown()) {
            return;
        }
        mNetBusyTips.setVisibility(View.VISIBLE);
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mNetBusyTips.setVisibility(View.GONE);
            }
        }, 5000);

    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        stopRecordAnimation();

        mPlayerList.recycleVideoView();
        mPlayerList = null;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
        }

        long endPushPts = System.currentTimeMillis();
        long diff = (endPushPts - mStartPushPts) / 1000 ;
        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_CAMERA_PUSH_DURATION, TCUserMgr.getInstance().getUserId(), diff, "摄像头推流时长", null);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.switch_cam:
                if (mLiveRoom != null) {
                    mLiveRoom.switchCamera();
                }
                break;
            case R.id.flash_btn:
                if (mLiveRoom == null || !mLiveRoom.enableTorch(!mFlashOn)) {
                    Toast.makeText(getApplicationContext(), "打开闪光灯失败", Toast.LENGTH_SHORT).show();
                    return;
                }
                mFlashOn = !mFlashOn;
                mFlashView.setBackgroundDrawable(mFlashOn ?
                        getResources().getDrawable(R.drawable.icon_flash_pressed) :
                        getResources().getDrawable(R.drawable.icon_flash));

                break;
            case R.id.beauty_btn:
                if (mBeautyHepler.isAdded())
                    mBeautyHepler.dismiss();
                else
                    mBeautyHepler.show(getFragmentManager(), "");
                break;
            case R.id.btn_close:
                showComfirmDialog(TCConstants.TIPS_MSG_STOP_PUSH, false);
                break;
            case R.id.btn_audio_ctrl:
                if(null != mAudioCtrl ) {
                    mAudioCtrl.setVisibility(mAudioCtrl.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                }
                break;
            case R.id.btn_audio_effect:
                mAudioCtrl.setVisibility(mAudioCtrl.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                break;
            case R.id.btn_audio_close:
                mAudioCtrl.stopBGM();
                mAudioPluginLayout.setVisibility(View.GONE);
                mAudioCtrl.setVisibility(View.GONE);
                break;
            case R.id.btn_log:
                showLog();
                break;
            default:
                super.onClick(v);
                break;
        }
    }


    @Override
    protected void showErrorAndQuit(int errorCode, String errorMsg) {
        stopRecordAnimation();
        super.showErrorAndQuit(errorCode, errorMsg);
    }

    public void handleMemberJoinMsg(TCSimpleUserInfo userInfo) {
        //更新头像列表 返回false表明已存在相同用户，将不会更新数据
        if (!mAvatarListAdapter.addItem(userInfo))
            return;

        super.handleMemberJoinMsg(userInfo);
        mMemberCount.setText(String.format(Locale.CHINA, "%d", lMemberCount));

    }

    public void handleMemberQuitMsg(TCSimpleUserInfo userInfo) {

        mAvatarListAdapter.removeItem(userInfo.userid);

        super.handleMemberQuitMsg(userInfo);
        mMemberCount.setText(String.format(Locale.CHINA, "%d", lMemberCount));

    }

    @Override
    public void triggerSearch(String query, Bundle appSearchData) {
        super.triggerSearch(query, appSearchData);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (null != mAudioCtrl && mAudioCtrl.getVisibility() != View.GONE && ev.getRawY() < mAudioCtrl.getTop()) {
            mAudioCtrl.setVisibility(View.GONE);
        }
        return super.dispatchTouchEvent(ev);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        /** attention to this below ,must add this**/
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK) {//是否选择，没选择就不会继续
            if (requestCode == mAudioCtrl.REQUESTCODE) {
                if (data == null) {
                    Log.e(TAG, "null data");
                } else {
                    Uri uri = data.getData();//得到uri，后面就是将uri转化成file的过程。
                    if (mAudioCtrl != null) {
                        mAudioCtrl.processActivityResult(uri);
                    } else {
                        Log.e(TAG, "NULL Pointer! Get Music Failed");
                    }
                }
            }
        }
    }

    protected void showLog() {
        mShowLog = !mShowLog;
        if (mTXCloudVideoView != null) {
            mTXCloudVideoView.showLog(mShowLog);
        }
        Button liveLog = (Button) findViewById(R.id.btn_log);
        if (mShowLog) {
            if (liveLog != null) liveLog.setBackgroundResource(R.drawable.icon_log_on);

        } else {
            if (liveLog != null) liveLog.setBackgroundResource(R.drawable.icon_log_off);
        }

        mPlayerList.showLog(mShowLog);
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case 100:
                for (int ret : grantResults) {
                    if (ret != PackageManager.PERMISSION_GRANTED) {
                        showErrorAndQuit(-1314, "获取权限失败");
                        return;
                    }
                }
                startPublishImpl();
                break;
            default:
                break;
        }
    }
}
