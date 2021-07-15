package com.tencent.mlvb.livelink;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePlayer;
import com.tencent.live2.V2TXLivePlayerObserver;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.debug.AddressUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.Random;

/**
 * MLVB 连麦互动的观众视角
 *
 * 包含如下简单功能：
 * - 播放音视频流{@link LiveLinkAudienceActivity#startPlay()} ()}
 * - 开始连麦{@link LiveLinkAudienceActivity#startLink()}
 * - 停止连麦{@link LiveLinkAudienceActivity#stopLink()} ()}
 *
 * - 详见接入文档{https://cloud.tencent.com/document/product/454/52751}
 *
 *
 * Co-anchoring View for Audience
 *
 * Features:
 * - Play audio/video streams {@link LiveLinkAudienceActivity#startPlay()}
 * - Start co-anchoring {@link LiveLinkAudienceActivity#startLink()}
 * - Stop co-anchoring {@link LiveLinkAudienceActivity#stopLink()}
 *
 * - For more information, please see the integration document {https://intl.cloud.tencent.com/document/product/1071/39888}.
 */
public class LiveLinkAudienceActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = "LiveLinkActivity";

    private TXCloudVideoView mPlayRenderView;
    private V2TXLivePlayer   mLivePlayer;
    private EditText         mEditStreamId;
    private EditText         mEditUserId;
    private Button           mButtonLink;
    private TXCloudVideoView mPushRenderView;
    private V2TXLivePusher   mLivePusher;
    private TextView         mTextTitle;

    private String           mStreamId;
    private boolean          mLinkFlag = false;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livelink_activity_live_link_audience);
        if (checkPermission()) {
            initIntentData();
            initView();
            startPlay();
        }
    }

    @Override
    protected void onPermissionGranted() {
        initIntentData();
        initView();
        startPlay();
    }

    private void initIntentData() {
        mStreamId   = getIntent().getStringExtra("STREAM_ID");
    }

    private void initView() {
        mPushRenderView = findViewById(R.id.tx_cloud_view_push);
        mPlayRenderView = findViewById(R.id.tx_cloud_view_play);
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mEditUserId     = findViewById(R.id.et_user_id);
        mButtonLink     = findViewById(R.id.btn_link);
        mTextTitle      = findViewById(R.id.tv_title);

        findViewById(R.id.iv_back).setOnClickListener(this);
        mButtonLink.setOnClickListener(this);

        if(!TextUtils.isEmpty(mStreamId)){
            mTextTitle.setText(mStreamId);
        }
    }

    private void startPush(String streamId, String userId) {
        String pushUrl = AddressUtils.generatePushUrl(streamId, userId, 0);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

        mLivePusher.setRenderView(mPushRenderView);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
    }

    private void startPlay() {
        String playURL = AddressUtils.generatePlayUrl(mStreamId, "", 2);
        if(mLivePlayer == null){
            mLivePlayer = new V2TXLivePlayerImpl(LiveLinkAudienceActivity.this);
            mLivePlayer.setRenderView(mPushRenderView);
            mLivePlayer.setObserver(new V2TXLivePlayerObserver() {

                @Override
                public void onError(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
                    Log.e(TAG, "[Player] onError: player-" + player + " code-" + code + " msg-" + msg + " info-" + extraInfo);
                }

                @Override
                public void onVideoPlayStatusUpdate(V2TXLivePlayer player, V2TXLiveDef.V2TXLivePlayStatus status, V2TXLiveDef.V2TXLiveStatusChangeReason reason, Bundle bundle) {
                    Log.i(TAG, "[Player] onVideoPlayStatusUpdate: player-" + player + ", status-" + status + ", reason-" + reason);
                }
            });
        }

        int result = mLivePlayer.startPlay(playURL);
        Log.d(TAG, "startPlay : " + result);
    }

    private void link() {
        if(mLinkFlag){
            stopLink();
        }else{
            startLink();
        }
    }

    public void startLink(){
        String linkStreamId = mEditStreamId.getText().toString();
        String linkUserid   = mEditUserId.getText().toString();
        if(TextUtils.isEmpty(linkStreamId)){
            Toast.makeText(LiveLinkAudienceActivity.this, getString(R.string.livelink_please_input_streamid), Toast.LENGTH_SHORT).show();
            return;
        }

        if(TextUtils.isEmpty(linkUserid)){
            Toast.makeText(LiveLinkAudienceActivity.this, getString(R.string.livelink_please_input_userid), Toast.LENGTH_SHORT).show();
            return;
        }

        if(mLivePlayer != null && mLivePlayer.isPlaying() == 1){
            mLivePlayer.stopPlay();
        }

        String userId = String.valueOf(new Random().nextInt(10000));
        String playURL = AddressUtils.generatePlayUrl(mStreamId, userId, 0);
        mLivePlayer.setRenderView(mPlayRenderView);
        int result = mLivePlayer.startPlay(playURL);
        Log.d(TAG, "startPlay : " + result);

        startPush(linkStreamId, linkUserid);
        mLinkFlag = true;
        mButtonLink.setText(getString(R.string.livelink_stop_link));
    }

    public void stopLink(){
        if(mLivePlayer != null && mLivePlayer.isPlaying() == 1){
            mLivePlayer.stopPlay();
        }
        if(mLivePusher != null){
            mLivePusher.stopCamera();
            if(mLivePusher.isPushing() == 1){
                mLivePusher.stopPush();
            }

            mLivePusher = null;
        }
        startPlay();
        mButtonLink.setText(getString(R.string.livelink_start_link));
        mLinkFlag = false;
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

        if(mLivePlayer != null){
            if(mLivePlayer.isPlaying() == 1){
                mLivePlayer.stopPlay();
            }
            mLivePlayer = null;
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
        }else if(id == R.id.btn_link){
            link();
        }
    }
}
