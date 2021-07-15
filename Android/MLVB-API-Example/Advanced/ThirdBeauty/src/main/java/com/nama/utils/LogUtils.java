package com.nama.utils;

import android.util.Log;

/**
 * 日志工具类
 *
 * @author Richie on 2020.07.07
 */
public final class LogUtils {
    private static final String GLOBAL_ATG = "[NAMA_LOG] ";
    /**
     * Log level
     */
    public static final int VERBOSE = Log.VERBOSE;
    public static final int DEBUG = Log.DEBUG;
    public static final int INFO = Log.INFO;
    public static final int WARN = Log.WARN;
    public static final int ERROR = Log.ERROR;
    public static final int OFF = 7;

    private static int sLogLevel = OFF;

    private LogUtils() {
    }

    public static void setLogLevel(int level) {
        sLogLevel = level;
    }

    public static boolean isLoggable(int level) {
        return sLogLevel >= level;
    }


    public static void verbose(String tag, String msg, Object... obj) {
        if (VERBOSE >= sLogLevel) {
            Log.v(GLOBAL_ATG + tag, String.format(msg, obj));
        }
    }

    public static void debug(String tag, String msg, Object... obj) {
        if (DEBUG >= sLogLevel) {
            Log.d(GLOBAL_ATG + tag, String.format(msg, obj));
        }
    }

    public static void info(String tag, String msg, Object... obj) {
        if (INFO >= sLogLevel) {
            Log.i(GLOBAL_ATG + tag, String.format(msg, obj));
        }
    }

    public static void warn(String tag, String msg, Throwable tr) {
        if (Log.WARN >= sLogLevel) {
            Log.w(GLOBAL_ATG + tag, msg, tr);
        }
    }

    public static void warn(String tag, String msg, Object... obj) {
        if (WARN >= sLogLevel) {
            Log.w(GLOBAL_ATG + tag, String.format(msg, obj));
        }
    }

    public static void error(String tag, String msg, Object... obj) {
        if (ERROR >= sLogLevel) {
            Log.e(GLOBAL_ATG + tag, String.format(msg, obj));
        }
    }

    public static void warn(String tag, Throwable tr) {
        if (Log.WARN >= sLogLevel) {
            Log.w(GLOBAL_ATG + tag, tr);
        }
    }

    public static void error(String tag, String msg, Throwable tr) {
        if (Log.ERROR >= sLogLevel) {
            Log.e(GLOBAL_ATG + tag, msg, tr);
        }
    }

    public static void error(String tag, Throwable tr) {
        if (Log.ERROR >= sLogLevel) {
            Log.e(GLOBAL_ATG + tag, "", tr);
        }
    }

    public static void error(Throwable throwable) {
        if (ERROR >= sLogLevel) {
            Log.e(GLOBAL_ATG, throwable.getMessage());
        }
    }

}