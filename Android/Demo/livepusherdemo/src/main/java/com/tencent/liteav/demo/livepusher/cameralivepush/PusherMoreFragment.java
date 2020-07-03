package com.tencent.liteav.demo.livepusher.cameralivepush;

import android.app.Activity;
import android.app.DialogFragment;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;

import com.tencent.liteav.demo.livepusher.R;

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
    private static final String SP_KEY_WATER_MARK   = "sp_key_water_mark";
    private static final String SP_KEY_FOCUS        = "sp_key_focus";
    private static final String SP_KEY_ZOOM         = "sp_key_zoom";
    private static final String SP_KEY_PURE_AUDIO   = "sp_key_pure_audio";

    private boolean         mPrivateModel = false;
    private boolean         mMuteAudio = false;
    private boolean         mIsPortrait = true;
    private boolean         mMirrorEnable = false;
    private boolean         mFlashEnable = false;
    private boolean         mDebugInfo = false;
    private boolean         mWaterMarkEnable = true;
    private boolean         mFocusEnable = true;
    private boolean         mZoomEnable = false;
    private boolean         mPureAudio = false;

    private CheckBox        mCheckOrientation;
    private CheckBox        mCheckPrivateModel;
    private LinearLayout    mLinearOrientation;

    // 回调
    private WeakReference<OnMoreChangeListener> mWefSettingListener;

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
        return inflater.inflate(R.layout.livepusher_fragment_pusher_more, container, false);
    }

    @Override
    public void onViewCreated(final View view, @Nullable Bundle savedInstanceState) {
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
        mCheckPrivateModel = ((CheckBox) view.findViewById(R.id.livepusher_cb_private_mode));
        mCheckPrivateModel.setOnCheckedChangeListener(this);
        mCheckPrivateModel.setChecked(mPrivateModel);
        CheckBox cbMuteAudio = ((CheckBox) view.findViewById(R.id.livepusher_cb_mute_audio));
        cbMuteAudio.setOnCheckedChangeListener(this);
        cbMuteAudio.setChecked(mMuteAudio);
        CheckBox cbMirror = ((CheckBox) view.findViewById(R.id.livepusher_cb_mirror));
        cbMirror.setOnCheckedChangeListener(this);
        cbMirror.setChecked(mMirrorEnable);
        CheckBox cbFlashlight = ((CheckBox) view.findViewById(R.id.livepusher_cb_flash_light));
        cbFlashlight.setOnCheckedChangeListener(this);
        cbFlashlight.setChecked(mFlashEnable);
        CheckBox cbDebugInfo = ((CheckBox) view.findViewById(R.id.livepusher_cb_debug_info));
        cbDebugInfo.setOnCheckedChangeListener(this);
        cbDebugInfo.setChecked(mDebugInfo);
        CheckBox cbWaterMark = ((CheckBox) view.findViewById(R.id.livepusher_cb_water_mark));
        cbWaterMark.setOnCheckedChangeListener(this);
        cbWaterMark.setChecked(mWaterMarkEnable);
        CheckBox cbFocus = ((CheckBox) view.findViewById(R.id.livepusher_cb_focus));
        cbFocus.setOnCheckedChangeListener(this);
        cbFocus.setChecked(mFocusEnable);
        CheckBox cbZoom = ((CheckBox) view.findViewById(R.id.livepusher_cb_zoom));
        cbZoom.setOnCheckedChangeListener(this);
        cbZoom.setChecked(mZoomEnable);
        CheckBox cbAudio = ((CheckBox) view.findViewById(R.id.livepusher_cb_pure_audio));
        cbAudio.setOnCheckedChangeListener(this);
        cbAudio.setChecked(mPureAudio);

        mLinearOrientation = (LinearLayout) view.findViewById(R.id.livepusher_ll_orientation);
        mCheckOrientation = ((CheckBox) view.findViewById(R.id.livepusher_cb_orientation));
        mCheckOrientation.setOnCheckedChangeListener(this);
        mCheckOrientation.setChecked(!mIsPortrait);

        if (PhoneUtils.isActivityCanRotation(getActivity())) { // 如果当前系统可以自动旋转，那么不打开
            mLinearOrientation.setVisibility(View.GONE);
        }

        view.findViewById(R.id.livepusher_btn_snapshot).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnMoreChangeListener listener = getListener();
                if (listener != null) {
                    listener.onClickSnapshot();
                }
            }
        });
        view.findViewById(R.id.livepusher_btn_send).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnMoreChangeListener listener = getListener();
                if (listener != null) {
                    EditText editText = (EditText) view.findViewById(R.id.livepusher_et_message);
                    String message = editText.getText().toString().trim();
                    if (TextUtils.isEmpty(message)) {
                        return;
                    }
                    listener.onSendMessage(message);
                }
            }
        });
    }

    public void setMoreChangeListener(OnMoreChangeListener listener) {
        mWefSettingListener = new WeakReference<>(listener);
    }

    private OnMoreChangeListener getListener() {
        if (mWefSettingListener == null) {
            return null;
        }
        return mWefSettingListener.get();
    }

    /**
     * CheckBox 改变的回调
     * @param buttonView
     * @param isChecked
     */
    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (!buttonView.isPressed()) return;
        OnMoreChangeListener listener = getListener();
        if (listener == null) return;
        int id = buttonView.getId();
        if (id == R.id.livepusher_cb_private_mode) {
            mPrivateModel = isChecked;
            listener.onPrivateModeChange(mPrivateModel);
        } else if (id == R.id.livepusher_cb_mute_audio) {
            mMuteAudio = isChecked;
            listener.onMuteAudioChange(mMuteAudio);
        } else if (id == R.id.livepusher_cb_mirror) {
            mMirrorEnable = isChecked;
            listener.onMirrorChange(isChecked);
        } else if (id == R.id.livepusher_cb_flash_light) {
            mFlashEnable = isChecked;
            listener.onFlashLightChange(isChecked);
        } else if (id == R.id.livepusher_cb_debug_info) {
            mDebugInfo = isChecked;
            listener.onDebugInfoChange(isChecked);
        } else if (id == R.id.livepusher_cb_water_mark) {
            mWaterMarkEnable = isChecked;
            listener.onWaterMarkChange(isChecked);
        } else if (id == R.id.livepusher_cb_focus) {
            mFocusEnable = isChecked;
            listener.onFocusChange(isChecked);
        } else if (id == R.id.livepusher_cb_zoom) {
            mZoomEnable = isChecked;
            listener.onZoomChange(isChecked);
        } else if (id == R.id.livepusher_cb_orientation) {
            mIsPortrait = !isChecked;
            listener.onOrientationChange(mIsPortrait);
        } else if (id == R.id.livepusher_cb_pure_audio) {
            mPureAudio = isChecked;
        }
    }

    public void hideOrientationButton() {
        if (mLinearOrientation != null) {
            mLinearOrientation.setVisibility(View.GONE);
        }
    }

    public void showOrientationButton() {
        mIsPortrait = true;
        if (mLinearOrientation != null) {
            mLinearOrientation.setVisibility(View.VISIBLE);
        }
    }

    public void closePrivateModel() {
        mPrivateModel = false;
    }

    @Override
    public void onResume() {
        super.onResume();
        mCheckOrientation.setChecked(!mIsPortrait);
        mCheckPrivateModel.setChecked(mPrivateModel);
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

        /**
         * 发送sei消息
         */
        void onSendMessage(String string);
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
        Activity activity = getActivity();
        if (activity != null) {
            activity.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE)
                    .edit()
                    .putBoolean(SP_KEY_MUTE_AUDIO, mMuteAudio)
                    .putBoolean(SP_KEY_PORTRAIT, mIsPortrait)
                    .putBoolean(SP_KEY_MIRROR, mMirrorEnable)
                    .putBoolean(SP_KEY_FLASH_LIGHT, mFlashEnable)
                    .putBoolean(SP_KEY_DEBUG, mDebugInfo)
                    .putBoolean(SP_KEY_WATER_MARK, mWaterMarkEnable)
                    .putBoolean(SP_KEY_FOCUS, mFocusEnable)
                    .putBoolean(SP_KEY_ZOOM, mZoomEnable)
                    .putBoolean(SP_KEY_PURE_AUDIO, mPureAudio)
                    .apply();
        }
    }

    public void loadConfig(Context context) {
        SharedPreferences s = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        mMuteAudio = s.getBoolean(SP_KEY_MUTE_AUDIO, mMuteAudio);
        mIsPortrait = s.getBoolean(SP_KEY_PORTRAIT, mIsPortrait);
        mMirrorEnable = s.getBoolean(SP_KEY_MIRROR, mMirrorEnable);
        mFlashEnable = s.getBoolean(SP_KEY_FLASH_LIGHT, mFlashEnable);
        mDebugInfo = s.getBoolean(SP_KEY_DEBUG, mDebugInfo);
        mWaterMarkEnable = s.getBoolean(SP_KEY_WATER_MARK, mWaterMarkEnable);
        mFocusEnable = s.getBoolean(SP_KEY_FOCUS, mFocusEnable);
        mZoomEnable = s.getBoolean(SP_KEY_ZOOM, mZoomEnable);
        mPureAudio = s.getBoolean(SP_KEY_PURE_AUDIO, mPureAudio);
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

    public boolean isPureAudio() {
        return mPureAudio;
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
                ", mCbOrientation=" + mCheckOrientation +
                ", mPureAudio=" + mPureAudio +
                '}';
    }
}




