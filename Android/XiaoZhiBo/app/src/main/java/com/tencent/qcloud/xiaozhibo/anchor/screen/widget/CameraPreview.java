package com.tencent.qcloud.xiaozhibo.anchor.screen.widget;

import android.content.Context;
import android.hardware.Camera;
import android.util.Log;
import android.view.Display;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.WindowManager;

import java.io.IOException;
import java.util.List;

/**
 * Created by Administrator on 2016/9/13
 * 摄像头 srufaceview
 */
public class CameraPreview extends SurfaceView implements SurfaceHolder.Callback {
    private static final String TAG = CameraPreview.class.getSimpleName();

    private final SurfaceHolder     mHolder;
    private Camera                  mCamera;

    public CameraPreview(Context context) {
        super(context);
        this.mHolder = getHolder();
        this.mHolder.addCallback(this);
    }

    public void setCamera(Camera camera) {
        mCamera = camera;
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        try {
            mCamera.setPreviewDisplay(holder);
            mCamera.startPreview();
        } catch (IOException e) {
            Log.e(TAG, "Error setting camera preview: " + e.getMessage());
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

        if (mHolder.getSurface() == null) {
            return;
        }

        // 在修改设置前停止preview
        try {
            mCamera.stopPreview();
        } catch (Exception e) {
            // Tried to stop a non-existent preview, so ignore.
        }

        Log.d(TAG, "surfaceChanged");

        // camera设置
        try {
            this.setFocusable(true);
            this.setFocusableInTouchMode(true);
            mCamera.setDisplayOrientation(getDisplayOrientation());

            Camera.Parameters params = mCamera.getParameters();
            Camera.Size optimalSize = getOptimalPreviewSize(height);
            params.setPreviewSize(optimalSize.width, optimalSize.height);
            mCamera.setParameters(params);

            mCamera.setPreviewDisplay(mHolder);
            mCamera.startPreview();
        } catch (Exception e) {
            Log.d(TAG, "Error starting camera preview: " + e.getMessage());
        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.d(TAG, "surfaceDestroyed(SurfaceHolder");
    }


    /**
     * 获取当前适合的渲染方向
     * @return degree角度 0 - 360
     */
    public int getDisplayOrientation() {
        Display display = ((WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
        int rotation = display.getRotation();
        int degrees = 0;
        switch (rotation) {
            case Surface.ROTATION_0:
                degrees = 0;
                break;
            case Surface.ROTATION_90:
                degrees = 90;
                break;
            case Surface.ROTATION_180:
                degrees = 180;
                break;
            case Surface.ROTATION_270:
                degrees = 270;
                break;
        }

        Camera.CameraInfo info = new Camera.CameraInfo();
        Camera.getCameraInfo(Camera.CameraInfo.CAMERA_FACING_FRONT, info);

        int result;

        result = (info.orientation - degrees + 180) % 360;
        Log.d("rotationcalc", "info.ori:" + info.orientation + "degrees:" + degrees + " result:" + result);
        return result;
    }

    /**
     * 设定摄像头方向
     */
    public void setCameraOrientation() {
        try {
            mCamera.stopPreview();
        } catch (Exception e) {
            // Tried to stop a non-existent preview, so ignore.
        }

        try {
            this.setFocusable(true);
            this.setFocusableInTouchMode(true);
            //设置
            mCamera.setDisplayOrientation(getDisplayOrientation());

            mCamera.setPreviewDisplay(mHolder);
            mCamera.startPreview();
        } catch (Exception e) {
            Log.d(TAG, "Error starting camera preview: " + e.getMessage());
        }
    }

    /**
     * 获取当前环境下最佳的camera size
     * @param target 目标长宽
     * @return Camera.Size 当前摄像头支持最佳大小
     */
    public Camera.Size getOptimalPreviewSize(int target) {
        if (mCamera == null)
            return null;

        List<Camera.Size> sizes = mCamera.getParameters().getSupportedPreviewSizes();
        Camera.Size optimalSize = null;
        double minDiff = Double.MAX_VALUE;

        for (Camera.Size size : sizes) {
            if (Math.abs(size.height - target) + Math.abs(size.width - target) < minDiff) {
                optimalSize = size;
                minDiff = Math.abs(size.height - target) + Math.abs(size.width - target);
            }
        }
        return optimalSize;
    }

}
