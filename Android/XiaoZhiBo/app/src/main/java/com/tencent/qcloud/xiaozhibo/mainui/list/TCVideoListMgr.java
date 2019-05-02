package com.tencent.qcloud.xiaozhibo.mainui.list;

import android.text.TextUtils;

import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.RoomInfo;
import com.tencent.qcloud.xiaozhibo.common.TCLiveRoomMgr;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.rtmp.TXLog;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;

public class TCVideoListMgr {
    private static final String TAG = TCVideoListMgr.class.getSimpleName();
    private static final int PAGESIZE = 200;
    public static final int SUCCESS_CODE = 200;
    private boolean mIsFetching;

    private ArrayList<TCVideoInfo> mLiveInfoList = new ArrayList<>();
    private ArrayList<TCVideoInfo> mVodInfoList = new ArrayList<>();
    private ArrayList<TCVideoInfo> mUGCInfoList = new ArrayList<>();

    private TCVideoListMgr() {
        mIsFetching = false;
    }

    private static class TCVideoListMgrHolder {
        private static TCVideoListMgr instance = new TCVideoListMgr();
    }

    public static TCVideoListMgr getInstance() {
        return TCVideoListMgrHolder.instance;
    }

    /**
     * 视频列表获取结果回调
     */
    public interface Listener {
        /**
         * @param retCode 获取结果，0表示成功
         * @param result  列表数据
         * @param refresh 是否需要刷新界面，首页需要刷新
         */
        public void onVideoList(int retCode, final ArrayList<TCVideoInfo> result, boolean refresh);
    }

    public void fetchLiveList(final Listener listener) {
        MLVBLiveRoom liveRoom = TCLiveRoomMgr.getLiveRoom();
        liveRoom.getRoomList(0, PAGESIZE, new IMLVBLiveRoomListener.GetRoomListCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                if (listener != null) {
                    listener.onVideoList(errCode, null, false);
                }
                TXLog.w(TAG, "xzb_process: get_live_list error, code:"+errCode+", errInfo:"+errInfo);
            }

            @Override
            public void onSuccess(ArrayList<RoomInfo> data) {
                ArrayList<TCVideoInfo> infos = new ArrayList();
                if (data != null && data.size() > 0) {
                    for (RoomInfo value : data) {
                        List<AnchorInfo> pushers = value.pushers;

                        TCVideoInfo info = new TCVideoInfo();
                        info.playurl    = value.mixedPlayURL;
                        info.title      = value.roomName;
                        info.userid     = value.roomCreator;
                        info.groupid    = value.roomID;
                        info.viewerCount= value.audienceCount;
                        info.livePlay   = true;
                        if (pushers != null && !pushers.isEmpty()) {
                            AnchorInfo pusher = pushers.get(0);
                            info.nickname   = pusher.userName;
                            info.avatar     = pusher.userAvatar;
                        }

                        try {
                            JSONObject jsonRoomInfo = new JSONObject(value.roomInfo);
                            info.title      = jsonRoomInfo.optString("title");
                            info.frontcover = jsonRoomInfo.optString("frontcover");
                            info.location   = jsonRoomInfo.optString("location");
                        } catch (Exception e) {
                            e.printStackTrace();
                            if (!TextUtils.isEmpty(value.roomInfo)) {
                                info.title = value.roomInfo;
                            }
                        }

                        try {
                            JSONObject jsonCunstomInfo = new JSONObject(value.custom);
                            info.likeCount   = jsonCunstomInfo.optInt("praise");
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        infos.add(info);
                    }
                }
                if (listener != null) {
                    listener.onVideoList(0, infos, true);
                }
                TXLog.w(TAG, "xzb_process: get_live_list success");
            }
        });
    }

    public void fetchVodList(final Listener listener) {
        fetchVideoList("get_vod_list", listener);
    }

    public void fetchUGCList(final Listener listener) {
        fetchVideoList("get_ugc_list", listener);
    }

    private void fetchVideoList(String cmd, final Listener listener) {
        try {
            JSONObject body = new JSONObject().put("index","0").put("count",PAGESIZE);
            TCUserMgr.getInstance().request("/"+cmd, body, new TCUserMgr.HttpCallback(cmd, new TCUserMgr.Callback() {
                @Override
                public void onSuccess(JSONObject data) {
                    ArrayList<TCVideoInfo> videoList = new ArrayList();
                    if (data != null) {
                        JSONArray list = data.optJSONArray("list");
                        if (list != null) {
                            for (int i = 0; i<list.length(); i++) {
                                JSONObject obj = list.optJSONObject(i);
                                if (obj != null) {
                                    TCVideoInfo video  = new TCVideoInfo(obj);
                                    videoList.add(video);
                                }
                            }
                        }
                    }
                    if (listener != null) {
                        listener.onVideoList(0, videoList, false);
                    }
                }

                @Override
                public void onFailure(int code, final String msg) {
                    if (listener != null) {
                        listener.onVideoList(code, null, false);
                    }
                }
            }));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

