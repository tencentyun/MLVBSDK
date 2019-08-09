package com.tencent.liteav.demo.lvb.camerapush;

import android.app.DialogFragment;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.common.utils.PhoneUtil;
import com.tencent.liteav.demo.common.view.VisibleLogListAdapter;
import com.tencent.rtmp.TXLiveConstants;

/**
 *
 */
public class PusherTroubleshootingFragment extends DialogFragment implements View.OnClickListener {
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

    private boolean mDisableLog = false;
    public final static int CHECK_RTMP_URL_OK = 999;
    public final static int CHECK_RTMP_URL_FAIL = 998;
    public static final int PUSH_EVT_CONNECT_SUCC = 1001;   // 已经连接推流服务器
    public static final int PUSH_EVT_PUSH_BEGIN = 1002;   // 已经与服务器握手完毕,开始推流
    public static final int PUSH_EVT_OPEN_CAMERA_SUCC = 1003;   // 打开摄像头成功
    public static final int PUSH_EVT_START_VIDEO_ENCODER = 1008;   // 编码器启动
    public static final int PUSH_WARNING_DNS_FAIL = 3001;   // RTMP -DNS解析失败
    public static final int PUSH_WARNING_SEVER_CONN_FAIL = 3002;   // RTMP服务器连接失败
    public static final int PUSH_WARNING_SHAKE_FAIL = 3003;   // RTMP服务器握手失败
    public static final int PUSH_WARNING_SERVER_DISCONNECT = 3004;    // RTMP服务器主动断开，请检查推流地址的合法性或防盗链有效期
    public static final int PUSH_WARNING_READ_WRITE_FAIL = 3005;   // RTMP 读/写失败。
    public static final int PUSH_WARNING_NET_BUSY = 1101;   // 网络状况不佳:上行带宽太小
    private int que_denoising;


    private int mCurrentSuccessStep = 0; // 当前第几步已经成功
    private String mStep4Text = "";           // 第四步的提示语

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.room_setting_dlg);
    }

    @Override
    public void onStart() {
        super.onStart();
        WindowManager manager = this.getActivity().getWindowManager();
        DisplayMetrics outMetrics = new DisplayMetrics();
        manager.getDefaultDisplay().getMetrics(outMetrics);
        int width = outMetrics.widthPixels;
        int height = outMetrics.heightPixels;
        if (getDialog() != null)
            getDialog().getWindow().setLayout(width - 100, height - 300);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view =  inflater.inflate(R.layout.fragment_pusher_troubleshooting, container, false);
        mCatonRecyclerView = (RecyclerView) view.findViewById(R.id.recycler_view);
        mCatonRecyclerView.setLayoutManager(new LinearLayoutManager(view.getContext()));
        mAdapter = new VisibleLogListAdapter(view.getContext());
        mAdapter.setType(VisibleLogListAdapter.TYPE_DROP);
        mCatonRecyclerView.setAdapter(mAdapter);

        mTvFpsGop = (TextView) view.findViewById(R.id.tv_fpsgop);
        mTvBrand = (TextView) view.findViewById(R.id.tv_brand);
        mTvBitrate = (TextView) view.findViewById(R.id.tv_bitrate);
        mTvSpeed = (TextView) view.findViewById(R.id.tv_speed);
        mTvEncoder = (TextView) view.findViewById(R.id.tv_seg4);
        mIvClose = (ImageView) view.findViewById(R.id.iv_close);
        mIvQue = (ImageView) view.findViewById(R.id.iv_que);
        mIvStep1 = (ImageView) view.findViewById(R.id.iv_step1);
        mIvStep2 = (ImageView) view.findViewById(R.id.iv_step2);
        mIvStep3 = (ImageView) view.findViewById(R.id.iv_step3);
        mIvStep4 = (ImageView) view.findViewById(R.id.iv_step4);
        mIvStep5 = (ImageView) view.findViewById(R.id.iv_step5);

        mIvClose.setOnClickListener(this);
        mTvBrand.setText(String.format("机型:%s Android系统版本:%s", PhoneUtil.getSystemModel(), PhoneUtil.getSystemVersion()));

        // 这里不需要要加break
        switch (mCurrentSuccessStep) {
            case 5:
                mIvStep5.setImageResource(R.drawable.ic_green);
            case 4:
                mIvStep4.setImageResource(R.drawable.ic_green);
                mTvEncoder.setText(mStep4Text);
            case 3:
                mIvStep3.setImageResource(R.drawable.ic_green);
            case 2:
                mIvStep2.setImageResource(R.drawable.ic_green);
            case 1:
                mIvStep1.setImageResource(R.drawable.ic_green);
        }
        return view;
    }

    public void setLogText(Bundle status, Bundle event, int eventId) {
        if (mDisableLog) {
            return;
        }

        if (eventId == TXLiveConstants.PLAY_EVT_CHANGE_ROTATION || eventId == TXLiveConstants.PLAY_EVT_GET_MESSAGE)
            return;

        if (status != null && isVisible()) {
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
                        if (mIvStep1 != null)
                            mIvStep1.setImageResource(R.drawable.ic_green);
                        mCurrentSuccessStep = 1;
                        break;
                    case CHECK_RTMP_URL_FAIL:
                        if (mIvStep1 != null)
                            mIvStep1.setImageResource(R.drawable.ic_red);
                        mCurrentSuccessStep = 0;
                        break;
                    case PUSH_EVT_CONNECT_SUCC:        //已经连接推流服务器 step2
                        if (mIvStep2 != null)
                            mIvStep2.setImageResource(R.drawable.ic_green);
                        mCurrentSuccessStep = 2;
                        break;
                    case PUSH_EVT_OPEN_CAMERA_SUCC:    //打开摄像头成功 step3
                        if (mIvStep3 != null)
                            mIvStep3.setImageResource(R.drawable.ic_green);
                        // 这里有可能中途切换摄像头，导致step错乱
                        mCurrentSuccessStep = (mCurrentSuccessStep != 5 ? 3 : 5);
                        break;
                    case PUSH_EVT_START_VIDEO_ENCODER: //编码器启动 step4
                        if (mIvStep4 != null)
                            mIvStep4.setImageResource(R.drawable.ic_green);
                        int mode = event.getInt("EVT_PARAM1");
                        if (mode == ENCODER_HARD) { // 硬编码器1 软编码器2
                            mStep4Text = String.format("阶段四：编码器正常启动[%s]", "硬编");
                        } else {
                            mStep4Text = String.format("阶段四：编码器正常启动[%s]", "软编");
                        }
                        if (mTvEncoder != null)
                            mTvEncoder.setText(mStep4Text);
                        // 这里有可能中途切换软硬解，导致step错乱
                        mCurrentSuccessStep = (mCurrentSuccessStep != 5 ? 4 : 5);
                        break;
                    case PUSH_EVT_PUSH_BEGIN:          //已经与服务器握手完毕,开始推流 step5
                        if (mIvStep5 != null) {
                            mIvStep5.setImageResource(R.drawable.ic_green);
                        }
                        mCurrentSuccessStep = 5;
                        break;
                    case PUSH_WARNING_NET_BUSY:  //丢帧警告
                        if (mAdapter != null)
                            mAdapter.add("");
                        if (mCatonRecyclerView != null && mAdapter != null)
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
            if (mIvStep5 != null) {
                mIvStep5.setImageResource(R.drawable.ic_red);
                Log.i(TAG, "mIvStep5.setImageResource: ");
            }
            mCurrentSuccessStep = 4;
        }
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.iv_close) {
            try {
                dismissAllowingStateLoss();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public void clear() {
        if (mTvEncoder != null)
            mTvEncoder.setText("阶段四：编码器正常启动");
        if (mIvStep2 != null)
            mIvStep2.setImageResource(R.drawable.ic_red);
        if (mIvStep3 != null)
            mIvStep3.setImageResource(R.drawable.ic_red);
        if (mIvStep4 != null)
            mIvStep4.setImageResource(R.drawable.ic_red);
        if (mIvStep5 != null)
            mIvStep5.setImageResource(R.drawable.ic_red);
        if (mAdapter != null)
            mAdapter.clear();
    }
}
