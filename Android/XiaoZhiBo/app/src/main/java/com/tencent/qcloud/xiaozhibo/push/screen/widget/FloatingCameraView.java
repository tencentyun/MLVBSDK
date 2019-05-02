package com.tencent.qcloud.xiaozhibo.push.screen.widget;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Camera;
import android.util.Log;
import android.view.ViewGroup;
import android.view.WindowManager;

import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.rtmp.TXLog;

/**
 * Created by Administrator on 2016/9/13
 * 摄像头悬浮窗
 */
public class FloatingCameraView extends BaseFloatingView {
    private static final String TAG = FloatingCameraView.class.getSimpleName();

    // camera 在每次显示时创建，关闭时销毁
    private Camera mCamera;
    // camera preview
    private CameraPreview mPreview;
    // 当前屏幕方向缓存
    private int mOrientation;
    ScreenBroadcastReceiver mReceiver;
    public FloatingCameraView(Context context) {
        super(context);
        mReceiver = new ScreenBroadcastReceiver();
        if (context != null) {
            IntentFilter filter = new IntentFilter();
            filter.addAction(Intent.ACTION_SCREEN_OFF);
            filter.addAction(Intent.ACTION_SCREEN_ON);
            context.registerReceiver(mReceiver, filter);
    }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);

        //检测旋屏事件,若存在旋屏则更新surface角度
        if (mWindowManager != null)
            if (mOrientation != mWindowManager.getDefaultDisplay().getRotation()) {
                mOrientation = mWindowManager.getDefaultDisplay().getRotation();
                Log.d("boom!", "onlayout orientationchanged");
                ViewGroup.LayoutParams lp = mPreview.getLayoutParams();
                Camera.Size size = mPreview.getOptimalPreviewSize(TCUtils.dp2pxConvertInt(mContext, 120));
                //在某些角度摄像头翻转方向后长宽比相反
                if(mOrientation == 0 || mOrientation == 2) {
                    lp.width = size.height;
                    lp.height = size.width;
                } else {
                    lp.width = size.width;
                    lp.height = size.height;
                }

                updateViewLayout(mPreview, lp);
                mPreview.setCameraOrientation();
            }
    }

    private Camera getFacingFrontCamera() {
        try {
            Camera.CameraInfo cameraInfo = new Camera.CameraInfo();

            for (int i = 0; i < Camera.getNumberOfCameras(); i++) {
                Camera.getCameraInfo(i, cameraInfo);// 得到每一个摄像头的信息
                //取前置
                if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                    return Camera.open(i);
                }
            }

        } catch (RuntimeException e) {
            e.printStackTrace();
            //Toast.makeText(mContext, "获取摄像头服务失败", Toast.LENGTH_SHORT).show();
            TXLog.e(TAG, e.getMessage());
        }
        return null;

    }

    public void release() {
        if (null != mCamera)
            mCamera.release();
        try {
            mContext.unregisterReceiver(mReceiver);
        } catch (Exception e) {

    }
    }

    /**
     * 显示摄像头悬浮窗
     */
    public boolean show() {

        //每次显示时都
        mCamera = getFacingFrontCamera();

        //不存在前置摄像头
        if (null == mCamera)
            return false;

        if (null == mPreview) {
            //第一次创建
            mPreview = new CameraPreview(mContext);

            mPreview.setCamera(mCamera);

            WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
            //获取最近似于120dp*120dp的摄像头preview
            Camera.Size size = mPreview.getOptimalPreviewSize(TCUtils.dp2pxConvertInt(mContext, 120));

            if (null == size)
                return false;

            //摄像头翻转方向后长宽比相反
            lp.width = size.height;
            lp.height = size.width;

            addView(mPreview, lp);
        } else {
            //preview 已执行addview，注入camera对象即可
            mPreview.setCamera(mCamera);
        }
        super.showView(this);
        return true;
    }

    /**
     * 隐藏摄像头悬浮窗
     */
    public void dismiss() {
        super.hideView();
        //回收camera对象
        if (null != mCamera)
            mCamera.release();
        mCamera = null;
    }

    private class ScreenBroadcastReceiver extends BroadcastReceiver {
        private boolean mHidden = false;
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null) {
                String action = intent.getAction();
                if (Intent.ACTION_SCREEN_ON.equals(action)) {
                    if (mHidden) {
                        show();
                        mHidden = false;
}
                } else if (Intent.ACTION_SCREEN_OFF.equals(action)) {
                    if (isShown()) {
                        dismiss();
                        mHidden = true;
                    }
                }
            }
        }
    }

}
