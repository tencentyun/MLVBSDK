package com.tencent.liteav.demo.lvb.camerapush;

import android.app.DialogFragment;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.LinearLayout;

import com.tencent.liteav.demo.R;

import java.lang.ref.WeakReference;

/**
 */
public class PusherMoreFragment extends DialogFragment implements CompoundButton.OnCheckedChangeListener {
    private static final String SP_NAME             = "sp_pusher_setting";
    private static final String SP_KEY_MUTE_AUDIO   = "sp_key_mute_audio";
    private static final String SP_KEY_PORTRAIT     = "sp_key_portrait";
    private static final String SP_KEY_MIRROR       = "sp_key_mirror";
    private static final String SP_KEY_FLASH_LIGHT  = "sp_key_flash_light";
    private static final String SP_KEY_DEBUG        = "sp_key_debug";
    private static final String SP_KEY_WARTER_MARK  = "sp_key_water_mark";
    private static final String SP_KEY_FOCUS        = "sp_key_focus";
    private static final String SP_KEY_ZOOM         = "sp_key_zoom";

    private boolean mPrivateModel = false, mMuteAudio = false, mIsPortrait = true,
                    mMirrorEnable = false, mFlashEnable = false, mDebugInfo = false, mWaterMarkEnable = true,
                    mFocusEnable = true, mZoomEnable = false;
    // 回调
    private WeakReference<OnMoreChangeListener> mWefSettingListener;

    private CheckBox mCbOrientation, mCbPrivateModel;
    private LinearLayout mLlOrientation;


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
        return inflater.inflate(R.layout.fragment_pusher_more, container, false);
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
        mCbPrivateModel = ((CheckBox) view.findViewById(R.id.pusher_cb_private_mode));
        mCbPrivateModel.setOnCheckedChangeListener(this);
        mCbPrivateModel.setChecked(mPrivateModel);
        CheckBox cbMuteAudio = ((CheckBox) view.findViewById(R.id.pusher_cb_mute_audio));
        cbMuteAudio.setOnCheckedChangeListener(this);
        cbMuteAudio.setChecked(mMuteAudio);
        CheckBox cbMirror = ((CheckBox) view.findViewById(R.id.pusher_cb_mirror));
        cbMirror.setOnCheckedChangeListener(this);
        cbMirror.setChecked(mMirrorEnable);
        CheckBox cbFlashlight = ((CheckBox) view.findViewById(R.id.pusher_cb_flash_light));
        cbFlashlight.setOnCheckedChangeListener(this);
        cbFlashlight.setChecked(mFlashEnable);
        CheckBox cbDebugInfo = ((CheckBox) view.findViewById(R.id.pusher_cb_debug_info));
        cbDebugInfo.setOnCheckedChangeListener(this);
        cbDebugInfo.setChecked(mDebugInfo);
        CheckBox cbWaterMark = ((CheckBox) view.findViewById(R.id.pusher_cb_water_mark));
        cbWaterMark.setOnCheckedChangeListener(this);
        cbWaterMark.setChecked(mWaterMarkEnable);
        CheckBox cbFocus = ((CheckBox) view.findViewById(R.id.pusher_cb_focus));
        cbFocus.setOnCheckedChangeListener(this);
        cbFocus.setChecked(mFocusEnable);
        CheckBox cbZoom = ((CheckBox) view.findViewById(R.id.pusher_cb_zoom));
        cbZoom.setOnCheckedChangeListener(this);
        cbZoom.setChecked(mZoomEnable);

        mLlOrientation = (LinearLayout) view.findViewById(R.id.pusher_ll_orientation);
        mCbOrientation = ((CheckBox) view.findViewById(R.id.pusher_cb_orientation));
        mCbOrientation.setOnCheckedChangeListener(this);
        mCbOrientation.setChecked(!mIsPortrait);

        if (isActivityCanRotation(getActivity())) { // 如果当前系统可以自动旋转，那么不打开
            mLlOrientation.setVisibility(View.GONE);
        }

        view.findViewById(R.id.pusher_btn_snapshot).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnMoreChangeListener listener = getLisener();
                if (listener != null) {
                    listener.onClickSnapshot();
                }
            }
        });
    }

    public void setMoreChangeListener(OnMoreChangeListener listener) {
        mWefSettingListener = new WeakReference<>(listener);
    }

    private OnMoreChangeListener getLisener() {
        if (mWefSettingListener != null)
            return mWefSettingListener.get();
        return null;
    }

    /**
     * CheckBox 改变的回调
     * @param buttonView
     * @param isChecked
     */
    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (!buttonView.isPressed()) return;
        OnMoreChangeListener listener = getLisener();
        if (listener == null) return;
        switch (buttonView.getId()) {
            case R.id.pusher_cb_private_mode:
                mPrivateModel = isChecked;
                listener.onPrivateModeChange(mPrivateModel);
                break;
            case R.id.pusher_cb_mute_audio:
                mMuteAudio = isChecked;
                listener.onMuteAudioChange(mMuteAudio);
                break;
            case R.id.pusher_cb_mirror:
                mMirrorEnable = isChecked;
                listener.onMirrorChange(isChecked);
                break;
            case R.id.pusher_cb_flash_light:
                mFlashEnable = isChecked;
                listener.onFlashLightChange(isChecked);
                break;
            case R.id.pusher_cb_debug_info:
                mDebugInfo = isChecked;
                listener.onDebugInfoChange(isChecked);
                break;
            case R.id.pusher_cb_water_mark:
                mWaterMarkEnable = isChecked;
                listener.onWaterMarkChange(isChecked);
                break;
            case R.id.pusher_cb_focus:
                mFocusEnable = isChecked;
                listener.onFocusChange(isChecked);
                break;
            case R.id.pusher_cb_zoom:
                mZoomEnable = isChecked;
                listener.onZoomChange(isChecked);
                break;
            case R.id.pusher_cb_orientation:
                mIsPortrait = !isChecked;
                listener.onOrientationChange(mIsPortrait);
                break;
        }
    }

    public void hideOrientationButton() {
        if (mLlOrientation != null)
            mLlOrientation.setVisibility(View.GONE);
    }

    public void showOrientationButton() {
        mIsPortrait = true;
        if (mLlOrientation != null) {
            mLlOrientation.setVisibility(View.VISIBLE);
        }
    }

    public void closePrivateModel() {
        mPrivateModel = false;
    }

    @Override
    public void onResume() {
        super.onResume();
        mCbOrientation.setChecked(!mIsPortrait);
        mCbPrivateModel.setChecked(mPrivateModel);
    }

    public interface OnMoreChangeListener {
        /**
         * 横竖屏推流
         * @param isPortrait
         */
        void onOrientationChange(boolean isPortrait);

        /**
         * 是否开隐私模式
         * @param enable
         */
        void onPrivateModeChange(boolean enable);

        /**
         * 是否开启静音推流
         * @param enable
         */
        void onMuteAudioChange(boolean enable);

        /**
         * 开启或关闭观众端镜像
         * @param enable
         */
        void onMirrorChange(boolean enable);

        /**
         * 开启或关闭后置摄像头闪光灯
         * @param enable
         */
        void onFlashLightChange(boolean enable);

        /**
         * 开启或关闭 Debug 面板
         * @param enable
         */
        void onDebugInfoChange(boolean enable);

        /**
         * 开启或关闭水印
         * @param enable
         */
        void onWaterMarkChange(boolean enable);

        /**
         * 开启或关闭手动对焦
         * @param enable
         */
        void onFocusChange(boolean enable);

        /**
         * 开启或关闭双手缩放
         * @param enable
         */
        void onZoomChange(boolean enable);

        /**
         * 点击截图
         */
        void onClickSnapshot();
    }


    /**
     * 判断系统 "自动旋转" 设置功能是否打开
     *
     * @return false---Activity可根据重力感应自动旋转
     */
    public boolean isActivityCanRotation(Context context) {
        // 判断自动旋转是否打开
        int flag = Settings.System.getInt(context.getContentResolver(), Settings.System.ACCELEROMETER_ROTATION, 0);
        if (flag == 0) {
            return false;
        }
        return true;
    }

    @Override
    public void onPause() {
        super.onPause();
        saveConfigIntoSp();
    }

    /**
     * 保存配置到 SharePreferences
     */
    private void saveConfigIntoSp() {
        try {
            getActivity().getSharedPreferences(SP_NAME, 0)
                    .edit()
                    .putBoolean(SP_KEY_MUTE_AUDIO, mMuteAudio)
                    .putBoolean(SP_KEY_PORTRAIT, mIsPortrait)
                    .putBoolean(SP_KEY_MIRROR, mMirrorEnable)
                    .putBoolean(SP_KEY_FLASH_LIGHT, mFlashEnable)
                    .putBoolean(SP_KEY_DEBUG, mDebugInfo)
                    .putBoolean(SP_KEY_WARTER_MARK, mWaterMarkEnable)
                    .putBoolean(SP_KEY_FOCUS, mFocusEnable)
                    .putBoolean(SP_KEY_ZOOM, mZoomEnable)
                    .apply();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void loadConfig(Context context){
        try {
            SharedPreferences s = context.getSharedPreferences(SP_NAME, 0);
            mMuteAudio = s.getBoolean(SP_KEY_MUTE_AUDIO, mMuteAudio);
            mIsPortrait = s.getBoolean(SP_KEY_PORTRAIT, mIsPortrait);
            mMirrorEnable = s.getBoolean(SP_KEY_MIRROR, mMirrorEnable);
            mFlashEnable = s.getBoolean(SP_KEY_FLASH_LIGHT, mFlashEnable);
            mDebugInfo = s.getBoolean(SP_KEY_DEBUG, mDebugInfo);
            mWaterMarkEnable = s.getBoolean(SP_KEY_WARTER_MARK, mWaterMarkEnable);
            mFocusEnable = s.getBoolean(SP_KEY_FOCUS, mFocusEnable);
            mZoomEnable = s.getBoolean(SP_KEY_ZOOM, mZoomEnable);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isPrivateMode() {
        return mPrivateModel;
    }

    public boolean isMuteAudio() {
        return mMuteAudio;
    }

    public boolean isPortrait() {
        return mIsPortrait;
    }

    public boolean isMirrorEnable() {
        return mMirrorEnable;
    }

    public boolean isFlashEnable() {
        return mFlashEnable;
    }

    public boolean isDebugInfo() {
        return mDebugInfo;
    }

    public boolean isWaterMarkEnable() {
        return mWaterMarkEnable;
    }

    public boolean isFocusEnable() {
        return mFocusEnable;
    }

    public boolean isZoomEnable() {
        return mZoomEnable;
    }

    @Override
    public String toString() {
        return "PusherMoreFragment{" +
                "mPrivateModel=" + mPrivateModel +
                ", mMuteAudio=" + mMuteAudio +
                ", mIsPortrait=" + mIsPortrait +
                ", mMirrorEnable=" + mMirrorEnable +
                ", mFlashEnable=" + mFlashEnable +
                ", mDebugInfo=" + mDebugInfo +
                ", mWaterMarkEnable=" + mWaterMarkEnable +
                ", mFocusEnable=" + mFocusEnable +
                ", mZoomEnable=" + mZoomEnable +
                ", mWefSettingListener=" + mWefSettingListener +
                ", mCbOrientation=" + mCbOrientation +
                '}';
    }
}




