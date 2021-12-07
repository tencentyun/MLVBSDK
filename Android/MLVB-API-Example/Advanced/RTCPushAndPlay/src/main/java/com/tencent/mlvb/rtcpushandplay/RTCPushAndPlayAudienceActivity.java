package com.tencent.mlvb.rtcpushandplay;

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
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.Random;

/**
 * MLVB RTC连麦+超低延时播放的观众视角
 *
 * 包含如下简单功能：
 * - 开始拉流{@link RTCPushAndPlayAudienceActivity#startPlay()}
 * - 开始连麦{@link RTCPushAndPlayAudienceActivity#startLink()}
 * - 停止连麦{@link RTCPushAndPlayAudienceActivity#stopLink()}
 *
 * RTC Co-anchoring + Ultra-low-latency Playback View for Audience
 *
 * Features:
 * - Start playback {@link RTCPushAndPlayAudienceActivity#startPlay()}
 * - Start co-anchoring {@link RTCPushAndPlayAudienceActivity#startLink()}
 * - Stop co-anchoring {@link RTCPushAndPlayAudienceActivity#stopLink()}
 */
public class RTCPushAndPlayAudienceActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = RTCPushAndPlayAudienceActivity.class.getSimpleName();

    private TXCloudVideoView mLinkPlayRenderView;
    private V2TXLivePlayer   mLivePlayer;
    private EditText         mEditStreamId;
    private Button           mButtonLink;
    private TXCloudVideoView mPlayRenderView;
    private V2TXLivePlayer   mLinkPlayer;

    private TextView         mTextTitle;

    private String           mStreamId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.rtcpushandplay_activity_rtc_push_and_play_audience);
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
        mPlayRenderView = findViewById(R.id.tx_cloud_view_push);
        mLinkPlayRenderView = findViewById(R.id.tx_cloud_view_play);
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mButtonLink     = findViewById(R.id.btn_link);
        mTextTitle      = findViewById(R.id.tv_title);

        findViewById(R.id.iv_back).setOnClickListener(this);
        mButtonLink.setOnClickListener(this);

        if(!TextUtils.isEmpty(mStreamId)){
            mTextTitle.setText(mStreamId);
        }
    }

    private void startPlay() {
        String userId = String.valueOf(new Random().nextInt(10000));
        String playURL = URLUtils.generatePlayUrl(mStreamId, userId, 0);
        if(mLivePlayer == null){
            mLivePlayer = new V2TXLivePlayerImpl(RTCPushAndPlayAudienceActivity.this);
            mLivePlayer.setRenderView(mPlayRenderView);
            mLivePlayer.setObserver(new V2TXLivePlayerObserver() {

                @Override
                public void onError(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
                    Log.e(TAG, "[Player] onError: player-" + player + " code-" + code + " msg-" + msg + " info-" + extraInfo);
                }

                @Override
                public void onVideoLoading(V2TXLivePlayer player, Bundle extraInfo) {
                    Log.i(TAG, "[Player] onVideoLoading: player-" + player + ", extraInfo-" + extraInfo);
                }

                @Override
                public void onVideoPlaying(V2TXLivePlayer player, boolean firstPlay, Bundle extraInfo) {
                    Log.i(TAG, "[Player] onVideoPlaying: player-"
                            + player + " firstPlay-" + firstPlay + " info-" + extraInfo);
                }

                @Override
                public void onVideoResolutionChanged(V2TXLivePlayer player, int width, int height) {
                    Log.i(TAG, "[Player] onVideoResolutionChanged: player-"
                            + player + " width-" + width + " height-" + height);
                }
            });
        }

        int result = mLivePlayer.startPlay(playURL);
        Log.d(TAG, "startPlay : " + result);
    }

    private void link() {
        if(mLinkPlayer != null && mLinkPlayer.isPlaying() == 1){
            stopLink();
        }else{
            startLink();
        }
    }

    public void startLink(){
        String linkStreamId = mEditStreamId.getText().toString();
        if(TextUtils.isEmpty(linkStreamId)){
            Toast.makeText(RTCPushAndPlayAudienceActivity.this, "请输入streamId", Toast.LENGTH_SHORT).show();
            return;
        }
        String userId = String.valueOf(new Random().nextInt(10000));
        String playURL = URLUtils.generatePlayUrl(linkStreamId, userId, 0);
        if(mLinkPlayer == null){
            mLinkPlayer = new V2TXLivePlayerImpl(RTCPushAndPlayAudienceActivity.this);
            mLinkPlayer.setRenderView(mLinkPlayRenderView);
            mLinkPlayer.setObserver(new V2TXLivePlayerObserver() {

                @Override
                public void onError(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
                    Log.e(TAG, "[Player] onError: player-" + player + " code-" + code + " msg-" + msg + " info-" + extraInfo);
                }

                @Override
                public void onVideoLoading(V2TXLivePlayer player, Bundle extraInfo) {
                    Log.i(TAG, "[Player] onVideoLoading: player-" + player + ", extraInfo-" + extraInfo);
                }

                @Override
                public void onVideoPlaying(V2TXLivePlayer player, boolean firstPlay, Bundle extraInfo) {
                    Log.i(TAG, "[Player] onVideoPlaying: player-"
                            + player + " firstPlay-" + firstPlay + " info-" + extraInfo);
                }

                @Override
                public void onVideoResolutionChanged(V2TXLivePlayer player, int width, int height) {
                    Log.i(TAG, "[Player] onVideoResolutionChanged: player-"
                            + player + " width-" + width + " height-" + height);
                }
            });
        }

        int result = mLinkPlayer.startPlay(playURL);
        Log.d(TAG, "startPlay : " + result);
        mButtonLink.setText(R.string.rtcpushandplay_stop_play);
    }

    public void stopLink(){
        if(mLinkPlayer != null && mLinkPlayer.isPlaying() == 1){
            mLinkPlayer.stopPlay();
        }
        mButtonLink.setText(R.string.rtcpushandplay_rtc_play);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if(mLivePlayer != null){
            if(mLivePlayer.isPlaying() == 1){
                mLivePlayer.stopPlay();
            }
            mLivePlayer = null;
        }

        if(mLinkPlayer != null){
            if(mLinkPlayer.isPlaying() == 1){
                mLinkPlayer.stopPlay();
            }
            mLinkPlayer = null;
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
