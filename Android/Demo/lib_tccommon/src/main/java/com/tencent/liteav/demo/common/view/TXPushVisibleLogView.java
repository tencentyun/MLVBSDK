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
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.demo.common.R;
import com.tencent.liteav.demo.common.utils.PhoneUtil;
import com.tencent.rtmp.TXLiveConstants;

/**
 * 推流端：可视化Log
 */
public class TXPushVisibleLogView extends RelativeLayout implements View.OnClickListener {

    private static final String TAG = "TXPushVisibleLogView";
    private VisibleLogListAdapter mAdapter;
    private RecyclerView mCatonRecyclerView;
    private static final int ENCODER_HARD = 1;
    private static final int ENCODER_SOFT = 2;
    private ImageView mIvQue;
    private ImageView mIvStep1;
    private ImageView mIvStep2;
    private ImageView mIvStep3;
    private ImageView mIvStep4;
    private ImageView mIvStep5;
    private ImageView mIvClose;
    private TextView mTvSpeed;
    private TextView mTvBrand;
    private TextView mTvBitrate;
    private TextView mTvEncoder;
    private TextView mTvFpsGop;
    private int mClickCount;

    private boolean mDisableLog = false;
    public final static int CHECK_RTMP_URL_OK = 999;
    public final static int CHECK_RTMP_URL_FAIL = 998;
    public static final int PUSH_EVT_CONNECT_SUCC = 1001;   // 已经连接推流服务器
    public static final int PUSH_EVT_PUSH_BEGIN = 1002;   // 已经与服务器握手完毕,开始推流
    public static final int PUSH_EVT_OPEN_CAMERA_SUCC = 1003;   // 打开摄像头成功
    public static final int PUSH_EVT_START_VIDEO_ENCODER = 1008;   // 编码器启动
    public static final int PUSH_WARNING_DNS_FAIL            =  3001;   // RTMP -DNS解析失败
    public static final int PUSH_WARNING_SEVER_CONN_FAIL     =  3002;   // RTMP服务器连接失败
    public static final int PUSH_WARNING_SHAKE_FAIL          =  3003;   // RTMP服务器握手失败
    public static final int PUSH_WARNING_SERVER_DISCONNECT	 =  3004;	// RTMP服务器主动断开，请检查推流地址的合法性或防盗链有效期
    public static final int PUSH_WARNING_READ_WRITE_FAIL     =  3005;   // RTMP 读/写失败。
    public static final int PUSH_WARNING_NET_BUSY            =  1101;   // 网络状况不佳:上行带宽太小
    private int que_denoising;

    public TXPushVisibleLogView(Context context) {
        this(context, null);
    }

    public TXPushVisibleLogView(Context context, AttributeSet attrs) {
        super(context, attrs);

        LayoutInflater.from(context).inflate(R.layout.view_push_visible_log, this);

        mCatonRecyclerView = (RecyclerView) findViewById(R.id.recycler_view);
        mCatonRecyclerView.setLayoutManager(new LinearLayoutManager(context));
        mAdapter = new VisibleLogListAdapter(context);
        mAdapter.setType(VisibleLogListAdapter.TYPE_DROP);
        mCatonRecyclerView.setAdapter(mAdapter);

        mTvFpsGop = (TextView) findViewById(R.id.tv_fpsgop);
        mTvBrand = (TextView) findViewById(R.id.tv_brand);
        mTvBitrate = (TextView) findViewById(R.id.tv_bitrate);
        mTvSpeed = (TextView) findViewById(R.id.tv_speed);
        mTvEncoder = (TextView) findViewById(R.id.tv_seg4);
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
            int vra = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE);
            int ara = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE);
            int spd = status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED);
            String totalBitrate = String.format("编码码率：%skpbs", vra + ara);
            String uploadSpeed = String.format("上传网速：%skpbs", spd);

            mTvBitrate.setText(totalBitrate);
            mTvSpeed.setText(uploadSpeed);

            int fps = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS);
            int gop = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP);

            mTvFpsGop.setText(String.format("FPS：%s  GOP：%ss", fps, gop));

            int que_max = gop * fps;
            int que_current = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE);

            if (que_denoising == 0)
                que_denoising = que_current;
            else
                que_denoising = (int) (que_current * 1.0f / 4 + que_denoising * 3.0f / 4);
            Log.i(TAG, "que:" + que_current + ",que_denoising:" + que_denoising);
            if (que_denoising >= 0 && que_denoising < 3) {
                mIvQue.setImageResource(R.drawable.ic_que5);
            } else if (que_denoising > 3 && que_denoising <= que_max * 0.2) {
                mIvQue.setImageResource(R.drawable.ic_que4);
            } else if (que_denoising > que_max * 0.2 && que_denoising <= que_max * 0.4) {
                mIvQue.setImageResource(R.drawable.ic_que3);
            } else if (que_denoising > que_max * 0.4 && que_denoising <= que_max * 0.6) {
                mIvQue.setImageResource(R.drawable.ic_que2);
            } else if (que_denoising > que_max * 0.6 && que_denoising <= que_max * 0.8) {
                mIvQue.setImageResource(R.drawable.ic_que1);
            } else if (que_denoising > que_max * 0.8) {
                mIvQue.setImageResource(R.drawable.icon_que);
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
                    case PUSH_EVT_CONNECT_SUCC:        //已经连接推流服务器 step2
                        mIvStep2.setImageResource(R.drawable.ic_green);
                        break;
                    case PUSH_EVT_OPEN_CAMERA_SUCC:    //打开摄像头成功 step3
                        mIvStep3.setImageResource(R.drawable.ic_green);
                        break;
                    case PUSH_EVT_START_VIDEO_ENCODER: //编码器启动 step4
                        mIvStep4.setImageResource(R.drawable.ic_green);
                        int mode = event.getInt("EVT_PARAM1");
                        if (mode == ENCODER_HARD) { // 硬编码器1 软编码器2
                            mTvEncoder.setText(String.format("阶段四：编码器正常启动[%s]", "硬编"));
                        } else {
                            mTvEncoder.setText(String.format("阶段四：编码器正常启动[%s]", "软编"));
                        }
                        break;
                    case PUSH_EVT_PUSH_BEGIN:          //已经与服务器握手完毕,开始推流 step5
                        mIvStep5.setImageResource(R.drawable.ic_green);
                        break;
                    case PUSH_WARNING_NET_BUSY:  //丢帧警告
                        mAdapter.add("");
                        mCatonRecyclerView.scrollToPosition(mAdapter.getItemCount() - 1); // 自动滚到底部
                        break;
                }
            }
        }

        if (eventId < 0 || eventId == PUSH_WARNING_DNS_FAIL
                || eventId == PUSH_WARNING_SEVER_CONN_FAIL
                || eventId == PUSH_WARNING_SHAKE_FAIL
                || eventId == PUSH_WARNING_SERVER_DISCONNECT
                || eventId == PUSH_WARNING_READ_WRITE_FAIL) {
            mIvStep5.setImageResource(R.drawable.ic_red);
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

    public void clear() {
        mTvEncoder.setText("阶段四：编码器正常启动");
        mIvStep2.setImageResource(R.drawable.ic_red);
        mIvStep3.setImageResource(R.drawable.ic_red);
        mIvStep4.setImageResource(R.drawable.ic_red);
        mIvStep5.setImageResource(R.drawable.ic_red);
        mAdapter.clear();
    }
}
