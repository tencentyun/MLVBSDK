package com.tencent.qcloud.xiaozhibo.common;

import android.content.Context;

import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;

/**
 * Created by kuenzhang on 12/7/17.
 */

public class TCLiveRoomMgr {
    static MLVBLiveRoom liveRoom = null;

    static public MLVBLiveRoom getLiveRoom(Context context) {
        return MLVBLiveRoom.sharedInstance(context);
    }

    static public MLVBLiveRoom getLiveRoom() {
        return MLVBLiveRoom.sharedInstance(null);
    }
}
