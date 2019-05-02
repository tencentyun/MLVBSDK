package com.tencent.qcloud.xiaozhibo.mainui.list;

import org.json.JSONObject;

public class TCVideoInfo {
    public String   userid;
    public String   groupid;
//    public int      timestamp;
    public boolean  livePlay;
    public int      viewerCount;
    public int      likeCount;
    public String   title;
    public String   playurl;
    public String   fileid;
    public String   nickname;
    public String   headpic;
    public String   frontcover;
    public String   location;
    public String   avatar;
    public String   createTime;
    public String   startTime;
    public String   hlsPlayUrl;

    public TCVideoInfo() {}

    public TCVideoInfo(JSONObject data) {
        try {
            this.userid     = data.optString("userid");
            this.nickname   = data.optString("nickname");
            this.avatar     = data.optString("avatar");
            this.fileid     = data.optString("file_id");
            this.title      = data.optString("title");
            this.frontcover = data.optString("frontcover");
            this.location   = data.optString("location");
            this.playurl    = data.optString("play_url");
            this.hlsPlayUrl = data.optString("hls_play_url");
            this.createTime = data.optString("create_time");
            this.likeCount  = data.optInt("like_count");
            this.viewerCount  = data.optInt("viewer_count");
            this.startTime  = data.optString("start_time");

        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
