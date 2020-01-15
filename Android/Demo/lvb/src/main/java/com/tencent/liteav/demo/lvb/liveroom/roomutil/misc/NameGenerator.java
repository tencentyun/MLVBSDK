package com.tencent.liteav.demo.lvb.liveroom.roomutil.misc;

import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by jac on 2017/11/14.
 * Copyright © 2013-2017 Tencent Cloud. All Rights Reserved.
 */

public class NameGenerator {

    private static final String[] NAMES = {
            "宋 江", "卢俊义", "吴 用", "林 冲", "秦 明", "呼延灼", "花 荣", "李 应",
            "鲁智深", "武 松", "董 平", "张 清", "扬 志", "徐 宁", "阮小二", "扈三娘",
            "韩滔", "萧让", "裴宣", "樊瑞", "圣李衮", "汤隆", "郑天寿", "梦奇", "苏烈",
            "大乔", "小乔", "成吉思汗", "诸葛亮", "后羿", "露娜", "吕布","刘邦","雅典娜",
            "东皇太一","李元芳", "花木兰", "兰陵王"
    };

    public static String getRandomName(){
        Random random = new Random(System.currentTimeMillis());
        int i = Math.abs(random.nextInt()%NAMES.length);
        return NAMES[i];
    }

    public static String getRandomUserID() {
        return Long.toHexString(System.currentTimeMillis());
    }

    public static String replaceNonPrintChar(String s, int limitLength, String concatString, boolean middleConcat){
        String tpl="";
        if (s != null){
            Pattern pattern = Pattern.compile("[\\s]{2,}|\t|\r|\n");
            Matcher matcher = pattern.matcher(s);
            tpl = matcher.replaceAll(" ");
        }

        String r = tpl.trim();
        int size = ( r.length() - limitLength);
        if (size > 0 && limitLength > 0) {
            if (concatString != null) {
                if (middleConcat) {
                    int start = r.length() / 2 - size / 2;
                    int end = r.length() / 2 + size / 2;
                    StringBuffer sb = new StringBuffer();
                    String newString = sb.append(r.substring(0, start)).append(concatString).append(r.substring(end, r.length())).toString();
                    return newString;
                } else {
                    return r.substring(0, limitLength).concat(concatString);
                }
            }else {
                return r.substring(0, limitLength);
            }
        }

        return r;
    }

}
