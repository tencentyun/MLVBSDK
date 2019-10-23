package com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by jac on 2017/11/14.
 * Copyright © 2013-2017 Tencent Cloud. All Rights Reserved.
 */

public class LoginInfo implements Parcelable {

    /**
     * 直播的appID
     */
    public long   sdkAppID;

    /**
     * 自己的用户ID
     */
    public String   userID;

    public String userSig;

    /**
     * 自己的用户名称
     */
    public String   userName;

    /**
     * 自己的头像地址
     */
    public String   userAvatar;


    public LoginInfo() {

    }

    public LoginInfo(int sdkAppID, String userID, String userName, String userAvatar, String userSig) {
        this.sdkAppID = sdkAppID;
        this.userID = userID;
        this.userName = userName;
        this.userAvatar = userAvatar;
        this.userSig = userSig;
    }

    protected LoginInfo(Parcel in) {
        this.userID = in.readString();
        this.userName = in.readString();
        this.userAvatar = in.readString();
        this.userSig = in.readString();
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.userID);
        dest.writeString(this.userName);
        dest.writeString(this.userAvatar);
        dest.writeString(this.userSig);
    }

    public static final Parcelable.Creator<LoginInfo> CREATOR = new Parcelable.Creator<LoginInfo>() {
        @Override
        public LoginInfo createFromParcel(Parcel source) {
            return new LoginInfo(source);
        }

        @Override
        public LoginInfo[] newArray(int size) {
            return new LoginInfo[size];
        }
    };
}
