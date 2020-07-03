package com.tencent.liteav.demo.livepusher.cameralivepush;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DialogFragment;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
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

import com.tencent.liteav.demo.livepusher.R;
import com.tencent.rtmp.TXLiveConstants;

@SuppressLint("LongLogTag")
public class PusherTroubleshootingFragment extends DialogFragment implements View.OnClickListener {

    private static final String TAG = "PusherTroubleshootingFragment";

    private static final int ENCODER_HARD                   = 1;
    private static final int ENCODER_SOFT                   = 2;

    public static final int CHECK_RTMP_URL_OK               = 999;
    public static final int CHECK_RTMP_URL_FAIL             = 998;
    public static final int PUSH_EVT_CONNECT_SUCC           = 1001;     // 已经连接推流服务器
    public static final int PUSH_EVT_PUSH_BEGIN             = 1002;     // 已经与服务器握手完毕,开始推流
    public static final int PUSH_EVT_OPEN_CAMERA_SUCC       = 1003;     // 打开摄像头成功
    public static final int PUSH_EVT_START_VIDEO_ENCODER    = 1008;     // 编码器启动
    public static final int PUSH_WARNING_DNS_FAIL           = 3001;     // RTMP -DNS解析失败
    public static final int PUSH_WARNING_SEVER_CONN_FAIL    = 3002;     // RTMP服务器连接失败
    public static final int PUSH_WARNING_SHAKE_FAIL         = 3003;     // RTMP服务器握手失败
    public static final int PUSH_WARNING_SERVER_DISCONNECT  = 3004;     // RTMP服务器主动断开，请检查推流地址的合法性或防盗链有效期
    public static final int PUSH_WARNING_READ_WRITE_FAIL    = 3005;     // RTMP 读/写失败。
    public static final int PUSH_WARNING_NET_BUSY           = 1101;     // 网络状况不佳:上行带宽太小

    private static final int PUSH_STEP_0 = 0;   // 阶段零：初始化阶段
    private static final int PUSH_STEP_1 = 1;   // 阶段一：检查地址合法性
    private static final int PUSH_STEP_2 = 2;   // 阶段二：连接到云服务器
    private static final int PUSH_STEP_3 = 3;   // 阶段三：摄像头打开成功
    private static final int PUSH_STEP_4 = 4;   // 阶段四：编码器正常启动
    private static final int PUSH_STEP_5 = 5;   // 阶段五：开始进入推流中


    private boolean                 mDisableLog = false;
    private int                     mQueDenoising;
    private int                     mCurrentSuccessStep = PUSH_STEP_0;            // 当前第几步已经成功
    private String                  mStep4Text = "";                    // 第四步的提示语

    private VisibleLogListAdapter   mAdapter;
    private RecyclerView            mRecyclerCaton;
    private ImageView               mImageQue;
    private ImageView               mImageStep1;
    private ImageView               mImageStep2;
    private ImageView               mImageStep3;
    private ImageView               mImageStep4;
    private ImageView               mImageStep5;
    private ImageView               mImageClose;
    private TextView                mTextSpeed;
    private TextView                mTextBrand;
    private TextView                mTextBitrate;
    private TextView                mTextEncoder;
    private TextView                mTextFpsGop;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.LivePusherRoomSettingDialog);
    }

    @Override
    public void onStart() {
        super.onStart();
        WindowManager manager = this.getActivity().getWindowManager();
        DisplayMetrics outMetrics = new DisplayMetrics();
        manager.getDefaultDisplay().getMetrics(outMetrics);
        int width = outMetrics.widthPixels;
        int height = outMetrics.heightPixels;
        if (getDialog() != null) {
            getDialog().getWindow().setLayout(width - 100, height - 300);
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view =  inflater.inflate(R.layout.livepusher_fragment_pusher_troubleshooting, container, false);
        mRecyclerCaton = (RecyclerView) view.findViewById(R.id.livepusher_recycler_view);
        mRecyclerCaton.setLayoutManager(new LinearLayoutManager(view.getContext()));
        mAdapter = new VisibleLogListAdapter(view.getContext());
        mAdapter.setType(VisibleLogListAdapter.TYPE_DROP);
        mRecyclerCaton.setAdapter(mAdapter);

        mTextFpsGop = (TextView) view.findViewById(R.id.livepusher_tv_fpsgop);
        mTextBrand = (TextView) view.findViewById(R.id.livepusher_tv_brand);
        mTextBitrate = (TextView) view.findViewById(R.id.livepusher_tv_bitrate);
        mTextSpeed = (TextView) view.findViewById(R.id.livepusher_tv_speed);
        mTextEncoder = (TextView) view.findViewById(R.id.livepusher_tv_seg4);
        mImageClose = (ImageView) view.findViewById(R.id.livepusher_iv_close);
        mImageQue = (ImageView) view.findViewById(R.id.livepusher_iv_que);
        mImageStep1 = (ImageView) view.findViewById(R.id.livepusher_iv_step1);
        mImageStep2 = (ImageView) view.findViewById(R.id.livepusher_iv_step2);
        mImageStep3 = (ImageView) view.findViewById(R.id.livepusher_iv_step3);
        mImageStep4 = (ImageView) view.findViewById(R.id.livepusher_iv_step4);
        mImageStep5 = (ImageView) view.findViewById(R.id.livepusher_iv_step5);

        mImageClose.setOnClickListener(this);
        mTextBrand.setText(getString(R.string.livepusher_device_model, Build.MODEL, Build.VERSION.RELEASE));
        mTextBitrate.setText(getString(R.string.livepusher_total_bitrate, "0"));
        mTextSpeed.setText(getString(R.string.livepusher_upload_speed, "0"));
        mTextFpsGop.setText(getString(R.string.livepusher_fps_gop, "0", "0"));
        // 这里不需要要加break
        switch (mCurrentSuccessStep) {
            case PUSH_STEP_5:
                mImageStep5.setImageResource(R.drawable.livepusher_ic_green);
            case PUSH_STEP_4:
                mImageStep4.setImageResource(R.drawable.livepusher_ic_green);
                mTextEncoder.setText(mStep4Text);
            case PUSH_STEP_3:
                mImageStep3.setImageResource(R.drawable.livepusher_ic_green);
            case PUSH_STEP_2:
                mImageStep2.setImageResource(R.drawable.livepusher_ic_green);
            case PUSH_STEP_1:
                mImageStep1.setImageResource(R.drawable.livepusher_ic_green);
        }
        return view;
    }

    public void setLogText(Bundle status, Bundle event, int eventId) {
        if (mDisableLog) {
            return;
        }
        if (eventId == TXLiveConstants.PLAY_EVT_CHANGE_ROTATION || eventId == TXLiveConstants.PLAY_EVT_GET_MESSAGE) {
            return;
        }
        if (status != null && isVisible()) {
            int vra = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE);
            int ara = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE);
            int spd = status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED);

            String totalBitrate = getStr(R.string.livepusher_total_bitrate, String.valueOf(vra + ara));
            String uploadSpeed = getStr(R.string.livepusher_upload_speed, String.valueOf(spd));

            mTextBitrate.setText(totalBitrate);
            mTextSpeed.setText(uploadSpeed);

            int fps = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS);
            int gop = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP);

            mTextFpsGop.setText(getStr(R.string.livepusher_fps_gop, String.valueOf(fps), String.valueOf(gop)));

            int queMax = gop * fps;
            int queCurrent = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE);

            if (mQueDenoising == 0) {
                mQueDenoising = queCurrent;
            } else {
                mQueDenoising = (int) (queCurrent * 1.0f / 4 + mQueDenoising * 3.0f / 4);
            }
            Log.i(TAG, "que:" + queCurrent + ",mQueDenoising:" + mQueDenoising);
            if (mQueDenoising >= 0 && mQueDenoising < 3) {
                mImageQue.setImageResource(R.drawable.livepusher_ic_que5);
            } else if (mQueDenoising > 3 && mQueDenoising <= queMax * 0.2) {
                mImageQue.setImageResource(R.drawable.livepusher_ic_que4);
            } else if (mQueDenoising > queMax * 0.2 && mQueDenoising <= queMax * 0.4) {
                mImageQue.setImageResource(R.drawable.livepusher_ic_que3);
            } else if (mQueDenoising > queMax * 0.4 && mQueDenoising <= queMax * 0.6) {
                mImageQue.setImageResource(R.drawable.livepusher_ic_que2);
            } else if (mQueDenoising > queMax * 0.6 && mQueDenoising <= queMax * 0.8) {
                mImageQue.setImageResource(R.drawable.livepusher_ic_que1);
            } else if (mQueDenoising > queMax * 0.8) {
                mImageQue.setImageResource(R.drawable.livepusher_icon_que);
            }
        }

        if (event != null) {
            String message = event.getString(TXLiveConstants.EVT_DESCRIPTION);
            if (message != null && !message.isEmpty()) {
                switch (eventId) {
                    case CHECK_RTMP_URL_OK:            //检查地址合法性 step1
                        if (mImageStep1 != null) {
                            mImageStep1.setImageResource(R.drawable.livepusher_ic_green);
                        }
                        mCurrentSuccessStep = PUSH_STEP_1;
                        break;
                    case CHECK_RTMP_URL_FAIL:
                        if (mImageStep1 != null) {
                            mImageStep1.setImageResource(R.drawable.livepusher_ic_red);
                        }
                        mCurrentSuccessStep = PUSH_STEP_0;
                        break;
                    case PUSH_EVT_CONNECT_SUCC:        //已经连接推流服务器 step2
                        if (mImageStep2 != null) {
                            mImageStep2.setImageResource(R.drawable.livepusher_ic_green);
                        }
                        mCurrentSuccessStep = PUSH_STEP_2;
                        break;
                    case PUSH_EVT_OPEN_CAMERA_SUCC:    //打开摄像头成功 step3
                        if (mImageStep3 != null) {
                            mImageStep3.setImageResource(R.drawable.livepusher_ic_green);
                        }
                        // 这里有可能中途切换摄像头，导致step错乱
                        mCurrentSuccessStep = (mCurrentSuccessStep != PUSH_STEP_5 ? PUSH_STEP_3 : PUSH_STEP_5);
                        break;
                    case PUSH_EVT_START_VIDEO_ENCODER: //编码器启动 step4
                        if (mImageStep4 != null) {
                            mImageStep4.setImageResource(R.drawable.livepusher_ic_green);
                        }
                        int mode = event.getInt(TXLiveConstants.EVT_PARAM1);
                        if (mode == ENCODER_HARD) {     // 硬编码器1 软编码器2
                            mStep4Text = String.format("阶段四：编码器正常启动[%s]", "硬编");
                            // TODO: 2020/5/12 由于调用时机问题，通过resource获取字符串可能会出错
                            // mStep4Text = getStr(R.string.livepush_step_4_hardcode);
                        } else {
                            mStep4Text = String.format("阶段四：编码器正常启动[%s]", "软编");
                            // TODO: 2020/5/12 由于调用时机问题，通过resource获取字符串可能会出错
                            // mStep4Text = getStr(R.string.livepush_step_4_softcode);
                        }
                        if (mTextEncoder != null) {
                            mTextEncoder.setText(mStep4Text);
                        }
                        // 这里有可能中途切换软硬解，导致step错乱
                        mCurrentSuccessStep = (mCurrentSuccessStep != PUSH_STEP_5 ? PUSH_STEP_4 : PUSH_STEP_5);
                        break;
                    case PUSH_EVT_PUSH_BEGIN:          //已经与服务器握手完毕,开始推流 step5
                        if (mImageStep5 != null) {
                            mImageStep5.setImageResource(R.drawable.livepusher_ic_green);
                        }
                        mCurrentSuccessStep = PUSH_STEP_5;
                        break;
                    case PUSH_WARNING_NET_BUSY:         //丢帧警告
                        if (mAdapter != null) {
                            mAdapter.add("");
                        }
                        if (mRecyclerCaton != null && mAdapter != null) {
                            mRecyclerCaton.scrollToPosition(mAdapter.getItemCount() - 1); // 自动滚到底部
                        }
                        break;
                }
            }
        }

        if (eventId < 0 || eventId == PUSH_WARNING_DNS_FAIL
                || eventId == PUSH_WARNING_SEVER_CONN_FAIL
                || eventId == PUSH_WARNING_SHAKE_FAIL
                || eventId == PUSH_WARNING_SERVER_DISCONNECT
                || eventId == PUSH_WARNING_READ_WRITE_FAIL) {
            if (mImageStep5 != null) {
                mImageStep5.setImageResource(R.drawable.livepusher_ic_red);
                Log.i(TAG, "mIvStep5.setImageResource: ");
            }
            mCurrentSuccessStep = PUSH_STEP_4;
        }
    }

    @Override
    public void onClick(View v) {
        int viewId = v.getId();
        if (viewId == R.id.livepusher_iv_close) {
            try {
                dismissAllowingStateLoss();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public void clear() {
        if (mTextEncoder != null) {
            mTextEncoder.setText(getStr(R.string.livepusher_step_4_normal));
        }
        if (mImageStep2 != null) {
            mImageStep2.setImageResource(R.drawable.livepusher_ic_red);
        }
        if (mImageStep3 != null) {
            mImageStep3.setImageResource(R.drawable.livepusher_ic_red);
        }
        if (mImageStep4 != null) {
            mImageStep4.setImageResource(R.drawable.livepusher_ic_red);
        }
        if (mImageStep5 != null) {
            mImageStep5.setImageResource(R.drawable.livepusher_ic_red);
        }
        if (mAdapter != null) {
            mAdapter.clear();
        }
    }

    private String getStr(@StringRes int resId) {
        Activity activity = getActivity();
        if (activity != null) {
            return activity.getResources().getString(resId);
        }
        return "";
    }

    private String getStr(@StringRes int resId, Object... formatArgs) {
        Activity activity = getActivity();
        if (activity != null) {
            return activity.getResources().getString(resId, formatArgs);
        }
        return "";
    }
}
