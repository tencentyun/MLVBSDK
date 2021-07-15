package com.nama.param;

/**
 * 美体道具参数
 *
 * @author Richie on 2019.11.25
 */
public final class BodySlimParam {
    /**
     * 0.0~1.0，值越大，瘦身幅度越大，0.0为不变形
     */
    public static final String BODY_SLIM_STRENGTH = "BodySlimStrength";
    /**
     * 0.0~1.0，值越大，腿拉伸幅度越大，0.0为不变形
     */
    public static final String LEG_SLIM_STRENGTH = "LegSlimStrength";
    /**
     * 0.0~1.0，值越大，瘦腰幅度越大，0.0为不变形
     */
    public static final String WAIST_SLIM_STRENGTH = "WaistSlimStrength";
    /**
     * 0.0~1.0，小于0.5肩膀变窄，大于0.5肩膀变宽，0.5为不变形
     */
    public static final String SHOULDER_SLIM_STRENGTH = "ShoulderSlimStrength";
    /**
     * 0.0~1.0，值越大，臀部变宽上提越大，0.0为不变形
     */
    public static final String HIP_SLIM_STRENGTH = "HipSlimStrength";
    /**
     * 小头，0.0~1.0  程度渐强，默认 0.0
     */
    public static final String HEAD_SLIM = "HeadSlim";
    /**
     * 瘦腿，0.0~1.0  程度渐强，默认 0.0
     */
    public static final String LEG_SLIM = "LegSlim";
    /**
     * 清除所有身体变形
     */
    public static final String CLEAR_SLIM = "ClearSlim";
    /**
     * 设置相机方向 0, 1, 2, 3
     */
    public static final String ORIENTATION = "Orientation";
    /**
     * 参数 0.0 或者 1.0,  0.0 为关闭点位绘制，1.0 为打开，默认关闭
     */
    public static final String DEBUG = "Debug";
}
