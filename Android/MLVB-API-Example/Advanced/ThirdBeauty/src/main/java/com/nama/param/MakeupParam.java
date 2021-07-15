package com.nama.param;

/**
 * @author Richie on 2020.06.20
 */
public final class MakeupParam {
    /**
     * 美妆开关，1 为开，0 为关
     */
    public static final String IS_MAKEUP_ON = "is_makeup_on";
    /**
     * 整体妆容强度，范围 [0-1]
     */
    public static final String MAKEUP_INTENSITY = "makeup_intensity";
    /**
     * 在解绑妆容时，是否要清空妆容，0 表示不清除，1 表示清除
     */
    public static final String IS_CLEAR_MAKEUP = "is_clear_makeup";
    /**
     * 口红双色开关，0 为关闭，1 为开启。如果想使用咬唇，开启双色开关，并且将 makeup_lip_color2 的值都设置为 0
     */
    public static final String IS_TWO_COLOR = "is_two_color";
    /**
     * 口红类型，0 雾面，1 缎面，2 润泽，3 珠光
     */
    public static final String LIP_TYPE = "lip_type";
    /**
     * 嘴唇优化效果开关，1 为开，0 为关
     */
    public static final String MAKEUP_LIP_MASK = "makeup_lip_mask";
    /**
     * 点位镜像，1 为开，0 为关
     */
    public static final String IS_FLIP_POINTS = "is_flip_points";
    /**
     * 是否使用眉毛变形，1 为开，0 为关
     */
    public static final String BROW_WARP = "brow_warp";
    /**
     * 眉毛变形类型 0柳叶眉  1一字眉  2远山眉 3标准眉 4扶形眉  5日常风 6日系风
     */
    public static final String BROW_WARP_TYPE = "brow_warp_type";
    /**
     * 下面是各个妆容的颜色值
     */
    public static final String MAKEUP_EYE_BROW_COLOR = "makeup_eyeBrow_color";
    public static final String MAKEUP_LIP_COLOR = "makeup_lip_color";
    public static final String MAKEUP_LIP_COLOR2 = "makeup_lip_color2";
    public static final String MAKEUP_EYE_COLOR = "makeup_eye_color";
    public static final String MAKEUP_EYE_LINER_COLOR = "makeup_eyeLiner_color";
    public static final String MAKEUP_EYELASH_COLOR = "makeup_eyelash_color";
    public static final String MAKEUP_BLUSHER_COLOR = "makeup_blusher_color";
    public static final String MAKEUP_FOUNDATION_COLOR = "makeup_foundation_color";
    public static final String MAKEUP_HIGHLIGHT_COLOR = "makeup_highlight_color";
    public static final String MAKEUP_SHADOW_COLOR = "makeup_shadow_color";
    public static final String MAKEUP_PUPIL_COLOR = "makeup_pupil_color";

    /**
     * 下面是各个妆容强度参数，范围 [0-1]
     */
    public static final String MAKEUP_INTENSITY_LIP = "makeup_intensity_lip";
    public static final String MAKEUP_INTENSITY_EYE_LINER = "makeup_intensity_eyeLiner";
    public static final String MAKEUP_INTENSITY_BLUSHER = "makeup_intensity_blusher";
    public static final String MAKEUP_INTENSITY_PUPIL = "makeup_intensity_pupil";
    public static final String MAKEUP_INTENSITY_EYE_BROW = "makeup_intensity_eyeBrow";
    public static final String MAKEUP_INTENSITY_EYE = "makeup_intensity_eye";
    public static final String MAKEUP_INTENSITY_EYELASH = "makeup_intensity_eyelash";
    public static final String MAKEUP_INTENSITY_FOUNDATION = "makeup_intensity_foundation";
    public static final String MAKEUP_INTENSITY_HIGHLIGHT = "makeup_intensity_highlight";
    public static final String MAKEUP_INTENSITY_SHADOW = "makeup_intensity_shadow";
}
