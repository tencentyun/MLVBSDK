package com.tencent.liteav.demo.common.view;

import android.content.Context;
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

import com.tencent.liteav.demo.common.R;
import com.tencent.liteav.demo.common.utils.PhoneUtil;
import com.tencent.rtmp.TXLiveConstants;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 播放端：可视化Log
 */
public class TXPlayVisibleLogView extends RelativeLayout implements View.OnClickListener {

    private static final String TAG = "TXPlayVisibleLogView";
    private VisibleLogListAdapter mAdapter;
    private RecyclerView mCatonRecyclerView;
    private TCSeekbarWithText mSeekbarBlance;
    private ImageView mIvQue;
    private ImageView mIvStep1;
    private ImageView mIvStep2;
    private ImageView mIvStep3;
    private ImageView mIvStep4;
    private ImageView mIvStep5;
    private ImageView mIvClose;
    private TextView mTvDecoder;
    private TextView mTvBrand;
    private TextView mTvSpeed;
    private TextView mTvFpsGop;
    private TextView mTvResolution;
    private TextView mTvMaxAutoAdjustCacheTime;
    private int mClickCount;
    private ProgressBar mTvVidoCache;
    private ProgressBar mTvAudioCache;

    private boolean mDisableLog = false;

    public final static int CHECK_RTMP_URL_OK = 999;
    public final static int CHECK_RTMP_URL_FAIL = 998;
    public static final int PLAY_EVT_START_VIDEO_DECODER = 2008; // 解码器启动
    public static final int PLAY_WARNING_VIDEO_PLAY_LAG = 2105; //卡顿
    public static final int PLAY_EVT_CONNECT_SUCC = 2001;   // 已经连接服务器
    public static final int PLAY_EVT_RCV_FIRST_I_FRAME = 2003;   // 网络接收到首个视频数据包(IDR)
    public static final int PLAY_EVT_PLAY_BEGIN = 2004;   // 视频播放开始
    private float mMaxAutoAdjustCacheTime;
    private int speed_denoising;
    private final static int DECODER_HARD = 1;
    private final static int DECODER_SOFT = 2;

    public TXPlayVisibleLogView(Context context) {
        this(context, null);
    }

    public TXPlayVisibleLogView(Context context, AttributeSet attrs) {
        super(context, attrs);

        LayoutInflater.from(context).inflate(R.layout.view_play_visible_log, this);

        mCatonRecyclerView = (RecyclerView) findViewById(R.id.recycler_view);
        mCatonRecyclerView.setLayoutManager(new LinearLayoutManager(context));
        mAdapter = new VisibleLogListAdapter(context);
        mAdapter.setType(VisibleLogListAdapter.TYPE_CATON);
        mCatonRecyclerView.setAdapter(mAdapter);

        mTvDecoder = (TextView) findViewById(R.id.tv_seg2);
        mTvBrand = (TextView) findViewById(R.id.tv_brand);
        mTvVidoCache = (ProgressBar) findViewById(R.id.pb_video_cache_ts);
        mTvAudioCache = (ProgressBar) findViewById(R.id.pb_audio_cache_ts);

        mSeekbarBlance = (TCSeekbarWithText) findViewById(R.id.seekbar_balance);
        mSeekbarBlance.setEnabled(false);

        mTvSpeed = (TextView) findViewById(R.id.tv_speed);
        mTvFpsGop = (TextView) findViewById(R.id.tv_fpsgop);
        mTvResolution = (TextView) findViewById(R.id.tv_resolution);
        mTvMaxAutoAdjustCacheTime = (TextView) findViewById(R.id.tv_maxAutoAdjustCacheTime);

        mIvClose = (ImageView) findViewById(R.id.iv_close);
        mIvQue = (ImageView) findViewById(R.id.iv_que);
        mIvStep1 = (ImageView) findViewById(R.id.iv_step1);
        mIvStep2 = (ImageView) findViewById(R.id.iv_step2);
        mIvStep3 = (ImageView) findViewById(R.id.iv_step3);
        mIvStep4 = (ImageView) findViewById(R.id.iv_step4);
        mIvStep5 = (ImageView) findViewById(R.id.iv_step5);

        mIvClose.setOnClickListener(this);

        mTvBrand.setText(String.format("机型:%s Android系统版本:%s", PhoneUtil.getSystemModel(), PhoneUtil.getSystemVersion()));
    }

    public void countUp() {
        mClickCount++;
    }

    public int getCount() {
        return mClickCount;
    }

    public void setLogText(Bundle status, Bundle event, int eventId) {
        if (mDisableLog) {
            return;
        }

        if (eventId == TXLiveConstants.PLAY_EVT_CHANGE_ROTATION || eventId == TXLiveConstants.PLAY_EVT_GET_MESSAGE)
            return;

        if (status != null && getVisibility() == VISIBLE) {
            int speed = status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED);
            int width = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH);
            int height = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT);

            int fps = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS);
            int gop = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP);

            String downloadSpeed = String.format("下载速度：%skbps", speed);
            String resolutionStr = String.format("分辨率：%s*%s", width, height);

            mTvSpeed.setText(downloadSpeed);
            mTvResolution.setText(resolutionStr);
            mTvFpsGop.setText(String.format("FPS：%s  GOP：%ss", fps, gop));

            if (speed_denoising == 0)
                speed_denoising = speed;
            else
                speed_denoising = (int) (speed * 1.0f / 4 + speed_denoising * 3.0f / 4);
            Log.i(TAG, "speed:" + speed + ",speed_denoising:" + speed_denoising);

            if (speed_denoising > 1500) {
                mIvQue.setImageResource(R.drawable.ic_que5);
            } else if (speed_denoising > 1000 && speed_denoising <= 1500) {
                mIvQue.setImageResource(R.drawable.ic_que4);
            } else if (speed_denoising > 500 && speed_denoising <= 1000) {
                mIvQue.setImageResource(R.drawable.ic_que3);
            } else if (speed_denoising > 250 && speed <= 500) {
                mIvQue.setImageResource(R.drawable.ic_que2);
            } else if (speed_denoising > 0 && speed_denoising <= 250) {
                mIvQue.setImageResource(R.drawable.ic_que1);
            } else if (speed_denoising == 0) {
                mIvQue.setImageResource(R.drawable.icon_que);
            }
            if (mMaxAutoAdjustCacheTime != 0) {
                String balanceStr = String.format("%.1f", status.getFloat(TXLiveConstants.NET_STATUS_AUDIO_CACHE_THRESHOLD)).toString();
                float balance = Float.valueOf(balanceStr);

                int bp = (int) (balance * 100 / mMaxAutoAdjustCacheTime);
                mSeekbarBlance.setText(balanceStr);
                mSeekbarBlance.setProgress(bp);
                Log.i(TAG, "balanceStr:" + balanceStr + ",bp:" + bp);

                float video_cache_ts = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE) * 1.0f / 1000;//s
                float audio_cache_ts = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE) * 1.0f / 1000;//s

                int vp = (int) (video_cache_ts * 100 / mMaxAutoAdjustCacheTime);
                int ap = (int) (audio_cache_ts * 100 / mMaxAutoAdjustCacheTime);
                mTvVidoCache.setProgress(vp);
                mTvAudioCache.setProgress(ap);
                Log.i(TAG, "max:" + mMaxAutoAdjustCacheTime + " video_cache_ts:" + video_cache_ts + " audio_cache_ts:" + audio_cache_ts + ",vp:" + vp + ",ap:" + ap);
            }
        }

        if (event != null) {
            String message = event.getString(TXLiveConstants.EVT_DESCRIPTION);
            if (message != null && !message.isEmpty()) {
                switch (eventId) {
                    case CHECK_RTMP_URL_OK:            //检查地址合法性 step1
                        mIvStep1.setImageResource(R.drawable.ic_green);
                        break;
                    case CHECK_RTMP_URL_FAIL:
                        mIvStep1.setImageResource(R.drawable.ic_red);
                        break;
                    case PLAY_EVT_START_VIDEO_DECODER:
                        int mode = event.getInt("EVT_PARAM1");
                        if (mode == DECODER_HARD) {           // 硬解码器1 软解码器2
                            mTvDecoder.setText(String.format("阶段二：解码器正常启动[%s]", "硬解"));
                        } else {
                            mTvDecoder.setText(String.format("阶段二：解码器正常启动[%s]", "软解"));
                        }
                        mIvStep2.setImageResource(R.drawable.ic_green);
                        break;
                    case PLAY_EVT_CONNECT_SUCC:              // 已经连接服务器(step3:成功连接到服务器)
                        mIvStep3.setImageResource(R.drawable.ic_green);
                        break;
                    case PLAY_EVT_PLAY_BEGIN:                // 视频播放开始（step4：）
                        mIvStep4.setImageResource(R.drawable.ic_green);
                        break;
                    case PLAY_EVT_RCV_FIRST_I_FRAME:         // 网络接收到首个视频数据包(IDR)（step5：收到首帧视频数据）
                        mIvStep5.setImageResource(R.drawable.ic_green);
                        break;
                    case PLAY_WARNING_VIDEO_PLAY_LAG: // 卡顿
                        String caton = getCatonNum(message);
                        mAdapter.add(caton);
                        mCatonRecyclerView.scrollToPosition(mAdapter.getItemCount() - 1); // 自动滚到底部
                        Log.i(TAG, "caton:" + caton);
                }
            }
        }


    }

    public void show(boolean enable) {
        setVisibility(enable ? View.VISIBLE : View.GONE);
    }

    public void disableLog(boolean disable) {
        mDisableLog = disable;
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.iv_close) {
            setVisibility(View.GONE);
            countUp();
        }
    }

    public String getCatonNum(String string) {
        String pattern = "\\d+";

        Pattern r = Pattern.compile(pattern);
        Matcher m = r.matcher(string);
        if (m.find()) {
            return m.group();
        } else {
            return null;
        }
    }

    public void clear() {
        mTvDecoder.setText("阶段二：解码器正常启动");
        mIvStep2.setImageResource(R.drawable.ic_red);
        mIvStep3.setImageResource(R.drawable.ic_red);
        mIvStep4.setImageResource(R.drawable.ic_red);
        mIvStep5.setImageResource(R.drawable.ic_red);
        mAdapter.clear();
    }

    public void setCacheTime(float maxAutoAdjustCacheTime) {
        mMaxAutoAdjustCacheTime = maxAutoAdjustCacheTime;
        Log.i(TAG, "setCacheTime:" + maxAutoAdjustCacheTime);

        if (mTvMaxAutoAdjustCacheTime != null) {
            mTvMaxAutoAdjustCacheTime.setText(String.format("%ss", mMaxAutoAdjustCacheTime));
        }
    }

}
