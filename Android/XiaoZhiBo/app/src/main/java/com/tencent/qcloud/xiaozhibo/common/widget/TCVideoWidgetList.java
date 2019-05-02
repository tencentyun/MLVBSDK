package com.tencent.qcloud.xiaozhibo.common.widget;


import android.app.Activity;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.List;

public class TCVideoWidgetList {
    private List<TCVideoWidget> mVideoViews = new ArrayList<>();

    public TCVideoWidgetList(Activity context, final TCVideoWidget.OnRoomViewListener l) {

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
        mVideoViews.add(new TCVideoWidget(videoViews[0], kickoutBtns[0], loadingBkgs[0], loadingImgs[0], l));
        mVideoViews.add(new TCVideoWidget(videoViews[1], kickoutBtns[1], loadingBkgs[1], loadingImgs[1], l));
        mVideoViews.add(new TCVideoWidget(videoViews[2], kickoutBtns[2], loadingBkgs[2], loadingImgs[2], l));

    }
    public synchronized TCVideoWidget applyVideoView(String id) {
        if (id == null) {
            return null;
        }

        for (TCVideoWidget item : mVideoViews) {
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
        for (TCVideoWidget item : mVideoViews) {
            if (item.userID != null && item.userID.equals(id)){
                item.userID = null;
                item.setUsed(false);
            }
        }
    }

    public synchronized void recycleVideoView(){
        for (TCVideoWidget item : mVideoViews) {
            item.userID = null;
            item.setUsed(false);
        }
    }

    public synchronized void showLog(boolean show) {
        for (TCVideoWidget item : mVideoViews) {
            if (item.isUsed) {
                item.videoView.showLog(show);
            }
        }
    }

    public synchronized TCVideoWidget getFirstRoomView() {
        return mVideoViews.get(0);
    }
}
