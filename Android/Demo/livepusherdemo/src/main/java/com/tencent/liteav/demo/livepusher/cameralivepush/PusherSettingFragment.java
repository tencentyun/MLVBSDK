package com.tencent.liteav.demo.livepusher.cameralivepush;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DialogFragment;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.Spinner;

import com.tencent.liteav.demo.livepusher.R;
import com.tencent.rtmp.TXLiveConstants;

import java.lang.ref.WeakReference;
import java.util.Arrays;

/**
 */
@SuppressLint("ValidFragment")
public class PusherSettingFragment extends DialogFragment implements CompoundButton.OnCheckedChangeListener {

    /**
     * SharePreferences 用于存储相关配置的key
     */
    public static final String SP_NAME                          = "sp_pusher_setting";
    public static final String SP_KEY_HW_ACC                    = "sp_key_hw_acc";
    public static final String SP_KEY_ADJUST_BITRATE            = "sp_key_adjust_bitrate";
    public static final String SP_KEY_QUALITY                   = "sp_key_quality";
    public static final String SP_KEY_AUDIO_CHANNEL             = "sp_key_audio_channel";
    public static final String SP_KEY_EAR_MONITORING            = "sp_key_ear_monitoring";

    // 对应 SDK 的画质列表（TXLiveConstants中定义）
    private static final int[] VIDEO_QUALITY_TYPE_ARR           = new int[]{TXLiveConstants.VIDEO_QUALITY_ULTRA_DEFINITION,
                                                                        TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION,
                                                                        TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION,
                                                                        TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION,
                                                                        TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER,
                                                                        TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER,
                                                                        TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT};

    private static final int AUDIO_SPEECH                       = 0;    // 语音(speech)
    private static final int AUDIO_DEFAULT                      = 1;    // 标准(default)
    private static final int AUDIO_MUSIC                        = 2;    // 音乐(music)

    private static final int AUDIO_CHANNEL_ONE                  = 1;    // 单声道
    private static final int AUDIO_CHANNEL_TWO                  = 2;    // 双声道

    private static final int AUDIO_SAMPLE_RATE_16000            = 16000;// 音频采样率，16000
    private static final int AUDIO_SAMPLE_RATE_48000            = 48000;// 音频采样率，48000

    // CheckBox控件
    private CheckBox    mCheckHwAcc;
    private CheckBox    mCheckAdjustBitrate;
    private CheckBox    mCheckEarMonitoring;

    // Spinner控件
    private Spinner     mSpinnerVideoQuality;
    private Spinner     mSpinnerVoiceChannel;

    private boolean     mIsHWAcc = true;
    private boolean     mIsAdjustBitrate = true;
    private boolean     mIsEarMonitoringEnable = false;

    private int         mQualityIndex = 1;
    private int         mAudioChannelIndex = 2;

    // 回调
    private WeakReference<OnSettingChangeListener> mWefSettingListener;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.LivePusherMlvbDialogFragment);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null) {
            getDialog().getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.livepusher_fragment_pusher_setting, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try{
                    dismissAllowingStateLoss();
                }catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        mCheckHwAcc = (CheckBox) view.findViewById(R.id.livepusher_cb_hw_acc);
        mCheckHwAcc.setChecked(mIsHWAcc);
        mCheckAdjustBitrate = (CheckBox) view.findViewById(R.id.livepusher_cb_adjust_bitrate);
        mCheckAdjustBitrate.setChecked(mIsAdjustBitrate);
        mCheckEarMonitoring = (CheckBox) view.findViewById(R.id.livepusher_cb_ear_monitoring);
        mCheckEarMonitoring.setChecked(mIsEarMonitoringEnable);

        mCheckHwAcc.setOnCheckedChangeListener(this);
        mCheckAdjustBitrate.setOnCheckedChangeListener(this);
        mCheckEarMonitoring.setOnCheckedChangeListener(this);

        initVideoQualitySpinner(view);
        initAudioChannelSpinner(view);
    }

    public void setOnSettingChangeListener(OnSettingChangeListener listener) {
        mWefSettingListener = new WeakReference<>(listener);
    }

    private OnSettingChangeListener getListener() {
        if (mWefSettingListener == null) {
            return null;
        }
        return mWefSettingListener.get();
    }

    /**
     * CheckBox 改变的回调
     *
     * @param buttonView
     * @param isChecked
     */
    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (!buttonView.isPressed()) {// 如果不是点击的，忽略
            return;
        }
        OnSettingChangeListener listener = getListener();
        if (listener == null) return;
        int id = buttonView.getId();
        if (id == R.id.livepusher_cb_hw_acc) {
            mIsHWAcc = mCheckHwAcc.isChecked();
            listener.onHwAccChange(mCheckHwAcc.isChecked());
        } else if (id == R.id.livepusher_cb_adjust_bitrate) {
            mIsAdjustBitrate = mCheckAdjustBitrate.isChecked();
            listener.onAdjustBitrateChange(mIsAdjustBitrate);
        } else if (id == R.id.livepusher_cb_ear_monitoring) {
            mIsEarMonitoringEnable = mCheckEarMonitoring.isChecked();
            listener.onEarMonitoringChange(mIsEarMonitoringEnable);
        }
    }

    private void initVideoQualitySpinner(View view) {
        mSpinnerVideoQuality = (Spinner) view.findViewById(R.id.livepusher_spinner_video_quality);
        ArrayAdapter<String> videoQualityAdapter = new ArrayAdapter<String>(view.getContext(),
                R.layout.livepusher_setting_spinner_text, Arrays.asList(getResources().getStringArray(R.array.livepusher_video_quality_list)));
        mSpinnerVideoQuality.setAdapter(videoQualityAdapter);
        mSpinnerVideoQuality.setSelection(mQualityIndex);
        mSpinnerVideoQuality.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (mQualityIndex == position) return;
                mQualityIndex = position;
                OnSettingChangeListener listener = getListener();
                if (listener == null) return;
                listener.onQualityChange(VIDEO_QUALITY_TYPE_ARR[position]);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
    }

    private void initAudioChannelSpinner(View view) {
        mSpinnerVoiceChannel = (Spinner) view.findViewById(R.id.livepusher_spinner_audio_channel);
        ArrayAdapter<String> videoQualityAdapter = new ArrayAdapter<String>(view.getContext(),
                R.layout.livepusher_setting_spinner_text, Arrays.asList(getResources().getStringArray(R.array.livepusher_voice_channel)));
        mSpinnerVoiceChannel.setAdapter(videoQualityAdapter);
        mSpinnerVoiceChannel.setSelection(mAudioChannelIndex);
        mSpinnerVoiceChannel.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (mAudioChannelIndex == position) return;
                mAudioChannelIndex = position;
                OnSettingChangeListener listener = getListener();
                if (listener == null) return;
                listener.onAudioChannelChange(getAudioChannels(), getAudioSampleRate());
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
    }

    /**
     * 从 SharePreferences 加载配置
     * @param context
     */
    public void loadConfig(Context context) {
        SharedPreferences s = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        mIsHWAcc = s.getBoolean(SP_KEY_HW_ACC, mIsHWAcc);
        mIsAdjustBitrate = s.getBoolean(SP_KEY_ADJUST_BITRATE, mIsAdjustBitrate);
        mQualityIndex = s.getInt(SP_KEY_QUALITY, mQualityIndex);
        mAudioChannelIndex = s.getInt(SP_KEY_AUDIO_CHANNEL, mAudioChannelIndex);
        mIsEarMonitoringEnable = s.getBoolean(SP_KEY_EAR_MONITORING, mIsEarMonitoringEnable);
    }

    /**
     * 保存配置到 SharePreferences
     */
    private void saveConfigIntoSp() {
        Activity activity = getActivity();
        if (activity != null) {
            activity.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE)
                    .edit()
                    .putBoolean(SP_KEY_HW_ACC, mIsHWAcc)
                    .putBoolean(SP_KEY_ADJUST_BITRATE, mIsAdjustBitrate)
                    .putInt(SP_KEY_QUALITY, mQualityIndex)
                    .putInt(SP_KEY_AUDIO_CHANNEL, mAudioChannelIndex)
                    .putBoolean(SP_KEY_EAR_MONITORING, mIsEarMonitoringEnable)
                    .apply();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        saveConfigIntoSp();
    }


    public interface OnSettingChangeListener {
        /**
         * 硬件加速
         * @param enable
         */
        void onHwAccChange(boolean enable);

        /**
         * 码率自适应
         * @param enable
         */
        void onAdjustBitrateChange(boolean enable);

        /**
         * 视频编码质量
         *
         * @param type
         */
        void onQualityChange(int type);

        /**
         * 耳返开关
         * @param enable
         */
        void onEarMonitoringChange(boolean enable);

        /**
         * 音质选择（声道设置）
         * 语音(speech)：16000，单声道
         * 标准(default)：48000，单声道
         * 音乐(music)：48000，双声道
         *
         * @param channel    单声道 1，双声道 2
         * @param sampleRate 音频采样率
         */
        void onAudioChannelChange(int channel, int sampleRate);
    }

    public int getQualityType() {
        return VIDEO_QUALITY_TYPE_ARR[mQualityIndex];
    }

    public boolean isHWAcc() {
        return mIsHWAcc;
    }

    public boolean isEnableAdjustBitrate() {
        return mIsAdjustBitrate;
    }

    public boolean isEarMonitoringEnable(){
        return mIsEarMonitoringEnable;
    }

    /**
     * 声道
     * @return
     */
    public int getAudioChannels() {
        int channel = AUDIO_CHANNEL_ONE;
        switch (mAudioChannelIndex) {
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
     * @return
     */
    public int getAudioSampleRate() {
        int sampleRate = AUDIO_SAMPLE_RATE_16000;
        switch (mAudioChannelIndex) {
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
}
