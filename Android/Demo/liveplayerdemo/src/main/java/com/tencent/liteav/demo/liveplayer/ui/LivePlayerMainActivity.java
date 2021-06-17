package com.tencent.liteav.demo.liveplayer.ui;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.AnimationDrawable;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.tencent.liteav.demo.liveplayer.R;
import com.tencent.liteav.demo.liveplayer.ui.view.LogInfoWindow;
import com.tencent.liteav.demo.liveplayer.ui.view.RadioSelectView.RadioButton;
import com.tencent.liteav.demo.liveplayer.ui.view.RadioSelectView;
import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePlayer;
import com.tencent.live2.V2TXLivePlayerObserver;
import com.tencent.live2.impl.V2TXLivePlayerImpl;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;

import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_ERROR_INVALID_PARAMETER;
import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_OK;

/**
 * 腾讯云 {@link V2TXLivePlayer} 直播播放器 V2 使用参考 Demo
 * 有以下功能参考 ：
 * - 基本功能参考： 启动推流 {@link #startPlay()}与 结束推流 {@link #stopPlay()}
 * - 渲染角度、渲染模式切换： 横竖屏渲染、铺满与自适应渲染
 * - 缓存策略选择：{@link #setCacheStrategy} 缓存策略：自动、极速、流畅。 极速模式：时延会尽可能低、但抗网络抖动效果不佳；流畅模式：时延较高、抗抖动能力较强
 */
public class LivePlayerMainActivity extends Activity {

    private static final String TAG = "LivePlayerActivity";

    private Context          mContext;

    private ImageView        mImageLoading;          //显示视频缓冲动画
    private RelativeLayout   mLayoutRoot;            //视频暂停时更新背景
    private ImageView        mImageRoot;             //背景icon
    private ImageButton      mButtonPlay;            //视频的播放控制按钮
    private ImageButton      mButtonRenderRotation;  //调整视频播放方向：横屏、竖屏
    private ImageButton      mButtonRenderMode;      //调整视频渲染模式：全屏、自适应
    private ImageButton      mButtonCacheStrategy;   //设置视频的缓存策略
    private ImageView        mImageCacheStrategyShadow;
    private ImageButton      mButtonAcc;             //切换超低时延视频源，测试专用；
    private ImageButton      mImageLogInfo;
    private RadioSelectView  mLayoutCacheStrategy;   //显示所有缓存模式的View

    private LogInfoWindow    mLogInfoWindow;

    private int              mLogClickCount = 0;

    private V2TXLivePlayer   mLivePlayer;               //直播拉流的视频播放器
    private TXCloudVideoView mVideoView;

    private String mPlayURL = "";
    private String mAccPlayURL = "";

    private boolean mIsPlaying = false;
    private boolean mFetching  = false;          //是否正在获取视频源，测试专用
    private boolean mIsAcc     = false;          //是否播放超低时延视频，测试专用

    private int mCacheStrategy      = Constants.CACHE_STRATEGY_AUTO;                    //Player缓存策略
    private int mActivityPlayType   = Constants.ACTIVITY_TYPE_LIVE_PLAY;                //播放类型
    private V2TXLiveDef.V2TXLiveFillMode mRenderMode         = V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFit;    //Player 当前渲染模式
    private V2TXLiveDef.V2TXLiveRotation mRenderRotation     = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0;         //Player 当前渲染角度

    private OkHttpClient mOkHttpClient = null;   //获取超低时延视频源直播地址

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        setContentView(R.layout.liveplayer_activity_live_player_main);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        initialize();
    }

    private void initialize() {
        mLayoutRoot = (RelativeLayout) findViewById(R.id.liveplayer_rl_root);
        mImageRoot = (ImageView) findViewById(R.id.liveplayer_iv_root);
        initPlayView();
        initLogInfo();
        initPlayButton();
        initRenderRotationButton();
        initRenderModeButton();
        initCacheStrategyButton();
        initAccButton();
        initNavigationBack();
        initRTMPURL();

        // 初始化完成之后自动播放
        startPlay();
    }

    private void initRTMPURL() {
        int activityType = getIntent().getIntExtra(Constants.INTENT_ACTIVITY_TYPE, Constants.ACTIVITY_TYPE_LIVE_PLAY);
        String playURL = getIntent().getStringExtra(Constants.INTENT_URL);
        if (activityType == Constants.ACTIVITY_TYPE_REALTIME_PLAY) {
            if (TextUtils.isEmpty(playURL)) {
                setPlayURL(Constants.ACTIVITY_TYPE_LIVE_PLAY, Constants.NORMAL_PLAY_URL);
                mButtonCacheStrategy.setClickable(true);
                mImageCacheStrategyShadow.setVisibility(View.GONE);
            } else {
                setPlayURL(Constants.ACTIVITY_TYPE_REALTIME_PLAY, playURL);
                mButtonCacheStrategy.setClickable(false);
                mImageCacheStrategyShadow.setVisibility(View.VISIBLE);
            }
        } else {
            if (TextUtils.isEmpty(playURL)) {
                setPlayURL(activityType, Constants.NORMAL_PLAY_URL);
            } else {
                setPlayURL(activityType, playURL);
            }
            mButtonCacheStrategy.setClickable(true);
            mImageCacheStrategyShadow.setVisibility(View.GONE);
        }
    }

    private void initPlayView() {
        mVideoView = (TXCloudVideoView) findViewById(R.id.liveplayer_video_view);
        mVideoView.setLogMargin(12, 12, 110, 60);
        mVideoView.showLog(false);
        mLivePlayer = new V2TXLivePlayerImpl(mContext);
        mImageLoading = (ImageView) findViewById(R.id.liveplayer_iv_loading);
    }

    private void initPlayButton() {
        mButtonPlay = (ImageButton) findViewById(R.id.liveplayer_btn_play);
        mButtonPlay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                togglePlay();
            }
        });
    }

    private void initRenderRotationButton() {
        mButtonRenderRotation = (ImageButton) findViewById(R.id.liveplayer_btn_render_rotate_landscape);
        mButtonRenderRotation.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                V2TXLiveDef.V2TXLiveRotation renderRotation = getRenderRotation();
                if (renderRotation == V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0) {
                    mButtonRenderRotation.setBackgroundResource(R.drawable.liveplayer_render_rotate_portrait);
                    renderRotation = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation270;
                } else if (renderRotation == V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation270) {
                    mButtonRenderRotation.setBackgroundResource(R.drawable.liveplayer_render_rotate_landscape);
                    renderRotation = V2TXLiveDef.V2TXLiveRotation.V2TXLiveRotation0;
                }
                setRenderRotation(renderRotation);
            }
        });
    }

    private void initRenderModeButton() {
        mButtonRenderMode = (ImageButton) findViewById(R.id.liveplayer_btn_render_mode_fill);
        mButtonRenderMode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                V2TXLiveDef.V2TXLiveFillMode renderMode = getRenderMode();
                if (getRenderMode() == V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFill) {
                    mButtonRenderMode.setBackgroundResource(R.drawable.liveplayer_render_mode_fill);
                    renderMode = V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFit;
                } else if (getRenderMode() == V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFit) {
                    mButtonRenderMode.setBackgroundResource(R.drawable.liveplayer_adjust_mode_btn);
                    renderMode = V2TXLiveDef.V2TXLiveFillMode.V2TXLiveFillModeFill;
                }
                setRenderMode(renderMode);
            }
        });
    }

    private void initCacheStrategyButton() {
        mLayoutCacheStrategy = (RadioSelectView) findViewById(R.id.liveplayer_rsv_cache_strategy);
        mImageCacheStrategyShadow = (ImageView) findViewById(R.id.liveplayer_btn_cache_strategy_shadow);
        mButtonCacheStrategy = (ImageButton) findViewById(R.id.liveplayer_btn_cache_strategy);
        mButtonCacheStrategy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutCacheStrategy.setVisibility(mLayoutCacheStrategy.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
            }
        });
        mLayoutCacheStrategy.setTitle(R.string.liveplayer_cache_strategy);
        String[] stringArray = getResources().getStringArray(R.array.liveplayer_cache_strategy);
        mLayoutCacheStrategy.setData(stringArray, Constants.CACHE_STRATEGY_AUTO);
        mLayoutCacheStrategy.setRadioSelectListener(new RadioSelectView.RadioSelectListener() {
            @Override
            public void onClose() {
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }

            @Override
            public void onChecked(int prePosition, RadioButton preRadioButton, int curPosition, RadioButton curRadioButton) {
                if (curPosition == Constants.CACHE_STRATEGY_FAST) {
                    mLogInfoWindow.setCacheTime(Constants.CACHE_TIME_FAST);
                } else {
                    mLogInfoWindow.setCacheTime(Constants.CACHE_TIME_SMOOTH);
                }
                setCacheStrategy(curPosition);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });
        setCacheStrategy(Constants.CACHE_STRATEGY_AUTO);
        mLogInfoWindow.setCacheTime(Constants.CACHE_TIME_SMOOTH);
    }

    private void initAccButton() {
        mButtonAcc = (ImageButton) findViewById(R.id.liveplayer_btn_acc);
        mButtonAcc.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isAcc()) {
                    if (mActivityPlayType != Constants.ACTIVITY_TYPE_REALTIME_PLAY) {
                        mButtonCacheStrategy.setClickable(true);
                        mImageCacheStrategyShadow.setVisibility(View.GONE);
                        mButtonAcc.setBackgroundResource(R.drawable.liveplayer_acc);
                    }
                } else {
                    mImageCacheStrategyShadow.setVisibility(View.VISIBLE);
                    mButtonCacheStrategy.setClickable(false);
                }
                toggleAcc();
            }
        });

    }

    private void initNavigationBack() {
        findViewById(R.id.liveplayer_ibtn_left).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                destroy();
                finish();
            }
        });
    }

    private void initLogInfo() {
        mImageLogInfo = (ImageButton) findViewById(R.id.liveplayer_ibtn_right);
        mImageLogInfo.setImageResource(R.drawable.liveplayer_log_info_btn_show);
        mImageLogInfo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLogInfoWindow.isShowing()) {
                    mLogInfoWindow.dismiss();
                }
                int count = mLogClickCount % 3;
                if (count == 0) {
                    mLogInfoWindow.show(v);
                    showVideoLog(false);
                } else if (count == 1) {
                    showVideoLog(true);
                } else if (count == 2) {
                    showVideoLog(false);
                }
                mLogClickCount++;
            }
        });
        mLogInfoWindow = new LogInfoWindow(mContext);
    }

    public void onFetchURLFailure() {
        stopLoadingAnimation();
        Toast.makeText(mContext, R.string.liveplayer_error_get_test_res, Toast.LENGTH_LONG).show();
    }

    public void onFetchURLSuccess(String url) {
        stopLoadingAnimation();
        Toast.makeText(mContext, R.string.liveplayer_toast_fetch_test_res, Toast.LENGTH_LONG).show();
    }

    @Override
    public void onBackPressed() {
        stopPlay();
        super.onBackPressed();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        destroy();
    }

    private void startLoadingAnimation() {
        if (mImageLoading != null) {
            mImageLoading.setVisibility(View.VISIBLE);
            ((AnimationDrawable) mImageLoading.getDrawable()).start();
        }
    }

    private void stopLoadingAnimation() {
        if (mImageLoading != null) {
            mImageLoading.setVisibility(View.GONE);
            ((AnimationDrawable) mImageLoading.getDrawable()).stop();
        }
    }

    public void onPlayStart(int code) {
        switch (code) {
            case V2TXLIVE_OK:
                startLoadingAnimation();
                break;
            case V2TXLIVE_ERROR_INVALID_PARAMETER:
                Toast.makeText(mContext, R.string.liveplayer_warning_res_url_invalid, Toast.LENGTH_SHORT).show();
                break;
            default:
                break;
        }
        if (code != V2TXLIVE_OK) {
            mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_start_btn);
            mLayoutRoot.setBackgroundResource(R.drawable.liveplayer_content_bg);
            mImageRoot.setVisibility(View.VISIBLE);
            Bundle params = new Bundle();
            params.putString(TXLiveConstants.EVT_DESCRIPTION, mContext.getResources().getString(R.string.liveplayer_warning_checkout_res_url));
            mLogInfoWindow.setLogText(null, params, LogInfoWindow.CHECK_RTMP_URL_FAIL);
        } else {
            mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_pause_btn);
            mLayoutRoot.setBackgroundColor(getResources().getColor(R.color.liveplayer_black));
            mImageRoot.setVisibility(View.GONE);
            Bundle params = new Bundle();
            params.putString(TXLiveConstants.EVT_DESCRIPTION, mContext.getResources().getString(R.string.liveplayer_warning_checkout_res_url));
            mLogInfoWindow.setLogText(null, params, LogInfoWindow.CHECK_RTMP_URL_OK);
        }
    }

    public void onPlayStop() {
        mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_start_btn);
        mLayoutRoot.setBackgroundResource(R.drawable.liveplayer_content_bg);
        mImageRoot.setVisibility(View.VISIBLE);
        mLogInfoWindow.clear();
        stopLoadingAnimation();
    }

    private void startPlay() {
        String playURL = mIsAcc ? mAccPlayURL : mPlayURL;
        int code = checkPlayURL(playURL);
        if (code != Constants.PLAY_STATUS_SUCCESS) {
            mIsPlaying = false;
        } else {
            mLivePlayer.setRenderView(mVideoView);
            mLivePlayer.setObserver(new MyPlayerObserver());

            mLivePlayer.setRenderRotation(mRenderRotation);
            mLivePlayer.setRenderFillMode(mRenderMode);

            /**
             * result返回值：
             * 0 V2TXLIVE_OK; -2 V2TXLIVE_ERROR_INVALID_PARAMETER; -3 V2TXLIVE_ERROR_REFUSED;
             */
            code = mLivePlayer.startPlay(playURL);
            mIsPlaying = code == 0;

            Log.d("video render", "timetrack start play");
        }

        //处理UI相关操作
        onPlayStart(code);
    }

    private void stopPlay() {
        if (!mIsPlaying) {
            return;
        }
        if (mLivePlayer != null) {
            mLivePlayer.setObserver(null);
            mLivePlayer.stopPlay();
        }
        mIsPlaying = false;

        //处理UI相关操作
        onPlayStop();
    }

    private void togglePlay() {
        Log.d(TAG, "togglePlay: mIsPlaying:" + mIsPlaying + ", mCurrentPlayType:" + mActivityPlayType);
        if (mIsPlaying) {
            stopPlay();
        } else {
            startPlay();
        }
    }

    private boolean isAcc() {
        return mIsAcc;
    }

    private void startAcc() {
        mIsAcc = true;
        stopPlay();
        fetchPlayURL();
    }

    private void stopAcc() {
        mIsAcc = false;
        // 停止 Acc 播放之后，自动开始普通播放
        stopPlay();
        startPlay();
    }

    private void toggleAcc() {
        if (mIsAcc) {
            stopAcc();
        } else {
            startAcc();
        }
    }

    private void setPlayURL(int activityPlayType, String url) {
        mActivityPlayType = activityPlayType;
        mPlayURL = url;
    }

    private void fetchPlayURL() {
        if (mFetching) {
            return;
        }
        mFetching = true;

        //处理UI相关操作
        startLoadingAnimation();

        mOkHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(10, TimeUnit.SECONDS)
                .readTimeout(10, TimeUnit.SECONDS)
                .writeTimeout(10, TimeUnit.SECONDS)
                .build();

        Request request = new Request.Builder()
                .url(Constants.RTMP_ACC_TEST_URL)
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build();

        Log.d(TAG, "start fetch push url");
        mOkHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e(TAG, "fetch push url error.", e);
                mFetching = false;
                onFailure();
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                mFetching = false;
                if (response.isSuccessful()) {
                    String rspString = response.body().string();
                    try {
                        JSONObject   jsonRsp = new JSONObject(rspString);
                        final String playURL = jsonRsp.optString("url_rtmpacc");
                        mAccPlayURL = playURL;
                        onSuccess(playURL);
                    } catch (Exception e) {
                        Log.e(TAG, "fetch push url error.", e);
                        onFailure();
                    }
                } else {
                    onFailure();
                }
            }

            void onSuccess(final String url) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onFetchURLSuccess(url);
                        // 低延时拉流地址获取成功后自动开始播放
                        startPlay();
                    }
                });
            }

            void onFailure() {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onFetchURLFailure();
                    }
                });
            }

        });
    }

    private class MyPlayerObserver extends V2TXLivePlayerObserver {

        @Override
        public void onWarning(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
            Log.w(TAG, "[Player] onWarning: player-" + player + " code-" + code + " msg-" + msg + " info-" + extraInfo);
        }

        @Override
        public void onError(V2TXLivePlayer player, int code, String msg, Bundle extraInfo) {
            Log.e(TAG, "[Player] onError: player-" + player + " code-" + code + " msg-" + msg + " info-" + extraInfo);
        }

        @Override
        public void onSnapshotComplete(V2TXLivePlayer v2TXLivePlayer, Bitmap bitmap) {
        }

        @Override
        public void onVideoPlayStatusUpdate(V2TXLivePlayer player, V2TXLiveDef.V2TXLivePlayStatus status, V2TXLiveDef.V2TXLiveStatusChangeReason reason, Bundle bundle) {
            Log.i(TAG, "[Player] onVideoPlayStatusUpdate: player-" + player + ", status-" + status + ", reason-" + reason);
            switch (status) {
                case V2TXLivePlayStatusLoading:
                    startLoadingAnimation();
                    break;
                case V2TXLivePlayStatusPlaying:
                    stopLoadingAnimation();
                    Bundle params = new Bundle();
                    params.putString(TXLiveConstants.EVT_DESCRIPTION, mContext.getResources().getString(R.string.liveplayer_warning_checkout_res_url));
                    mLogInfoWindow.setLogText(null, params, LogInfoWindow.CHECK_RTMP_URL_OK);
                    break;
                default:
                    break;
            }
        }

        @Override
        public void onAudioPlayStatusUpdate(V2TXLivePlayer player, V2TXLiveDef.V2TXLivePlayStatus status, V2TXLiveDef.V2TXLiveStatusChangeReason reason, Bundle bundle) {
            Log.i(TAG, "[Player] onAudioPlayStatusUpdate: player-" + player + ", status-" + status + ", reason-" + reason);
            switch (status) {
                case V2TXLivePlayStatusLoading:
                    startLoadingAnimation();
                    break;
                case V2TXLivePlayStatusPlaying:
                    stopLoadingAnimation();
                    break;
                default:
                    break;
            }
        }

        @Override
        public void onPlayoutVolumeUpdate(V2TXLivePlayer player, int volume) {
//            Log.i(TAG, "onPlayoutVolumeUpdate: player-" + player +  ", volume-" + volume);
        }

        @Override
        public void onStatisticsUpdate(V2TXLivePlayer player, V2TXLiveDef.V2TXLivePlayerStatistics statistics) {
            Bundle netStatus = new Bundle();
            netStatus.putInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH, statistics.width);
            netStatus.putInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT, statistics.height);
            int appCpu = statistics.appCpu / 10;
            int totalCpu = statistics.systemCpu / 10;
            String strCpu = appCpu + "/" + totalCpu + "%";
            netStatus.putCharSequence(TXLiveConstants.NET_STATUS_CPU_USAGE, strCpu);
            netStatus.putInt(TXLiveConstants.NET_STATUS_NET_SPEED, statistics.videoBitrate + statistics.audioBitrate);
            netStatus.putInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE, statistics.audioBitrate);
            netStatus.putInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE, statistics.videoBitrate);
            netStatus.putInt(TXLiveConstants.NET_STATUS_VIDEO_FPS, statistics.fps);
            netStatus.putInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE, 0);
            netStatus.putInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE, 0);
            netStatus.putInt(TXLiveConstants.NET_STATUS_V_SUM_CACHE_SIZE, 0);
            netStatus.putInt(TXLiveConstants.NET_STATUS_V_DEC_CACHE_SIZE, 0);
            netStatus.putString(TXLiveConstants.NET_STATUS_AUDIO_INFO, "");
            Log.d(TAG, "Current status, CPU:" + netStatus.getString(TXLiveConstants.NET_STATUS_CPU_USAGE) +
                    ", RES:" + netStatus.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + netStatus.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT) +
                    ", SPD:" + netStatus.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps" +
                    ", FPS:" + netStatus.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS) +
                    ", ARA:" + netStatus.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps" +
                    ", VRA:" + netStatus.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps");
            mLogInfoWindow.setLogText(netStatus, null, 0);
        }

    }

    private void setCacheStrategy(int cacheStrategy) {
        if (mCacheStrategy == cacheStrategy) {
            return;
        }
        mCacheStrategy = cacheStrategy;
        switch (cacheStrategy) {
            case Constants.CACHE_STRATEGY_FAST:
                mLivePlayer.setCacheParams(Constants.CACHE_TIME_FAST, Constants.CACHE_TIME_FAST);
                break;
            case Constants.CACHE_STRATEGY_SMOOTH:
                mLivePlayer.setCacheParams(Constants.CACHE_TIME_SMOOTH, Constants.CACHE_TIME_SMOOTH);
                break;
            case Constants.CACHE_STRATEGY_AUTO:
                mLivePlayer.setCacheParams(Constants.CACHE_TIME_FAST, Constants.CACHE_TIME_SMOOTH);
                break;
            default:
                break;
        }
    }

    private void setRenderMode(V2TXLiveDef.V2TXLiveFillMode renderMode) {
        mRenderMode = renderMode;
        mLivePlayer.setRenderFillMode(renderMode);
    }

    private V2TXLiveDef.V2TXLiveFillMode getRenderMode() {
        return mRenderMode;
    }

    private void setRenderRotation(V2TXLiveDef.V2TXLiveRotation renderRotation) {
        mRenderRotation = renderRotation;
        mLivePlayer.setRenderRotation(renderRotation);
    }

    private V2TXLiveDef.V2TXLiveRotation getRenderRotation() {
        return mRenderRotation;
    }

    private void showVideoLog(boolean enable) {
        mVideoView.showLog(enable);
    }

    private void destroy() {
        if (mOkHttpClient != null) {
            mOkHttpClient.dispatcher().cancelAll();
        }
        if (mLivePlayer != null) {
            mLivePlayer.stopPlay();
            mLivePlayer = null;
        }
        if (mVideoView != null) {
            mVideoView.onDestroy();
            mVideoView = null;
        }
    }

    private int checkPlayURL(final String playURL) {
        if (TextUtils.isEmpty(playURL)) {
            return Constants.PLAY_STATUS_EMPTY_URL;
        }

        if (!playURL.startsWith(Constants.URL_PREFIX_HTTP) && !playURL.startsWith(Constants.URL_PREFIX_HTTPS)
                && !playURL.startsWith(Constants.URL_PREFIX_RTMP) && !playURL.startsWith("/")) {
            return Constants.PLAY_STATUS_INVALID_URL;
        }

        boolean isLiveRTMP = playURL.startsWith(Constants.URL_PREFIX_RTMP);
        boolean isLiveFLV = (playURL.startsWith(Constants.URL_PREFIX_HTTP) || playURL.startsWith(Constants.URL_PREFIX_HTTPS)) && playURL.contains(Constants.URL_SUFFIX_FLV);

        if (mActivityPlayType == Constants.ACTIVITY_TYPE_LIVE_PLAY) {
            if (isLiveRTMP) {
                return Constants.PLAY_STATUS_SUCCESS;
            }
            if (isLiveFLV) {
                return Constants.PLAY_STATUS_SUCCESS;
            }
            return Constants.PLAY_STATUS_INVALID_URL;
        }

        if (mActivityPlayType == Constants.ACTIVITY_TYPE_REALTIME_PLAY) {
            if (!isLiveRTMP) {
                return Constants.PLAY_STATUS_INVALID_RTMP_URL;
            }
            if (!playURL.contains(Constants.URL_TX_SECRET)) {
                return Constants.PLAY_STATUS_INVALID_SECRET_RTMP_URL;
            }
            return Constants.PLAY_STATUS_SUCCESS;
        }
        return Constants.PLAY_STATUS_INVALID_URL;
    }

}