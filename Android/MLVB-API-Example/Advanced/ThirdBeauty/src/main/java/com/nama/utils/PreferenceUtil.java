package com.nama.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.text.TextUtils;

public class PreferenceUtil {
    public static final String KEY_FACEUNITY_IS_ON = "faceunity_is_on";
    public static final String VALUE_ON = "on";
    public static final String VALUE_OFF = "off";

    public static boolean persistString(Context context, String key, String value) {
        if (context == null || TextUtils.isEmpty(key)) {
            return false;
        }
        SharedPreferences defaultPreference = PreferenceManager.getDefaultSharedPreferences(context);
        try {
            defaultPreference.edit().putString(key, value).apply();
        } catch (Exception e) {
            return false;
        }
        return true;
    }

    public static String getString(Context context, String key) {
        if (context == null || TextUtils.isEmpty(key)) {
            return null;
        }
        SharedPreferences defaultPreference = PreferenceManager.getDefaultSharedPreferences(context);
        try {
            return defaultPreference.getString(key, PreferenceUtil.VALUE_ON);
        } catch (Exception e) {
            return null;
        }
    }

}
