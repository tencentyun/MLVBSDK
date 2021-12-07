package com.tencent.mlvb.linkpk;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePlayer;
import com.tencent.live2.V2TXLivePlayerObserver;
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.mlvb.livepk.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * MLVB 连麦PK的观众视角
 *
 * 包含如下简单功能：
 * - 播放音视频流{@link LivePKAudienceActivity#startPlay()} ()}
 *
 * - 详见接入文档{https://cloud.tencent.com/document/product/454/52751}
 *
 *
 * Competition View for Audience
 *
 * Features:
 * - Play audio/video streams {@link LivePKAudienceActivity#startPlay()}
 *
 * - For more information, please see the integration document {https://intl.cloud.tencent.com/document/product/1071/39888}.
 */
public class LivePKAudienceActivity extends MLVBBaseActivity {
    private static final String TAG = "LivePKAudienceActivity";

    private TXCloudVideoView    mPlayRenderView;
    private V2TXLivePlayer      mLivePlayer;
    private TextView            mTextTitle;

    private String              mStreamId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livepk_activity_live_pk_audience);
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
        mPlayRenderView = findViewById(R.id.tx_cloud_view_play);
        mTextTitle      = findViewById(R.id.tv_title);

        findViewById(R.id.iv_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        if(!TextUtils.isEmpty(mStreamId)){
            mTextTitle.setText(mStreamId);
        }
    }

    private void startPlay() {
        String playURL = URLUtils.generatePlayUrl(mStreamId, "", 2);
        if(mLivePlayer == null){
            mLivePlayer = new V2TXLivePlayerImpl(LivePKAudienceActivity.this);
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

    @Override
    protected void onDestroy() {
        super.onDestroy();
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
