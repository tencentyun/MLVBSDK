package com.tencent.liteav.demo.lvb.liveroom.roomutil.http;

import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.RoomInfo;

import java.util.List;
import java.util.Map;

/**
 * Created by jac on 2017/10/30.
 */

public class HttpResponse {
    public int code;

    public String message;

    public long timestamp;

    public transient static int CODE_OK = 0;

    public static class LoginResponse extends HttpResponse {
        public String userID;
        public String token;
    }

    public static class RoomList extends HttpResponse {
        public List<RoomInfo> rooms;
    }

    public static class PusherList extends HttpResponse {
        public String roomID;
        public String roomInfo;
        public String roomCreator;
        public String mixedPlayURL;
        public int roomStatusCode;
        public List<AnchorInfo> pushers;
    }

    public static class AudienceList extends HttpResponse {
        public List<AudienceInfo> audiences; //观众列表
    }

    public static class CreateRoom extends HttpResponse {
        public String roomID;
    }

    public static class PushUrl extends HttpResponse {
        public String pushURL;
        public String accelerateURL;
    }

    public static class MergeStream extends HttpResponse {
        public int merge_code;
        public String merge_msg;
    }

    public static class GetCustomInfoResponse extends HttpResponse {
        public Map<String, Object> custom;
    }
}
