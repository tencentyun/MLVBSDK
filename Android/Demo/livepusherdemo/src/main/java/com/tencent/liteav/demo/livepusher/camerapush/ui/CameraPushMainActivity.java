package com.tencent.liteav.demo.livepusher.camerapush.ui;

import android.app.AlertDialog;
import android.app.Service;
import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.database.ContentObserver;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.support.annotation.StringRes;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.FileProvider;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.audiosettingkit.AudioEffectPanel;
import com.tencent.liteav.demo.beauty.view.BeautyPanel;
import com.tencent.liteav.demo.livepusher.R;
import com.tencent.liteav.demo.livepusher.camerapush.ui.view.LogInfoWindow;
import com.tencent.liteav.demo.livepusher.camerapush.ui.view.PusherPlayQRCodeFragment;
import com.tencent.liteav.demo.livepusher.camerapush.ui.view.PusherSettingFragment;
import com.tencent.liteav.demo.livepusher.camerapush.ui.view.PusherVideoQualityFragment;
import com.tencent.rtmp.ITXLivePushListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePushConfig;
import com.tencent.rtmp.TXLivePusher;
import com.tencent.rtmp.TXLog;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;

/**
 * 腾讯云 {@link TXLivePusher} 推流器使用参考 Demo
 * <p>
 * 有以下功能参考 ：
 * <p>
 * - 基本功能参考： 启动推流 {@link #startPush()} 与 结束推流 {@link #stopPush()} ()}
 * <p>
 * - 性能数据查看参考： {@link #onNetStatus(Bundle)}
 * <p>
 * - 处理 SDK 回调事件参考： {@link #onPushEvent(int, Bundle)}
 * <p>
 * - 美颜面板：{@link BeautyPanel}
 * <p>
 * - BGM 面板：{@link AudioEffectPanel}
 * <p>
 * - 画质选择：{@link PusherVideoQualityFragment}
 * <p>
 * - 混响、变声、码率自适应、硬件加速等使用参考： {@link PusherSettingFragment} 与 {@link PusherSettingFragment.OnSettingChangeListener}
 */
public class CameraPushMainActivity extends FragmentActivity implements ITXLivePushListener,
        PusherVideoQualityFragment.OnVideoQualityChangeListener, PusherSettingFragment.OnSettingChangeListener {

    private static final String TAG = CameraPushMainActivity.class.getSimpleName();

    private static final String PUSHER_SETTING_FRAGMENT = "push_setting_fragment";
    private static final String PUSHER_PLAY_QR_CODE_FRAGMENT = "push_play_qr_code_fragment";
    private static final String PUSHER_VIDEO_QUALITY_FRAGMENT = "push_video_quality_fragment";

    private TXPhoneStateListener     mPhoneListener;
    private ActivityRotationObserver mActivityRotationObserver;

    private TextView         mTextNetBusyTips;              // 网络繁忙Tips
    private BeautyPanel      mBeautyPanelView;              // 美颜模块pannel
    private Button           mBtnStartPush;                 // 开启推流的按钮
    private LinearLayout     mLinearBottomBar;              // 底部工具栏布局
    private AudioEffectPanel mAudioEffectPanel;             // 音效面板

    private PusherPlayQRCodeFragment   mPusherPlayQRCodeFragment;   // 拉流地址面板
    private PusherSettingFragment      mPusherSettingFragment;      // 设置面板
    private PusherVideoQualityFragment mPusherVideoQualityFragment; // 画质面板
    private LogInfoWindow              mLogInfoWindow;              // Log 信息面板

    private String mPusherURL       = "";   // 推流地址
    private String mRTMPPlayURL     = "";   // RTMP 拉流地址
    private String mFlvPlayURL      = "";   // flv 拉流地址
    private String mHlsPlayURL      = "";   // hls 拉流地址
    private String mRealtimePlayURL = "";   // 低延时拉流地址

    private int mLogClickCount = 0;

    private TXLivePusher     mLivePusher;
    private TXLivePushConfig mLivePushConfig;
    private TXCloudVideoView mPusherView;

    private Bitmap mWaterMarkBitmap;

    private boolean mIsPushing             = false;
    private boolean mIsResume              = false;
    private boolean mIsWaterMarkEnable     = true;
    private boolean mIsDebugInfo           = false;
    private boolean mIsMuteAudio           = false;
    private boolean mIsPrivateMode         = false;
    private boolean mIsLandscape           = true;
    private boolean mIsMirrorEnable        = false;
    private boolean mIsFocusEnable         = false;
    private boolean mIsZoomEnable          = false;
    private boolean mIsPureAudio           = false;
    private boolean mIsEarMonitoringEnable = false;
    private boolean mIsHWAcc               = false;
    private boolean mFrontCamera           = true;
    private boolean mIsEnableAdjustBitrate = false;
    private boolean mIsFlashLight          = false;

    private int mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
    private int mAudioChannels;
    private int mAudioSample;
    private int mQualityType;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setTheme(R.style.LivePusherBeautyTheme);
        setContentView(R.layout.livepusher_activity_live_pusher_main);
        initData();                // 初始化数据
        initFragment();            // 初始化Fragment
        initPusher();              // 初始化 SDK 推流器
        initMainView();            // 初始化一些核心的 View

        // 进入页面，自动开始推流，并且弹出推流对应的拉流地址
        startPush();
        mPusherPlayQRCodeFragment.toggle(getFragmentManager(), PUSHER_PLAY_QR_CODE_FRAGMENT);
    }

    @Override
    public void onResume() {
        super.onResume();
        resume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        pause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopPush();
        mPusherView.onDestroy();
        unInitPhoneListener();
        if (mAudioEffectPanel != null) {
            mAudioEffectPanel.unInit();
            mAudioEffectPanel = null;
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        setRotationForActivity(); // Activity 旋转
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (null != mAudioEffectPanel && mAudioEffectPanel.getVisibility() != View.GONE && ev.getRawY() < mAudioEffectPanel.getTop()) {
            mAudioEffectPanel.setVisibility(View.GONE);
            mAudioEffectPanel.hideAudioPanel();
            mLinearBottomBar.setVisibility(View.VISIBLE);
        }
        if (null != mBeautyPanelView && mBeautyPanelView.getVisibility() != View.GONE && ev.getRawY() < mBeautyPanelView.getTop()) {
            mBeautyPanelView.setVisibility(View.GONE);
            mLinearBottomBar.setVisibility(View.VISIBLE);
        }
        return super.dispatchTouchEvent(ev);
    }

    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.livepusher_ibtn_back) {
            stopPush();
            finish();
        } else if (id == R.id.livepusher_ibtn_show_log) {
            if (mLogInfoWindow.isShowing()) {
                mLogInfoWindow.dismiss();
            }
            int count = mLogClickCount % 3;
            if (count == 0) {
                mLogInfoWindow.show(view);
                showLog(false);
            } else if (count == 1) {
                showLog(true);
            } else if (count == 2) {
                showLog(false);
            }
            mLogClickCount++;
        } else if (id == R.id.livepusher_ibtn_qrcode) {
            if (mLogInfoWindow.isShowing()) {
                mLogInfoWindow.dismiss();
            }
            mPusherPlayQRCodeFragment.toggle(getFragmentManager(), PUSHER_PLAY_QR_CODE_FRAGMENT);
        } else if (id == R.id.livepusher_btn_start) {
            togglePush();
        } else if (id == R.id.livepusher_btn_switch_camera) {
            // 表明当前是前摄像头
            if (view.getTag() == null || (Boolean) view.getTag()) {
                view.setTag(false);
                view.setBackgroundResource(R.drawable.livepusher_camera_back_btn);
            } else {
                view.setTag(true);
                view.setBackgroundResource(R.drawable.livepusher_camera_front);
            }
            switchCamera();
        } else if (id == R.id.livepusher_btn_beauty) {
            if (mLogInfoWindow.isShowing()) {
                mLogInfoWindow.dismiss();
            }
            if (mBeautyPanelView.isShown()) {
                mBeautyPanelView.setVisibility(View.GONE);
                mLinearBottomBar.setVisibility(View.VISIBLE);
            } else {
                mBeautyPanelView.setVisibility(View.VISIBLE);
                mLinearBottomBar.setVisibility(View.GONE);
            }
        } else if (id == R.id.livepusher_btn_bgm) {
            if (mLogInfoWindow.isShowing()) {
                mLogInfoWindow.dismiss();
            }
            if (mAudioEffectPanel.isShown()) {
                mAudioEffectPanel.setVisibility(View.GONE);
                mAudioEffectPanel.hideAudioPanel();
                mLinearBottomBar.setVisibility(View.VISIBLE);
            } else {
                mAudioEffectPanel.setVisibility(View.VISIBLE);
                mAudioEffectPanel.showAudioPanel();
                mLinearBottomBar.setVisibility(View.GONE);
            }
        } else if (id == R.id.livepusher_btn_video_quality) {
            if (mLogInfoWindow.isShowing()) {
                mLogInfoWindow.dismiss();
            }
            mPusherVideoQualityFragment.toggle(getSupportFragmentManager(), PUSHER_VIDEO_QUALITY_FRAGMENT);
        } else if (id == R.id.livepusher_btn_setting) {
            if (mLogInfoWindow.isShowing()) {
                mLogInfoWindow.dismiss();
            }
            mPusherSettingFragment.toggle(getSupportFragmentManager(), PUSHER_SETTING_FRAGMENT);
        }
    }

    /**
     * 推流器状态回调
     *
     * @param event 事件id.id类型请参考 {@linkplain TXLiveConstants#PLAY_EVT_CONNECT_SUCC 推流事件列表}.
     * @param param
     */
    @Override
    public void onPushEvent(int event, Bundle param) {
        String msg = param.getString(TXLiveConstants.EVT_DESCRIPTION);
        String pushEventLog = getString(R.string.livepusher_receive_event) + event + ", " + msg;
        TXLog.d(TAG, pushEventLog);

        // 如果开始推流，设置了隐私模式。 需要在回调里面设置，不能直接start之后直接pause
        if (event == TXLiveConstants.PUSH_EVT_PUSH_BEGIN) {
            if (mIsPrivateMode) {
                mLivePusher.pausePusher();
            }
        }
        if (event == TXLiveConstants.PUSH_ERR_NET_DISCONNECT
                || event == TXLiveConstants.PUSH_ERR_INVALID_ADDRESS
                || event == TXLiveConstants.PUSH_ERR_OPEN_CAMERA_FAIL
                || event == TXLiveConstants.PUSH_ERR_OPEN_MIC_FAIL) {
            // 遇到以上错误，则停止推流
            stopPush();
        } else if (event == TXLiveConstants.PUSH_WARNING_HW_ACCELERATION_FAIL) {
            // 开启硬件加速失败
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_SOFTWARE);
            mLivePusher.setConfig(mLivePushConfig);
            showToast(param.getString(TXLiveConstants.EVT_DESCRIPTION));
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_RESOLUTION) {
            TXLog.d(TAG, "change resolution to " + param.getInt(TXLiveConstants.EVT_PARAM2) + ", bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_BITRATE) {
            TXLog.d(TAG, "change bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_EVT_OPEN_CAMERA_SUCC) {
            // 只有后置摄像头可以打开闪光灯，若默认需要开启闪光灯。 那么在打开摄像头成功后，才可以进行配置。 若果当前是前置，设定无效；若是后置，打开闪光灯。
            turnOnFlashLight(mIsFlashLight);
        } else if (event == TXLiveConstants.PUSH_WARNING_NET_BUSY) {
            showNetBusyTips();
        }

        mLogInfoWindow.setLogText(null, param, event);

        // Toast错误内容
        if (event < 0) {
            showToast(param.getString(TXLiveConstants.EVT_DESCRIPTION));
        }
    }

    @Override
    public void onNetStatus(Bundle status) {
        TXLog.d(TAG, "Current status, CPU:" + status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE) +
                ", RES:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT) +
                ", SPD:" + status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps" +
                ", FPS:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS) +
                ", ARA:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps" +
                ", VRA:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps");
        mLogInfoWindow.setLogText(status, null, 0);
    }

    @Override
    public void onPrivateModeChange(boolean enable) {
        setPrivateMode(enable);
        if (mIsPushing) {
            mBeautyPanelView.setMotionTmplEnable(enable);
        }
    }

    @Override
    public void onMuteChange(boolean enable) {
        setMute(enable);
    }

    @Override
    public void onHomeOrientationChange(boolean isPortrait) {
        setHomeOrientation(isPortrait);
    }

    @Override
    public void onMirrorChange(boolean enable) {
        setMirror(enable);
    }

    @Override
    public void onFlashLightChange(boolean enable) {
        turnOnFlashLight(enable);
    }

    @Override
    public void onWatermarkChange(boolean enable) {
        setWatermark(enable);
    }

    @Override
    public void onPureAudioPushChange(boolean enable) {
        enablePureAudioPush(enable);
    }

    @Override
    public void onHardwareAcceleration(boolean enable) {
        setHardwareAcceleration(enable);
    }

    @Override
    public void onTouchFocusChange(boolean enable) {
        setTouchFocus(enable);
        if (mIsPushing) {
            showToast(R.string.livepusher_pushing_start_stop_retry_push_by_focus);
        }
    }

    @Override
    public void onEnableZoomChange(boolean enable) {
        setEnableZoom(enable);
        if (mIsPushing) {
            showToast(R.string.livepusher_pushing_start_stop_retry_push);
        }
    }

    @Override
    public void onClickSnapshot() {
        snapshot();
    }

    @Override
    public void onSendMessage(String msg) {
        sendMessage(msg);
    }

    @Override
    public void onAdjustBitrateChange(boolean enable) {
        setAdjustBitrate(enable, mPusherVideoQualityFragment.getQualityType());
    }

    @Override
    public void onQualityChange(int type) {
        setQuality(mPusherSettingFragment.isAdjustBitrate(), type);
    }

    @Override
    public void onEnableAudioEarMonitoringChange(boolean enable) {
        enableAudioEarMonitoring(enable);
    }

    @Override
    public void onAudioQualityChange(int channel, int sampleRate) {
        setAudioQuality(channel, sampleRate);
    }

    private void initData() {
        Intent intent = getIntent();
        mPusherURL = intent.getStringExtra(Constants.INTENT_URL_PUSH);
        mRTMPPlayURL = intent.getStringExtra(Constants.INTENT_URL_PLAY_RTMP);
        mFlvPlayURL = intent.getStringExtra(Constants.INTENT_URL_PLAY_FLV);
        mHlsPlayURL = intent.getStringExtra(Constants.INTENT_URL_PLAY_HLS);
        mRealtimePlayURL = intent.getStringExtra(Constants.INTENT_URL_PLAY_ACC);
    }

    /**
     * 初始化 SDK 推流器
     */
    private void initPusher() {
        mPusherView = findViewById(R.id.livepusher_tx_cloud_view);

        mLivePusher = new TXLivePusher(this);
        mLivePushConfig = new TXLivePushConfig();
        mLivePushConfig.setVideoEncodeGop(5);
        mLivePusher.setConfig(mLivePushConfig);
        // 设置默认美颜参数， 美颜样式为光滑，美颜等级 5，美白等级 3，红润等级 2
        mLivePusher.setBeautyFilter(TXLiveConstants.BEAUTY_STYLE_SMOOTH, 5, 3, 2);

        mWaterMarkBitmap = decodeResource(getResources(), R.drawable.livepusher_watermark);
        initListener();

        setMute(mPusherSettingFragment.isMute());
        setMirror(mPusherSettingFragment.isMirror());
        setWatermark(mPusherSettingFragment.isWatermark());
        setTouchFocus(mPusherSettingFragment.isTouchFocus());
        setEnableZoom(mPusherSettingFragment.isEnableZoom());
        enablePureAudioPush(mPusherSettingFragment.enablePureAudioPush());
        enableAudioEarMonitoring(mPusherSettingFragment.enableAudioEarMonitoring());
        setQuality(mPusherSettingFragment.isAdjustBitrate(), mPusherVideoQualityFragment.getQualityType());
        setAudioQuality(mPusherSettingFragment.getAudioChannels(), mPusherSettingFragment.getAudioSampleRate());
        setHomeOrientation(mPusherSettingFragment.isLandscape());
        turnOnFlashLight(mPusherSettingFragment.isFlashEnable());
        setHardwareAcceleration(mPusherSettingFragment.isHardwareAcceleration());
    }

    /**
     * 初始化两个配置的 Fragment
     */
    private void initFragment() {
        if (mPusherSettingFragment == null) {
            mPusherSettingFragment = new PusherSettingFragment();
            mPusherSettingFragment.loadConfig(this);
            mPusherSettingFragment.setOnSettingChangeListener(this);
        }
        if (mPusherPlayQRCodeFragment == null) {
            mPusherPlayQRCodeFragment = new PusherPlayQRCodeFragment();
            mPusherPlayQRCodeFragment.setQRCodeURL(mFlvPlayURL, mRTMPPlayURL, mHlsPlayURL, mRealtimePlayURL);
        }
        if (mPusherVideoQualityFragment == null) {
            mPusherVideoQualityFragment = new PusherVideoQualityFragment();
            mPusherVideoQualityFragment.loadConfig(this);
            mPusherVideoQualityFragment.setOnVideoQualityChangeListener(this);
        }
        if (mLogInfoWindow == null) {
            mLogInfoWindow = new LogInfoWindow(this);
        }
    }

    /**
     * 初始化 美颜、log、二维码 等 view
     */
    private void initMainView() {
        mBtnStartPush = findViewById(R.id.livepusher_btn_start);
        mBeautyPanelView = findViewById(R.id.livepusher_bp_beauty_pannel);
        mTextNetBusyTips = findViewById(R.id.livepusher_tv_net_error_warning);
        mLinearBottomBar = findViewById(R.id.livepusher_ll_bottom_bar);

        mAudioEffectPanel = findViewById(R.id.livepusher_audio_panel);
        mAudioEffectPanel.setAudioEffectManager(mLivePusher.getAudioEffectManager());
        mAudioEffectPanel.setBackgroundColor(0xff13233F);
        mAudioEffectPanel.setOnAudioEffectPanelHideListener(new AudioEffectPanel.OnAudioEffectPanelHideListener() {
            @Override
            public void onClosePanel() {
                mAudioEffectPanel.setVisibility(View.GONE);
                mLinearBottomBar.setVisibility(View.VISIBLE);
            }
        });

        mBeautyPanelView.setBeautyManager(mLivePusher.getBeautyManager());
        mBeautyPanelView.setOnBeautyListener(new BeautyPanel.OnBeautyListener() {
            @Override
            public boolean onClose() {
                mBeautyPanelView.setVisibility(View.GONE);
                mLinearBottomBar.setVisibility(View.VISIBLE);
                return true;
            }
        });
    }

    /**
     * 显示网络繁忙的提示
     */
    private void showNetBusyTips() {
        if (mTextNetBusyTips.isShown()) {
            return;
        }
        mTextNetBusyTips.setVisibility(View.VISIBLE);
        mTextNetBusyTips.postDelayed(new Runnable() {
            @Override
            public void run() {
                mTextNetBusyTips.setVisibility(View.GONE);
            }
        }, 5000);
    }

    private Uri getUri(File file) {
        Uri uri;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            uri = FileProvider.getUriForFile(this, "com.tencent.liteav.demo", file);
        } else {
            uri = Uri.fromFile(file);
        }
        return uri;
    }


    /**
     * 判断系统 "自动旋转" 设置功能是否打开
     *
     * @return false---Activity可根据重力感应自动旋转
     */
    private boolean isActivityCanRotation() {
        int flag = Settings.System.getInt(getContentResolver(), Settings.System.ACCELEROMETER_ROTATION, 0);
        return flag != 0;
    }

    private void showToast(final @StringRes int resId) {
        showToast(getString(resId));
    }

    private void showToast(final String text) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            Toast.makeText(this, text, Toast.LENGTH_SHORT).show();
        } else {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(CameraPushMainActivity.this, text, Toast.LENGTH_SHORT).show();
                }
            });
        }
    }

    private void onPushStart(int code) {
        TXLog.d(TAG, "onPusherStart: code -> " + code);
        switch (code) {
            case Constants.PLAY_STATUS_SUCCESS:
                mBtnStartPush.setBackgroundResource(R.drawable.livepusher_pause);
                break;
            case Constants.PLAY_STATUS_INVALID_URL:
                showToast(R.string.livepusher_url_illegal);
                // 输出状态log
                Bundle params = new Bundle();
                params.putString(TXLiveConstants.EVT_DESCRIPTION, getString(R.string.livepusher_check_url));
                mLogInfoWindow.setLogText(null, params, LogInfoWindow.CHECK_RTMP_URL_FAIL);
                break;
            case Constants.PLAY_STATUS_LICENSE_ERROR:
                String errInfo = getString(R.string.livepusher_license_check_fail);
                int start = (errInfo + getString(R.string.livepusher_license_click_info)).length();
                int end = (errInfo + getString(R.string.livepusher_license_click_use_info)).length();
                SpannableStringBuilder spannableStrBuidler = new SpannableStringBuilder(errInfo + getString(R.string.livepusher_license_click_use_info));
                ClickableSpan clickableSpan = new ClickableSpan() {
                    @Override
                    public void onClick(View view) {
                        Intent intent = new Intent();
                        intent.setAction("android.intent.action.VIEW");
                        Uri content_url = Uri.parse("https://cloud.tencent.com/document/product/454/34750");
                        intent.setData(content_url);
                        startActivity(intent);
                    }
                };
                spannableStrBuidler.setSpan(new ForegroundColorSpan(Color.BLUE), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                spannableStrBuidler.setSpan(clickableSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                TextView tv = new TextView(this);
                tv.setMovementMethod(LinkMovementMethod.getInstance());
                tv.setText(spannableStrBuidler);
                tv.setPadding(20, 0, 20, 0);
                AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(this);
                dialogBuilder.setTitle(getString(R.string.livepusher_push_fail)).setView(tv).setPositiveButton(getString(R.string.livepusher_comfirm), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        stopPush();
                    }
                });
                dialogBuilder.show();
            default:
                break;
        }
        if (code != Constants.PLAY_STATUS_INVALID_URL) {
            // 输出状态log
            Bundle bundle = new Bundle();
            bundle.putString(TXLiveConstants.EVT_DESCRIPTION, getString(R.string.livepusher_check_url));
            mLogInfoWindow.setLogText(null, bundle, LogInfoWindow.CHECK_RTMP_URL_OK);
        }
    }

    /**
     * 获取当前推流状态
     *
     * @param status
     * @return
     */
    private String getStatus(Bundle status) {
        String str = String.format("%-14s %-14s %-12s\n%-8s %-8s %-8s %-8s\n%-14s %-14s %-12s\n%-14s %-14s",
                "CPU:" + status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE),
                "RES:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT),
                "SPD:" + status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps",
                "JIT:" + status.getInt(TXLiveConstants.NET_STATUS_NET_JITTER),
                "FPS:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS),
                "GOP:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP) + "s",
                "ARA:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps",
                "QUE:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE) + "|" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE),
                "DRP:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_DROP) + "|" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_DROP),
                "VRA:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps",
                "SVR:" + status.getString(TXLiveConstants.NET_STATUS_SERVER_IP),
                "AUDIO:" + status.getString(TXLiveConstants.NET_STATUS_AUDIO_INFO));
        return str;
    }

    private void startPush() {
        int resultCode = Constants.PLAY_STATUS_SUCCESS;
        String tRTMPURL = "";
        if (!TextUtils.isEmpty(mPusherURL)) {
            String url[] = mPusherURL.split("###");
            if (url.length > 0) {
                tRTMPURL = url[0];
            }
        }

        if (TextUtils.isEmpty(tRTMPURL) || (!tRTMPURL.trim().toLowerCase().startsWith("rtmp://"))) {
            resultCode = Constants.PLAY_STATUS_INVALID_URL;
        } else {
            // 显示本地预览的View
            mPusherView.setVisibility(View.VISIBLE);
            // 添加播放回调
            mLivePusher.setPushListener(this);
            // 添加后台垫片推流参数
            Bitmap bitmap = decodeResource(getResources(), R.drawable.livepusher_pause_publish);
            mLivePushConfig.setPauseImg(bitmap);
            mLivePushConfig.setPauseImg(300, 5);
            mLivePushConfig.setPauseFlag(TXLiveConstants.PAUSE_FLAG_PAUSE_VIDEO);// 设置暂停时，只停止画面采集，不停止声音采集。

            // 设置推流分辨率
            mLivePushConfig.setVideoResolution(mVideoResolution);

            // 如果当前Activity可以自动旋转的话，那么需要进行设置
            if (isActivityCanRotation()) {
                setRotationForActivity();
            }
            // 开启麦克风推流相关
            mLivePusher.setMute(mIsMuteAudio);

            // 横竖屏推流相关
            int renderRotation = 0;
            if (mIsLandscape) {
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT);
                renderRotation = 90; // 因为采集旋转了，那么保证本地渲染是正的，则设置渲染角度为90度。
            } else {
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
                renderRotation = 0;
            }
            mLivePusher.setRenderRotation(renderRotation);

            // 是否开启观众端镜像观看
            mLivePusher.setMirror(mIsMirrorEnable);
            // 是否打开调试信息
            mPusherView.showLog(mIsDebugInfo);

            // 是否添加水印
            if (mIsWaterMarkEnable) {
                mLivePushConfig.setWatermark(mWaterMarkBitmap, 0.02f, 0.05f, 0.2f);
            } else {
                mLivePushConfig.setWatermark(null, 0, 0, 0);
            }

            // 是否打开曝光对焦
            mLivePushConfig.setTouchFocus(mIsFocusEnable);
            // 是否打开手势放大预览画面
            mLivePushConfig.setEnableZoom(mIsZoomEnable);
            mLivePushConfig.enablePureAudioPush(mIsPureAudio);
            mLivePushConfig.enableAudioEarMonitoring(mIsEarMonitoringEnable);
            // 设置推流配置
            mLivePusher.setConfig(mLivePushConfig);
            // 设置场景
            setPushScene(mQualityType, mIsEnableAdjustBitrate);

            // 设置声道，必须在 TXLivePusher.setVideoQuality 之后，TXLivePusher.startPusher之前设置才能生效
            mLivePushConfig.setAudioChannels(mAudioChannels);
            // 设置音频采样率，必须在 TXLivePusher.setVideoQuality 之后，TXLivePusher.startPusher之前设置才能生效
            mLivePushConfig.setAudioSampleRate(mAudioSample);
            mLivePusher.setConfig(mLivePushConfig);

            // 设置本地预览View
            mLivePusher.startCameraPreview(mPusherView);
            if (!mFrontCamera) mLivePusher.switchCamera();
            // 发起推流
            resultCode = mLivePusher.startPusher(tRTMPURL.trim());

            mIsPushing = true;
        }
        TXLog.i(TAG, "start: mIsResume -> " + mIsResume);
        onPushStart(resultCode);
    }

    private void stopPush() {
        if (!mIsPushing) {
            return;
        }
        // 停止本地预览
        mLivePusher.stopCameraPreview(true);
        // 移除监听
        mLivePusher.setPushListener(null);
        // 停止推流
        mLivePusher.stopPusher();
        // 隐藏本地预览的View
        mPusherView.setVisibility(View.GONE);
        // 移除垫片图像
        mLivePushConfig.setPauseImg(null);
        mIsPrivateMode = false;
        mIsPushing = false;
        if (mPusherSettingFragment != null) {
            mPusherSettingFragment.closePrivateModel();
        }
        mBtnStartPush.setBackgroundResource(R.drawable.livepusher_start);
        mLogInfoWindow.reset();
        mAudioEffectPanel.reset();
    }

    private void togglePush() {
        if (mIsPushing) {
            stopPush();
        } else {
            startPush();
        }
    }

    private void resume() {
        TXLog.i(TAG, "resume: mIsResume -> " + mIsResume);
        if (mIsResume) {
            return;
        }
        if (mPusherView != null) {
            mPusherView.onResume();
        }
        if (mIsPushing && mLivePusher != null) {
            // 如果当前是隐私模式，那么不resume
            if (!mIsPrivateMode) {
                mLivePusher.resumePusher();
            }
        }
        mIsResume = true;
        mAudioEffectPanel.resumeBGM();
    }

    private void pause() {
        TXLog.i(TAG, "pause: mIsResume -> " + mIsResume);
        if (mPusherView != null) {
            mPusherView.onPause();
        }
        if (mIsPushing && mLivePusher != null) {
            // 如果当前已经是隐私模式，那么则不pause
            if (!mIsPrivateMode) {
                mLivePusher.pausePusher();
            }
        }
        mIsResume = false;
        mAudioEffectPanel.pauseBGM();
    }

    private void switchCamera() {
        mFrontCamera = !mFrontCamera;
        mLivePusher.switchCamera();
    }

    private void setHomeOrientation(boolean isLandscape) {
        mIsLandscape = isLandscape;
        int renderRotation;
        if (isLandscape) {  // 横屏
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT);
            renderRotation = 90; // 因为采集旋转了，那么保证本地渲染是正的，则设置渲染角度为90度。
        } else {            // 竖屏
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
            renderRotation = 0;
        }
        if (mLivePusher.isPushing()) {
            mLivePusher.setConfig(mLivePushConfig);
            mLivePusher.setRenderRotation(renderRotation);
        }
    }

    private void setPrivateMode(boolean enable) {
        mIsPrivateMode = enable;
        // 隐私模式下，会进入垫片推流
        if (mIsPushing) {
            if (enable) {
                mLivePusher.pausePusher();
            } else {
                mLivePusher.resumePusher();
            }
        }
    }

    private void setMute(boolean enable) {
        mIsMuteAudio = enable;
        mLivePusher.setMute(enable);
    }

    private void setMirror(boolean enable) {
        mIsMirrorEnable = enable;
        mLivePusher.setMirror(enable);
    }

    private void turnOnFlashLight(boolean enable) {
        mIsFlashLight = enable;
        mLivePusher.turnOnFlashLight(enable);
    }

    private void showLog(boolean enable) {
        mIsDebugInfo = enable;
        mPusherView.showLog(enable);
    }

    private void setWatermark(boolean enable) {
        mIsWaterMarkEnable = enable;
        if (enable) {
            mLivePushConfig.setWatermark(mWaterMarkBitmap, 0.02f, 0.05f, 0.2f);
        } else {
            mLivePushConfig.setWatermark(null, 0, 0, 0);
        }
        if (mLivePusher.isPushing()) {
            // 水印变更不需要重启推流，直接应用配置项即可
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    private void setTouchFocus(boolean enable) {
        mIsFocusEnable = enable;
        mLivePushConfig.setTouchFocus(enable);
        if (mLivePusher.isPushing()) {
            stopPush();
            startPush();
        }
    }

    private void setEnableZoom(boolean enable) {
        mIsZoomEnable = enable;
        mLivePushConfig.setEnableZoom(enable);
        if (mLivePusher.isPushing()) {
            stopPush();
            startPush();
        }
    }

    private void snapshot() {
        mLivePusher.snapshot(new TXLivePusher.ITXSnapshotListener() {
            @Override
            public void onSnapshot(Bitmap bitmap) {
                if (mLivePusher.isPushing()) {
                    if (bitmap != null) {
                        saveSnapshotBitmap(bitmap);
                    } else {
                        showToast(R.string.livepusher_screenshot_fail);
                    }
                } else {
                    showToast(R.string.livepusher_screenshot_fail_push);
                }
            }
        });
    }

    private void sendMessage(String msg) {
        mLivePusher.sendMessage(msg.getBytes());
    }

    private void setHardwareAcceleration(boolean enable) {
        mIsHWAcc = enable;
        if (enable) {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_HARDWARE); // 启动硬编
        } else {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_SOFTWARE); // 启动软编
        }
        if (mLivePusher.isPushing()) {
            // 硬件加速变更不需要重启推流，直接应用配置项即可
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    private void setAdjustBitrate(boolean enable, int qualityType) {
        mIsEnableAdjustBitrate = enable;
        setPushScene(qualityType, enable);
    }

    private void setQuality(boolean enable, int type) {
        setPushScene(type, enable);
    }

    private void enableAudioEarMonitoring(boolean enable) {
        mIsEarMonitoringEnable = enable;
        if (mLivePusher != null) {
            TXLivePushConfig config = mLivePusher.getConfig();
            config.enableAudioEarMonitoring(enable);
            mLivePusher.setConfig(config);
        }
    }

    private void enablePureAudioPush(boolean enable) {
        mIsPureAudio = enable;
    }

    private void setAudioQuality(int channel, int sampleRate) {
        mAudioChannels = channel;
        mAudioSample = sampleRate;
        if (mLivePusher != null) {
            TXLivePushConfig config = mLivePusher.getConfig();
            config.setAudioChannels(channel);
            config.setAudioSampleRate(sampleRate);
            mLivePusher.setConfig(config);
        }
    }

    /**
     * 根据当前 Activity 的旋转方向，配置推流器
     */
    private void setRotationForActivity() {
        // 自动旋转打开，Activity随手机方向旋转之后，需要改变推流方向
        int mobileRotation = getWindowManager().getDefaultDisplay().getRotation();
        int pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
        switch (mobileRotation) {
            case Surface.ROTATION_0:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
                break;
            case Surface.ROTATION_180:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_UP;
                break;
            case Surface.ROTATION_90:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT;
                break;
            case Surface.ROTATION_270:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_LEFT;
                break;
            default:
                break;
        }

        mLivePusher.setRenderRotation(0);                                   // 因为activity也旋转了，本地渲染相对正方向的角度为0。
        mLivePushConfig.setHomeOrientation(pushRotation);                   // 根据Activity方向，设置采集角度

        if (mLivePusher.isPushing()) {                                      // 当前正在推流，
            mLivePusher.setConfig(mLivePushConfig);
            if (!mIsPrivateMode) {                       // 不是隐私模式，则开启摄像头推流。
                mLivePusher.stopCameraPreview(true);
                mLivePusher.startCameraPreview(mPusherView);
            }
        }
    }

    /**
     * 设置推流场景
     * <p>
     * SDK 内部将根据具体场景，进行推流 分辨率、码率、FPS、是否启动硬件加速、是否启动回声消除 等进行配置
     * <p>
     * 适用于一般客户，方便快速进行配置
     * <p>
     * 专业客户，推荐通过 {@link TXLivePushConfig} 进行逐一配置
     */
    private void setPushScene(int type, boolean enableAdjustBitrate) {
        TXLog.i(TAG, "setPushScene: type = " + type + " enableAdjustBitrate = " + enableAdjustBitrate);
        mQualityType = type;
        mIsEnableAdjustBitrate = enableAdjustBitrate;
        // 码率、分辨率自适应都关闭
        boolean autoResolution = false;
        switch (type) {
            case TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION:     // 360P
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION:         // 540P
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION:        // 720p
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_ULTRA_DEFINITION:        // 1080p
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_ULTRA_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_1080_1920;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER:  //连麦大主播
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER:   //连麦小主播
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_320_480;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT:      //实时
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                }
                break;
            default:
                break;
        }
        // 设置场景化配置后，SDK 内部会根据场景自动选择相关的配置参数，所以我们这里把内部的config获取出来，赋值到外部。
        mLivePushConfig = mLivePusher.getConfig();

        // 是否开启硬件加速
        if (mIsHWAcc) {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_HARDWARE);
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    /**
     * 初始化电话监听、系统是否打开旋转监听
     */
    private void initListener() {
        mPhoneListener = new TXPhoneStateListener();
        TelephonyManager tm = (TelephonyManager) getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);
        mActivityRotationObserver = new ActivityRotationObserver(new Handler(Looper.getMainLooper()));
        mActivityRotationObserver.startObserver();
    }

    /**
     * 销毁
     */
    private void unInitPhoneListener() {
        TelephonyManager tm = (TelephonyManager) getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_NONE);
        mActivityRotationObserver.stopObserver();
    }

    /**
     * 获取资源图片
     *
     * @param resources
     * @param id
     * @return
     */
    private Bitmap decodeResource(Resources resources, int id) {
        TypedValue value = new TypedValue();
        resources.openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(resources, id, opts);
    }

    /**
     * 保存并分享图片
     *
     * @param bmp
     */
    private void saveSnapshotBitmap(final Bitmap bmp) {
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                String bitmapFileName = UUID.randomUUID().toString();//通过UUID生成字符串文件名
                FileOutputStream out = null;
                File sdcardDir = getExternalFilesDir(null);
                if (sdcardDir == null) {
                    TXLog.e(TAG, "sdcardDir is null");
                    return;
                }
                final String path = sdcardDir + File.separator + bitmapFileName + ".png";
                final File file = new File(path);
                try {
                    file.getParentFile().mkdirs();
                    if (!file.exists()) {
                        file.createNewFile();
                    }
                    out = new FileOutputStream(file);
                    bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (out != null) {
                            out.flush();
                            out.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                if (file.exists() && file.length() > 0) {
                    showToast(R.string.livepusher_screenshot_success);
                    Intent intent = new Intent();
                    intent.setAction(Intent.ACTION_SEND);//设置分享行为
                    Uri uri = getUri(file);
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    intent.setType("image/*");
                    intent.putExtra(Intent.EXTRA_STREAM, uri);
                    startActivity(Intent.createChooser(intent, getString(R.string.livepusher_share_pic)));
                } else {
                    showToast(R.string.livepusher_screenshot_fail);
                }
            }
        });
    }

    /**
     * 电话监听
     */
    private class TXPhoneStateListener extends PhoneStateListener {

        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            TXLog.i(TAG, "onCallStateChanged: state -> " + state);
            switch (state) {
                case TelephonyManager.CALL_STATE_RINGING:   //电话等待接听
                case TelephonyManager.CALL_STATE_OFFHOOK:   //电话接听
                    pause();
                    break;
                case TelephonyManager.CALL_STATE_IDLE:      //电话挂机
                    resume();
                    break;
            }
        }
    }

    /**
     * 观察屏幕旋转设置变化
     */
    private class ActivityRotationObserver extends ContentObserver {
        ContentResolver mResolver;

        public ActivityRotationObserver(Handler handler) {
            super(handler);
            mResolver = getContentResolver();
        }

        //屏幕旋转设置改变时调用
        @Override
        public void onChange(boolean selfChange) {
            super.onChange(selfChange);
            if (isActivityCanRotation()) {
                setRotationForActivity();
            } else {
                // 恢复到正方向
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
                // 恢复渲染角度
                mLivePusher.setRenderRotation(0);
                if (mLivePusher.isPushing()) {
                    mLivePusher.setConfig(mLivePushConfig);
                }
            }
            if (isActivityCanRotation()) {
                mPusherSettingFragment.hideOrientationItem();
            } else {
                mPusherSettingFragment.showOrientationItem();
            }
        }

        public void startObserver() {
            mResolver.registerContentObserver(Settings.System.getUriFor(Settings.System.ACCELEROMETER_ROTATION), false, this);
        }

        public void stopObserver() {
            mResolver.unregisterContentObserver(this);
        }
    }
}
