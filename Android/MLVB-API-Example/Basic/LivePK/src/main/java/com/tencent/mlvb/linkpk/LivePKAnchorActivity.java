package com.tencent.mlvb.linkpk;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.InputType;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
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
import com.tencent.mlvb.livepk.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.Random;

import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_OK;
import static com.tencent.live2.V2TXLiveDef.V2TXLiveMixInputType.V2TXLiveMixInputTypePureVideo;

/**
 * MLVB 连麦PK的主播视角
 * <p>
 * 包含如下简单功能：
 * - 开始推流{@link LivePKAnchorActivity#startPush()}
 * - 开始PK{@link LivePKAnchorActivity#startPK(String, String)}
 * - 停止PK{@link LivePKAnchorActivity#stopPK()}
 * - 播放对面主播的流{@link LivePKAnchorActivity#startPlay(String)}
 * <p>
 * 详见接入文档{https://cloud.tencent.com/document/product/454/52751}
 * <p>
 * <p>
 * Competition View for Anchors
 * <p>
 * Features:
 * - Start publishing {@link LivePKAnchorActivity#startPush()}
 * - Start competition {@link LivePKAnchorActivity#startPK(String, String)}
 * - Stop competition {@link LivePKAnchorActivity#stopPK()}
 * - Play the other anchor’s streams {@link LivePKAnchorActivity#startPlay(String)}
 * <p>
 * For more information, please see the integration document {https://intl.cloud.tencent.com/document/product/1071/39888}.
 */
public class LivePKAnchorActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = "LivePKAnchorActivity";

    private TXCloudVideoView mPlayRenderView;
    private V2TXLivePlayer   mLivePlayer;
    private TXCloudVideoView mPushRenderView;
    private V2TXLivePusher   mLivePusher;
    private TextView         mTextTitle;

    private String mStreamId;
    private String mUserId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livepk_activity_live_pk_anchor);
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
        mStreamId = getIntent().getStringExtra("STREAM_ID");
        mUserId = getIntent().getStringExtra("USER_ID");
    }

    private void initView() {
        mPushRenderView = findViewById(R.id.tx_cloud_view_push);
        mPlayRenderView = findViewById(R.id.tx_cloud_view_play);
        mTextTitle = findViewById(R.id.tv_title);

        findViewById(R.id.iv_back).setOnClickListener(this);
        findViewById(R.id.btn_accept_pk).setOnClickListener(this);
        findViewById(R.id.btn_stop_pk).setOnClickListener(this);

        if (!TextUtils.isEmpty(mStreamId)) {
            mTextTitle.setText(mStreamId);
        }
    }

    private void startPush() {
        String pushUrl = URLUtils.generatePushUrl(mStreamId, mUserId, 0);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

        mLivePusher.setRenderView(mPushRenderView);
        mLivePusher.startCamera(true);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
    }

    @SuppressLint("SetTextI18n")
    public void startPK(String pkStreamId, String pkUserId) {
        if (TextUtils.isEmpty(pkStreamId)) {
            Toast.makeText(LivePKAnchorActivity.this, getString(R.string.livepk_please_input_streamid), Toast.LENGTH_SHORT).show();
            return;
        }
        if (TextUtils.isEmpty(pkUserId)) {
            Toast.makeText(LivePKAnchorActivity.this, getString(R.string.livepk_please_input_userid), Toast.LENGTH_SHORT).show();
            return;
        }

        startPlay(pkStreamId);

        int result = mLivePusher.setMixTranscodingConfig(createConfig(pkStreamId, pkUserId));
        if (result == V2TXLIVE_OK) {
            findViewById(R.id.btn_stop_pk).setVisibility(View.VISIBLE);
            findViewById(R.id.btn_accept_pk).setVisibility(View.GONE);
        } else {
            Toast.makeText(LivePKAnchorActivity.this, getString(R.string.livepk_mix_stream_fail), Toast.LENGTH_SHORT).show();
        }
    }

    private void stopPK() {
        if (mLivePusher != null && mLivePusher.isPushing() == 1) {
            mLivePusher.setMixTranscodingConfig(null);
        }
        if (mLivePlayer != null && mLivePlayer.isPlaying() == 1) {
            mLivePlayer.stopPlay();
        }
        findViewById(R.id.btn_stop_pk).setVisibility(View.GONE);
        findViewById(R.id.btn_accept_pk).setVisibility(View.VISIBLE);
    }

    private void startPlay(String linkStreamId) {
        String userId = String.valueOf(new Random().nextInt(10000));
        String playURL = URLUtils.generatePlayUrl(linkStreamId, userId, 0);
        if (mLivePlayer == null) {
            mLivePlayer = new V2TXLivePlayerImpl(LivePKAnchorActivity.this);
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

    private V2TXLiveDef.V2TXLiveTranscodingConfig createConfig(String linkStreamId, String linkUserId) {
        V2TXLiveDef.V2TXLiveTranscodingConfig config = new V2TXLiveDef.V2TXLiveTranscodingConfig();
        config.videoWidth = 750;
        config.videoHeight = 640;
        config.videoBitrate = 900;
        config.videoFramerate = 15;
        config.videoGOP = 2;
        config.backgroundColor = 0x000000;
        config.backgroundImage = null;
        config.audioSampleRate = 48000;
        config.audioBitrate = 64;
        config.audioChannels = 1;
        config.outputStreamId = null;
        config.mixStreams = new ArrayList<>();

        V2TXLiveDef.V2TXLiveMixStream mixStream = new V2TXLiveDef.V2TXLiveMixStream();
        mixStream.userId = mUserId;
        mixStream.streamId = mStreamId;
        mixStream.x = 10;
        mixStream.y = 0;
        mixStream.width = 360;
        mixStream.height = 640;
        mixStream.zOrder = 0;
        mixStream.inputType = V2TXLiveMixInputTypePureVideo;
        config.mixStreams.add(mixStream);

        V2TXLiveDef.V2TXLiveMixStream remote = new V2TXLiveDef.V2TXLiveMixStream();
        remote.userId = linkUserId;
        remote.streamId = linkStreamId;
        remote.x = 380;
        remote.y = 0;
        remote.width = 360;
        remote.height = 640;
        remote.zOrder = 1;
        mixStream.inputType = V2TXLiveMixInputTypePureVideo;
        config.mixStreams.add(remote);
        return config;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mLivePusher != null) {
            mLivePusher.stopCamera();
            mLivePusher.stopMicrophone();
            if (mLivePusher.isPushing() == 1) {
                mLivePusher.stopPush();
            }
            mLivePusher = null;
        }

        if (mLivePlayer != null) {
            if (mLivePlayer.isPlaying() == 1) {
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
        if (id == R.id.iv_back) {
            finish();
        } else if (id == R.id.btn_accept_pk) {
            showInputUserIdDialog();
        } else if (id == R.id.btn_stop_pk) {
            stopPK();
        }
    }

    private void showInputUserIdDialog() {
        AlertDialog.Builder dialog = new AlertDialog.Builder(this);
        dialog.setTitle(R.string.livepk_input_other_info);
        LinearLayout ll = new LinearLayout(this);
        ll.setOrientation(LinearLayout.VERTICAL);
        final EditText editStreamId = new EditText(this);
        editStreamId.setInputType(InputType.TYPE_CLASS_NUMBER);
        editStreamId.setHint(getString(R.string.livepk_please_input_streamid));
        ll.addView(editStreamId);
        final EditText editUserId = new EditText(this);
        editUserId.setInputType(InputType.TYPE_CLASS_NUMBER);
        editUserId.setHint(getString(R.string.livepk_please_input_userid));
        ll.addView(editUserId);
        dialog.setView(ll);
        dialog.setPositiveButton(R.string.livepk_ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface arg0, int arg1) {
                String streamId = editStreamId.getText().toString();
                String userId = editUserId.getText().toString();
                startPK(streamId, userId);
            }
        });
        dialog.create();
        dialog.show();
    }
}
