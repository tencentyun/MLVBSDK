package com.tencent.qcloud.xiaozhibo.common.widget.video;


import android.app.Activity;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.List;
/**
 * Module:   TCVideoViewMgr
 *
 * Function: 视频播放View的管理类
 *
 *  {@link TCVideoView}  的管理类
 */
public class TCVideoViewMgr {
    private List<TCVideoView> mVideoViews = new ArrayList<>();

    public TCVideoViewMgr(Activity context, final TCVideoView.OnRoomViewListener l) {

        TXCloudVideoView videoViews[] = new TXCloudVideoView[3];
        videoViews[0] = ((TXCloudVideoView) context.findViewById(R.id.video_player1));
        videoViews[1] = ((TXCloudVideoView) context.findViewById(R.id.video_player2));
        videoViews[2] = ((TXCloudVideoView) context.findViewById(R.id.video_player3));

        Button kickoutBtns[] = {null, null, null};
        kickoutBtns[0] = (Button)context.findViewById(R.id.btn_kick_out1);
        kickoutBtns[1] = (Button)context.findViewById(R.id.btn_kick_out2);
        kickoutBtns[2] = (Button)context.findViewById(R.id.btn_kick_out3);

        FrameLayout loadingBkgs[] = {null, null, null};
        loadingBkgs[0] = (FrameLayout)context.findViewById(R.id.loading_background1);
        loadingBkgs[1] = (FrameLayout)context.findViewById(R.id.loading_background2);
        loadingBkgs[2] = (FrameLayout)context.findViewById(R.id.loading_background3);

        ImageView loadingImgs[] = {null, null, null};
        loadingImgs[0] = (ImageView)context.findViewById(R.id.loading_imageview1);
        loadingImgs[1] = (ImageView)context.findViewById(R.id.loading_imageview2);
        loadingImgs[2] = (ImageView)context.findViewById(R.id.loading_imageview3);

        // 连麦拉流
        mVideoViews.add(new TCVideoView(videoViews[0], kickoutBtns[0], loadingBkgs[0], loadingImgs[0], l));
        mVideoViews.add(new TCVideoView(videoViews[1], kickoutBtns[1], loadingBkgs[1], loadingImgs[1], l));
        mVideoViews.add(new TCVideoView(videoViews[2], kickoutBtns[2], loadingBkgs[2], loadingImgs[2], l));

    }
    public synchronized TCVideoView applyVideoView(String id) {
        if (id == null) {
            return null;
        }

        for (TCVideoView item : mVideoViews) {
            if (!item.isUsed) {
                item.setUsed(true);
                item.userID = id;
                return item;
            } else {
                if (item.userID != null && item.userID.equals(id)) {
                    item.setUsed(true);
                    return item;
                }
            }
        }
        return null;
    }

    public synchronized void recycleVideoView(String id){
        for (TCVideoView item : mVideoViews) {
            if (item.userID != null && item.userID.equals(id)){
                item.userID = null;
                item.setUsed(false);
            }
        }
    }

    public synchronized void recycleVideoView(){
        for (TCVideoView item : mVideoViews) {
            item.userID = null;
            item.setUsed(false);
        }
    }

    public synchronized void showLog(boolean show) {
        for (TCVideoView item : mVideoViews) {
            if (item.isUsed) {
                item.videoView.showLog(show);
            }
        }
    }

    public synchronized TCVideoView getFirstRoomView() {
        return mVideoViews.get(0);
    }
}
