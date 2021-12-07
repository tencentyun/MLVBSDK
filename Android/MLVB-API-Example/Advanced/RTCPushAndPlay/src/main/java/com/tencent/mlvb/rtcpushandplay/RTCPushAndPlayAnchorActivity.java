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
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.Random;

/**
 * MLVB RTC连麦+超低延时播放的主播视角
 *
 * 包含如下简单功能：
 * - 开始推流{@link RTCPushAndPlayAnchorActivity#startPush()}
 * - 开始连麦{@link RTCPushAndPlayAnchorActivity#startLink()} ()}
 * - 停止连麦{@link RTCPushAndPlayAnchorActivity#stopLink()} ()}
 * - 播放对面主播的流{@link RTCPushAndPlayAnchorActivity#startPlay(String)}
 *
 *
 * RTC Co-anchoring + Ultra-low-latency Playback View for Anchors
 *
 * Features:
 * - Start publishing {@link RTCPushAndPlayAnchorActivity#startPush()}
 * - Start co-anchoring {@link RTCPushAndPlayAnchorActivity#startLink()}
 * - Stop co-anchoring {@link RTCPushAndPlayAnchorActivity#stopLink()}
 * - Play the other anchor’s streams {@link RTCPushAndPlayAnchorActivity#startPlay(String)}
 */
public class RTCPushAndPlayAnchorActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = "LiveLinkAnchorActivity";

    private TXCloudVideoView    mPlayRenderView;
    private V2TXLivePlayer      mLivePlayer;
    private EditText            mEditStreamId;
    private Button              mButtonLink;
    private TXCloudVideoView    mPushRenderView;
    private V2TXLivePusher      mLivePusher;
    private TextView            mTextTitle;

    private String              mStreamId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.rtcpushandplay_activity_rtc_push_and_play_anchor);
        if (checkPermission()) {
            initIntentData();
            initView();
            startPush();
        }
    }

    @Override
    protected void onPermissionGranted() {
        initIntentData();
        initView();
        startPush();
    }

    private void initIntentData() {
        mStreamId   = getIntent().getStringExtra("STREAM_ID");
    }


    private void initView() {
        mPushRenderView = findViewById(R.id.tx_cloud_view_push);
        mPlayRenderView = findViewById(R.id.tx_cloud_view_play);
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mButtonLink     = findViewById(R.id.btn_link);
        mTextTitle      = findViewById(R.id.tv_title);

        mButtonLink.setOnClickListener(this);
        findViewById(R.id.iv_back).setOnClickListener(this);

        if(!TextUtils.isEmpty(mStreamId)){
            mTextTitle.setText(mStreamId);
        }
    }

    private void startPush() {
        String userId = String.valueOf(new Random().nextInt(10000));
        String pushUrl = URLUtils.generatePushUrl(mStreamId, userId, 0);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

        mLivePusher.setRenderView(mPushRenderView);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
    }

    private void link() {
        if(mLivePlayer != null && mLivePlayer.isPlaying() == 1){
            stopLink();
        }else{
            startLink();
        }
    }

    public void startLink(){
        String linkStreamId = mEditStreamId.getText().toString();
        if(TextUtils.isEmpty(linkStreamId)){
            Toast.makeText(RTCPushAndPlayAnchorActivity.this, "请输入streamId", Toast.LENGTH_SHORT).show();
            return;
        }
        startPlay(linkStreamId);
        mButtonLink.setText(R.string.rtcpushandplay_stop_link);
    }

    private void stopLink() {
        if(mLivePlayer != null && mLivePlayer.isPlaying() == 1){
            mLivePlayer.stopPlay();
        }
        mButtonLink.setText(R.string.rtcpushandplay_start_link);
    }

    private void startPlay(String linkStreamId) {
        String userId = String.valueOf(new Random().nextInt(10000));
        String playURL = URLUtils.generatePlayUrl(linkStreamId, userId, 0);
        if(mLivePlayer == null){
            mLivePlayer = new V2TXLivePlayerImpl(RTCPushAndPlayAnchorActivity.this);
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
        if(mLivePusher != null){
            mLivePusher.stopCamera();
            mLivePusher.stopMicrophone();
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
