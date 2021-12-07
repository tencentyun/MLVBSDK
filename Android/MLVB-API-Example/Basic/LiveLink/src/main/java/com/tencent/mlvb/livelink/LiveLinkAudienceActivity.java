package com.tencent.mlvb.livelink;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePlayer;
import com.tencent.live2.V2TXLivePlayerObserver;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

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
public class LiveLinkAudienceActivity extends MLVBBaseActivity {
    private static final String TAG = "LiveLinkActivity";

    private TXCloudVideoView mVideoViewAnchor;
    private TXCloudVideoView mVideoViewAudience;
    private TextView         mTextTitle;
    private Button           mButtonStartLink;
    private Button           mButtonStopLink;
    private ImageView        mButtonBack;

    private V2TXLivePlayer   mLivePlayer;
    private V2TXLivePusher   mLivePusher;

    private String           mStreamId;
    private String           mUserId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livelink_activity_live_link_audience);

        if (checkPermission()) {
            initData();
            initView();
            startPlay();
        }
    }

    @Override
    protected void onPermissionGranted() {
        initData();
        initView();
        startPlay();
    }

    private void initData() {
        mStreamId = getIntent().getStringExtra("STREAM_ID");
        mUserId = getIntent().getStringExtra("USER_ID");
    }

    private void initView() {
        mVideoViewAnchor = findViewById(R.id.tx_cloud_view_anchor);
        mVideoViewAudience = findViewById(R.id.tx_cloud_view_audience);

        mTextTitle = findViewById(R.id.tv_title);
        mTextTitle.setText(TextUtils.isEmpty(mStreamId) ? "" : mStreamId);

        mButtonStartLink = findViewById(R.id.btn_start_link);
        mButtonStartLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startLink();
            }
        });

        mButtonStopLink = findViewById(R.id.btn_stop_link);
        mButtonStopLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                stopLink();
            }
        });

        mButtonBack = findViewById(R.id.iv_back);
        mButtonBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

    }

    private void startPush(String streamId, String userId) {
        String pushUrl = URLUtils.generatePushUrl(streamId, userId, 0);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

        mLivePusher.setRenderView(mVideoViewAudience);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
    }

    private void startPlay() {
        String playURL = URLUtils.generatePlayUrl(mStreamId, "", 2);
        if(mLivePlayer == null){
            mLivePlayer = new V2TXLivePlayerImpl(LiveLinkAudienceActivity.this);
            mLivePlayer.setRenderView(mVideoViewAnchor);
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

    public void startLink(){
        if(mLivePlayer != null && mLivePlayer.isPlaying() == 1){
            mLivePlayer.stopPlay();
        }

        String playURL = URLUtils.generatePlayUrl(mStreamId, mUserId, 0);
        mLivePlayer.setRenderView(mVideoViewAnchor);
        int result = mLivePlayer.startPlay(playURL);
        Log.d(TAG, "startPlay : " + result);

        // 备注：使用userId作为streamId，尽可能的减少参数；
        startPush(mUserId, mUserId);

        mButtonStartLink.setVisibility(View.GONE);
        mButtonStopLink.setVisibility(View.VISIBLE);
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

        mButtonStartLink.setVisibility(View.VISIBLE);
        mButtonStopLink.setVisibility(View.GONE);
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
}
