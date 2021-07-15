package com.nama.utils;

import android.os.SystemClock;
import android.util.Log;

/**
 * 帧率限制
 *
 * @author Richie on 2019.04.13
 */
public final class LimitFpsUtil {
    private static final String TAG = "LimitFpsUtil";
    private static long frameStartTimeMs;
    private static long frameCount;
    private static long startTimeMs;

    private LimitFpsUtil() {
    }

    public static void limitFrameRate(int fps) {
        long elapsedFrameTimeUs = SystemClock.elapsedRealtime() - frameStartTimeMs;
        long expectedFrameTimeUs = 1000 / fps;
        long timeToSleepMs = expectedFrameTimeUs - elapsedFrameTimeUs;
        if (timeToSleepMs > 0) {
            SystemClock.sleep(timeToSleepMs);
        }
        frameStartTimeMs = SystemClock.elapsedRealtime();
    }

    public static void logFrameRate() {
        long elapsedRealtimeMs = SystemClock.elapsedRealtime();
        double elapsedSeconds = (float) (elapsedRealtimeMs - startTimeMs) / 1000;
        if (elapsedSeconds >= 1.0) {
            int fps = (int) (frameCount / elapsedSeconds);
            Log.v(TAG, "logFrameRate: " + fps);
            startTimeMs = SystemClock.elapsedRealtime();
            frameCount = 0;
        }
        frameCount++;
    }
}
