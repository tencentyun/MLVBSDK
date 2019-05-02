package com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef;

import android.os.Parcel;
import android.os.Parcelable;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by jac on 2017/10/30.
 */

public class RoomInfo implements Parcelable {

    /**
     * 房间ID
     */
    public String   roomID;

    /**
     * 房间信息（创建房间时传入）
     */
    public String   roomInfo;

    /**
     * 房间名称
     */
    public String   roomName;

    /**
     * 房间创建者ID
     */
    public String   roomCreator;

    /**
     * 房间创建者的拉流地址（实时模式下不使用该字段；直播模式下就是主播的拉流地址；连麦模式下就是混流地址）
     */
    public String   mixedPlayURL;

    /**
     * 房间成员列表
     */
    public List<AnchorInfo> pushers;

    /**
     * 房间观众数
     */
    public int audienceCount;

    /**
     * 房间观众列表
     */
    public List<Audience> audiences;

    /**
     * 房间自定义数据
     */
    public String custom;

    public static class Audience {
        public String userID;     //观众ID
        public String userInfo;   //观众信息
        public String userName;
        public String userAvatar;

        public void transferUserInfo() {
            JSONObject jsonRoomInfo = null;
            try {
                jsonRoomInfo = new JSONObject(userInfo);
                userName    = jsonRoomInfo.optString("userName");
                userAvatar  = jsonRoomInfo.optString("userAvatar");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public RoomInfo() {

    }

    public RoomInfo(String roomID, String roomInfo, String roomName, String roomCreator, String mixedPlayURL, List<AnchorInfo> anchors) {
        this.roomID = roomID;
        this.roomInfo = roomInfo;
        this.roomName = roomName;
        this.roomCreator = roomCreator;
        this.mixedPlayURL = mixedPlayURL;
        this.pushers = anchors;
    }

    protected RoomInfo(Parcel in) {
        this.roomID = in.readString();
        this.roomInfo = in.readString();
        this.roomName = in.readString();
        this.roomCreator = in.readString();
        this.mixedPlayURL = in.readString();
        this.pushers = new ArrayList<AnchorInfo>();
        in.readList(this.pushers, AnchorInfo.class.getClassLoader());
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.roomID);
        dest.writeString(this.roomInfo);
        dest.writeString(this.roomName);
        dest.writeString(this.roomCreator);
        dest.writeString(this.mixedPlayURL);
        dest.writeList(this.pushers);
    }

    public static final Parcelable.Creator<RoomInfo> CREATOR = new Parcelable.Creator<RoomInfo>() {
        @Override
        public RoomInfo createFromParcel(Parcel source) {
            return new RoomInfo(source);
        }

        @Override
        public RoomInfo[] newArray(int size) {
            return new RoomInfo[size];
        }
    };
}
