package com.tencent.mlvb.livelink;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.InputType;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
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

import java.util.ArrayList;

import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_OK;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveMixInputType.V2TXLiveMixInputTypePureVideo;

/**
 * MLVB 连麦互动的主播视角
 *
 * 包含如下简单功能：
 * - 开始推流{@link LiveLinkAnchorActivity#startPush()}
 * - 接受连麦{@link LiveLinkAnchorActivity#startLink(String)}
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
 * - Start co-anchoring {@link LiveLinkAnchorActivity#startLink(String)}
 * - Stop co-anchoring {@link LiveLinkAnchorActivity#stopLink()}
 * - Play the co-anchoring user’s streams {@link LiveLinkAnchorActivity#startPlay(String)}
 *
 * For more information, please see the integration document {https://intl.cloud.tencent.com/document/product/1071/39888}.
 */
public class LiveLinkAnchorActivity extends MLVBBaseActivity {
    private static final String TAG = "LiveLinkAnchorActivity";

    private TextView            mTextTitle;
    private ImageView           mButtonBack;
    private TXCloudVideoView    mVideoViewAnchor;
    private TXCloudVideoView    mVideoViewAudience;
    private Button              mButtonAcceptLink;
    private Button              mButtonStopLink;

    private V2TXLivePlayer      mLivePlayer;
    private V2TXLivePusher      mLivePusher;

    private String              mStreamId;
    private String              mUserId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livelink_activity_live_link_anchor);
        if (checkPermission()) {
            initData();
            initView();
            startPush();
        }
    }

    @Override
    protected void onPermissionGranted() {
        initData();
        initView();
        startPush();
    }

    private void initData() {
        mStreamId   = getIntent().getStringExtra("STREAM_ID");
        mUserId     = getIntent().getStringExtra("USER_ID");
    }

    private void initView() {
        mVideoViewAudience = findViewById(R.id.tx_cloud_view_anchor);
        mVideoViewAnchor = findViewById(R.id.tx_cloud_view_audience);

        mTextTitle = findViewById(R.id.tv_title);
        mTextTitle.setText(TextUtils.isEmpty(mStreamId) ? "" : mStreamId);

        mButtonAcceptLink = findViewById(R.id.btn_accept_link);
        mButtonAcceptLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showInputUserIdDialog();
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


    private void startPush() {
        String pushUrl = URLUtils.generatePushUrl(mStreamId, mUserId, 0);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

        mLivePusher.setRenderView(mVideoViewAudience);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
    }

    public void startLink(String linkUserId){
        if(TextUtils.isEmpty(linkUserId)){
            Toast.makeText(LiveLinkAnchorActivity.this, getString(R.string.livelink_please_input_userid), Toast.LENGTH_SHORT).show();
            return;
        }

        // 备注：因为观众册使用userId作为streamId，此处即为连麦观众的UserId；
        startPlay(linkUserId);

        int result = mLivePusher.setMixTranscodingConfig(createConfig(linkUserId, linkUserId));
        if(result == V2TXLIVE_OK){
            mButtonAcceptLink.setVisibility(View.GONE);
            mButtonStopLink.setVisibility(View.VISIBLE);
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
        mButtonAcceptLink.setVisibility(View.VISIBLE);
        mButtonStopLink.setVisibility(View.GONE);
    }

    private void startPlay(String linkStreamId) {
        String playURL = URLUtils.generatePlayUrl(linkStreamId, mUserId, 0);
        if(mLivePlayer == null){
            mLivePlayer = new V2TXLivePlayerImpl(LiveLinkAnchorActivity.this);
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

    private void showInputUserIdDialog() {
        AlertDialog.Builder dialog = new AlertDialog.Builder(this);
        dialog.setTitle(R.string.livelink_tips_input_userid);
        final EditText editText = new EditText(this);
        editText.setInputType(InputType.TYPE_CLASS_NUMBER);
        dialog.setView(editText);
        dialog.setPositiveButton(R.string.livelink_ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface arg0, int arg1) {
                if (editText != null){
                    startLink(editText.getText().toString());
                }
            }
        });

        dialog.create();
        dialog.show();
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

}
