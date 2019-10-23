package com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef;

import android.os.Parcel;
import android.os.Parcelable;

public class AnchorInfo implements Parcelable {

    /**
     * 用户ID
     */
    public String   userID;

    /**
     * 用户昵称
     */
    public String   userName;

    /**
     * 用户头像地址
     */
    public String   userAvatar;

    /**
     * 低时延拉流地址（带防盗链key）
     */
    public String   accelerateURL;


    public AnchorInfo() {

    }

    public AnchorInfo(String userID, String userName, String userAvatar, String accelerateURL) {
        this.userID = userID;
        this.userName = userName;
        this.userAvatar = userAvatar;
        this.accelerateURL = accelerateURL;
    }

    protected AnchorInfo(Parcel in) {
        this.userID = in.readString();
        this.userName = in.readString();
        this.accelerateURL = in.readString();
        this.userAvatar = in.readString();
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.userID);
        dest.writeString(this.userName);
        dest.writeString(this.accelerateURL);
        dest.writeString(this.userAvatar);
    }

    public static final Parcelable.Creator<AnchorInfo> CREATOR = new Parcelable.Creator<AnchorInfo>() {
        @Override
        public AnchorInfo createFromParcel(Parcel source) {
            return new AnchorInfo(source);
        }

        @Override
        public AnchorInfo[] newArray(int size) {
            return new AnchorInfo[size];
        }
    };

    @Override
    public int hashCode() {
        return userID.hashCode();
    }

    @Override
    public String toString() {
        return "AnchorInfo{" +
                "userID='" + userID + '\'' +
                ", userName='" + userName + '\'' +
                ", accelerateURL='" + accelerateURL + '\'' +
                ", userAvatar='" + userAvatar + '\'' +
                '}';
    }
}
