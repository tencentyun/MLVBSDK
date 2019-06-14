package com.tencent.qcloud.xiaozhibo.common.msg;

/**
 * Module:   TCSimpleUserInfo
 * <p>
 * Function: 用户基本信息封装
 */
public class TCSimpleUserInfo {

    public String userid;       // userId
    public String nickname;     // 昵称
    public String avatar;       // 头像链接

    public TCSimpleUserInfo(String userId, String nickname, String avatar) {
        this.userid = userId;
        this.nickname = nickname;
        this.avatar = avatar;
    }
}
