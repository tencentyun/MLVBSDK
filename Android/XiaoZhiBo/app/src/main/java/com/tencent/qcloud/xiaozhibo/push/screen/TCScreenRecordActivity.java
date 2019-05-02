package com.tencent.qcloud.xiaozhibo.push.screen;

import android.annotation.TargetApi;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.push.TCLiveBasePublisherActivity;
import com.tencent.qcloud.xiaozhibo.push.screen.widget.FloatingCameraView;
import com.tencent.qcloud.xiaozhibo.push.screen.widget.FloatingView;
import com.umeng.socialize.UMShareAPI;

/**
 * 屏幕录制Activity
 * 注：Android在API21+的版本才支持屏幕录制功能
 */
@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class TCScreenRecordActivity extends TCLiveBasePublisherActivity {

    private static final String TAG = TCScreenRecordActivity.class.getSimpleName();

    //悬浮摄像窗以及悬浮球
    private FloatingView mFloatingView;
    private FloatingCameraView mFloatingCameraView;
    private ImageView mPrivateBtn;
    private ImageView mCameraBtn;

    //隐私模式drawable(支持自定义大小)
    private TextView mTVPrivateMode;
    private Drawable mDrawableLockOn;
    private Drawable mDrawableLockOff;

    private boolean mInPrivacy = false;
    private boolean mInCamera = false;

    private Intent serviceIntent;

    public static int OVERLAY_PERMISSION_REQ_CODE = 1234;

    /**
     * APP统计录屏推流，您可以忽略
     */
    private long mStartPushPts;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //启动后台拉活进程（处理强制下线消息）
        serviceIntent = new Intent();
        serviceIntent.setClassName(this, TCScreenRecordService.class.getName());

        startService(serviceIntent);
        //bindService(intentService, mServiceConn, BIND_AUTO_CREATE);

        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_SCREEN_PUSH, TCUserMgr.getInstance().getUserId(), 0, "录屏推流", null);
        mStartPushPts = System.currentTimeMillis();
    }

    protected void initView() {

        setContentView(R.layout.activity_screen_record);

        super.initView();

        //悬浮球界面
        mFloatingView = new FloatingView(getApplicationContext(), R.layout.view_floating_default);
        mFloatingView.setPopupWindow(R.layout.popup_layout);
        mFloatingCameraView = new FloatingCameraView(getApplicationContext());

        mPrivateBtn = (ImageView) mFloatingView.getPopupView().findViewById(R.id.btn_privacy);
        mCameraBtn = (ImageView) mFloatingView.getPopupView().findViewById(R.id.btn_camera);

        mFloatingView.setOnPopupItemClickListener(this);

        mDrawableLockOn = getResources().getDrawable(R.mipmap.lock_off);
        if (null != mDrawableLockOn) mDrawableLockOn .setBounds(0, 0, 40, 40);

        mDrawableLockOff = getResources().getDrawable(R.mipmap.lock_on);
        if (null != mDrawableLockOff) mDrawableLockOff.setBounds(0, 0, 40, 40);

        mTVPrivateMode = (TextView) findViewById(R.id.tv_private_mode);
        if (null != mTVPrivateMode)  mTVPrivateMode.setCompoundDrawables(mDrawableLockOff ,null, null, null);
    }

    protected void startPublishImpl() {
        mLiveRoom.setListener(this);
        mLiveRoom.setCameraMuteImage(BitmapFactory.decodeResource(getResources(), R.mipmap.recording_background_private_vertical));
        mLiveRoom.startScreenCapture();
        super.startPublishImpl();
    }

    @Override
    protected void onResume() {
        super.onResume();
        //关闭悬浮球与相机
//        if (mScrOrientation == TCConstants.ORIENTATION_LANDSCAPE) {
//            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
//            mRootRelativeLayout.setBackground(getDrawable(R.mipmap.recording_background_horizontal));
//        }

        if (mFloatingView.isShown()) {
            mFloatingView.dismiss();
        }
        if (null != mFloatingCameraView && mFloatingCameraView.isShown()) {
            mFloatingCameraView.dismiss();
            mCameraBtn.setImageResource(R.mipmap.camera_off);
            mInCamera = false;
        }

    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    public void requestDrawOverLays() {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(TCScreenRecordActivity.this)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + TCScreenRecordActivity.this.getPackageName()));
            startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
        } else {
            showFloatingView();
        }
    }

    private void showFloatingView() {
        if (!mFloatingView.isShown()) {
            if ((null != mLiveRoom)) {
//                if (mLiveRoom.isPushing()) {
                    mFloatingView.show();
                    mFloatingView.setOnPopupItemClickListener(this);
//                    mTXLivePusher.resumePusher();
//                }
            }
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        requestDrawOverLays();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mFloatingView.isShown()) {
            mFloatingView.dismiss();
        }

        if (null != mFloatingCameraView) {
            if (mFloatingCameraView.isShown()) {
                mFloatingCameraView.dismiss();
            }
            mFloatingCameraView.release();
        }

        //unbindService(mServiceConn);
        stopService(serviceIntent);

        stopPublish();

        long endPushPts = System.currentTimeMillis();
        long diff = (endPushPts - mStartPushPts) / 1000;
        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_SCREEN_PUSH_DURATION, TCUserMgr.getInstance().getUserId(), diff, "录屏推流时长", null);
    }

    @Override
    public void onBackPressed() {
        showComfirmDialog(TCConstants.TIPS_MSG_STOP_PUSH, false);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_return:
                //悬浮球返回主界面按钮
                Toast.makeText(getApplicationContext(), "返回主界面", Toast.LENGTH_SHORT).show();
                Intent intent = new Intent(getApplicationContext(), TCScreenRecordActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(intent);
                break;
            case R.id.tv_private_mode:
            case R.id.btn_privacy:
                //隐私模式
//                triggerPrivateMode();
                break;
            case R.id.btn_camera:
                //camera悬浮窗
                triggerFloatingCameraView();
                break;
            default:
                super.onClick(v);
                break;
        }
    }

//    /**
//     * 隐私模式切换
//     */
//    public void triggerPrivateMode() {
//        if (mInPrivacy) {
//            Toast.makeText(getApplicationContext(), getString(R.string.private_mode_off), Toast.LENGTH_SHORT).show();
//            mTVPrivateMode.setText(getString(R.string.private_mode_off));
//            mTVPrivateMode.setCompoundDrawables(mDrawableLockOn,null,null,null);
//            mPrivateBtn.setImageResource(R.mipmap.lock_off);
//            mLiveRoom.switchToForeground();
//        } else {
//            Toast.makeText(getApplicationContext(), getString(R.string.private_mode_on), Toast.LENGTH_SHORT).show();
//            mLiveRoom.switchToBackground();
//            mPrivateBtn.setImageResource(R.mipmap.lock_on);
//            mTVPrivateMode.setText(getString(R.string.private_mode_on));
//            mTVPrivateMode.setCompoundDrawables(mDrawableLockOff,null,null,null);
//        }
//        mInPrivacy = !mInPrivacy;
//    }

    /**
     * 处理cameraview初始化、权限申请 以及 cameraview的显示与隐藏
     */
    public void triggerFloatingCameraView() {
        //trigger
        if (mInCamera) {
            Toast.makeText(getApplicationContext(), "关闭摄像头", Toast.LENGTH_SHORT).show();
            mCameraBtn.setImageResource(R.mipmap.camera_off);
            mFloatingCameraView.dismiss();
        } else {
            //show失败显示错误信息
            if (!mFloatingCameraView.show()) {
                Toast.makeText(getApplicationContext(), "打开摄像头权限失败,请在系统设置打开摄像头权限", Toast.LENGTH_SHORT).show();
                return;
            }
            Toast.makeText(getApplicationContext(), "打开摄像头", Toast.LENGTH_SHORT).show();
            mCameraBtn.setImageResource(R.mipmap.camera_on);
        }
        mInCamera = !mInCamera;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == OVERLAY_PERMISSION_REQ_CODE) {
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(TCScreenRecordActivity.this)) {
                Toast.makeText(getApplicationContext(), "请在设置-权限设置里打开悬浮窗权限", Toast.LENGTH_SHORT).show();
            } else {
                showFloatingView();
            }
        } else {
            /** attention to this below ,must add this**/
            UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);
            com.umeng.socialize.utils.Log.d("result", "onActivityResult");
        }
    }
}
