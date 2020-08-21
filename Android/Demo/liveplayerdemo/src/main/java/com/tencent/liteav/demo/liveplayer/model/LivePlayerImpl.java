package com.tencent.liteav.demo.liveplayer.model;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;

import org.json.JSONObject;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * 腾讯云 {@link TXLivePlayer} 直播播放器使用参考 Demo
 * 有以下功能参考 ：
 * - 基本功能参考： 启动推流 {@link #startPlay()}与 结束推流 {@link #stopPlay()}
 * - 硬件加速： 使用硬解码
 * - 性能数据查看参考： {@link #onNetStatus(Bundle)}
 * - 处理 SDK 回调事件参考： {@link #onPlayEvent(int, Bundle)}
 * - 渲染角度、渲染模式切换： 横竖屏渲染、铺满与自适应渲染
 * - 缓存策略选择：{@link #setCacheStrategy} 缓存策略：自动、极速、流畅。 极速模式：时延会尽可能低、但抗网络抖动效果不佳；流畅模式：时延较高、抗抖动能力较强
 */
public class LivePlayerImpl implements LivePlayer, ITXLivePlayListener {

    private static final String TAG = "LivePlayerImpl";

    private Context          mContext;

    private TXLivePlayer     mLivePlayer;               //直播拉流的视频播放器
    private TXLivePlayConfig mPlayerConfig;             //TXLivePlayer 播放配置项
    private TXCloudVideoView mVideoView;

    private String mPlayURL = "";
    private String mAccPlayURL = "";

    private boolean mIsPlaying = false;
    private boolean mFetching  = false;          //是否正在获取视频源，测试专用
    private boolean mIsAcc     = false;          //是否播放超低时延视频，测试专用
    private boolean mHWDecode  = false;          //是否启用了硬解码

    private int mCacheStrategy      = Constants.CACHE_STRATEGY_AUTO;                    //Player缓存策略
    private int mActivityPlayType   = Constants.ACTIVITY_TYPE_LIVE_PLAY;                    // 播放类型
    private int mCurrentPlayURLType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;                 //Player 当前播放链接类型
    private int mRenderMode         = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;    //Player 当前渲染模式
    private int mRenderRotation     = TXLiveConstants.RENDER_ROTATION_PORTRAIT;         //Player 当前渲染角度

    private long mStartPlayTS       = 0;         //保存开始播放的时间戳，测试专用

    private OnLivePlayerCallback mOnLivePlayerCallback;

    public LivePlayerImpl(Context context, TXCloudVideoView videoView) {
        initialize(context, videoView);
    }

    @Override
    public void startPlay() {
        String playURL = mIsAcc ? mAccPlayURL : mPlayURL;
        int code = checkPlayURL(playURL);
        if (code != Constants.PLAY_STATUS_SUCCESS) {
            mIsPlaying = false;
        } else {
            mLivePlayer.setPlayerView(mVideoView);
            mLivePlayer.setPlayListener(this);

            /**
             * 硬件加速在1080p解码场景下效果显著，但细节之处并不如想象的那么美好：
             * - 只有 4.3 以上android系统才支持
             * - 兼容性我们目前还仅过了小米华为等常见机型，故这里的返回值您先不要太当真
             *
             */
            mLivePlayer.enableHardwareDecode(mHWDecode);
            mLivePlayer.setRenderRotation(mRenderRotation);
            mLivePlayer.setRenderMode(mRenderMode);
            mPlayerConfig.setEnableMessage(true);
            mLivePlayer.setConfig(mPlayerConfig);

            /**
             * result返回值：
             * 0 success; -1 empty url; -2 invalid url; -3 invalid playType;
             */
            code = mLivePlayer.startPlay(playURL, mCurrentPlayURLType);
            mIsPlaying = code == 0;

            Log.d("video render", "timetrack start play");
            mStartPlayTS = System.currentTimeMillis();
        }
        if (mOnLivePlayerCallback != null) {
            mOnLivePlayerCallback.onPlayStart(code);
        }
    }

    @Override
    public void stopPlay() {
        if (!mIsPlaying) {
            return;
        }
        if (mLivePlayer != null) {
            mLivePlayer.stopRecord();
            mLivePlayer.setPlayListener(null);
            mLivePlayer.stopPlay(true);
        }
        mIsPlaying = false;
        if (mOnLivePlayerCallback != null) {
            mOnLivePlayerCallback.onPlayStop();
        }
    }

    @Override
    public void togglePlay() {
        Log.d(TAG, "togglePlay: mIsPlaying:" + mIsPlaying + ", mCurrentPlayType:" + mActivityPlayType);
        if (mIsPlaying) {
            stopPlay();
        } else {
            startPlay();
        }
    }

    @Override
    public boolean isAcc() {
        return mIsAcc;
    }

    @Override
    public void startAcc() {
        mIsAcc = true;
        mActivityPlayType = Constants.ACTIVITY_TYPE_REALTIME_PLAY;
        stopPlay();
        fetchPlayURL();
    }

    @Override
    public void stopAcc() {
        mIsAcc = false;
        mActivityPlayType = Constants.ACTIVITY_TYPE_LIVE_PLAY;
        // 停止 Acc 播放之后，自动开始普通播放
        stopPlay();
        startPlay();
    }

    @Override
    public void toggleAcc() {
        if (mIsAcc) {
            stopAcc();
        } else {
            startAcc();
        }
    }

    @Override
    public void setPlayURL(String url) {
        setPlayURL(Constants.ACTIVITY_TYPE_LIVE_PLAY, url);
    }

    @Override
    public void setPlayURL(int activityPlayType, String url) {
        mActivityPlayType = activityPlayType;
        mPlayURL = url;
    }

    @Override
    public void fetchPlayURL() {
        if (mFetching) {
            return;
        }
        mFetching = true;
        if (mOnLivePlayerCallback != null) {
            mOnLivePlayerCallback.onFetchURLStart();
        }
        OkHttpClient mOkHttpClient = new OkHttpClient().newBuilder()
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
                        JSONObject jsonRsp = new JSONObject(rspString);
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
                runMainThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mOnLivePlayerCallback != null) {
                            mOnLivePlayerCallback.onFetchURLSuccess(url);
                        }
                        // 低延时拉流地址获取成功后自动开始播放
                        startPlay();
                    }
                });
            }

            void onFailure() {
                runMainThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mOnLivePlayerCallback != null) {
                            mOnLivePlayerCallback.onFetchURLFailure();
                        }
                    }
                });
            }

        });
    }

    @Override
    public void setCacheStrategy(int cacheStrategy) {
        if (mCacheStrategy == cacheStrategy) return;
        mCacheStrategy = cacheStrategy;
        switch (cacheStrategy) {
            case Constants.CACHE_STRATEGY_FAST:
                mPlayerConfig.setAutoAdjustCacheTime(true);
                mPlayerConfig.setMaxAutoAdjustCacheTime(Constants.CACHE_TIME_FAST);
                mPlayerConfig.setMinAutoAdjustCacheTime(Constants.CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayerConfig);
                break;
            case Constants.CACHE_STRATEGY_SMOOTH:
                mPlayerConfig.setAutoAdjustCacheTime(false);
                mPlayerConfig.setMaxAutoAdjustCacheTime(Constants.CACHE_TIME_SMOOTH);
                mPlayerConfig.setMinAutoAdjustCacheTime(Constants.CACHE_TIME_SMOOTH);
                mLivePlayer.setConfig(mPlayerConfig);
                break;
            case Constants.CACHE_STRATEGY_AUTO:
                mPlayerConfig.setAutoAdjustCacheTime(true);
                mPlayerConfig.setMaxAutoAdjustCacheTime(Constants.CACHE_TIME_SMOOTH);
                mPlayerConfig.setMinAutoAdjustCacheTime(Constants.CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayerConfig);
                break;
            default:
                break;
        }
    }

    @Override
    public void setRenderMode(int renderMode) {
        mRenderMode = renderMode;
        mLivePlayer.setRenderMode(renderMode);
    }

    @Override
    public int getRenderMode() {
        return mRenderMode;
    }

    @Override
    public void setRenderRotation(int renderRotation) {
        mRenderRotation = renderRotation;
        mLivePlayer.setRenderRotation(renderRotation);
    }

    @Override
    public int getRenderRotation() {
        return mRenderRotation;
    }

    @Override
    public void setHWDecode(int mode) {
        mHWDecode = mode == 0;
        if (mIsPlaying) {
            stopPlay();
            startPlay();
        }
    }

    @Override
    public int getHWDecode() {
        return mHWDecode ? 1 : 0;
    }

    @Override
    public void showVideoLog(boolean enable) {
        mVideoView.showLog(enable);
    }

    @Override
    public void setOnLivePlayerCallback(OnLivePlayerCallback callback) {
        mOnLivePlayerCallback = callback;
    }

    @Override
    public void destroy() {
        if (mLivePlayer != null) {
            mLivePlayer.stopPlay(true);
            mLivePlayer = null;
        }
        if (mVideoView != null) {
            mVideoView.onDestroy();
            mVideoView = null;
        }
        mPlayerConfig = null;
    }

    @Override
    public void onPlayEvent(int event, Bundle param) {
        Log.d(TAG, "receive event: " + event + ", " + param.getString(TXLiveConstants.EVT_DESCRIPTION));
        switch (event) {
            case TXLiveConstants.PLAY_EVT_PLAY_BEGIN:
                Log.d("AutoMonitor", "PlayFirstRender,cost=" + (System.currentTimeMillis() - mStartPlayTS));
                break;
            case TXLiveConstants.PLAY_ERR_NET_DISCONNECT:
            case TXLiveConstants.PLAY_EVT_PLAY_END:
                stopPlay();
                break;
            default:
                break;
        }
        if (mOnLivePlayerCallback != null) {
            mOnLivePlayerCallback.onPlayEvent(event, param);
        }
    }

    @Override
    public void onNetStatus(Bundle bundle) {
        Log.d(TAG, "Current status, CPU:" + bundle.getString(TXLiveConstants.NET_STATUS_CPU_USAGE) +
                ", RES:" + bundle.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + bundle.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT) +
                ", SPD:" + bundle.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps" +
                ", FPS:" + bundle.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS) +
                ", ARA:" + bundle.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps" +
                ", VRA:" + bundle.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps");
        if (mOnLivePlayerCallback != null) {
            mOnLivePlayerCallback.onNetStatus(bundle);
        }
    }

    private void initialize(Context context, TXCloudVideoView videoView) {
        mContext = context;
        mVideoView = videoView;
        mPlayerConfig = new TXLivePlayConfig();
        mLivePlayer = new TXLivePlayer(mContext);
        showVideoLog(false);
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
                mCurrentPlayURLType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;
                return Constants.PLAY_STATUS_SUCCESS;
            }
            if (isLiveFLV) {
                mCurrentPlayURLType = TXLivePlayer.PLAY_TYPE_LIVE_FLV;
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
            mCurrentPlayURLType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP_ACC;
            return Constants.PLAY_STATUS_SUCCESS;
        }
        return Constants.PLAY_STATUS_INVALID_URL;
    }

    private void runMainThread(Runnable runnable) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            ((Activity) mContext).runOnUiThread(runnable);
        } else {
            runnable.run();
        }
    }
}
