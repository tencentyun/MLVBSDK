package com.tencent.liteav.demo.lvb.camerapush;

import android.annotation.SuppressLint;
import android.app.DialogFragment;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.Spinner;

import com.tencent.liteav.demo.R;
import com.tencent.rtmp.TXLiveConstants;

import java.lang.ref.WeakReference;
import java.util.Arrays;
import java.util.List;

/**
 */
@SuppressLint("ValidFragment")
public class PusherSettingFragment extends DialogFragment implements CompoundButton.OnCheckedChangeListener {
    private static final String TAG = "PusherSettingFragment";
    /**
     * SharePreferences 用于存储相关配置的key
     */
    public static final String SP_NAME = "sp_pusher_setting";
    public static final String SP_KEY_HW_ACC = "sp_key_hw_acc";
    public static final String SP_KEY_ADJUST_BITRATE = "sp_key_adjust_bitrate";
    public static final String SP_KEY_QUALIY = "sp_key_quality";
    public static final String SP_KEY_REVERB = "sp_key_reverb";
    public static final String SP_KEY_VOICE = "sp_key_voice";

    // 画质偏好列表
    private static final List<String> VIDEO_QUALITY_LIST = Arrays.asList(new String[]{"标清", "高清", "超清", "连麦大主播", "连麦小主播", "实时音视频"});
    // 对应 SDK 的画质列表（TXLiveConstants中定义）
    private static final int[] VIDEO_QUALITY_TYPE_ARR = new int[]{TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION,
            TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION, TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION, TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER,
            TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER, TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT};
    // 混响列表
    private static final List<String> REVERB_LIST = Arrays.asList(new String[]{"关闭混响", "KTV", "小房间", "大会堂", "低沉", "洪亮", "磁性"});
    // 对应 SDK 的混响列表（TXLiveConstants中定义）
    private static final int[] REVERB_TYPE_ARR = new int[]{TXLiveConstants.REVERB_TYPE_0,
            TXLiveConstants.REVERB_TYPE_1, TXLiveConstants.REVERB_TYPE_2, TXLiveConstants.REVERB_TYPE_3,
            TXLiveConstants.REVERB_TYPE_4, TXLiveConstants.REVERB_TYPE_5, TXLiveConstants.REVERB_TYPE_6};
    // 变声列表
    private static final List<String> VOICE_CHANGER_LIST = Arrays.asList(new String[]{"关闭变声", "熊孩子", "萝莉", "大叔", "重金属", "感冒", "外国人", "困兽", "死肥仔", "强电流", "重机械", "空灵"});
    // 对应 SDK 的变声列表（TXLiveConstants中定义）
    private static final int[] VOICE_CHANGER_TYPE_ARR = new int[]{TXLiveConstants.VOICECHANGER_TYPE_0,
            TXLiveConstants.VOICECHANGER_TYPE_1, TXLiveConstants.VOICECHANGER_TYPE_2, TXLiveConstants.VOICECHANGER_TYPE_3,
            TXLiveConstants.VOICECHANGER_TYPE_4, TXLiveConstants.VOICECHANGER_TYPE_5, TXLiveConstants.VOICECHANGER_TYPE_6,
            TXLiveConstants.VOICECHANGER_TYPE_7, TXLiveConstants.VOICECHANGER_TYPE_8, TXLiveConstants.VOICECHANGER_TYPE_9,
            TXLiveConstants.VOICECHANGER_TYPE_10, TXLiveConstants.VOICECHANGER_TYPE_11};

    // CheckBox控件
    private CheckBox mCbHwAcc, mCbAdjustBitrate;
    private boolean mIsHWAcc = true, mIsAdjustBitrate = true;

    // Spinner控件
    private Spinner mSpVideoQuality, mSpReverb, mSpVoiceChanger;
    private int mQualityIndex = 1, mReverbIndex = 0, mVoiceChangerIndex = 0;


    // 回调
    private WeakReference<OnSettingChangeListener> mWefSettingListener;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.mlvb_dialog_fragment);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null)
            getDialog().getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_pusher_setting, container, false);
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
        mCbHwAcc = (CheckBox) view.findViewById(R.id.pusher_cb_hw_acc);
        mCbHwAcc.setChecked(mIsHWAcc);
        mCbAdjustBitrate = (CheckBox) view.findViewById(R.id.pusher_cb_adjust_bitrate);
        mCbAdjustBitrate.setChecked(mIsAdjustBitrate);

        mCbHwAcc.setOnCheckedChangeListener(this);
        mCbAdjustBitrate.setOnCheckedChangeListener(this);

        initVideoQualitySpinner(view);
        initRevervSpinner(view);
        initVoiceChanegrSpinner(view);
    }

    public void setOnSettingChangeListener(OnSettingChangeListener listener) {
        mWefSettingListener = new WeakReference<>(listener);
    }

    private OnSettingChangeListener getLisener() {
        if (mWefSettingListener != null)
            return mWefSettingListener.get();
        return null;
    }

    /**
     * CheckBox 改变的回调
     *
     * @param buttonView
     * @param isChecked
     */
    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (!buttonView.isPressed()) return; // 如果不是点击的，忽略

        OnSettingChangeListener listener = getLisener();
        if (listener == null) return;
        switch (buttonView.getId()) {
            case R.id.pusher_cb_hw_acc:
                mIsHWAcc = mCbHwAcc.isChecked();
                listener.onHwAccChange(mCbHwAcc.isChecked());
                break;
            case R.id.pusher_cb_adjust_bitrate:
                mIsAdjustBitrate = mCbAdjustBitrate.isChecked();
                listener.onAdjustBitrateChange(mIsAdjustBitrate);
                break;
        }
    }

    private void initVoiceChanegrSpinner(View view) {
        mSpVoiceChanger = (Spinner) view.findViewById(R.id.pusher_spinner_voice_changer);
        ArrayAdapter<String> reverbAdapter = new ArrayAdapter<String>(view.getContext(),
                R.layout.pusher_setting_spinner_text, VOICE_CHANGER_LIST);
        mSpVoiceChanger.setAdapter(reverbAdapter);
        mSpVoiceChanger.setSelection(mVoiceChangerIndex);
        mSpVoiceChanger.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (mVoiceChangerIndex == position) return;
                mVoiceChangerIndex = position;
                OnSettingChangeListener listener = getLisener();
                if (listener == null) return;
                listener.onVoiceChange(VOICE_CHANGER_TYPE_ARR[position]);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
    }

    private void initRevervSpinner(View view) {
        mSpReverb = (Spinner) view.findViewById(R.id.pusher_spinner_reverb);
        ArrayAdapter<String> reverbAdapter = new ArrayAdapter<String>(view.getContext(),
                R.layout.pusher_setting_spinner_text, REVERB_LIST);
        mSpReverb.setAdapter(reverbAdapter);
        mSpReverb.setSelection(mReverbIndex);
        mSpReverb.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position == mReverbIndex) return;
                mReverbIndex = position;
                OnSettingChangeListener listener = getLisener();
                if (listener == null) return;
                listener.onReverbChange(REVERB_TYPE_ARR[position]);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
    }


    private void initVideoQualitySpinner(View view) {
        mSpVideoQuality = (Spinner) view.findViewById(R.id.pusher_spinner_video_quality);
        ArrayAdapter<String> videoQualityAdapter = new ArrayAdapter<String>(view.getContext(),
                R.layout.pusher_setting_spinner_text, VIDEO_QUALITY_LIST);
        mSpVideoQuality.setAdapter(videoQualityAdapter);
        mSpVideoQuality.setSelection(mQualityIndex);
        mSpVideoQuality.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (mQualityIndex == position) return;
                mQualityIndex = position;
                OnSettingChangeListener listener = getLisener();
                if (listener == null) return;
                listener.onQualityChange(VIDEO_QUALITY_TYPE_ARR[position]);
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
        try {
            SharedPreferences s = context.getSharedPreferences(SP_NAME, 0);
            mIsHWAcc = s.getBoolean(SP_KEY_HW_ACC, mIsHWAcc);
            mIsAdjustBitrate = s.getBoolean(SP_KEY_ADJUST_BITRATE, mIsAdjustBitrate);
            mQualityIndex = s.getInt(SP_KEY_QUALIY, mQualityIndex);
            mReverbIndex = s.getInt(SP_KEY_REVERB, mReverbIndex);
            mVoiceChangerIndex = s.getInt(SP_KEY_VOICE, mVoiceChangerIndex);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 保存配置到 SharePreferences
     */
    private void saveConfigIntoSp() {
        try {
            getActivity().getSharedPreferences(SP_NAME, 0)
                    .edit()
                    .putBoolean(SP_KEY_HW_ACC, mIsHWAcc)
                    .putBoolean(SP_KEY_ADJUST_BITRATE, mIsAdjustBitrate)
                    .putInt(SP_KEY_QUALIY, mQualityIndex)
                    .putInt(SP_KEY_REVERB, mReverbIndex)
                    .putInt(SP_KEY_VOICE, mVoiceChangerIndex)
                    .apply();
        } catch (Exception e) {
            e.printStackTrace();
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
         * 混响
         * @param type
         */
        void onReverbChange(int type);

        /**
         * 变声
         * @param type
         */
        void onVoiceChange(int type);
    }

    public int getQualityType() {
        return VIDEO_QUALITY_TYPE_ARR[mQualityIndex];
    }

    public int getReverbIndex() {
        return mReverbIndex;
    }

    public int getVoiceChangerIndex() {
        return mVoiceChangerIndex;
    }

    public boolean isHWAcc() {
        return mIsHWAcc;
    }

    public boolean isEnableAdjustBitrate() {
        return mIsAdjustBitrate;
    }
}

