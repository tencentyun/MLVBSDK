package com.tencent.qcloud.xiaozhibo.anchor.screen;

import android.annotation.TargetApi;
import android.app.PendingIntent;
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
import com.tencent.qcloud.xiaozhibo.anchor.TCBaseAnchorActivity;
import com.tencent.qcloud.xiaozhibo.anchor.screen.widget.FloatingCameraView;
import com.tencent.qcloud.xiaozhibo.anchor.screen.widget.FloatingView;
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;

/**
 * Module:   TCScreenAnchorActivity
 * <p>
 * Function: 屏幕录制推流的页面
 * <p>
 *
 * 注：Android 在 API 21+ 的版本才支持屏幕录制功能
 */
@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class TCScreenAnchorActivity extends TCBaseAnchorActivity {
    private static final String TAG = TCScreenAnchorActivity.class.getSimpleName();
    public static int OVERLAY_PERMISSION_REQ_CODE = 1234;

    //悬浮摄像窗以及悬浮球
    private FloatingView            mFloatingView;              // 悬浮球
    private FloatingCameraView      mFloatingCameraView;        // 悬浮摄像框
    private ImageView               mCameraBtn;                 // 开启-关闭摄像头按钮
    private boolean                 mInCamera = false;          // 摄像头是否打开
    private Intent                  serviceIntent;              // 后台服务

    private long                    mStartPushPts;              // APP统计录屏推流，您可以忽略

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //启动后台拉活进程（处理强制下线消息）
        serviceIntent = new Intent();
        serviceIntent.setClassName(this, TCScreenRecordService.class.getName());

        startService(serviceIntent);

        TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_SCREEN_PUSH, TCUserMgr.getInstance().getUserId(), 0, "录屏推流", null);

        mStartPushPts = System.currentTimeMillis();
    }

    protected void initView() {

        setContentView(R.layout.activity_screen_anchor);

        super.initView();

        //悬浮球界面
        mFloatingView = new FloatingView(getApplicationContext(), R.layout.view_floating_default);
        mFloatingView.setPopupWindow(R.layout.popup_layout);
        mFloatingCameraView = new FloatingCameraView(getApplicationContext());

        mCameraBtn = (ImageView) mFloatingView.getPopupView().findViewById(R.id.btn_camera);

        mFloatingView.setOnPopupItemClickListener(this);
    }

    @Override
    protected void onResume() {
        super.onResume();

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
        TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_SCREEN_PUSH_DURATION, TCUserMgr.getInstance().getUserId(), diff, "录屏推流时长", null);
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      推流相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    protected void startPublish() {
        mLiveRoom.setListener(this);
        mLiveRoom.setCameraMuteImage(BitmapFactory.decodeResource(getResources(), R.mipmap.recording_background_private_vertical));
        mLiveRoom.startScreenCapture();
        super.startPublish();
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      浮窗相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    public void requestDrawOverLays() {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(TCScreenAnchorActivity.this)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + TCScreenAnchorActivity.this.getPackageName()));
            startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
        } else {
            showFloatingView();
        }
    }

    private void showFloatingView() {
        if (!mFloatingView.isShown()) {
            if ((null != mLiveRoom)) {
                mFloatingView.show();
                mFloatingView.setOnPopupItemClickListener(this);
            }
        }
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
            case R.id.btn_return:
                //悬浮球返回主界面按钮
                Toast.makeText(getApplicationContext(), "返回主界面", Toast.LENGTH_SHORT).show();
                Intent intent = new Intent(getApplicationContext(), TCScreenAnchorActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//                getApplicationContext().startActivity(intent);
                try {
                    PendingIntent pendingIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent, 0);
                    pendingIntent.send();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case R.id.btn_camera:
                //camera悬浮窗
                triggerFloatingCameraView();
                break;
            case R.id.btn_close:
                showExitInfoDialog("当前正在直播，是否退出直播？", false);
                break;
            default:
                super.onClick(v);
                break;
        }
    }


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
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N && !Settings.canDrawOverlays(TCScreenAnchorActivity.this)) {
                Toast.makeText(getApplicationContext(), "请在设置-权限设置里打开悬浮窗权限", Toast.LENGTH_SHORT).show();
            } else {
                showFloatingView();
            }
        }
    }
}
