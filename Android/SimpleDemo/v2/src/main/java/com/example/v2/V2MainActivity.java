package com.example.v2;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.InputType;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.device.TXDeviceManager;
import com.tencent.live2.V2TXLiveCode;
import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePlayer;
import com.tencent.live2.V2TXLivePlayerObserver;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.live2.trtc.TXLiveUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import static com.tencent.live2.V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait;

public class V2MainActivity extends AppCompatActivity {

    private static final String TAG = "V2MainActivity";
    private static final int REQ_PERMISSION_CODE = 0x1000;
    private static final int PLAY_ERROR_TIMEOUT = 5000;
    private Handler mHandler = new Handler(Looper.getMainLooper());
    private static final String URL_FETCH_PUSH_URL = "https://lvb.qcloud.com/weapp/utils/get_test_pushurl";

    // pusher
    private MainItemRenderView mPushRenderView;
    private V2TXLivePusher mLivePusher;
    private boolean mHasInitPusher = false;
    private boolean mHasStopPusher = false;
    private boolean mIsPusherStart = false;
    private boolean mIsFrontCamera = true;
    private boolean mIsMuteVideo = false;
    private boolean mIsMuteAudio = false;
    private V2VideoSource mVideoSource = V2VideoSource.CAMERA;

    // player
    private final List<PlayerViewContainer> mRemoteRenderViewList = new ArrayList<>();
    private HashMap<Integer, String> mPlayURL = new HashMap<>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_roompusher_main);
        initView();
        checkPermission();
    }

    private boolean checkPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
            }
            if (permissions.size() != 0) {
                ActivityCompat.requestPermissions(V2MainActivity.this,
                        (String[]) permissions.toArray(new String[0]),
                        REQ_PERMISSION_CODE);
                return false;
            }
        }
        return true;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mHasStopPusher && mLivePusher != null) {
            mLivePusher.startCamera(true);
        }
    }

    @Override
    public void onBackPressed() {
        finish();
    }

    public void selectDialog() {
        if (mHasInitPusher) {
            return;
        }
        View view  = LayoutInflater.from(V2MainActivity.this).inflate(R.layout.app_item_input, null);
        final EditText pushStreamEdit = view.findViewById(R.id.et_streamid);
        pushStreamEdit.setInputType(InputType.TYPE_CLASS_NUMBER);
        pushStreamEdit.setHint("请输入streamId");
        final RadioButton cbRTMP = view.findViewById(R.id.rb_rtmp);
        final RadioButton cbTRTC = view.findViewById(R.id.rb_trtc);
        final RadioGroup radioGroup = view.findViewById(R.id.rg_protocol);
        radioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup radioGroup, int checkedId) {
                if (checkedId == R.id.rb_rtmp) {
                    OkHttpClient okHttpClient = new OkHttpClient().newBuilder()
                            .connectTimeout(10, TimeUnit.SECONDS)
                            .readTimeout(10, TimeUnit.SECONDS)
                            .writeTimeout(10, TimeUnit.SECONDS)
                            .build();
                    Request request = new Request.Builder()
                            .url(URL_FETCH_PUSH_URL)
                            .addHeader("Content-Type", "application/json; charset=utf-8")
                            .build();
                    okHttpClient.newCall(request).enqueue(new Callback() {
                        @Override
                        public void onFailure(Call call, IOException e) {

                        }

                        @Override
                        public void onResponse(Call call, Response response) throws IOException {
                            if (response.isSuccessful()) {
                                try {
                                    JSONObject jsonRsp = new JSONObject(response.body().string());
                                    final String pusherURLDefault = jsonRsp.optString("url_push");
                                    // 二维码 URL
                                    String mQRCodePusherURL = jsonRsp.optString("url_play_flv");
                                    Log.d(TAG, "pusherURLDefault " + pusherURLDefault);
                                    Log.d(TAG, "mQRCodePusherURL " + mQRCodePusherURL);
                                    runOnUiThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            pushStreamEdit.setText(pusherURLDefault);
                                        }
                                    });
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    });
                } else if (checkedId == R.id.rb_trtc) {
                    pushStreamEdit.setText("");
                }
            }
        });

        new AlertDialog.Builder(this).setTitle("")
                .setView(view)
                .setPositiveButton("开始推流", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        Log.i(TAG, "[Pusher] onStart");
                        mPushRenderView.hideAddIcon();
                        if (cbRTMP.isChecked()) {
                            String pushURL = pushStreamEdit.getText().toString().trim();
                            Log.i(TAG, "[Pusher]  onStart CDNPushURL url: " + pushURL);
                            SingleHelper.getInstance().roomPushURL = pushURL;
                        } else if (cbTRTC.isChecked()) {
                            // TRTC push
                            if (pushStreamEdit != null) {
                                String streamId = pushStreamEdit.getText().toString().trim();
                                if (TextUtils.isEmpty(streamId)) {
                                    Toast.makeText(V2MainActivity.this, "请输入一个streamId", Toast.LENGTH_LONG).show();
                                    return;
                                }
                                String userId = String.valueOf(new Random().nextInt(10000));
                                // 拼装 TRTC 下 push 协议
                                String trtcPushURL = "trtc://cloud.tencent.com/push/" + streamId + "?sdkappid=" + GenerateTestUserSig.SDKAPPID + "&userid=" + userId + "&usersig=" + GenerateTestUserSig.genTestUserSig(userId);
                                Log.i(TAG, "[Pusher] onStart parse trtcPushURL url: " + trtcPushURL);

                                SingleHelper.getInstance().roomPushURL = trtcPushURL;
                            }
                        }
                        startPush();
                    }
                }).setNegativeButton("取消", null).show();
    }

    public void onRadioButtonClicked(View view) {
        RadioButton button = (RadioButton) view;
        boolean isChecked = button.isChecked();
        int id = view.getId();
        if (id == R.id.rb_rtmp) {
            if (isChecked) {

            }
        } else if (id == R.id.rb_trtc) {
            if (isChecked) {

            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        resetRenderView(mPushRenderView);
        for (PlayerViewContainer container : mRemoteRenderViewList) {
            resetRenderView(container.playerView);
            container.isPlaying = false;
        }

        resetPusher(mLivePusher, mPushRenderView);
        mHasStopPusher = false;
        for (V2TXLivePlayer player : SingleHelper.getInstance().playerMap.values()) {
            player.stopPlay();
        }
        // 销毁 Pusher 实例
        SingleHelper.getInstance().pusherInstance = null;
        SingleHelper.getInstance().playerURLList.clear();
        SingleHelper.getInstance().playerMap.clear();
        SingleHelper.getInstance().playerViewScanMap.clear();
        mHandler.removeCallbacksAndMessages(null);
        Log.i(TAG, "onDestroy ");
    }

    private void initView() {
        mPushRenderView = (MainItemRenderView) findViewById(R.id.live_render_user_1);
        PlayerViewContainer container1 = new PlayerViewContainer();
        container1.playerView = (MainItemRenderView) findViewById(R.id.live_render_user_2);
        PlayerViewContainer container2 = new PlayerViewContainer();
        container2.playerView = (MainItemRenderView) findViewById(R.id.live_render_user_3);
        PlayerViewContainer container3 = new PlayerViewContainer();
        container3.playerView = (MainItemRenderView) findViewById(R.id.live_render_user_4);
        PlayerViewContainer container4 = new PlayerViewContainer();
        container4.playerView = (MainItemRenderView) findViewById(R.id.live_render_user_5);
        PlayerViewContainer container5 = new PlayerViewContainer();
        container5.playerView = (MainItemRenderView) findViewById(R.id.live_render_user_6);

        mRemoteRenderViewList.add(container1);
        mRemoteRenderViewList.add(container2);
        mRemoteRenderViewList.add(container3);
        mRemoteRenderViewList.add(container4);
        mRemoteRenderViewList.add(container5);

        for (PlayerViewContainer container : mRemoteRenderViewList) {
            container.playerView.setTag("");
            container.playerView.setRenderTextTips("Player");
            container.playerView.hideControlLayout();
        }
        mPushRenderView.hideControlLayout();
        mPushRenderView.setRenderTextTips("Pusher");
        mPushRenderView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectDialog();
            }
        });
        mPushRenderView.setSwitchListener(new PushViewCallback());
    }

    private void startPlayChooseProtocolType(final int positionView) {
        View view  = LayoutInflater.from(V2MainActivity.this).inflate(R.layout.app_item_input, null);
        final EditText playStreamEdit = view.findViewById(R.id.et_streamid);
        playStreamEdit.setInputType(InputType.TYPE_CLASS_NUMBER);
        playStreamEdit.setHint("请输入streamId");
        final RadioButton cbRTMP = view.findViewById(R.id.rb_rtmp);
        final RadioButton cbTRTC = view.findViewById(R.id.rb_trtc);
        final RadioGroup radioGroup = view.findViewById(R.id.rg_protocol);
        radioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup radioGroup, int checkedId) {
                if (checkedId == R.id.rb_rtmp) {
                    playStreamEdit.setText("http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv");
                } else if (checkedId == R.id.rb_trtc) {
                    playStreamEdit.setText("");
                }
            }
        });

        new AlertDialog.Builder(this).setTitle("")
                .setView(view)
                .setPositiveButton("开始拉流", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        Log.i(TAG, "[Player] onStart");
                        String playURL = "";
                        if (cbRTMP.isChecked()) {
                            playURL = playStreamEdit.getText().toString().trim();
                        } else if (cbTRTC.isChecked()) {
                            if (playStreamEdit != null) {
                                String streamId = playStreamEdit.getText().toString().trim();
                                if (TextUtils.isEmpty(streamId)) {
                                    Toast.makeText(V2MainActivity.this, "请输入一个streamId", Toast.LENGTH_LONG).show();
                                    return;
                                }
                                String simpleURL = "trtc://cloud.tencent.com/play/" + streamId;
                                if (SingleHelper.getInstance().playerViewScanMap.get(simpleURL) != null) {
                                    Toast.makeText(V2MainActivity.this, "重复的streamId，请换一个streamId", Toast.LENGTH_LONG).show();
                                    return;
                                }
                                mPlayURL.put(positionView, simpleURL);
                                String userId = String.valueOf(new Random().nextInt(10000));
                                // 拼装 TRTC 下 play 协议
                                playURL = "trtc://cloud.tencent.com/play/" + streamId + "?sdkappid=" + GenerateTestUserSig.SDKAPPID + "&userid=" + userId + "&usersig=" + GenerateTestUserSig.genTestUserSig(userId);
                                Log.i(TAG, "[Player] onStart url: " + playURL);
                            }
                        }
                        PlayerViewContainer playerViewContainer = mRemoteRenderViewList.get(positionView);
                        playerViewContainer.index = positionView;
                        startPlay(playURL, playerViewContainer);
                    }
                }).setNegativeButton("取消", null).show();
    }

    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.livepusher_ibtn_back) {
            finish();
        } else if (id == R.id.live_render_user_2) {
            startPlayChooseProtocolType(0);
        } else if (id == R.id.live_render_user_3) {
            startPlayChooseProtocolType(1);
        } else if (id == R.id.live_render_user_4) {
            startPlayChooseProtocolType(2);
        } else if (id == R.id.live_render_user_5) {
            startPlayChooseProtocolType(3);
        } else if (id == R.id.live_render_user_6) {
            startPlayChooseProtocolType(4);
        }
    }

    private void startPush() {
        String pushURL = SingleHelper.getInstance().roomPushURL;
        if (TextUtils.isEmpty(pushURL)) {
            Log.w(TAG, "[Pusher] startPush failed, push url is empty! ");
            return;
        }
        mIsPusherStart = false;
        mLivePusher = new V2TXLivePusherImpl(this, TXLiveUtils.parseLiveMode(pushURL));

        mLivePusher.setObserver(new MyPusherObserver());
        SingleHelper.getInstance().pusherInstance = mLivePusher;

        if (mVideoSource == V2VideoSource.CAMERA) {
            // 设置本地预览View
            mLivePusher.setRenderView(mPushRenderView.getCloudView());
            mLivePusher.startCamera(true);
            mLivePusher.getDeviceManager().switchCamera(true);
            mLivePusher.getDeviceManager().enableCameraAutoFocus(true);
            mLivePusher.getDeviceManager().setCameraZoomRatio(1);
            mLivePusher.getDeviceManager().enableCameraTorch(false);
        } else {
            mLivePusher.startScreenCapture();
        }

        // 音频相关
        mLivePusher.setRenderMirror(V2TXLiveDef.V2TXLiveMirrorType.V2TXLiveMirrorTypeAuto);
        mLivePusher.setVideoQuality(V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution960x540, V2TXLiveVideoResolutionModePortrait);
        mLivePusher.setRenderRotation(V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0);
        mLivePusher.setEncoderMirror(false);

        // 音频相关
        mLivePusher.getAudioEffectManager().enableVoiceEarMonitor(true);
        mLivePusher.setAudioQuality(V2TXLiveDef.V2TXLiveAudioQuality.V2TXLiveAudioQualityDefault);

        mLivePusher.getDeviceManager().setSystemVolumeType(TXDeviceManager.TXSystemVolumeType.TXSystemVolumeTypeAuto);
        mLivePusher.getDeviceManager().setAudioRoute(TXDeviceManager.TXAudioRoute.TXAudioRouteSpeakerphone);

        mLivePusher.getAudioEffectManager().setVoiceCaptureVolume(100);
        mLivePusher.enableVolumeEvaluation(300);
        mLivePusher.startMicrophone();
        final V2TXLivePusher pusher = mLivePusher;
        // 开始推流
        int result = mLivePusher.startPush(SingleHelper.getInstance().roomPushURL);
        if (result != 0) {
            if (result == V2TXLiveCode.V2TXLIVE_ERROR_REFUSED) {
                Toast.makeText(V2MainActivity.this, "推流失败：抱歉，RTC暂不支持同一台设备使用相同streamid同时推拉流", Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(V2MainActivity.this, "推流失败!", Toast.LENGTH_LONG).show();
            }
            Log.w(TAG, "[Pusher] startPush failed, result " + result);
            resetPusher(pusher, mPushRenderView);
            return;
        }
        mPushRenderView.showControlLayout();
        mPushRenderView.showCloseButton();
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (!mIsPusherStart) {
                    Toast.makeText(V2MainActivity.this, "推流失败！", Toast.LENGTH_SHORT).show();
                    Log.w(TAG, "[Pusher] pusher failed, timeout to receive local first video");
                    resetPusher(pusher, mPushRenderView);
                }
            }
        }, PLAY_ERROR_TIMEOUT); // 5s内没有收到本地首帧视频采集或者音频采集到，认为推流异常
        mHasInitPusher = true;
    }

    private void stopPush() {
        Log.i(TAG, "[Pusher] stopPush " + mLivePusher);
        if (mLivePusher != null) {
            // 释放资源
            mLivePusher.stopMicrophone();
            mLivePusher.stopCamera();
            mLivePusher.stopScreenCapture();

            mLivePusher.stopPush();
            mLivePusher = null;
        }
        mHasInitPusher = false;
        mIsPusherStart = false;
        mIsMuteAudio = false;
        mIsMuteVideo = false;
        mIsFrontCamera = true;
        SingleHelper.getInstance().roomPushURL = null;
    }

    private void startPlay(String url, final PlayerViewContainer container) {
        final MainItemRenderView playerView = container.playerView;
        if (TextUtils.isEmpty(url) || playerView == null) {
            Toast.makeText(V2MainActivity.this, "URL为空！", Toast.LENGTH_SHORT).show();
            resetPlayer(container);
            container.isPlaying = false;
            return;
        }
        boolean isURLInvalid = url.startsWith("room://") || url.startsWith("trtc://") || url.startsWith("http://") || url.startsWith("rtmp://");
        if (!isURLInvalid) {
            Toast.makeText(V2MainActivity.this, "无效的URL！", Toast.LENGTH_SHORT).show();
            resetPlayer(container);
            container.isPlaying = false;
            return;
        }

        Log.i(TAG, "[Player] startPlay url " + url);
        final V2TXLivePlayer player = new V2TXLivePlayerImpl(V2MainActivity.this);

        playerView.hideAddIcon();
        playerView.showControlLayout();
        playerView.hidePushFeatureView();
        playerView.setSwitchListener(new PlayerViewCallback(container));

        player.setRenderView(playerView.getCloudView());
        player.setRenderRotation(V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0);
        player.setRenderFillMode(V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFill);
        player.setPlayoutVolume(100);
        player.enableVolumeEvaluation(300);
        SingleHelper.getInstance().playerMap.put(url, player);
        player.setObserver(new MyPlayerObserver(container));
        final int result = player.startPlay(url);
        if (result != 0) {
            if (result == V2TXLiveCode.V2TXLIVE_ERROR_REFUSED) {
                Toast.makeText(V2MainActivity.this, "拉流失败：抱歉，RTC暂不支持同一台设备使用相同streamid同时推拉流", Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(V2MainActivity.this, "拉流失败！", Toast.LENGTH_SHORT).show();
            }
            Log.e(TAG, "[Player] startPlay failed, result " + result);
            resetPlayer(container);
            return;
        }
        SingleHelper.getInstance().playerURLList.add(url);
        SingleHelper.getInstance().playerViewScanMap.put(mPlayURL.get(container.index), playerView);
        container.isPlaying = false;
        container.playURL = url;
        container.livePlayer = player;

        playerView.setTag(url);
        playerView.showCloseButton();
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (!container.isPlaying) {
                    Toast.makeText(V2MainActivity.this, "拉流失败！", Toast.LENGTH_SHORT).show();
                    Log.e(TAG, "[Player] play error, timeout to receive first video");
                    resetPlayer(container);
                    container.isPlaying = false;
                }
            }
        }, PLAY_ERROR_TIMEOUT); // 5s内没有收到首帧视频或者音频，认为播放异常
    }

    private class MyPusherObserver extends V2TXLivePusherObserver {
        @Override
        public void onWarning(int code, String msg, Bundle extraInfo) {
            Log.w(TAG, "[Pusher] onWarning errorCode: " + code + ", msg " + msg);
        }

        @Override
        public void onError(int code, String msg, Bundle extraInfo) {
            Log.e(TAG, "[Pusher] onError: " + msg + ", extraInfo " + extraInfo);
            mIsPusherStart = false;
        }

        @Override
        public void onCaptureFirstAudioFrame() {
            Log.i(TAG, "[Pusher] onCaptureFirstAudioFrame");
            mIsPusherStart = true;
        }

        @Override
        public void onCaptureFirstVideoFrame() {
            Log.i(TAG, "[Pusher] onCaptureFirstVideoFrame");
            mIsPusherStart = true;
        }

        @Override
        public void onMicrophoneVolumeUpdate(int volume) {
            mPushRenderView.setVolumeProgress(volume);
        }

        @Override
        public void onConnectionStateUpdate(V2TXLiveDef.V2TXLiveConnectionState state, String msg, Bundle extraInfo) {
            if (state == V2TXLiveDef.V2TXLiveConnectionState.V2TXLiveConnectionStateConnecting || state == V2TXLiveDef.V2TXLiveConnectionState.V2TXLiveConnectionStateReconnecting) {
                mPushRenderView.showLoading();
            } else {
                mPushRenderView.dismissLoading();
            }
        }

        @Override
        public void onStatisticsUpdate(V2TXLiveDef.V2TXLivePusherStatistics statistics) {
        }

    }

    // player
    private class MyPlayerObserver extends V2TXLivePlayerObserver {

        private PlayerViewContainer mPlayerContainer;

        public MyPlayerObserver(PlayerViewContainer view) {
            mPlayerContainer = view;
        }

        @Override
        public void onWarning(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
            Log.w(TAG, "[Player] onWarning: player-" + player + " code-" + code + " msg-" + msg + " info-" + extraInfo);
        }

        @Override
        public void onError(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
            Log.e(TAG, "[Player] onError: player-" + player + " code-" + code + " msg-" + msg + " info-" + extraInfo);
        }

        @Override
        public void onRecvFirstAudioFrame(V2TXLivePlayer player) {
            Log.i(TAG, "[Player] onRecvFirstAudioFrame: player-" + player);
            mPlayerContainer.isPlaying = true;
        }

        @Override
        public void onRecvFirstVideoFrame(V2TXLivePlayer player) {
            Log.i(TAG, "[Player] onRecvFirstVideoFrame: player-" + player);
            mPlayerContainer.isPlaying = true;
        }

        @Override
        public void onVideoResolutionChanged(V2TXLivePlayer player, int width, int height) {
            Log.i(TAG, "[Player] onVideoResolutionChanged: player-" + player + " width-" + width + " height-" + height);
        }

        @Override
        public void onPlayoutVolumeUpdate(V2TXLivePlayer player, int volume) {
//            Log.i(TAG, "onPlayoutVolumeUpdate: player-" + player +  ", volume-" + volume);
            MainItemRenderView renderView = mPlayerContainer.playerView;
            for (String url : SingleHelper.getInstance().playerMap.keySet()) {
                if (SingleHelper.getInstance().playerMap.get(url) == player) {
                    if (renderView != null) {
                        renderView.setVolumeProgress(volume);
                    }
                    return;
                }
            }
        }

        @Override
        public void onLoading(V2TXLivePlayer player) {
            Log.i(TAG, "[Player] onLoading: player-" + player);
            MainItemRenderView view = null;
            for (String url : SingleHelper.getInstance().playerMap.keySet()) {
                if (SingleHelper.getInstance().playerMap.get(url) == player) {
                    view = mPlayerContainer.playerView;
                    break;
                }
            }
            view.showLoading();
        }

        @Override
        public void onPlayBegin(V2TXLivePlayer player) {
            Log.i(TAG, "[Player] onPlayBegin: player- " + player);
            MainItemRenderView view = null;
            for (String url : SingleHelper.getInstance().playerMap.keySet()) {
                if (SingleHelper.getInstance().playerMap.get(url) == player) {
                    view = mPlayerContainer.playerView;
                    break;
                }
            }
            view.dismissLoading();
        }

        @Override
        public void onConnectionBroken(V2TXLivePlayer player, int result) {
            Log.i(TAG, "[Player] onConnectionBroken: player-" + player + ", result-" + result);
            Toast.makeText(V2MainActivity.this, "连接断开", Toast.LENGTH_SHORT).show();
            resetPlayer(mPlayerContainer);
            mPlayerContainer.isPlaying = false;
        }

        @Override
        public void onStatisticsUpdate(V2TXLivePlayer player, V2TXLiveDef.V2TXLivePlayerStatistics statistics) {
        }

    }

    private class PlayerViewCallback implements MainItemRenderView.ILiveRenderViewSwitchCallback {
        private PlayerViewContainer mPlayViewContainer;

        public PlayerViewCallback(PlayerViewContainer playViewContainer) {
            mPlayViewContainer = playViewContainer;
        }

        @Override
        public void onCameraChange(View view) {
        }

        @Override
        public void onMuteVideo(View view) {
            if (!mPlayViewContainer.isMuteVideo) {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_remote_video_off);
                mPlayViewContainer.isMuteVideo = true;
                mPlayViewContainer.livePlayer.pauseVideo();
            } else {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_remote_video_on);
                mPlayViewContainer.isMuteVideo = false;
                mPlayViewContainer.livePlayer.resumeVideo();
            }
        }

        @Override
        public void onMuteAudio(View view) {
            if (!mPlayViewContainer.isMuteAudio) {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_bottom_mic_off);
                mPlayViewContainer.isMuteAudio = true;
                mPlayViewContainer.livePlayer.pauseAudio();
            } else {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_bottom_mic_on);
                mPlayViewContainer.isMuteAudio = false;
                mPlayViewContainer.livePlayer.resumeAudio();
            }
        }

        @Override
        public void onClose(View view) {
            if (mPlayViewContainer.isPlaying) {
                resetPlayer(mPlayViewContainer);
                mPlayViewContainer.isPlaying = false;
            }
        }
    }

    private class PushViewCallback implements MainItemRenderView.ILiveRenderViewSwitchCallback {

        @Override
        public void onCameraChange(View view) {
            if (mLivePusher == null) {
                Toast.makeText(V2MainActivity.this, "推流尚未开始！", Toast.LENGTH_LONG).show();
                return;
            }
            mIsFrontCamera = !mIsFrontCamera;
            ((ImageView) view).setImageResource(mIsFrontCamera ? R.mipmap.app_ic_bottom_camera_back : R.mipmap.app_ic_bottom_camera_front);
            mLivePusher.getDeviceManager().switchCamera(mIsFrontCamera);
        }

        @Override
        public void onMuteVideo(View view) {
            if (mLivePusher == null) {
                Toast.makeText(V2MainActivity.this, "推流尚未开始！", Toast.LENGTH_LONG).show();
                return;
            }
            if (!mIsMuteVideo) {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_remote_video_off);
                mLivePusher.stopCamera();
                mIsMuteVideo = true;
            } else {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_remote_video_on);
                mLivePusher.startCamera(mIsFrontCamera);
                mIsMuteVideo = false;
            }
        }

        @Override
        public void onMuteAudio(View view) {
            if (mLivePusher == null) {
                Toast.makeText(V2MainActivity.this, "推流尚未开始！", Toast.LENGTH_LONG).show();
                return;
            }
            if (!mIsMuteAudio) {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_bottom_mic_off);
                mLivePusher.stopMicrophone();
                mIsMuteAudio = true;
            } else {
                ((ImageView) view).setImageResource(R.mipmap.app_ic_bottom_mic_on);
                mLivePusher.startMicrophone();
                mIsMuteAudio = false;
            }
        }

        @Override
        public void onClose(View view) {
            if (mIsPusherStart) {
                resetPusher(mLivePusher, mPushRenderView);
            }
        }
    }

    private void resetPlayer(PlayerViewContainer container) {
        Log.i(TAG, "[Player] resetPlayer: player-" + container);
        if (container == null) {
            Log.i(TAG, "[Player] resetPlayer: playerViewContainer is null");
            return;
        }
        SingleHelper.getInstance().playerViewScanMap.remove(mPlayURL.get(container.index));
        if (container.livePlayer != null) {
            container.livePlayer.stopPlay();
            container.isPlaying = false;
            container.isMuteAudio = false;
            container.isMuteVideo = false;
        }
        if (container.playerView == null) {
            Log.i(TAG, "[Player] resetPlayer: playerView is null");
            return;
        }
        MainItemRenderView playerView = container.playerView;
        if (!container.isMuteAudio) {
            ((ImageView) playerView.getMicButton()).setImageResource(R.mipmap.app_ic_bottom_mic_on);
        } else {
            ((ImageView) playerView.getMicButton()).setImageResource(R.mipmap.app_ic_bottom_mic_off);
        }
        if (!container.isMuteVideo) {
            ((ImageView) playerView.getCameraButton()).setImageResource(R.mipmap.app_ic_remote_video_on);
        } else {
            ((ImageView) playerView.getCameraButton()).setImageResource(R.mipmap.app_ic_remote_video_off);
        }

        playerView.showAddIcon();
        playerView.setTag("");
        playerView.hideControlLayout();
        playerView.setVolumeProgress(0);
        playerView.hideCloseButton();
    }

    private void resetPusher(V2TXLivePusher pusher, MainItemRenderView pusherView) {
        Log.i(TAG, "[Pusher] resetPusher: pusher-" + pusher + ", pusherView-" + pusherView);
        stopPush();
        if (!mIsMuteAudio) {
            ((ImageView) pusherView.getMicButton()).setImageResource(R.mipmap.app_ic_bottom_mic_on);
        } else {
            ((ImageView) pusherView.getMicButton()).setImageResource(R.mipmap.app_ic_bottom_mic_off);
        }
        if (!mIsMuteVideo) {
            ((ImageView) pusherView.getCameraButton()).setImageResource(R.mipmap.app_ic_remote_video_on);
        } else {
            ((ImageView) pusherView.getCameraButton()).setImageResource(R.mipmap.app_ic_remote_video_off);
        }
        ((ImageView) pusherView.getSwitchCameraButton()).setImageResource(mIsFrontCamera ? R.mipmap.app_ic_bottom_camera_back : R.mipmap.app_ic_bottom_camera_front);
        pusherView.showAddIcon();
        pusherView.setTag("");
        pusherView.hideControlLayout();
        pusherView.setVolumeProgress(0);
        pusherView.hideCloseButton();
        pusherView.getCloudView().clearLastFrame(true);
    }

    private void resetRenderView(MainItemRenderView view) {
        Log.i(TAG, "resetRenderView: view-" + view);
        if (view != null) {
            view.setTag("");
            view.setVolumeProgress(0);
        }
    }

    private enum V2VideoSource {
        CAMERA,
        SCREEN
    }

    private class PlayerViewContainer {
        private MainItemRenderView playerView;
        private boolean isPlaying;
        private String playURL;
        private V2TXLivePlayer livePlayer;
        private boolean isMuteVideo;
        private boolean isMuteAudio;
        private int index;
    }

    static class SingleHelper {

        public V2TXLivePusher pusherInstance;
        public Map<String, V2TXLivePlayer> playerMap = new HashMap<>();
        public Map<String, MainItemRenderView> playerViewScanMap = new HashMap<>();
        public List<String> playerURLList = new ArrayList<>();
        public String roomPushURL;

        private SingleHelper() {
        }

        public static SingleHelper getInstance() {
            return SingletonHolder.instance;
        }

        private static class SingletonHolder {
            private static SingleHelper instance = new SingleHelper();
        }
    }

    static class MainItemRenderView extends FrameLayout {

        private ProgressBar mPbVolume;
        private TextView mTvLoading;
        private TXCloudVideoView mCloudView;
        private ImageView mIconAdd;
        private TextView mRenderTextTips;
        private LinearLayout mControlLayout;

        public MainItemRenderView(@NonNull Context context) {
            super(context);
            init();
        }

        public MainItemRenderView(@NonNull Context context, @Nullable AttributeSet attrs) {
            super(context, attrs);
            init();
        }

        public MainItemRenderView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
            init();
        }

        private void init() {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.app_item_layout_live_render, this, true);
            mControlLayout = (LinearLayout) findViewById(R.id.ll_control);
            mTvLoading = (TextView) findViewById(R.id.render_tv_loading);
            mPbVolume = (ProgressBar) findViewById(R.id.render_pb_volume);
            mCloudView = (TXCloudVideoView) findViewById(R.id.render_cloud_view);
            mIconAdd = (ImageView) findViewById(R.id.render_add);
            mRenderTextTips = (TextView) findViewById(R.id.render_text_tips);

            findViewById(R.id.iv_mic).setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mCallback != null) {
                        mCallback.onMuteAudio(view);
                    }
                }
            });

            findViewById(R.id.iv_camera).setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mCallback != null) {
                        mCallback.onMuteVideo(view);
                    }
                }
            });

            findViewById(R.id.iv_switch_camera).setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mCallback != null) {
                        mCallback.onCameraChange(view);
                    }
                }
            });

            findViewById(R.id.ic_close).setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mCallback != null) {
                        mCallback.onClose(view);
                    }
                }
            });
        }

        private boolean isVisiable(View view) {
            return view.getVisibility() == View.VISIBLE;
        }

        public TXCloudVideoView getCloudView() {
            mCloudView.setVisibility(VISIBLE);
            return mCloudView;
        }

        public void showLoading() {
            mTvLoading.setVisibility(VISIBLE);
        }

        public void dismissLoading() {
            mTvLoading.setVisibility(GONE);
        }

        public void setVolumeProgress(int volume) {
            mPbVolume.setProgress(volume);
        }

        public void showAddIcon() {
            mIconAdd.setVisibility(View.VISIBLE);
            mRenderTextTips.setVisibility(View.VISIBLE);
        }

        public void hideAddIcon() {
            mIconAdd.setVisibility(View.GONE);
            mRenderTextTips.setVisibility(View.GONE);
        }

        public void showControlLayout() {
            mControlLayout.setVisibility(View.VISIBLE);
        }

        public void hideControlLayout() {
            mControlLayout.setVisibility(View.GONE);
        }

        public void hidePushFeatureView() {
            findViewById(R.id.ll_switch_camera).setVisibility(View.GONE);
        }

        public void showCloseButton() {
            findViewById(R.id.ic_close).setVisibility(View.VISIBLE);
        }

        public View getSwitchCameraButton() {
            return findViewById(R.id.iv_switch_camera);
        }

        public View getCameraButton() {
            return findViewById(R.id.iv_camera);
        }

        public View getMicButton() {
            return findViewById(R.id.iv_mic);
        }

        public void hideCloseButton() {
            findViewById(R.id.ic_close).setVisibility(View.GONE);
        }

        public void setRenderTextTips(String text) {
            mRenderTextTips.setText(text);
        }

        private ILiveRenderViewSwitchCallback mCallback;

        public void setSwitchListener(ILiveRenderViewSwitchCallback callback) {
            mCallback = callback;
        }

        interface ILiveRenderViewSwitchCallback {

            void onCameraChange(View view);

            void onMuteVideo(View view);

            void onMuteAudio(View view);

            void onClose(View view);
        }
    }
}
