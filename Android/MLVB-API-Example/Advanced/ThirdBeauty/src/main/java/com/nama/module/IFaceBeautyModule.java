package com.nama.module;

/**
 * 美颜模块接口
 *
 * @author Richie on 2020.07.07
 */
public interface IFaceBeautyModule extends IEffectModule {
    /**
     * 设置需要识别的人脸个数
     *
     * @param maxFaces 默认 4 人，最大 8 人
     */
    void setMaxFaces(int maxFaces);

    /**
     * 美颜全局开关
     *
     * @param isBeautyOn 0 关，1 开，默认 1
     */
    void setIsBeautyOn(int isBeautyOn);

    /**
     * 滤镜名称
     *
     * @param name 默认 origin
     */
    void setFilterName(String name);

    /**
     * 滤镜强度
     *
     * @param level 范围 [0-1]，默认 1
     */
    void setFilterLevel(float level);

    /**
     * 磨皮程度
     *
     * @param level 范围 [0-6]，默认 6
     */
    void setBlurLevel(float level);

    /**
     * 美白程度
     *
     * @param level 范围 [0-2]，默认 0.2
     */
    void setColorLevel(float level);

    /**
     * 红润程度
     *
     * @param level 范围 [0-2]，默认 0.5
     */
    void setRedLevel(float level);

    /**
     * 亮眼程度
     *
     * @param level 范围 [0-1]，默认 1
     */
    void setEyeBright(float level);

    /**
     * 美牙程度
     *
     * @param level 范围 [0-1]，默认 1
     */
    void setToothWhiten(float level);

    /**
     * 大眼程度
     *
     * @param level 范围 [0-1]，默认 0.5
     */
    void setEyeEnlarging(float level);

    /**
     * 瘦脸程度
     *
     * @param level 范围 [0-1]，默认 0
     */
    void setCheekThinning(float level);

    /**
     * 窄脸程度
     *
     * @param level 范围 [0-1]，默认 0
     */
    void setCheekNarrow(float level);

    /**
     * 小脸程度
     *
     * @param level 范围 [0-1]，默认 0
     */
    void setCheekSmall(float level);

    /**
     * V 脸程度
     *
     * @param level 范围 [0-1]，默认 0
     */
    void setCheekV(float level);

    /**
     * 下巴调整程度
     *
     * @param intensity 范围 [0-1]，默认 0.5
     */
    void setIntensityChin(float intensity);

    /**
     * 额头调整程度
     *
     * @param intensity 范围 [0-1]，默认 0.5
     */
    void setIntensityForehead(float intensity);

    /**
     * 瘦鼻程度
     *
     * @param intensity 范围 [0-1]，默认 0
     */
    void setIntensityNose(float intensity);

    /**
     * 嘴巴调整程度
     *
     * @param intensity 范围 [0-1]，默认 0.5
     */
    void setIntensityMouth(float intensity);

    /**
     * 去黑眼圈强度
     *
     * @param strength 0.0 到 1.0 变强
     */
    void setRemovePouchStrength(float strength);

    /**
     * 去法令纹强度
     *
     * @param strength 0.0 到 1.0 变强
     */
    void setRemoveNasolabialFoldsStrength(float strength);

    /**
     * 微笑嘴角强度
     *
     * @param intensity 0.0 到 1.0 变强
     */
    void setIntensitySmile(float intensity);

    /**
     * 开眼角强度
     *
     * @param intensity 0.0 到 1.0 变强
     */
    void setIntensityCanthus(float intensity);

    /**
     * 人中长度
     *
     * @param intensity 0.5 到 1.0 是逐渐缩短，0.5 到 0.0 是逐渐增长
     */
    void setIntensityPhiltrum(float intensity);

    /**
     * 鼻子长度
     *
     * @param intensity 0.5 到 1.0 是逐渐缩短，0.5 到 0.0 是逐渐增长
     */
    void setIntensityLongNose(float intensity);

    /**
     * 眼睛间距
     *
     * @param intensity 0.5 到 1.0 是逐渐缩短，0.5 到 0.0 是逐渐增长
     */
    void setIntensityEyeSpace(float intensity);

    /**
     * 眼睛角度
     *
     * @param intensity 0.5 到 1.0 眼角向下旋转，0.5 到 0.0 眼角向上旋转
     */
    void setIntensityEyeRotate(float intensity);
}
