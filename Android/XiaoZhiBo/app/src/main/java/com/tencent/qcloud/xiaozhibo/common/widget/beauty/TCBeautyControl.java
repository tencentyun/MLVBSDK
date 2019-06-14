package com.tencent.qcloud.xiaozhibo.common.widget.beauty;

import android.app.FragmentManager;

import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.rtmp.TXLiveBase;

/**
 * Module:   TCBeautyControl
 *
 * Function: 美颜控制类
 *
 * 将美颜界面的参数，设置到 MLVB 组件中去的控制类。
 *
 */
public class TCBeautyControl implements TCBeautyDialogFragment.OnBeautyParamsChangeListener {
    private TCBeautyDialogFragment mBeautyDialogFragment;
    private TCBeautyDialogFragment.BeautyParams   mBeautyParams   = new TCBeautyDialogFragment.BeautyParams();
    private MLVBLiveRoom mLiveRoom;

    public TCBeautyControl(MLVBLiveRoom liveRoom) {
        mLiveRoom = liveRoom;
        mBeautyDialogFragment = new TCBeautyDialogFragment();
        mBeautyDialogFragment.setBeautyParamsListner(mBeautyParams,this);
        //设置默认的滤镜参数
        mLiveRoom.setFilterConcentration(0.3f);
    }

    public void show(FragmentManager manager, String tag) {
        mBeautyDialogFragment.show(manager, tag);
    }

    public void dismiss() {
        mBeautyDialogFragment.dismiss();
    }

    public boolean isAdded() {
        return mBeautyDialogFragment.isAdded();
    }

    public TCBeautyDialogFragment.BeautyParams getParams() {
        return mBeautyParams;
    }
    @Override
    public void onBeautyParamsChange(TCBeautyDialogFragment.BeautyParams params, int key) {
        switch (key){
            case TCBeautyDialogFragment.BEAUTYPARAM_BEAUTY:
            case TCBeautyDialogFragment.BEAUTYPARAM_WHITE:
                if (mLiveRoom != null) {
                    mLiveRoom.setBeautyStyle(params.mBeautyStyle, params.mBeautyProgress, params.mWhiteProgress, params.mRuddyProgress);
                }
                break;
            case TCBeautyDialogFragment.BEAUTYPARAM_FACE_LIFT:
                if (mLiveRoom != null) {
                    mLiveRoom.setFaceSlimLevel(params.mFaceLiftProgress);
                }
                break;
            case TCBeautyDialogFragment.BEAUTYPARAM_BIG_EYE:
                if (mLiveRoom != null) {
                    mLiveRoom.setEyeScaleLevel(params.mBigEyeProgress);
                }
                break;
            case TCBeautyDialogFragment.BEAUTYPARAM_FILTER:
                if (mLiveRoom != null) {
                    mLiveRoom.setFilter(TCUtils.getFilterBitmap(mBeautyDialogFragment.getResources(), params.mFilterIdx));
                }
                break;
            case TCBeautyDialogFragment.BEAUTYPARAM_MOTION_TMPL:
                if (mLiveRoom != null){
                    mLiveRoom.setMotionTmpl(params.mMotionTmplPath);
                }
                break;
            case TCBeautyDialogFragment.BEAUTYPARAM_GREEN:
                if (mLiveRoom != null){
                    mLiveRoom.setGreenScreenFile(TCUtils.getGreenFileName(params.mGreenIdx));
                }
                break;
            default:
                break;
        }
    }
}
