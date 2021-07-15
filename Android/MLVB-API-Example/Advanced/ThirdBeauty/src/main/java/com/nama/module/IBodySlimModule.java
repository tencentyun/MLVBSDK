package com.nama.module;

/**
 * 美体模块接口
 *
 * @author Richie on 2020.07.07
 */
public interface IBodySlimModule extends IEffectModule {
    /**
     * 设置最大人体数量
     *
     * @param maxHumans 最大支持 1 人
     */
    void setMaxHumans(int maxHumans);

    /**
     * 设置瘦身程度
     *
     * @param intensity 范围 [0-1]，0 为不变形
     */
    void setBodySlimIntensity(float intensity);

    /**
     * 设置长腿程度
     *
     * @param intensity 范围 [0-1]，0 为不变形
     */
    void setLegSlimIntensity(float intensity);

    /**
     * 设置细腰程度
     *
     * @param intensity 范围 [0-1]，0 为不变形
     */
    void setWaistSlimIntensity(float intensity);

    /**
     * 设置美肩程度
     *
     * @param intensity 范围 [0-1]，0.5 为不变形
     */
    void setShoulderSlimIntensity(float intensity);

    /**
     * 设置美臀程度
     *
     * @param intensity 范围 [0-1]，0 为不变形
     */
    void setHipSlimIntensity(float intensity);

    /**
     * 设置小头程度
     *
     * @param intensity 范围 [0-1]，0 为不变形
     */
    void setHeadSlimIntensity(float intensity);

    /**
     * 设置瘦腿程度
     *
     * @param intensity 范围 [0-1]，0 为不变形
     */
    void setLegThinSlimIntensity(float intensity);
}
