package com.tencent.mlvb.thirdbeauty;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.nama.FURenderer;
import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.Random;

import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeTexture;
import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatTexture2D;

/**
 * TRTC 第三方美颜页面
 *
 * 首先需要调用 {@link V2TXLivePusher#enableCustomVideoProcess(boolean, V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)}  }开启自定义视频处理，才会收到这个回调通知。
 * - 首先在推流之前调用{@link V2TXLivePusher#enableCustomVideoProcess(boolean, V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)},设置开启自定义渲染
 * - 然后掉用{@link V2TXLivePusher#setObserver(V2TXLivePusherObserver)} 监听SDK的视频数据
 * - 当收到数据时，在{@link V2TXLivePusherObserver#onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame, V2TXLiveDef.V2TXLiveVideoFrame)}中适应第三方的美颜组件去处理。
 *
 * 本DemO集成的是相芯的第三方美颜功能
 * 如需调通此功能，需要参考相芯SDK集成文档：{https://www.faceunity.com/developer-center.html} 本Demo已经集成了相芯SDK,
 * 但需注意相芯科技 为Android端 发放的证书为authpack.java 文件， 你需要获取该证书， 使用您的证书替换我们demo中的 {@link com.nama.authpack} 文件即可
 *
 *
 * TRTC Third-Party Beauty Filter View
 *
 * You must call {@link V2TXLivePusher#enableCustomVideoProcess(boolean, V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)} to enable custom video processing before you can receive this callback.
 * - Before stream publishing, call {@link V2TXLivePusher#enableCustomVideoProcess(boolean, V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)} to enable custom rendering.
 * - Call {@link V2TXLivePusher#setObserver(V2TXLivePusherObserver)} to listen for video data from the SDK.
 * - After data is received, use third-party beauty filters to process the data in {@link V2TXLivePusherObserver#onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame, V2TXLiveDef.V2TXLiveVideoFrame)}.
 *
 *
 * This demo integrates the third-party beauty function of faceunity
 * To enable this function, you need to refer to the faceunity SDK integration document:{ https://www.faceunity.com/developer-center.html }This demo has integrated the faceunity SDK,
 * However, it should be noted that the certificate issued by faceunity technology for Android terminal is authpack.java file. You need to obtain the certificate and use your certificate to replace the {@link com.nama.authpack} file in our demo
 */
public class ThirdBeautyActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = "ThirdBeautyActivity";

    private TXCloudVideoView    mPushRenderView;
    private V2TXLivePusher      mLivePusher;
    private SeekBar             mSeekBlurLevel;
    private TextView            mTextBlurLevel;
    private EditText            mEditStreamId;
    private Button              mButtonPush;
    private TextView            mTextTitle;
    private FURenderer          mFURenderer;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.thirdbeauty_activity_third_beauty);
        FURenderer.setup(getApplicationContext());
        mFURenderer = new FURenderer.Builder(getApplicationContext())
                .setCreateEglContext(false)
                .setInputTextureType(0)
                .setCreateFaceBeauty(true)
                .build();
        if (checkPermission()) {
            initView();
        }
    }

    @Override
    protected void onPermissionGranted() {
        initView();
    }


    private void initView() {
        mPushRenderView = findViewById(R.id.pusher_tx_cloud_view);
        mSeekBlurLevel  = findViewById(R.id.sb_blur_level);
        mTextBlurLevel  = findViewById(R.id.tv_blur_level);
        mButtonPush     = findViewById(R.id.btn_push);
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mTextTitle      = findViewById(R.id.tv_title);

        mEditStreamId.setText(generateStreamId());
        findViewById(R.id.iv_back).setOnClickListener(this);

        mSeekBlurLevel.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (mLivePusher != null && mLivePusher.isPushing() == 1 && fromUser) {
                    mFURenderer.getFaceBeautyModule().setBlurLevel(seekBar.getProgress() / 9f);
                }
                mTextBlurLevel.setText(String.valueOf(progress));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        mButtonPush.setOnClickListener(this);
        if(!TextUtils.isEmpty(mEditStreamId.getText().toString())){
            mTextTitle.setText(mEditStreamId.getText().toString());
        }
    }

    private void startPush() {
        String streamId = mEditStreamId.getText().toString();
        if(TextUtils.isEmpty(streamId)){
            Toast.makeText(ThirdBeautyActivity.this, getString(R.string.thirdbeauty_please_input_streamd), Toast.LENGTH_SHORT).show();
            return;
        }
        mTextTitle.setText(streamId);
        String userId = String.valueOf(new Random().nextInt(10000));
        String pushUrl = URLUtils.generatePushUrl(streamId, userId, 0);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

        mLivePusher.enableCustomVideoProcess(true, V2TXLivePixelFormatTexture2D, V2TXLiveBufferTypeTexture);
        mLivePusher.setObserver(new V2TXLivePusherObserver() {
            @Override
            public void onGLContextCreated() {
                mFURenderer.onSurfaceCreated();
            }

            @Override
            public int onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame srcFrame, V2TXLiveDef.V2TXLiveVideoFrame dstFrame) {
                dstFrame.texture.textureId = mFURenderer.onDrawFrameSingleInput(srcFrame.texture.textureId, srcFrame.width, srcFrame.height);
                return 0;
            }

            @Override
            public void onGLContextDestroyed() {
                mFURenderer.onSurfaceDestroyed();
            }
        });
        mLivePusher.setRenderView(mPushRenderView);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
        mButtonPush.setText(R.string.thirdbeauty_stop_push);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(mLivePusher != null){
            mLivePusher.stopCamera();
            mLivePusher.stopMicrophone();
            if(mLivePusher.isPushing() == 1){
                mLivePusher.stopPush();
            }
            mLivePusher = null;
        }
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
        if(mLivePusher != null){
            mLivePusher.stopCamera();
            mLivePusher.stopMicrophone();
            if(mLivePusher.isPushing() == 1){
                mLivePusher.stopPush();
            }
            mLivePusher = null;
        }
        mButtonPush.setText(R.string.thirdbeauty_start_push);
    }
}
