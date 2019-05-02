package com.tencent.qcloud.xiaozhibo.im;

/**
 * Created by Administrator on 2016/8/22.
 * 用户基本信息封装 id、nickname、faceurl
 */
public class TCSimpleUserInfo {

    public String userid;
    public String nickname;
    public String headpic;

    public TCSimpleUserInfo(String userId, String nickname, String headpic) {
        this.userid = userId;
        this.nickname = nickname;
        this.headpic = headpic;
    }
}
