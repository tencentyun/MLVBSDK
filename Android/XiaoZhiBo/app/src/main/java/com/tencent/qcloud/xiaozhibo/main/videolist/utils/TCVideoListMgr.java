package com.tencent.qcloud.xiaozhibo.main.videolist.utils;

import android.content.Context;
import android.text.TextUtils;

import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.RoomInfo;
import com.tencent.qcloud.xiaozhibo.TCGlobalConfig;
import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.rtmp.TXLog;

import org.json.JSONArray;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;
/**
 *  Module:   TCVideoListMgr
 *
 *  Function: 获取当前正在直播的房间列表或者视频回放列表
 *
 *  1. 获取当前正在直播的列表，通过 MLVB 组件获取正在直播的房间列表。 {@link TCVideoListMgr#fetchLiveList(Context, Listener)}
 *
 *  2. 获取回放视频的列表，向您部署的小直播后台发起获取视频回放的列表。{@link TCVideoListMgr#fetchVodList(Listener)} (Context)}
 *
 */
public class TCVideoListMgr {
    private static final String TAG = TCVideoListMgr.class.getSimpleName();
    private static final int PAGE_SIZE = 200;

    private static class TCVideoListMgrHolder {
        private static TCVideoListMgr instance = new TCVideoListMgr();
    }

    public static TCVideoListMgr getInstance() {
        return TCVideoListMgrHolder.instance;
    }

    /**
     * 获取正在直播的列表
     *
     * @param listener
     */
    public void fetchLiveList(Context context, final Listener listener) {
        MLVBLiveRoom liveRoom = MLVBLiveRoom.sharedInstance(context);
        liveRoom.getRoomList(0, PAGE_SIZE, new IMLVBLiveRoomListener.GetRoomListCallback() {
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
                        info.playUrl = value.mixedPlayURL;
                        info.title      = value.roomName;
                        info.userId = value.roomCreator;
                        info.groupId = value.roomID;
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
                            info.frontCover = jsonRoomInfo.optString("frontcover");
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

    /**
     * 获取回放的视频列表
     *
     * @param listener
     */
    public void fetchVodList(final Listener listener) {
        try {
            JSONObject body = new JSONObject().put("index","0").put("count", PAGE_SIZE);
            TCHTTPMgr.getInstance().requestWithSign(TCGlobalConfig.APP_SVR_URL + "/get_vod_list", body, new TCHTTPMgr.Callback() {
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
                public void onFailure(int code, String msg) {
                    if (listener != null) {
                        listener.onVideoList(code, null, false);
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
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
        void onVideoList(int retCode, final ArrayList<TCVideoInfo> result, boolean refresh);
    }
}

