package com.tencent.qcloud.xiaozhibo.anchor;

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
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.widget.beauty.TCBeautyControl;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.widget.TCUserAvatarListAdapter;
import com.tencent.qcloud.xiaozhibo.common.widget.video.TCVideoView;
import com.tencent.qcloud.xiaozhibo.common.widget.video.TCVideoViewMgr;
import com.tencent.qcloud.xiaozhibo.common.widget.beauty.TCBeautyDialogFragment;
import com.tencent.qcloud.xiaozhibo.common.msg.TCSimpleUserInfo;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.anchor.music.TCAudioControl;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

/**
 * Module:   TCBaseAnchorActivity
 * <p>
 * Function: 主播推流的页面
 * <p>
 *
 * 1. MLVB 其他观众发起连麦请求处理：{@link TCCameraAnchorActivity#onRequestJoinAnchor(AnchorInfo, String)}
 *
 * 2. MLVB 其他主播连麦，结束连麦处理：{@link TCCameraAnchorActivity#onAnchorEnter(AnchorInfo)} {@link TCCameraAnchorActivity#onAnchorExit(AnchorInfo)}
 *
 * 3. 音效控制面板类 {@link TCAudioControl}
 *
 * 4. 美颜特效控制类 {@link TCBeautyControl}
 */
public class TCCameraAnchorActivity extends TCBaseAnchorActivity {
    private static final String TAG = TCCameraAnchorActivity.class.getSimpleName();

    private TXCloudVideoView                mTXCloudVideoView;      // 主播本地预览的 View
    private Button                          mFlashView;             // 闪光灯按钮

    // 观众头像列表控件
    private RecyclerView                    mUserAvatarList;        // 用户头像的列表控件
    private TCUserAvatarListAdapter         mAvatarListAdapter;     // 头像列表的 Adapter

    // 主播信息
    private ImageView                       mHeadIcon;              // 主播头像
    private ImageView                       mRecordBall;            // 表明正在录制的红点球
    private TextView                        mBroadcastTime;         // 已经开播的时间
    private TextView                        mMemberCount;           // 观众数量


    private TCAudioControl                  mAudioCtrl;             // 音效控制面板
    private LinearLayout                    mAudioPluginLayout;

    private TCBeautyControl                 mBeautyControl;          // 美颜设置的控制类

    // log相关
    private boolean                         mShowLog;               // 是否打开 log 面板
    private boolean                         mFlashOn;               // 是否打开闪光灯

    // 连麦主播
    private boolean                         mPendingRequest;        // 主播是否正在处理请求
    private TCVideoViewMgr mPlayerVideoViewList;   // 主播视频列表的View
    private List<AnchorInfo>                mPusherList;            // 当前在麦上的主播

    private ObjectAnimator                  mObjAnim;               // 动画


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_CAMERA_PUSH, TCUserMgr.getInstance().getUserId(), 0, "摄像头推流", null);
        mPusherList = new ArrayList<>();
    }

    @Override
    protected void initView() {
        setContentView(R.layout.activity_camera_anchor);
        super.initView();
        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.anchor_video_view);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);

        mUserAvatarList = (RecyclerView) findViewById(R.id.anchor_rv_avatar);
        mAvatarListAdapter = new TCUserAvatarListAdapter(this, TCUserMgr.getInstance().getUserId());
        mUserAvatarList.setAdapter(mAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mUserAvatarList.setLayoutManager(linearLayoutManager);

        mFlashView = (Button) findViewById(R.id.anchor_btn_flash);

        mBroadcastTime = (TextView) findViewById(R.id.anchor_tv_broadcasting_time);
        mBroadcastTime.setText(String.format(Locale.US, "%s", "00:00:00"));
        mRecordBall = (ImageView) findViewById(R.id.anchor_iv_record_ball);

        mHeadIcon = (ImageView) findViewById(R.id.anchor_iv_head_icon);
        showHeadIcon(mHeadIcon, TCUserMgr.getInstance().getAvatar());
        mMemberCount = (TextView) findViewById(R.id.anchor_tv_member_counts);
        mMemberCount.setText("0");

        //AudioControl
        mAudioCtrl = (TCAudioControl) findViewById(R.id.anchor_audio_control);
        mAudioPluginLayout = (LinearLayout) findViewById(R.id.anchor_ll_audio_plugin);

        mBeautyControl = new TCBeautyControl(mLiveRoom);

        // 监听踢出的回调
        mPlayerVideoViewList = new TCVideoViewMgr(this, new TCVideoView.OnRoomViewListener() {
            @Override
            public void onKickUser(String userID) {
                if (userID != null) {
                    for (AnchorInfo item : mPusherList) {
                        if (userID.equalsIgnoreCase(item.userID)) {
                            onAnchorExit(item);
                            break;
                        }
                    }
                    mLiveRoom.kickoutJoinAnchor(userID);
                }
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


    @Override
    protected void onDestroy() {
        super.onDestroy();

        stopRecordAnimation();

        mPlayerVideoViewList.recycleVideoView();
        mPlayerVideoViewList = null;
        if (mMainHandler != null) {
            mMainHandler.removeCallbacksAndMessages(null);
        }
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      开始和停止推流相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    @Override
    protected void startPublish() {
        mAudioCtrl.setPusher(mLiveRoom);
        mTXCloudVideoView.setVisibility(View.VISIBLE);
        TCBeautyDialogFragment.BeautyParams beautyParams = mBeautyControl.getParams();
        // 打开本地预览，传入预览的 View
        mLiveRoom.startLocalPreview(true, mTXCloudVideoView);
        // 设置美颜参数
        mLiveRoom.setBeautyStyle(beautyParams.mBeautyStyle, beautyParams.mBeautyProgress, beautyParams.mWhiteProgress, beautyParams.mRuddyProgress);
        // 设置瘦脸参数
        mLiveRoom.setFaceSlimLevel(beautyParams.mFaceLiftProgress);
        // 设置大眼参数
        mLiveRoom.setEyeScaleLevel(beautyParams.mBigEyeProgress);
        if (TCUtils.checkRecordPermission(this)) {
            super.startPublish();
        }
    }

    @Override
    protected void stopPublish() {
        super.stopPublish();
        if (mAudioCtrl != null) {
            mAudioCtrl.unInit();
            mAudioCtrl.setPusher(null);
            mAudioCtrl = null;
        }
    }

    @Override
    protected void onCreateRoomSuccess() {
        super.onCreateRoomSuccess();
        startRecordAnimation();
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      MLVB 组件回调
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onAnchorEnter(final AnchorInfo pusherInfo) {
        if (pusherInfo == null || pusherInfo.userID == null) {
            return;
        }

        final TCVideoView videoView = mPlayerVideoViewList.applyVideoView(pusherInfo.userID);
        if (videoView == null) {
            return;
        }

        if (mPusherList != null) {
            boolean exist = false;
            for (AnchorInfo item : mPusherList) {
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
        mPlayerVideoViewList.recycleVideoView(pusherInfo.userID);
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

        mMainHandler.post(new Runnable() {
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

                mMainHandler.postDelayed(new Runnable() {
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
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      音乐控制面板相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

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


    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      界面动画与时长统计
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */
    /**
     * 开启红点与计时动画
     */
    private void startRecordAnimation() {
        mObjAnim = ObjectAnimator.ofFloat(mRecordBall, "alpha", 1f, 0f, 1f);
        mObjAnim.setDuration(1000);
        mObjAnim.setRepeatCount(-1);
        mObjAnim.start();
    }

    /**
     * 关闭红点与计时动画
     */
    private void stopRecordAnimation() {
        if (null != mObjAnim)
            mObjAnim.cancel();
    }

    @Override
    protected void onBroadcasterTimeUpdate(long second) {
        super.onBroadcasterTimeUpdate(second);
        if (!mTCSwipeAnimationController.isMoving())
            mBroadcastTime.setText(TCUtils.formattedTime(second));
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      点击事件与调用函数相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.switch_cam:
                if (mLiveRoom != null) {
                    mLiveRoom.switchCamera();
                }
                break;
            case R.id.anchor_btn_flash:
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
                if (mBeautyControl.isAdded())
                    mBeautyControl.dismiss();
                else
                    mBeautyControl.show(getFragmentManager(), "");
                break;
            case R.id.btn_close:
                showExitInfoDialog("当前正在直播，是否退出直播？", false);
                break;
            case R.id.btn_audio_ctrl:
                if (null != mAudioCtrl) {
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


    private void showLog() {
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

        mPlayerVideoViewList.showLog(mShowLog);
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      成员进退房事件信息处理
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    protected void handleMemberJoinMsg(TCSimpleUserInfo userInfo) {
        //更新头像列表 返回false表明已存在相同用户，将不会更新数据
        if (mAvatarListAdapter.addItem(userInfo))
            super.handleMemberJoinMsg(userInfo);
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentMemberCount));
    }

    @Override
    protected void handleMemberQuitMsg(TCSimpleUserInfo userInfo) {
        mAvatarListAdapter.removeItem(userInfo.userid);
        super.handleMemberQuitMsg(userInfo);
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentMemberCount));
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      权限相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
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
                this.startPublish();
                break;
            default:
                break;
        }
    }

    @Override
    protected void showPublishFinishDetailsDialog() {
        super.showPublishFinishDetailsDialog();
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
}
