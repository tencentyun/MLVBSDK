package com.tencent.liteav.demo.lvb.liveroom.ui;

import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;

/**
 * Created by dennyfeng on 2017/11/22.
 */

public interface LiveRoomActivityInterface {
    MLVBLiveRoom getLiveRoom();
    String   getSelfUserID();
    String   getSelfUserName();
    void     showGlobalLog(boolean enable);
    void     printGlobalLog(String format, Object... args);
    void     setTitle(String s);
}
