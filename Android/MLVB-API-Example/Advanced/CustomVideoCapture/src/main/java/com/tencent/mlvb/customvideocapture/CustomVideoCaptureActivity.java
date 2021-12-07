package com.tencent.mlvb.customvideocapture;

import android.annotation.SuppressLint;
import android.opengl.EGLContext;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.customvideocapture.helper.CustomCameraCapture;
import com.tencent.mlvb.customvideocapture.helper.CustomFrameRender;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.Random;

import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeTexture;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatTexture2D;

/**
 * MLVB 自定义视频采集&渲染的示例
 *
 * 本文件展示了如何实现自定义采集&渲染功能，主要流程如下：
 *
 * 自定义采集：
 * - 首先在推流之前调用{@link V2TXLivePusher#enableCustomVideoCapture(boolean)},设置开启自定义采集
 * - 然后掉用{@link V2TXLivePusher#sendCustomVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame)} 发送数据给SDK
 *
 * 自定义渲染
 * - 首先在推流之前调用{@link V2TXLivePusher#enableCustomVideoProcess(boolean, V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)},设置开启自定义渲染
 * - 然后掉用{@link V2TXLivePusher#setObserver(V2TXLivePusherObserver)} 监听SDK的视频数据
 * - 当收到数据时，在{@link V2TXLivePusherObserver#onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame, V2TXLiveDef.V2TXLiveVideoFrame)}中处理渲染逻辑
 *
 * - 更多细节，详见API说明文档{https://cloud.tencent.com/document/product/454/56601}
 *
 *
 * Example for Custom Video Capturing & Rendering
 *
 * This document shows how to enable custom video capturing and rendering.
 *
 * Custom capturing:
 * - Before stream publishing, call {@link V2TXLivePusher#enableCustomVideoCapture(boolean)} to enable custom capturing.
 * - Call {@link V2TXLivePusher#sendCustomVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame)} to send data to the SDK.
 *
 * Custom rendering
 * - Before stream publishing, call {@link V2TXLivePusher#enableCustomVideoProcess(boolean, V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)} to enable custom rendering.
 * - Call {@link V2TXLivePusher#setObserver(V2TXLivePusherObserver)} to listen for video data from the SDK.
 * - After data is received, execute the rendering logic in {@link V2TXLivePusherObserver#onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame, V2TXLiveDef.V2TXLiveVideoFrame)}.
 *
 * - For more information, please see the API document {https://cloud.tencent.com/document/product/454/56601}.
 */
public class CustomVideoCaptureActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = CustomVideoCaptureActivity.class.getSimpleName();

    private V2TXLivePusher      mLivePusher;
    private EditText            mEditStreamId;
    private Button              mButtonPush;
    private CustomCameraCapture mCustomCameraCapture;
    private CustomFrameRender   mCustomFrameRender;
    private TXCloudVideoView    mPushRenderView;
    private TextView            mTextTitle;

    private CustomCameraCapture.VideoFrameReadListener mVideoFrameReadListener = new CustomCameraCapture.VideoFrameReadListener() {
        @SuppressLint("NewApi")
        @Override
        public void onFrameAvailable(EGLContext eglContext, int textureId, int width, int height) {
            V2TXLiveDef.V2TXLiveVideoFrame videoFrame = new V2TXLiveDef.V2TXLiveVideoFrame();
            videoFrame.pixelFormat = V2TXLivePixelFormatTexture2D;
            videoFrame.bufferType = V2TXLiveBufferTypeTexture;
            videoFrame.texture = new V2TXLiveDef.V2TXLiveTexture();
            videoFrame.texture.textureId = textureId;
            videoFrame.texture.eglContext14 = eglContext;
            videoFrame.width = width;
            videoFrame.height = height;

            if(mLivePusher != null && mLivePusher.isPushing() == 1){
                int ret = mLivePusher.sendCustomVideoFrame(videoFrame);
                Log.d(TAG, "sendCustomVideoFrame : " + ret);
            }
        }
    };


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.customvideocaptureactivity_activity_custom_video_capture);
        if (checkPermission()) {
            initView();
        }
    }

    @Override
    protected void onPermissionGranted() {
        initView();
    }


    private void initView() {
        mPushRenderView = findViewById(R.id.tx_cloud_view);
        mButtonPush     = findViewById(R.id.btn_push);
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mTextTitle      = findViewById(R.id.tv_title);

        mEditStreamId.setText(generateStreamId());
        findViewById(R.id.iv_back).setOnClickListener(this);
        mButtonPush.setOnClickListener(this);

        if(!TextUtils.isEmpty(mEditStreamId.getText().toString())){
            mTextTitle.setText(mEditStreamId.getText().toString());
        }
    }

    private void startPush() {
        String streamId = mEditStreamId.getText().toString();
        if(TextUtils.isEmpty(streamId)){
            Toast.makeText(CustomVideoCaptureActivity.this, getString(R.string.customvideocapture_please_input_streamid), Toast.LENGTH_SHORT).show();
            return;
        }
        mTextTitle.setText(streamId);
        String userId = String.valueOf(new Random().nextInt(10000));
        String pushUrl = URLUtils.generatePushUrl(streamId, userId, 0);

        mCustomCameraCapture = new CustomCameraCapture();
        mCustomFrameRender   = new CustomFrameRender();

        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);
        mLivePusher.setObserver(mCustomFrameRender);
        mLivePusher.enableCustomVideoCapture(true);

        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();

        if(ret == 0){
            mCustomCameraCapture.start(mVideoFrameReadListener);

            mLivePusher.enableCustomVideoProcess(true, V2TXLivePixelFormatTexture2D, V2TXLiveBufferTypeTexture);
            final TextureView textureView = new TextureView(this);
            mPushRenderView.addVideoView(textureView);
            mCustomFrameRender.start(textureView);
            mButtonPush.setText(R.string.customvideocapture_stop_push);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopPush();
    }

    @Override
    public void onBackPressed() {
        finish();
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if(id == R.id.btn_push){
            push();
        }else if(id == R.id.iv_back){
            finish();
        }
    }

    private void push() {
        if(mLivePusher != null && mLivePusher.isPushing() == 1){
            stopPush();
        }else{
            startPush();
        }
    }

    private void stopPush() {
        if (mCustomCameraCapture != null) {
            mCustomCameraCapture.stop();
        }
        if (mCustomFrameRender != null) {
            mCustomFrameRender.stop();
        }
        if(mLivePusher != null){
            mLivePusher.stopMicrophone();
            if(mLivePusher.isPushing() == 1){
                mLivePusher.stopPush();
            }
            mLivePusher = null;
        }
        mButtonPush.setText(R.string.customvideocapture_start_push);
    }
}
