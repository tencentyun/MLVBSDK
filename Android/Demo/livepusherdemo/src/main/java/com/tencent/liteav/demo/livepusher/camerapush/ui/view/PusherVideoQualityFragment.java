package com.tencent.liteav.demo.livepusher.camerapush.ui.view;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.BottomSheetDialog;
import android.support.design.widget.BottomSheetDialogFragment;
import android.support.v4.app.FragmentManager;
import android.view.View;

import com.tencent.liteav.demo.livepusher.R;
import com.tencent.rtmp.TXLiveConstants;

/**
 * 画质设置面板
 */
public class PusherVideoQualityFragment extends BottomSheetDialogFragment {

    /**
     * SharePreferences 用于存储相关配置的key
     */
    public static final String SP_NAME              = "sp_pusher_setting";
    public static final String SP_KEY_VIDEO_QUALITY = "sp_key_video_quality";

    // 对应 SDK 的画质列表（TXLiveConstants中定义）
    private static final int[] VIDEO_QUALITY_TYPE_ARR = new int[]{
            TXLiveConstants.VIDEO_QUALITY_ULTRA_DEFINITION,
            TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION,
            TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION,
            TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION,
            TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER,
            TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER,
            TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT};

    private BottomSheetBehavior          mBehavior;
    private OnVideoQualityChangeListener mOnVideoQualityChangeListener;
    private BottomSheetDialog            mBottomSheetDialog;

    private int mQualityIndex = 1;

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = (BottomSheetDialog) super.onCreateDialog(savedInstanceState);
            RadioSelectView view = new RadioSelectView(getActivity());
            initViews(view);
            mBottomSheetDialog.setContentView(view);
            mBottomSheetDialog.getWindow().findViewById(R.id.design_bottom_sheet)
                    .setBackgroundResource(android.R.color.transparent);
            mBehavior = BottomSheetBehavior.from((View) view.getParent());
        }
        return mBottomSheetDialog;
    }

    private void initViews(RadioSelectView view) {
        view.setData(getResources().getStringArray(R.array.livepusher_video_quality_list), mQualityIndex);
        view.setTitle(getString(R.string.livepusher_video_quality));
        view.setRadioSelectListener(new RadioSelectView.RadioSelectListener() {
            @Override
            public void onClose() {
                dismissAllowingStateLoss();
            }

            @Override
            public void onChecked(int prePosition, RadioButton preRadioButton, int curPosition, RadioButton curRadioButton) {
                onQualityChange(curPosition);
                dismissAllowingStateLoss();
            }
        });
    }

    private void onQualityChange(int position) {
        mQualityIndex = position;
        if (mOnVideoQualityChangeListener != null) {
            mOnVideoQualityChangeListener.onQualityChange(VIDEO_QUALITY_TYPE_ARR[position]);
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        mBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);//全屏展开
    }

    @Override
    public void onPause() {
        super.onPause();
        saveConfigIntoSp();
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

    /**
     * 保存配置到 SharePreferences
     */
    private void saveConfigIntoSp() {
        Activity activity = getActivity();
        if (activity != null) {
            activity.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE)
                    .edit()
                    .putInt(SP_KEY_VIDEO_QUALITY, mQualityIndex)
                    .apply();
        }
    }

    public void loadConfig(Context context) {
        SharedPreferences s = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        mQualityIndex = s.getInt(SP_KEY_VIDEO_QUALITY, mQualityIndex);
    }

    @Override
    public void dismissAllowingStateLoss() {
        try {
            super.dismissAllowingStateLoss();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int getQualityType() {
        return VIDEO_QUALITY_TYPE_ARR[mQualityIndex];
    }

    public void toggle(FragmentManager manager, String tag) {
        if (isVisible()) {
            dismissAllowingStateLoss();
        } else {
            show(manager, tag);
        }
    }

    public void setOnVideoQualityChangeListener(OnVideoQualityChangeListener onVideoQualityChangeListener) {
        mOnVideoQualityChangeListener = onVideoQualityChangeListener;
    }

    public interface OnVideoQualityChangeListener {

        /**
         * 视频编码质量
         *
         * @param type
         */
        void onQualityChange(int type);
    }
}
