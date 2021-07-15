package com.nama.utils;

/**
 * 数值工具类
 *
 * @author Richie on 2019.07.05
 */
public final class DecimalUtils {
    /**
     * 两个浮点数的差值小于 0.01 认为相等，浮点数不要用 == 判断相等
     */
    private static final float THRESHOLD = 0.01F;

    private DecimalUtils() {
    }

    public static boolean floatEquals(float a, float b) {
        return Math.abs(a - b) < THRESHOLD;
    }

    public static boolean doubleEquals(double a, double b) {
        return Math.abs(a - b) < THRESHOLD;
    }

    public static boolean floatArrayEquals(float[] a, float[] b) {
        if (a == null && b == null) {
            return true;
        } else if (a == null || b == null) {
            return false;
        } else {
            if (a.length != b.length) {
                return false;
            }
        }

        for (int i = 0; i < a.length; i++) {
            if (!floatEquals(a[i], b[i])) {
                return false;
            }
        }
        return true;
    }

    public static boolean doubleArrayEquals(double[] a, double[] b) {
        if (a == null && b == null) {
            return true;
        } else if (a == null || b == null) {
            return false;
        } else {
            if (a.length != b.length) {
                return false;
            }
        }

        for (int i = 0; i < a.length; i++) {
            if (!doubleEquals(a[i], b[i])) {
                return false;
            }
        }
        return true;
    }

}
