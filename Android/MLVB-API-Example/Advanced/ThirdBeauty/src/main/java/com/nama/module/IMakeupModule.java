package com.nama.module;


import com.nama.entity.Makeup;

/**
 * 美妆模块接口
 *
 * @author Richie on 2020.07.07
 */
public interface IMakeupModule extends IEffectModule {
    /**
     * 选择美妆
     *
     * @param makeup
     */
    void selectMakeup(Makeup makeup);

    /**
     * 调节美妆强度
     *
     * @param intensity 范围 [0-1]
     */
    void setMakeupIntensity(float intensity);

    /**
     * 美妆点位镜像
     *
     * @param isMakeupFlipPoints 0 为关闭，1 为开启
     */
    void setIsMakeupFlipPoints(int isMakeupFlipPoints);

    /**
     * 设置美妆选择回调
     *
     * @param onMakeupSelectedListener
     */
    void setOnMakeupSelectedListener(OnMakeupSelectedListener onMakeupSelectedListener);

    interface OnMakeupSelectedListener {
        /**
         * 选择美妆
         *
         * @param itemHandle 句柄
         */
        void onMakeupSelected(int itemHandle);
    }
}
