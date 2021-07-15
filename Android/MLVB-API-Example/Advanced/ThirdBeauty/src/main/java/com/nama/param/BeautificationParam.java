package com.nama.param;

/**
 * 美颜道具参数，包含红润、美白、磨皮、滤镜、变形、亮眼、美牙等功能。
 *
 * @author Richie on 2019.07.18
 */
public final class BeautificationParam {
    /**
     * 美颜参数全局开关，0 关，1 开，默认 1
     */
    public static final String IS_BEAUTY_ON = "is_beauty_on";
    /**
     * 美颜道具是否使用人脸点位能力，关闭后美型不可用。0 为关，1 为开，默认 1
     */
    public static final String USE_LANDMARK = "use_landmark";
    /**
     * 滤镜名称，默认 origin
     */
    public static final String FILTER_NAME = "filter_name";
    /**
     * 滤镜程度，范围 [0-1]，默认 1
     */
    public static final String FILTER_LEVEL = "filter_level";
    /**
     * 美白程度，范围 [0-2]，默认 0.2
     */
    public static final String COLOR_LEVEL = "color_level";
    /**
     * 锐化程度，范围 [0-1]，默认 0.0
     */
    public static final String SHARPEN = "sharpen";
    /**
     * 红润程度，范围 [0-2]，默认 0.5
     */
    public static final String RED_LEVEL = "red_level";
    /**
     * 磨皮程度，范围 [0-6]，默认 6
     */
    public static final String BLUR_LEVEL = "blur_level";
    /**
     * 磨皮类型，0 清晰磨皮  1 朦胧磨皮  2精细磨皮。
     * 此参数优先级比 heavy_blur 低，在使用时要将 heavy_blur 设为 0
     */
    public static final String BLUR_TYPE = "blur_type";
    /**
     * 1 为开启基于人脸的磨皮 mask，0 为不使用 mask 正常磨皮。只在 blur_type 为 2 时生效。默认为 0
     */
    public static final String BLUR_USE_MASK = "blur_use_mask";
    /**
     * 肤色检测开关，0 关，1 开，默认 0
     */
    public static final String SKIN_DETECT = "skin_detect";
    /**
     * 肤色检测之后非肤色区域的融合程度，取值范围 0.0-1.0，默认 0.0
     */
    public static final String NONSKIN_BLUR_SCALE = "nonskin_blur_scale";
    /**
     * 朦胧磨皮开关，0 为清晰磨皮，1 为朦胧磨皮
     */
    public static final String HEAVY_BLUR = "heavy_blur";
    /**
     * 亮眼程度，范围 [0-1]，默认 1
     */
    public static final String EYE_BRIGHT = "eye_bright";
    /**
     * 美牙程度，范围 [0-1]，默认 1
     */
    public static final String TOOTH_WHITEN = "tooth_whiten";
    /**
     * 变形选择，0 女神，1 网红，2 自然，3 默认，4 精细变形，默认 3
     */
    public static final String FACE_SHAPE = "face_shape";
    /**
     * 变形程度，0-1，默认 1
     */
    public static final String FACE_SHAPE_LEVEL = "face_shape_level";
    /**
     * 下颌骨，范围 [0-1]，默认 0
     */
    public static final String INTENSITY_LOW_JAW = "intensity_lower_jaw";
    /**
     * 颧骨，范围 [0-1]，默认 0
     */
    public static final String INTENSITY_CHEEKBONES = "intensity_cheekbones";
    /**
     * 圆眼，范围 [0-1]，默认 0.5
     */
    public static final String INTENSITY_EYE_CIRCLE = "intensity_eye_circle";
    /**
     * 大眼程度，范围 [0-1]，默认 0.5
     */
    public static final String EYE_ENLARGING = "eye_enlarging";
    /**
     * 瘦脸程度，范围 [0-1]，默认 0
     */
    public static final String CHEEK_THINNING = "cheek_thinning";
    /**
     * 窄脸程度，范围 [0-1]，默认 0
     */
    public static final String CHEEK_NARROW = "cheek_narrow";
    /**
     * 小脸程度，范围 [0-1]，默认 0
     */
    public static final String CHEEK_SMALL = "cheek_small";
    /**
     * V脸程度，范围 [0-1]，默认 0
     */
    public static final String CHEEK_V = "cheek_v";
    /**
     * 瘦鼻程度，范围 [0-1]，默认 0
     */
    public static final String INTENSITY_NOSE = "intensity_nose";
    /**
     * 嘴巴调整程度，范围 [0-1]，0-0.5是变小，0.5-1是变大，默认 0.5
     */
    public static final String INTENSITY_MOUTH = "intensity_mouth";
    /**
     * 额头调整程度，范围 [0-1]，0-0.5 是变小，0.5-1 是变大，默认 0.5
     */
    public static final String INTENSITY_FOREHEAD = "intensity_forehead";
    /**
     * 下巴调整程度，范围 [0-1]，0-0.5是变小，0.5-1是变大，默认 0.5
     */
    public static final String INTENSITY_CHIN = "intensity_chin";
    /**
     * 变形渐变调整参数，0 渐变关闭，大于 0 渐变开启，值为渐变需要的帧数
     */
    public static final String CHANGE_FRAMES = "change_frames";
    /**
     * 去黑眼圈强度，范围 [0-1]，0.0 到 1.0 变强，默认 0
     */
    public static final String REMOVE_POUCH_STRENGTH = "remove_pouch_strength";
    /**
     * 去法令纹强度，范围 [0-1]，0.0 到 1.0 变强，默认 0
     */
    public static final String REMOVE_NASOLABIAL_FOLDS_STRENGTH = "remove_nasolabial_folds_strength";
    /**
     * 微笑嘴角强度，范围 [0-1]，0.0 到 1.0 变强
     */
    public static final String INTENSITY_SMILE = "intensity_smile";
    /**
     * 开眼角强度，范围 [0-1]，0.0 到 1.0 变强
     */
    public static final String INTENSITY_CANTHUS = "intensity_canthus";
    /**
     * 调节人中，范围 [0-1]，0.5-1.0 变长，0.5-0.0 变短
     */
    public static final String INTENSITY_PHILTRUM = "intensity_philtrum";
    /**
     * 鼻子长度，范围 [0-1]，0.5-0.0 变短，0.5-1.0 变长
     */
    public static final String INTENSITY_LONG_NOSE = "intensity_long_nose";
    /**
     * 眼睛间距，范围 [0-1]，0.5-0.0 变长，0.5-1.0 变短
     */
    public static final String INTENSITY_EYE_SPACE = "intensity_eye_space";
    /**
     * 眼睛角度，范围 [0-1]，0.5-0.0 逆时针旋转，0.5-1.0 顺时针旋转
     */
    public static final String INTENSITY_EYE_ROTATE = "intensity_eye_rotate";

    /**
     * 滤镜使用的 key
     */
    public static final String ORIGIN = "origin";
    public static final String FENNEN_1 = "fennen1";
    public static final String FENNEN_2 = "fennen2";
    public static final String FENNEN_3 = "fennen3";
    public static final String FENNEN_4 = "fennen4";
    public static final String FENNEN_5 = "fennen5";
    public static final String FENNEN_6 = "fennen6";
    public static final String FENNEN_7 = "fennen7";
    public static final String FENNEN_8 = "fennen8";
    public static final String XIAOQINGXIN_1 = "xiaoqingxin1";
    public static final String XIAOQINGXIN_2 = "xiaoqingxin2";
    public static final String XIAOQINGXIN_3 = "xiaoqingxin3";
    public static final String XIAOQINGXIN_4 = "xiaoqingxin4";
    public static final String XIAOQINGXIN_5 = "xiaoqingxin5";
    public static final String XIAOQINGXIN_6 = "xiaoqingxin6";
    public static final String BAILIANG_1 = "bailiang1";
    public static final String BAILIANG_2 = "bailiang2";
    public static final String BAILIANG_3 = "bailiang3";
    public static final String BAILIANG_4 = "bailiang4";
    public static final String BAILIANG_5 = "bailiang5";
    public static final String BAILIANG_6 = "bailiang6";
    public static final String BAILIANG_7 = "bailiang7";
    public static final String LENGSEDIAO_1 = "lengsediao1";
    public static final String LENGSEDIAO_2 = "lengsediao2";
    public static final String LENGSEDIAO_3 = "lengsediao3";
    public static final String LENGSEDIAO_4 = "lengsediao4";
    public static final String LENGSEDIAO_5 = "lengsediao5";
    public static final String LENGSEDIAO_6 = "lengsediao6";
    public static final String LENGSEDIAO_7 = "lengsediao7";
    public static final String LENGSEDIAO_8 = "lengsediao8";
    public static final String LENGSEDIAO_9 = "lengsediao9";
    public static final String LENGSEDIAO_10 = "lengsediao10";
    public static final String LENGSEDIAO_11 = "lengsediao11";
    public static final String NUANSEDIAO_1 = "nuansediao1";
    public static final String NUANSEDIAO_2 = "nuansediao2";
    public static final String NUANSEDIAO_3 = "nuansediao3";
    public static final String HEIBAI_1 = "heibai1";
    public static final String HEIBAI_2 = "heibai2";
    public static final String HEIBAI_3 = "heibai3";
    public static final String HEIBAI_4 = "heibai4";
    public static final String HEIBAI_5 = "heibai5";
    public static final String GEXING_1 = "gexing1";
    public static final String GEXING_2 = "gexing2";
    public static final String GEXING_3 = "gexing3";
    public static final String GEXING_4 = "gexing4";
    public static final String GEXING_5 = "gexing5";
    public static final String GEXING_6 = "gexing6";
    public static final String GEXING_7 = "gexing7";
    public static final String GEXING_8 = "gexing8";
    public static final String GEXING_9 = "gexing9";
    public static final String GEXING_10 = "gexing10";
    public static final String GEXING_11 = "gexing11";
    public static final String ZIRAN_1 = "ziran1";
    public static final String ZIRAN_2 = "ziran2";
    public static final String ZIRAN_3 = "ziran3";
    public static final String ZIRAN_4 = "ziran4";
    public static final String ZIRAN_5 = "ziran5";
    public static final String ZIRAN_6 = "ziran6";
    public static final String ZIRAN_7 = "ziran7";
    public static final String ZIRAN_8 = "ziran8";
    public static final String ZHIGANHUI_1 = "zhiganhui1";
    public static final String ZHIGANHUI_2 = "zhiganhui2";
    public static final String ZHIGANHUI_3 = "zhiganhui3";
    public static final String ZHIGANHUI_4 = "zhiganhui4";
    public static final String ZHIGANHUI_5 = "zhiganhui5";
    public static final String ZHIGANHUI_6 = "zhiganhui6";
    public static final String ZHIGANHUI_7 = "zhiganhui7";
    public static final String ZHIGANHUI_8 = "zhiganhui8";
    public static final String MITAO_1 = "mitao1";
    public static final String MITAO_2 = "mitao2";
    public static final String MITAO_3 = "mitao3";
    public static final String MITAO_4 = "mitao4";
    public static final String MITAO_5 = "mitao5";
    public static final String MITAO_6 = "mitao6";
    public static final String MITAO_7 = "mitao7";
    public static final String MITAO_8 = "mitao8";

}
