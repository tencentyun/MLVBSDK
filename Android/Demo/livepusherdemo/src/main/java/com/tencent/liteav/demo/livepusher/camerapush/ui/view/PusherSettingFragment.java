package com.tencent.liteav.demo.livepusher.camerapush.ui.view;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.BottomSheetDialog;
import android.support.design.widget.BottomSheetDialogFragment;
import android.support.design.widget.CoordinatorLayout;
import android.support.v4.app.FragmentManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;

import com.tencent.liteav.demo.livepusher.R;

/**
 * 设置面板，包括硬件加速、耳返、静音、横屏推流等开关设置
 */
public class PusherSettingFragment extends BottomSheetDialogFragment implements View.OnClickListener {

    private static final String TAG = "PusherSettingFragment";

    private static final int POSITION_ADJUST_BITRATE        = 0;
    private static final int POSITION_HW_ACC                = 1;
    private static final int POSITION_EAR_MONITORING_ENABLE = 2;
    private static final int POSITION_PRIVATE_MODEL         = 3;
    private static final int POSITION_MUTE_AUDIO            = 4;
    private static final int POSITION_LANDSCAPE             = 5;
    private static final int POSITION_WATER_MARK_ENABLE     = 6;
    private static final int POSITION_PURE_AUDIO            = 7;
    private static final int POSITION_MIRROR_ENABLE         = 8;
    private static final int POSITION_FLASH_ENABLE          = 9;
    private static final int POSITION_FOCUS_ENABLE          = 10;
    private static final int POSITION_ZOOM_ENABLE           = 11;

    /**
     * SharePreferences 用于存储相关配置的key
     */
    private static final String SP_NAME               = "sp_pusher_setting";
    private static final String SP_KEY_ADJUST_BITRATE = "sp_key_adjust_bitrate";
    private static final String SP_KEY_HW_ACC         = "sp_key_hw_acc";
    private static final String SP_KEY_EAR_MONITORING = "sp_key_ear_monitoring";
    private static final String SP_KEY_MUTE_AUDIO     = "sp_key_mute_audio";
    private static final String SP_KEY_LANDSCAPE      = "sp_key_portrait";
    private static final String SP_KEY_WATER_MARK     = "sp_key_water_mark";
    private static final String SP_KEY_PURE_AUDIO     = "sp_key_pure_audio";
    private static final String SP_KEY_MIRROR         = "sp_key_mirror";
    private static final String SP_KEY_FLASH_LIGHT    = "sp_key_flash_light";
    private static final String SP_KEY_FOCUS          = "sp_key_focus";
    private static final String SP_KEY_ZOOM           = "sp_key_zoom";
    private static final String SP_KEY_AUDIO_QUALITY  = "sp_key_audio_quality";

    private static final int AUDIO_SPEECH  = 0;    // 语音(speech)
    private static final int AUDIO_DEFAULT = 1;    // 标准(default)
    private static final int AUDIO_MUSIC   = 2;    // 音乐(music)

    private static final int AUDIO_CHANNEL_ONE = 1;    // 单声道
    private static final int AUDIO_CHANNEL_TWO = 2;    // 双声道

    private static final int AUDIO_SAMPLE_RATE_16000 = 16000;// 音频采样率，16000
    private static final int AUDIO_SAMPLE_RATE_48000 = 48000;// 音频采样率，48000


    private BottomSheetBehavior     mBehavior;
    private OnSettingChangeListener mOnSettingChangeListener;
    private BottomSheetDialog       mBottomSheetDialog;
    private CheckSelectView         mCheckSelectView;
    private EditText                mEditMessage;
    private RadioButton[]           mRadioAudioQuality = new RadioButton[3];

    private boolean[] mEnables = new boolean[12];

    private int mAudioQualityIndex = 2;

    public PusherSettingFragment() {
        initialize();
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = (BottomSheetDialog) super.onCreateDialog(savedInstanceState);
            View inflate = View.inflate(getActivity(), R.layout.livepusher_fragment_setting, null);
            initViews(inflate);
            mBottomSheetDialog.setContentView(inflate);
            mBottomSheetDialog.getWindow().findViewById(R.id.design_bottom_sheet)
                    .setBackgroundResource(android.R.color.transparent);
            mBehavior = BottomSheetBehavior.from((View) inflate.getParent());

            View parent = (View) inflate.getParent();
            BottomSheetBehavior behavior = BottomSheetBehavior.from(parent);
            inflate.measure(0, 0);
            behavior.setPeekHeight(inflate.getMeasuredHeight());
            CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams) parent.getLayoutParams();
            params.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
            parent.setLayoutParams(params);
            mBottomSheetDialog.show();
        }
        return mBottomSheetDialog;
    }

    private void initViews(View view) {
        mEditMessage = (EditText) view.findViewById(R.id.livepusher_et_message);
        mRadioAudioQuality[0] = (RadioButton) view.findViewById(R.id.livepusher_rb_audio_quality_speech);
        mRadioAudioQuality[0].setText(getString(R.string.livepusher_audio_quality_speech));
        mRadioAudioQuality[0].setImageToTextWidth(dip2px(6));
        mRadioAudioQuality[0].setOnClickListener(this);
        mRadioAudioQuality[1] = (RadioButton) view.findViewById(R.id.livepusher_rb_audio_quality_default);
        mRadioAudioQuality[1].setText(getString(R.string.livepusher_audio_quality_default));
        mRadioAudioQuality[1].setImageToTextWidth(dip2px(6));
        mRadioAudioQuality[1].setOnClickListener(this);
        mRadioAudioQuality[2] = (RadioButton) view.findViewById(R.id.livepusher_rb_audio_quality_music);
        mRadioAudioQuality[2].setText(getString(R.string.livepusher_audio_quality_music));
        mRadioAudioQuality[2].setImageToTextWidth(dip2px(6));
        mRadioAudioQuality[2].setOnClickListener(this);
        mRadioAudioQuality[mAudioQualityIndex].setChecked(true);
        view.findViewById(R.id.livepusher_btn_send_message).setOnClickListener(this);
        view.findViewById(R.id.livepusher_btn_close).setOnClickListener(this);
        view.findViewById(R.id.livepusher_btn_snapshot).setOnClickListener(this);

        mCheckSelectView = (CheckSelectView) view.findViewById(R.id.livepusher_ctv_setting_check);
        mCheckSelectView.setData(getResources().getStringArray(R.array.livepusher_setting), mEnables);
        mCheckSelectView.setCheckSelectListener(new CheckSelectView.CheckSelectListener() {
            @Override
            public void onChecked(int position, boolean enable) {
                Log.i(TAG, "onChecked: position -> " + position + ", enable -> " + enable);
                mEnables[position] = enable;
                if (mOnSettingChangeListener == null) {
                    return;
                }
                switch (position) {
                    case POSITION_ADJUST_BITRATE:
                        mOnSettingChangeListener.onAdjustBitrateChange(enable);
                        break;
                    case POSITION_HW_ACC:
                        mOnSettingChangeListener.onHardwareAcceleration(enable);
                        break;
                    case POSITION_EAR_MONITORING_ENABLE:
                        mOnSettingChangeListener.onEnableAudioEarMonitoringChange(enable);
                        break;
                    case POSITION_PRIVATE_MODEL:
                        mOnSettingChangeListener.onPrivateModeChange(enable);
                        break;
                    case POSITION_MUTE_AUDIO:
                        mOnSettingChangeListener.onMuteChange(enable);
                        break;
                    case POSITION_LANDSCAPE:
                        mOnSettingChangeListener.onHomeOrientationChange(enable);
                        break;
                    case POSITION_WATER_MARK_ENABLE:
                        mOnSettingChangeListener.onWatermarkChange(enable);
                        break;
                    case POSITION_PURE_AUDIO:
                        mOnSettingChangeListener.onPureAudioPushChange(enable);
                        break;
                    case POSITION_MIRROR_ENABLE:
                        mOnSettingChangeListener.onMirrorChange(enable);
                        break;
                    case POSITION_FLASH_ENABLE:
                        mOnSettingChangeListener.onFlashLightChange(enable);
                        break;
                    case POSITION_FOCUS_ENABLE:
                        mOnSettingChangeListener.onTouchFocusChange(enable);
                        break;
                    case POSITION_ZOOM_ENABLE:
                        mOnSettingChangeListener.onEnableZoomChange(enable);
                        break;
                }
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        mBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
    }

    @Override
    public void onResume() {
        super.onResume();
        mCheckSelectView.setChecked(POSITION_LANDSCAPE, mEnables[POSITION_LANDSCAPE]);
        mCheckSelectView.setChecked(POSITION_PRIVATE_MODEL, mEnables[POSITION_PRIVATE_MODEL]);
    }

    @Override
    public void onPause() {
        super.onPause();
        saveConfigIntoSp();
    }

    private void initialize() {
        mEnables[POSITION_ADJUST_BITRATE] = true;
        mEnables[POSITION_HW_ACC] = true;
        mEnables[POSITION_WATER_MARK_ENABLE] = true;
        mEnables[POSITION_FOCUS_ENABLE] = true;
    }

    private void onAudioChannelChange(int channel, int sampleRate) {
        if (mOnSettingChangeListener != null) {
            mOnSettingChangeListener.onAudioQualityChange(channel, sampleRate);
        }
    }

    /**
     * 保存配置到 SharePreferences
     */
    private void saveConfigIntoSp() {
        Activity activity = getActivity();
        if (activity != null) {
            activity.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE)
                    .edit()
                    .putBoolean(SP_KEY_ADJUST_BITRATE, mEnables[POSITION_ADJUST_BITRATE])
                    .putBoolean(SP_KEY_HW_ACC, mEnables[POSITION_HW_ACC])
                    .putBoolean(SP_KEY_EAR_MONITORING, mEnables[POSITION_EAR_MONITORING_ENABLE])
                    .putBoolean(SP_KEY_MUTE_AUDIO, mEnables[POSITION_MUTE_AUDIO])
                    .putBoolean(SP_KEY_LANDSCAPE, mEnables[POSITION_LANDSCAPE])
                    .putBoolean(SP_KEY_WATER_MARK, mEnables[POSITION_WATER_MARK_ENABLE])
                    .putBoolean(SP_KEY_PURE_AUDIO, mEnables[POSITION_PURE_AUDIO])
                    .putBoolean(SP_KEY_MIRROR, mEnables[POSITION_MIRROR_ENABLE])
                    .putBoolean(SP_KEY_FLASH_LIGHT, mEnables[POSITION_FLASH_ENABLE])
                    .putBoolean(SP_KEY_FOCUS, mEnables[POSITION_FOCUS_ENABLE])
                    .putBoolean(SP_KEY_ZOOM, mEnables[POSITION_ZOOM_ENABLE])
                    .putInt(SP_KEY_AUDIO_QUALITY, mAudioQualityIndex)
                    .apply();
        }
    }

    public void loadConfig(Context context) {
        SharedPreferences s = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        mEnables[POSITION_ADJUST_BITRATE] = s.getBoolean(SP_KEY_ADJUST_BITRATE, mEnables[POSITION_ADJUST_BITRATE]);
        mEnables[POSITION_HW_ACC] = s.getBoolean(SP_KEY_HW_ACC, mEnables[POSITION_HW_ACC]);
        mEnables[POSITION_EAR_MONITORING_ENABLE] = s.getBoolean(SP_KEY_EAR_MONITORING, mEnables[POSITION_EAR_MONITORING_ENABLE]);
        mEnables[POSITION_MUTE_AUDIO] = s.getBoolean(SP_KEY_MUTE_AUDIO, mEnables[POSITION_MUTE_AUDIO]);
        mEnables[POSITION_LANDSCAPE] = s.getBoolean(SP_KEY_LANDSCAPE, mEnables[POSITION_LANDSCAPE]);
        mEnables[POSITION_WATER_MARK_ENABLE] = s.getBoolean(SP_KEY_WATER_MARK, mEnables[POSITION_WATER_MARK_ENABLE]);
        mEnables[POSITION_PURE_AUDIO] = s.getBoolean(SP_KEY_PURE_AUDIO, mEnables[POSITION_PURE_AUDIO]);
        mEnables[POSITION_MIRROR_ENABLE] = s.getBoolean(SP_KEY_MIRROR, mEnables[POSITION_MIRROR_ENABLE]);
        mEnables[POSITION_FLASH_ENABLE] = s.getBoolean(SP_KEY_FLASH_LIGHT, mEnables[POSITION_FLASH_ENABLE]);
        mEnables[POSITION_FOCUS_ENABLE] = s.getBoolean(SP_KEY_FOCUS, mEnables[POSITION_FOCUS_ENABLE]);
        mEnables[POSITION_ZOOM_ENABLE] = s.getBoolean(SP_KEY_ZOOM, mEnables[POSITION_ZOOM_ENABLE]);
        mAudioQualityIndex = s.getInt(SP_KEY_AUDIO_QUALITY, mAudioQualityIndex);
    }

    private int dip2px(float dpValue) {
        final float scale = getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    @Override
    public void dismissAllowingStateLoss() {
        try {
            super.dismissAllowingStateLoss();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void show(FragmentManager manager, String tag) {
        try {
            //在每个add事务前增加一个remove事务，防止连续的add
            manager.beginTransaction().remove(this).commit();
            super.show(manager, tag);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void toggle(FragmentManager manager, String tag) {
        if (isVisible()) {
            dismissAllowingStateLoss();
        } else {
            show(manager, tag);
        }
    }

    public void showOrientationItem() {
        if (mCheckSelectView != null) {
            mCheckSelectView.showItem(POSITION_LANDSCAPE);
        }
    }

    public void hideOrientationItem() {
        if (mCheckSelectView != null) {
            mCheckSelectView.hideItem(POSITION_LANDSCAPE);
        }
    }

    public void setOnSettingChangeListener(OnSettingChangeListener onSettingChangeListener) {
        mOnSettingChangeListener = onSettingChangeListener;
    }

    public boolean isAdjustBitrate() {
        return mEnables[POSITION_ADJUST_BITRATE];
    }

    public boolean isHardwareAcceleration() {
        return mEnables[POSITION_HW_ACC];
    }

    public boolean enableAudioEarMonitoring() {
        return mEnables[POSITION_EAR_MONITORING_ENABLE];
    }

    public boolean isPrivateModel() {
        return mEnables[POSITION_PRIVATE_MODEL];
    }

    public boolean isMute() {
        return mEnables[POSITION_MUTE_AUDIO];
    }

    public boolean isLandscape() {
        return mEnables[POSITION_LANDSCAPE];
    }

    public boolean isWatermark() {
        return mEnables[POSITION_WATER_MARK_ENABLE];
    }

    public boolean enablePureAudioPush() {
        return mEnables[POSITION_PURE_AUDIO];
    }

    public boolean isMirror() {
        return mEnables[POSITION_MIRROR_ENABLE];
    }

    public boolean isFlashEnable() {
        return mEnables[POSITION_FLASH_ENABLE];
    }

    public boolean isTouchFocus() {
        return mEnables[POSITION_FOCUS_ENABLE];
    }

    public boolean isEnableZoom() {
        return mEnables[POSITION_ZOOM_ENABLE];
    }

    public void closePrivateModel() {
        mEnables[POSITION_PRIVATE_MODEL] = false;
        if (mCheckSelectView != null) {
            mCheckSelectView.setChecked(POSITION_PRIVATE_MODEL, false);
        }
    }

    /**
     * 声道
     *
     * @return
     */
    public int getAudioChannels() {
        int channel = AUDIO_CHANNEL_ONE;
        switch (mAudioQualityIndex) {
            case AUDIO_SPEECH:  // 语音
            case AUDIO_DEFAULT: // 标准
                channel = AUDIO_CHANNEL_ONE;
                break;
            case AUDIO_MUSIC:   // 音乐
                channel = AUDIO_CHANNEL_TWO;
                break;
        }
        return channel;
    }

    /**
     * 音频采样率
     *
     * @return
     */
    public int getAudioSampleRate() {
        int sampleRate = AUDIO_SAMPLE_RATE_16000;
        switch (mAudioQualityIndex) {
            case AUDIO_SPEECH:  // 语音
                sampleRate = AUDIO_SAMPLE_RATE_16000;
                break;
            case AUDIO_DEFAULT: // 标准
            case AUDIO_MUSIC:   // 音乐
                sampleRate = AUDIO_SAMPLE_RATE_48000;
                break;
        }
        return sampleRate;
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.livepusher_btn_close) {
            dismissAllowingStateLoss();
        } else if (id == R.id.livepusher_btn_snapshot) {
            if (mOnSettingChangeListener != null) {
                mOnSettingChangeListener.onClickSnapshot();
            }
        } else if (id == R.id.livepusher_btn_send_message) {
            String message = mEditMessage.getText().toString().trim();
            if (TextUtils.isEmpty(message)) {
                Toast.makeText(getActivity(), R.string.livepusher_empty_message, Toast.LENGTH_SHORT).show();
            } else {
                if (mOnSettingChangeListener != null) {
                    mOnSettingChangeListener.onSendMessage(message);
                    mEditMessage.setText("");
                }
            }
        } else if (id == R.id.livepusher_rb_audio_quality_speech) {
            mRadioAudioQuality[mAudioQualityIndex].setChecked(false);
            mAudioQualityIndex = 0;
            mRadioAudioQuality[mAudioQualityIndex].setChecked(true);
            onAudioChannelChange(getAudioChannels(), getAudioSampleRate());
        } else if (id == R.id.livepusher_rb_audio_quality_default) {
            mRadioAudioQuality[mAudioQualityIndex].setChecked(false);
            mAudioQualityIndex = 1;
            mRadioAudioQuality[mAudioQualityIndex].setChecked(true);
            onAudioChannelChange(getAudioChannels(), getAudioSampleRate());
        } else if (id == R.id.livepusher_rb_audio_quality_music) {
            mRadioAudioQuality[mAudioQualityIndex].setChecked(false);
            mAudioQualityIndex = 2;
            mRadioAudioQuality[mAudioQualityIndex].setChecked(true);
            onAudioChannelChange(getAudioChannels(), getAudioSampleRate());
        }
    }

    public interface OnSettingChangeListener {
        /**
         * 音质选择（声道设置）
         * 语音(speech)：16000，单声道
         * 标准(default)：48000，单声道
         * 音乐(music)：48000，双声道
         *
         * @param channel    单声道 1，双声道 2
         * @param sampleRate 音频采样率
         */
        void onAudioQualityChange(int channel, int sampleRate);

        /**
         * 硬件加速
         *
         * @param enable
         */
        void onHardwareAcceleration(boolean enable);

        /**
         * 码率自适应
         *
         * @param enable
         */
        void onAdjustBitrateChange(boolean enable);

        /**
         * 耳返开关
         *
         * @param enable
         */
        void onEnableAudioEarMonitoringChange(boolean enable);

        /**
         * 横竖屏推流
         *
         * @param isPortrait
         */
        void onHomeOrientationChange(boolean isPortrait);

        /**
         * 是否开隐私模式
         *
         * @param enable
         */
        void onPrivateModeChange(boolean enable);

        /**
         * 是否开启静音推流
         *
         * @param enable
         */
        void onMuteChange(boolean enable);

        /**
         * 开启或关闭观众端镜像
         *
         * @param enable
         */
        void onMirrorChange(boolean enable);

        /**
         * 开启或关闭后置摄像头闪光灯
         *
         * @param enable
         */
        void onFlashLightChange(boolean enable);

        /**
         * 开启或关闭水印
         *
         * @param enable
         */
        void onWatermarkChange(boolean enable);

        void onPureAudioPushChange(boolean enable);

        /**
         * 开启或关闭手动对焦
         *
         * @param enable
         */
        void onTouchFocusChange(boolean enable);

        /**
         * 开启或关闭双手缩放
         *
         * @param enable
         */
        void onEnableZoomChange(boolean enable);

        /**
         * 点击截图
         */
        void onClickSnapshot();

        /**
         * 发送sei消息
         */
        void onSendMessage(String string);
    }
}
