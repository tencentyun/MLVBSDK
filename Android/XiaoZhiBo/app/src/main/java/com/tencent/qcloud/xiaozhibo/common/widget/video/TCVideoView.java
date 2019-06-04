package com.tencent.qcloud.xiaozhibo.common.widget.video;

import android.graphics.drawable.AnimationDrawable;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * Module:   TCVideoView
 *
 * Function: 视频播放View的封装类
 *
 * 1. 封装了主播连麦、观众观看的View。
 *
 * 2. loading显示、踢出按钮等
 */
public class TCVideoView {

    public TXCloudVideoView     videoView;
    public FrameLayout          loadingBkg;
    public ImageView            loadingImg;
    public Button               kickButton;
    public String               userID;
    boolean                     isUsed;

    public interface OnRoomViewListener {
        void onKickUser(String userId);
    }

    public TCVideoView(TXCloudVideoView view, Button button, FrameLayout loadingBkg, ImageView loadingImg, final OnRoomViewListener l) {
        this.videoView = view;
        this.videoView.setVisibility(View.GONE);
        this.loadingBkg = loadingBkg;
        this.loadingImg = loadingImg;
        this.isUsed = false;
        this.kickButton = button;
        this.kickButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                kickButton.setVisibility(View.INVISIBLE);
                String userID = TCVideoView.this.userID;
                if (userID != null && l != null) {
                    l.onKickUser(userID);
                }
            }
        });
    }

    public void startLoading() {
        kickButton.setVisibility(View.INVISIBLE);
        loadingBkg.setVisibility(View.VISIBLE);
        loadingImg.setVisibility(View.VISIBLE);
        loadingImg.setImageResource(R.drawable.linkmic_loading);
        AnimationDrawable ad = (AnimationDrawable) loadingImg.getDrawable();
        ad.start();
    }

    public void stopLoading(boolean showKickoutBtn) {
        kickButton.setVisibility(showKickoutBtn ? View.VISIBLE : View.GONE);
        loadingBkg.setVisibility(View.GONE);
        loadingImg.setVisibility(View.GONE);
        AnimationDrawable ad = (AnimationDrawable) loadingImg.getDrawable();
        if (ad != null) {
            ad.stop();
        }
    }

    public void stopLoading() {
        kickButton.setVisibility(View.GONE);
        loadingBkg.setVisibility(View.GONE);
        loadingImg.setVisibility(View.GONE);
        AnimationDrawable ad = (AnimationDrawable) loadingImg.getDrawable();
        if (ad != null) {
            ad.stop();
        }
    }

    public void setUsed(boolean used){
        videoView.setVisibility(used ? View.VISIBLE : View.GONE);
        if (used == false) {
            stopLoading(false);
        }
        this.isUsed = used;
    }
}

