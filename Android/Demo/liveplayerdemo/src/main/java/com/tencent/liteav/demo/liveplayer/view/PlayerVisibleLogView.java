package com.tencent.liteav.demo.liveplayer.view;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.liveplayer.R;
import com.tencent.rtmp.TXLiveConstants;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 直播拉流过程中，可视化的Log信息展示View，包含：
 * - 下载速度
 * - 分辨率
 * - FPS
 * - 阶段进度显示
 * - 其他
 */
public class PlayerVisibleLogView extends RelativeLayout implements View.OnClickListener {

    private static final String TAG = "PlayerVisibleLogView";

    private static final int DECODER_HARD = 1;                    //硬解码器
    private static final int DECODER_SOFT = 2;                    //软解码器

    public static final int CHECK_RTMP_URL_OK            = 999;   //视频播放检查：地址合法
    public static final int CHECK_RTMP_URL_FAIL          = 998;   //视频播放检查：地址不合法
    public static final int PLAY_EVT_START_VIDEO_DECODER = 2008;  //视频播放检查：解码器启动
    public static final int PLAY_WARNING_VIDEO_PLAY_LAG  = 2105;  //视频播放检查：视频卡顿
    public static final int PLAY_EVT_CONNECT_SUCC        = 2001;  //视频播放检查：已经连接服务器
    public static final int PLAY_EVT_RCV_FIRST_I_FRAME   = 2003;  //视频播放检查：网络接收到首个视频数据包(IDR)
    public static final int PLAY_EVT_PLAY_BEGIN          = 2004;  //视频播放检查：视频播放开始


    private WarningInfoAdapter  mWarningInfoRecyclerAdapter;
    private RecyclerView        mRecyclerWarningInfo;       //显示卡顿等警告信息
    private TCSeekBarWithText   mSeekBarBalance;            //显示当前音视频缓存的阈值信息
    private TextView            mTextDeviceBrand;           //显示当前设备的机型信息
    private ImageView           mImageNetSpeed;             //显示设备当前的网络情况
    private TextView            mTextResolution;            //显示当前视频的分辨率信息
    private TextView            mTextDownloadSpeed;         //显示当前视频流的下载速度
    private TextView            mTextFpsGop;                //显示当前视频的FPS/GOP信息
    private ImageView           mImageStep1Status;          //显示直播拉流过程中URL的合法性检查情况
    private ImageView           mImageStep2Status;          //显示直播拉流过程中解码器的启动情况
    private ImageView           mImageStep3Status;          //显示直播拉流过程中服务器的连接情况
    private ImageView           mImageStep4Status;          //显示直播拉流过程中视频流的是否开始播放
    private ImageView           mImageStep5Status;          //显示直播拉流过程中是否已经收到首帧数据
    private TextView            mTextDecoder;               //显示当前视频流使用的是硬/软解码信息
    private TextView            mTextMaxAutoAdjustCacheTime;//显示当前的最大缓存时间
    private ProgressBar         mProgressVideoCache;        //显示当前的视频缓存信息
    private ProgressBar         mProgressAudioCache;        //显示当前的音频缓存信息
    private ImageView           mImageClose;                //关闭当前的可视化Log的View
    private Context             mContext;

    private int     mClickCount             = 0;      //记录显示日志按钮被点击的次数，以此来显示不同LOG形式
    private int     mDenoisingSpeed         = 0;      //表示经过去除噪音后的网络信息
    private float   mMaxAutoAdjustCacheTime = 0f;     //表示在自动缓存策略下的最大缓存时间


    public PlayerVisibleLogView(Context context) {
        this(context, null);
    }

    public PlayerVisibleLogView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context.getApplicationContext();
        LayoutInflater.from(context).inflate(R.layout.liveplayer_view_player_log_info, this);

        mRecyclerWarningInfo = (RecyclerView) findViewById(R.id.recycler_view);
        mTextDecoder = (TextView) findViewById(R.id.tv_decode);
        mTextDeviceBrand = (TextView) findViewById(R.id.tv_brand);
        mProgressVideoCache = (ProgressBar) findViewById(R.id.pb_video_cache);
        mProgressAudioCache = (ProgressBar) findViewById(R.id.pb_audio_cache);
        mSeekBarBalance = (TCSeekBarWithText) findViewById(R.id.seekbar_balance);
        mTextDownloadSpeed = (TextView) findViewById(R.id.tv_speed);
        mTextFpsGop = (TextView) findViewById(R.id.tv_fps_gop);
        mTextResolution = (TextView) findViewById(R.id.tv_resolution);
        mTextMaxAutoAdjustCacheTime = (TextView) findViewById(R.id.tv_max_auto_adjust_cache_time);
        mImageClose = (ImageView) findViewById(R.id.iv_close);
        mImageNetSpeed = (ImageView) findViewById(R.id.iv_net_speed);
        mImageStep1Status = (ImageView) findViewById(R.id.iv_step1);
        mImageStep2Status = (ImageView) findViewById(R.id.iv_step2);
        mImageStep3Status = (ImageView) findViewById(R.id.iv_step3);
        mImageStep4Status = (ImageView) findViewById(R.id.iv_step4);
        mImageStep5Status = (ImageView) findViewById(R.id.iv_step5);

        mRecyclerWarningInfo.setLayoutManager(new LinearLayoutManager(context));
        mWarningInfoRecyclerAdapter = new WarningInfoAdapter(context);
        mRecyclerWarningInfo.setAdapter(mWarningInfoRecyclerAdapter);
        mSeekBarBalance.setEnabled(false);
        mImageClose.setOnClickListener(this);

        mTextDeviceBrand.setText(String.format(context.getString(R.string.liveplayer_text_device_brand), Build.MODEL, Build.VERSION.RELEASE));
    }

    @Override
    public void onClick(View view) {
        if (view == mImageClose) {
            setVisibility(View.GONE);
            clickCountUp();
        }
    }

    private String getFreezeNum(String message) {
        Pattern pattern = Pattern.compile("\\d+");
        Matcher matcher = pattern.matcher(message);
        if (matcher.find()) {
            return matcher.group();
        } else {
            return null;
        }
    }

    private void handleLogStatus(Bundle status) {
        int speed = status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED);
        int width = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH);
        int height = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT);

        int fps = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS);
        int gop = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP);

        String downloadSpeed = String.format(mContext.getString(R.string.liveplayer_text_download_speed), speed);
        String resolution = String.format(mContext.getString(R.string.liveplayer_text_resolution_detail), width, height);

        mTextDownloadSpeed.setText(downloadSpeed);
        mTextResolution.setText(resolution);
        mTextFpsGop.setText(String.format(mContext.getString(R.string.liveplayer_text_fps_gop), fps, gop));

        if (mDenoisingSpeed == 0) {
            mDenoisingSpeed = speed;
        } else {
            mDenoisingSpeed = (int) (speed * 1.0f / 4 + mDenoisingSpeed * 3.0f / 4);
        }
        Log.i(TAG, "speed:" + speed + ",speed_denoising:" + mDenoisingSpeed);

        if (mDenoisingSpeed > 1500) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed5);
        } else if (mDenoisingSpeed > 1000 && mDenoisingSpeed <= 1500) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed4);
        } else if (mDenoisingSpeed > 500 && mDenoisingSpeed <= 1000) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed3);
        } else if (mDenoisingSpeed > 250 && speed <= 500) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed2);
        } else if (mDenoisingSpeed > 0 && mDenoisingSpeed <= 250) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed1);
        } else if (mDenoisingSpeed == 0) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed0);
        }

        if (mMaxAutoAdjustCacheTime != 0) {
            String balance = String.format("%.1f", status.getFloat(TXLiveConstants.NET_STATUS_AUDIO_CACHE_THRESHOLD));
            int progress = (int) (Float.valueOf(balance) * 100 / mMaxAutoAdjustCacheTime);

            mSeekBarBalance.setText(balance);
            mSeekBarBalance.setProgress(progress);
            Log.i(TAG, "balance:" + balance + ",progress:" + progress);

            float video_cache_ts = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE) * 1.0f / 1000;//s
            float audio_cache_ts = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE) * 1.0f / 1000;//s

            int vp = (int) (video_cache_ts * 100 / mMaxAutoAdjustCacheTime);
            int ap = (int) (audio_cache_ts * 100 / mMaxAutoAdjustCacheTime);
            mProgressVideoCache.setProgress(vp);
            mProgressAudioCache.setProgress(ap);
            Log.i(TAG, "max:" + mMaxAutoAdjustCacheTime + " video_cache_ts:" + video_cache_ts + " audio_cache_ts:" + audio_cache_ts + ",vp:" + vp + ",ap:" + ap);
        }
    }

    private void handleLogEvent(Bundle event, int eventId) {
        String message = event.getString(TXLiveConstants.EVT_DESCRIPTION);
        if (message != null && !message.isEmpty()) {
            switch (eventId) {
                case CHECK_RTMP_URL_OK:
                    mImageStep1Status.setImageResource(R.drawable.liveplayer_log_info_step_success);
                    break;
                case CHECK_RTMP_URL_FAIL:
                    mImageStep1Status.setImageResource(R.drawable.liveplayer_log_info_step_fail);
                    break;
                case PLAY_EVT_START_VIDEO_DECODER:
                    int mode = event.getInt("EVT_PARAM1");
                    if (mode == DECODER_HARD) {
                        mTextDecoder.setText(R.string.liveplayer_text_hw_decode_start);
                    } else {
                        mTextDecoder.setText(R.string.liveplayer_text_sw_decode_start);
                    }
                    mImageStep2Status.setImageResource(R.drawable.liveplayer_log_info_step_success);
                    break;
                case PLAY_EVT_CONNECT_SUCC:
                    mImageStep3Status.setImageResource(R.drawable.liveplayer_log_info_step_success);
                    break;
                case PLAY_EVT_PLAY_BEGIN:
                    mImageStep4Status.setImageResource(R.drawable.liveplayer_log_info_step_success);
                    break;
                case PLAY_EVT_RCV_FIRST_I_FRAME:
                    mImageStep5Status.setImageResource(R.drawable.liveplayer_log_info_step_success);
                    break;
                case PLAY_WARNING_VIDEO_PLAY_LAG:
                    String freezeNum = getFreezeNum(message);
                    Log.d(TAG, "freezeNum:" + freezeNum);
                    mWarningInfoRecyclerAdapter.setWarningType(WarningInfoAdapter.TYPE_FREEZE);
                    mWarningInfoRecyclerAdapter.addWarningData(freezeNum);
                    //使RecycleView自动滚到底部
                    mRecyclerWarningInfo.scrollToPosition(mWarningInfoRecyclerAdapter.getItemCount() - 1);
                    break;
            }
        }
    }

    public void setLogText(Bundle status, Bundle event, int eventId) {
        if (eventId == TXLiveConstants.PLAY_EVT_CHANGE_ROTATION || eventId == TXLiveConstants.PLAY_EVT_GET_MESSAGE)
            return;

        if (status != null && this.getVisibility() == VISIBLE) {
            handleLogStatus(status);
        }

        if (event != null) {
            handleLogEvent(event, eventId);
        }
    }

    public void show(boolean enable) {
        setVisibility(enable ? View.VISIBLE : View.GONE);
    }

    public void clear() {
        mTextDecoder.setText(R.string.liveplayer_text_decode_start);
        mImageStep2Status.setImageResource(R.drawable.liveplayer_log_info_step_fail);
        mImageStep3Status.setImageResource(R.drawable.liveplayer_log_info_step_fail);
        mImageStep4Status.setImageResource(R.drawable.liveplayer_log_info_step_fail);
        mImageStep5Status.setImageResource(R.drawable.liveplayer_log_info_step_fail);
        mWarningInfoRecyclerAdapter.clearWarningData();
    }

    public void setCacheTime(float maxAutoAdjustCacheTime) {
        mMaxAutoAdjustCacheTime = maxAutoAdjustCacheTime;
        Log.i(TAG, "setCacheTime:" + maxAutoAdjustCacheTime);

        if (mTextMaxAutoAdjustCacheTime != null) {
            mTextMaxAutoAdjustCacheTime.setText(String.format("%ss", mMaxAutoAdjustCacheTime));
        }
    }

    public void clickCountUp() {
        mClickCount++;
    }

    public int getClickCount() {
        return mClickCount;
    }

}
