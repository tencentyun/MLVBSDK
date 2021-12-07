package com.tencent.mlvb.livepushscreen;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;

import java.util.Random;

import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_OK;

/**
 * MLVB 录屏推流详情页
 *
 * 包含如下简单功能：
 * - 开始屏幕分享{@link LivePushScreenActivity#startScreenPush()}
 * - 停止屏幕分享{@link LivePushScreenActivity#stopScreenPush()} (boolean)}】
 *
 * 详见接入文档{https://cloud.tencent.com/document/product/454/56595}
 *
 *
 * Publishing (Screen) View
 *
 * Features:
 * - Start screen sharing {@link LivePushScreenActivity#startScreenPush()}
 * - Stop screen sharing {@link LivePushScreenActivity#stopScreenPush()} (boolean)}
 *
 * For more information, please see the integration document {https://cloud.tencent.com/document/product/454/56595}.
 */
public class LivePushScreenActivity extends MLVBBaseActivity implements View.OnClickListener {

    private static final String TAG = "LivePushScreenActivity";
    private V2TXLivePusher   mLivePusher;
    private TextView         mTextTitle;
    private Button           mButtonPush;

    private String              mStreamId;
    private int                 mStreamType = 0;
    private boolean             mPushFlag   = false;

    private V2TXLiveDef.V2TXLiveAudioQuality    mAudioQuality   = V2TXLiveDef.V2TXLiveAudioQuality.V2TXLiveAudioQualityDefault;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livepushscreen_activity_push_screen);
        if (checkPermission()) {
            initIntentData();
            initView();
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
    }

    private void initView() {
        mTextTitle  = findViewById(R.id.tv_stream_id);
        mButtonPush = findViewById(R.id.btn_push);

        mButtonPush.setOnClickListener(this);
        findViewById(R.id.iv_back).setOnClickListener(this);

        if (!TextUtils.isEmpty(mStreamId)) {
            mTextTitle.setText(mStreamId);
        }
    }

    private void startScreenPush() {
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
        mLivePusher.startScreenCapture();
        int ret = mLivePusher.startPush(pushUrl);
        if(ret == V2TXLIVE_OK){
            mLivePusher.startMicrophone();
            mPushFlag = true;
            mButtonPush.setText(R.string.livepushscreen_close_screen_push);
        }
        Log.i(TAG, "startPush return: " + ret);
    }

    private void stopScreenPush() {
        if(mPushFlag && mLivePusher != null){
            mLivePusher.stopMicrophone();
            mLivePusher.stopScreenCapture();
            mLivePusher = null;
        }
        mButtonPush.setText(R.string.livepushscreen_start_screen_push);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopScreenPush();
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
        }else if(id == R.id.btn_push){
            if(mPushFlag){
                stopScreenPush();
                mPushFlag = false;
            }else{
                startScreenPush();
            }
        }
    }
}
