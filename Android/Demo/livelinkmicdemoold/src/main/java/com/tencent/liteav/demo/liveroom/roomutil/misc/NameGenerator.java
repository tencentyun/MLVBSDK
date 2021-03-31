package com.tencent.liteav.demo.liveroom.roomutil.misc;

import android.content.Context;

import com.tencent.liteav.demo.liveroom.R;

import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by jac on 2017/11/14.
 * Copyright © 2013-2017 Tencent Cloud. All Rights Reserved.
 */

public class NameGenerator {

    private static String[] NAMES = null;

    public static String getRandomName(Context context) {
        if (NAMES == null) {
            NAMES = context.getResources().getStringArray(R.array.mlvb_names);
        }
        Random random = new Random(System.currentTimeMillis());
        int i = Math.abs(random.nextInt() % NAMES.length);
        return NAMES[i];
    }

    public static String replaceNonPrintChar(String s, int limitLength, String concatString, boolean middleConcat) {
        String tpl = "";
        if (s != null) {
            Pattern pattern = Pattern.compile("[\\s]{2,}|\t|\r|\n");
            Matcher matcher = pattern.matcher(s);
            tpl = matcher.replaceAll(" ");
        }

        String r = tpl.trim();
        int size = (r.length() - limitLength);
        if (size > 0 && limitLength > 0) {
            if (concatString != null) {
                if (middleConcat) {
                    int start = r.length() / 2 - size / 2;
                    int end = r.length() / 2 + size / 2;
                    StringBuffer sb = new StringBuffer();
                    return sb.append(r.substring(0, start)).append(concatString).append(r.substring(end, r.length())).toString();
                } else {
                    return r.substring(0, limitLength).concat(concatString);
                }
            } else {
                return r.substring(0, limitLength);
            }
        }

        return r;
    }

}
