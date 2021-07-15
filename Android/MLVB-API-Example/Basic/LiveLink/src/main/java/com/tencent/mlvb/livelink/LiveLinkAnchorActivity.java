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

import java.util.ArrayList;
import java.util.Random;

import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_OK;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveMixInputType.V2TXLiveMixInputTypePureVideo;

/**
 * MLVB 连麦互动的主播视角
 *
 * 包含如下简单功能：
 * - 开始推流{@link LiveLinkAnchorActivity#startPush()}
 * - 接受连麦{@link LiveLinkAnchorActivity#startLink()}
 * - 断开连麦{@link LiveLinkAnchorActivity#stopLink()} ()}
 * - 拉去连麦观众的流{@link LiveLinkAnchorActivity#startPlay(String)}
 *
 * 详见接入文档{https://cloud.tencent.com/document/product/454/52751}
 *
 *
 * Co-anchoring View for Anchors
 *
 * Features:
 * - Start publishing {@link LiveLinkAnchorActivity#startPush()}
 * - Start co-anchoring {@link LiveLinkAnchorActivity#startLink()}
 * - Stop co-anchoring {@link LiveLinkAnchorActivity#stopLink()}
 * - Play the co-anchoring user’s streams {@link LiveLinkAnchorActivity#startPlay(String)}
 *
 * For more information, please see the integration document {https://intl.cloud.tencent.com/document/product/1071/39888}.
 */
public class LiveLinkAnchorActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = "LiveLinkAnchorActivity";

    private TXCloudVideoView    mPlayRenderView;
    private V2TXLivePlayer      mLivePlayer;
    private EditText            mEditStreamId;
    private EditText            mEditUserId;
    private Button              mButtonLink;
    private TXCloudVideoView    mPushRenderView;
    private V2TXLivePusher      mLivePusher;
    private TextView            mTextTitle;

    private String              mStreamId;
    private String              mUserId;
    private boolean             mLinkFlag = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livelink_activity_live_link_anchor);
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
        mUserId     = getIntent().getStringExtra("USER_ID");
    }


    private void initView() {
        mPushRenderView = findViewById(R.id.tx_cloud_view_push);
        mPlayRenderView = findViewById(R.id.tx_cloud_view_play);
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mEditUserId     = findViewById(R.id.et_user_id);
        mButtonLink     = findViewById(R.id.btn_link);
        mTextTitle      = findViewById(R.id.tv_title);

        mButtonLink.setOnClickListener(this);
        findViewById(R.id.iv_back).setOnClickListener(this);

        if(!TextUtils.isEmpty(mStreamId)){
            mTextTitle.setText(mStreamId);
        }
    }

    private void startPush() {
        String pushUrl = AddressUtils.generatePushUrl(mStreamId, mUserId, 0);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

        mLivePusher.setRenderView(mPushRenderView);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
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
            Toast.makeText(LiveLinkAnchorActivity.this, getString(R.string.livelink_please_input_streamid), Toast.LENGTH_SHORT).show();
            return;
        }

        if(TextUtils.isEmpty(linkUserid)){
            Toast.makeText(LiveLinkAnchorActivity.this, getString(R.string.livelink_please_input_userid), Toast.LENGTH_SHORT).show();
            return;
        }

        startPlay(linkStreamId);

        int result = mLivePusher.setMixTranscodingConfig(createConfig(linkStreamId, linkUserid));
        if(result == V2TXLIVE_OK){
            mButtonLink.setText(R.string.livelink_stop_link);
            mLinkFlag = true;
        }else{
            Toast.makeText(LiveLinkAnchorActivity.this, getString(R.string.livelink_mix_stream_fail), Toast.LENGTH_SHORT).show();
        }
    }

    private void stopLink() {
        if(mLivePusher != null && mLivePusher.isPushing() == 1){
            mLivePusher.setMixTranscodingConfig(null);
        }
        if(mLivePlayer != null && mLivePlayer.isPlaying() == 1){
            mLivePlayer.stopPlay();
        }
        mButtonLink.setText(getString(R.string.livelink_accept_link));
        mLinkFlag = false;
    }

    private void startPlay(String linkStreamId) {
        String userId = String.valueOf(new Random().nextInt(10000));
        String playURL = AddressUtils.generatePlayUrl(linkStreamId, userId, 0);
        if(mLivePlayer == null){
            mLivePlayer = new V2TXLivePlayerImpl(LiveLinkAnchorActivity.this);
            mLivePlayer.setRenderView(mPlayRenderView);
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

    private V2TXLiveDef.V2TXLiveTranscodingConfig createConfig(String linkStreamId, String linkUserId) {
        V2TXLiveDef.V2TXLiveTranscodingConfig config = new V2TXLiveDef.V2TXLiveTranscodingConfig();
        config.videoWidth      = 360;
        config.videoHeight     = 640;
        config.videoBitrate    = 900;
        config.videoFramerate  = 15;
        config.videoGOP        = 2;
        config.backgroundColor = 0x000000;
        config.backgroundImage = null;
        config.audioSampleRate = 48000;
        config.audioBitrate    = 64;
        config.audioChannels   = 1;
        config.outputStreamId  = null;
        config.mixStreams = new ArrayList<>();

        V2TXLiveDef.V2TXLiveMixStream mixStream = new V2TXLiveDef.V2TXLiveMixStream();
        mixStream.userId = mUserId;
        mixStream.streamId = mStreamId;
        mixStream.x = 0;
        mixStream.y = 0;
        mixStream.width = 360;
        mixStream.height = 640;
        mixStream.zOrder = 0;
        mixStream.inputType = V2TXLiveMixInputTypePureVideo;
        config.mixStreams.add(mixStream);

        V2TXLiveDef.V2TXLiveMixStream remote = new V2TXLiveDef.V2TXLiveMixStream();
        remote.userId = linkUserId;
        remote.streamId = linkStreamId;
        remote.x      = 150;
        remote.y      = 300;
        remote.width  = 135;
        remote.height = 240;
        remote.zOrder = 1;
        mixStream.inputType = V2TXLiveMixInputTypePureVideo;
        config.mixStreams.add(remote);
        return config;
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
