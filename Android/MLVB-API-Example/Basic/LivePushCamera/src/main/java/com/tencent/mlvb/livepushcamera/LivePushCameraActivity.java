package com.tencent.mlvb.livepushcamera;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.PopupMenu;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.Random;

/**
 * MLVB 摄像头推流详情页
 *
 * 包含如下简单功能：
 * - 开始推流{@link LivePushCameraActivity#startPush()} ()}
 * - 麦克风{@link LivePushCameraActivity#enableMic(boolean)}
 * - 设置分辨率{@link LivePushCameraActivity#showResolutionMenu()}
 * - 设置旋转角度{@link LivePushCameraActivity#showRotateMenu()}
 * - 设置镜像{@link LivePushCameraActivity#showMirrorMenu()}
 *
 * 详见接入文档{https://cloud.tencent.com/document/product/454/56592}
 *
 *
 *
 * Publishing (Camera) View
 *
 * Features:
 * - Start publishing {@link LivePushCameraActivity#startPush()}
 * - Turn on mic {@link LivePushCameraActivity#enableMic(boolean)}
 * - Set resolution {@link LivePushCameraActivity#showResolutionMenu()}
 * - Set rotation {@link LivePushCameraActivity#showRotateMenu()}
 * - Set mirror mode {@link LivePushCameraActivity#showMirrorMenu()}
 *
 * For more information, please see the integration document {https://intl.cloud.tencent.com/document/product/1071/38158}.
 */
public class LivePushCameraActivity extends MLVBBaseActivity implements View.OnClickListener {

    private static final String TAG = "LivePushCameraActivity";

    private TXCloudVideoView    mPushRenderView;
    private V2TXLivePusher      mLivePusher;
    private TextView            mTextTitle;
    private LinearLayout        mLinearResolution;
    private TextView            mTextResolution;
    private LinearLayout        mLinearRotate;
    private TextView            mTextRotate;
    private LinearLayout        mLinearMirror;
    private TextView            mTextMirror;
    private Button              mButtonMic;

    private String              mStreamId;
    private int                 mStreamType     = 0;
    private boolean             mMicFlag        = true;

    private V2TXLiveDef.V2TXLiveAudioQuality    mAudioQuality   = V2TXLiveDef.V2TXLiveAudioQuality.V2TXLiveAudioQualityDefault;
    private V2TXLiveDef.V2TXLiveRotation        mRotationFlag   = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0;
    private V2TXLiveDef.V2TXLiveMirrorType      mMirrorFlag     = V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeAuto;
    private V2TXLiveDef.V2TXLiveVideoResolution mResolutionFlag = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution960x540;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livepushcamera_activity_push_camera);
        if (checkPermission()) {
            initIntentData();
            initView();
            startPush();
        }
    }

    private void initIntentData() {
        mStreamId       = getIntent().getStringExtra("STREAM_ID");
        mStreamType     = getIntent().getIntExtra("STREAM_TYPE", 0);
        mAudioQuality   = (V2TXLiveDef.V2TXLiveAudioQuality)getIntent().getSerializableExtra("AUDIO_QUALITY");

        Log.d(TAG, "initIntentData: " + mStreamId + " : " + mStreamType + " : " + mAudioQuality);
    }

    @Override
    protected void onPermissionGranted() {
        initIntentData();
        initView();
        startPush();
    }

    private void initView() {
        mPushRenderView     = findViewById(R.id.pusher_tx_cloud_view);
        mTextTitle          = findViewById(R.id.tv_stream_id);
        mLinearResolution   = findViewById(R.id.ll_resolution);
        mTextResolution     = findViewById(R.id.tv_resolution);
        mLinearRotate       = findViewById(R.id.ll_rotate);
        mTextRotate         = findViewById(R.id.tv_rotate);
        mLinearMirror       = findViewById(R.id.ll_mirror);
        mTextMirror         = findViewById(R.id.tv_mirror);
        mButtonMic          = findViewById(R.id.btn_mic);

        findViewById(R.id.iv_back).setOnClickListener(this);
        findViewById(R.id.btn_mic).setOnClickListener(this);
        findViewById(R.id.ll_resolution).setOnClickListener(this);
        findViewById(R.id.ll_rotate).setOnClickListener(this);
        findViewById(R.id.ll_mirror).setOnClickListener(this);

        if (!TextUtils.isEmpty(mStreamId)) {
            mTextTitle.setText(mStreamId);
        }
    }

    private void startPush() {
        String pushUrl = "";
        if(mStreamType == 0){
            String userId = String.valueOf(new Random().nextInt(10000));
            pushUrl = URLUtils.generatePushUrl(mStreamId, userId, 0);
            mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);
        }else{
            pushUrl = URLUtils.generatePushUrl(mStreamId, "", 1);
            mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTMP);
        }
        Log.d(TAG, "pushUrl: " + pushUrl);
        mLivePusher.setAudioQuality(mAudioQuality);
        mLivePusher.setRenderView(mPushRenderView);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        mLivePusher.startMicrophone();
        Log.i(TAG, "startPush return: " + ret);

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(mLivePusher != null){
            mLivePusher.stopCamera();
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
        if(id == R.id.iv_back){
            finish();
        }else if(id == R.id.btn_mic){
            mMicFlag = !mMicFlag;
            enableMic(mMicFlag);
        }else if(id == R.id.ll_resolution){
            showResolutionMenu();
        }else if(id == R.id.ll_rotate){
            showRotateMenu();
        }else if(id == R.id.ll_mirror){
            showMirrorMenu();
        }
    }

    private void showResolutionMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLinearResolution, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.livepushcamera_resolution, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(mLivePusher != null && mLivePusher.isPushing() == 1){
                   if(item.getItemId() == R.id.resolution_360){
                        mResolutionFlag = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x360;
                        mTextResolution.setText("360P");
                    }else if(item.getItemId() == R.id.resolution_540){
                        mResolutionFlag = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution960x540;
                        mTextResolution.setText("540P");
                    }else if(item.getItemId() == R.id.resolution_720){
                        mResolutionFlag = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution1280x720;
                        mTextResolution.setText("720P");
                    }else if(item.getItemId() == R.id.resolution_1080){
                        mResolutionFlag = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution1920x1080;
                        mTextResolution.setText("1080P");
                    }
                    V2TXLiveDef.V2TXLiveVideoEncoderParam param = new V2TXLiveDef.V2TXLiveVideoEncoderParam(mResolutionFlag);
                    param.videoResolutionMode =  V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait;
                    mLivePusher.setVideoQuality(param);
                }else{
                    Toast.makeText(LivePushCameraActivity.this, getString(R.string.livepushcamera_please_ensure_pushing), Toast.LENGTH_SHORT).show();
                }
                return false;
            }
        });
        popupMenu.show();
    }

    private void showMirrorMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLinearMirror, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.livepushcamera_mirror, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(mLivePusher != null && mLivePusher.isPushing() == 1){
                    if(item.getItemId() == R.id.mirror_auto){
                        mMirrorFlag = V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeAuto;
                        mTextMirror.setText(R.string.livepushcamera_front_camera_open);
                    }else if(item.getItemId() == R.id.mirror_enable){
                        mMirrorFlag = V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeEnable;
                        mTextMirror.setText(R.string.livepushcamera_camera_all_open);
                    }else if(item.getItemId() == R.id.mirror_disable){
                        mMirrorFlag = V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeDisable;
                        mTextMirror.setText(R.string.livepushcamera_camera_all_close);
                    }
                    mLivePusher.setRenderMirror(mMirrorFlag);
                }else{
                    Toast.makeText(LivePushCameraActivity.this, getString(R.string.livepushcamera_please_ensure_pushing), Toast.LENGTH_SHORT).show();
                }
                return false;
            }
        });
        popupMenu.show();
    }

    private void showRotateMenu() {
        PopupMenu popupMenu = new PopupMenu(this, mLinearRotate, Gravity.TOP);
        popupMenu.getMenuInflater().inflate(R.menu.livepushcamera_rotate, popupMenu.getMenu());
        popupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                if(mLivePusher != null && mLivePusher.isPushing() == 1){
                    if(item.getItemId() == R.id.rotate_0){
                        mRotationFlag = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0;
                        mTextRotate.setText("0");
                    }else if(item.getItemId() == R.id.rotate_90){
                        mRotationFlag = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation90;
                        mTextRotate.setText("90");
                    }else if(item.getItemId() == R.id.rotate_180){
                        mRotationFlag = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation180;
                        mTextRotate.setText("180");
                    }else if(item.getItemId() == R.id.rotate_270){
                        mRotationFlag = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation270;
                        mTextRotate.setText("270");
                    }
                    mLivePusher.setRenderRotation(mRotationFlag);
                }else{
                    Toast.makeText(LivePushCameraActivity.this, getString(R.string.livepushcamera_please_ensure_pushing), Toast.LENGTH_SHORT).show();
                }
                return false;
            }
        });
        popupMenu.show();
    }

    private void enableMic(boolean mMicFlag) {
        if(mLivePusher != null && mLivePusher.isPushing() == 1){
            if(mMicFlag){
                mLivePusher.startMicrophone();
                mButtonMic.setText(R.string.livepushcamera_close_mic);
            }else{
                mLivePusher.stopMicrophone();
                mButtonMic.setText(R.string.livepushcamera_open_mic);
            }
        }else{
            Toast.makeText(LivePushCameraActivity.this, getString(R.string.livepushcamera_please_ensure_pushing), Toast.LENGTH_SHORT).show();
        }
    }
}
