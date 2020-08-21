package com.tencent.liteav.demo.liveplayer.model;

import android.os.Bundle;

import com.tencent.rtmp.TXLivePlayer;

/**
 * 拉流常用接口
 */
public interface LivePlayer {

    /**
     * 开始播放
     */
    void startPlay();

    /**
     * 停止播放
     */
    void stopPlay();

    /**
     * 当前正在播放则停止；当前停止则开始播放
     */
    void togglePlay();

    /**
     * 是否正在播放
     *
     * @return
     */
    boolean isAcc();

    /**
     * 测试专用
     */
    void startAcc();

    /**
     * 测试专用
     */
    void stopAcc();

    /**
     * 测试专用
     */
    void toggleAcc();

    /**
     * 设置URL
     *
     * @param url
     */
    void setPlayURL(String url);

    /**
     * 设置播放模式和URL
     *
     * @param activityPlayType
     * @param url
     */
    void setPlayURL(int activityPlayType, String url);

    /**
     * 获取播放URL
     */
    void fetchPlayURL();

    /**
     * 设置缓存策略
     *
     * @param cacheStrategy
     */
    void setCacheStrategy(int cacheStrategy);

    /**
     * 设置渲染模式
     *
     * @param renderMode TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN：全屏
     *                   TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION：自适应
     */
    void setRenderMode(int renderMode);

    int getRenderMode();

    /**
     * 设置视频方向
     *
     * @param renderRotation TXLiveConstants.RENDER_ROTATION_LANDSCAPE：横屏
     *                       TXLiveConstants.RENDER_ROTATION_PORTRAIT： 竖屏
     */
    void setRenderRotation(int renderRotation);

    int getRenderRotation();

    /**
     * 设置解码方式
     *
     * @param mode 0：软解，1：硬解
     */
    void setHWDecode(int mode);

    int getHWDecode();

    /**
     * 显示播放器中 log 信息
     */
    void showVideoLog(boolean enable);

    void setOnLivePlayerCallback(OnLivePlayerCallback callback);

    void destroy();

    interface OnLivePlayerCallback {
        /**
         * result返回值：
         * 0 success; -1 empty url; -2 invalid url; -3 invalid playType; -4 invalid rtmp url; -5 invalid secret rtmp url
         */
        void onPlayStart(int code);

        void onPlayStop();

        void onPlayEvent(int event, Bundle param);

        void onNetStatus(Bundle bundle);

        void onFetchURLStart();

        void onFetchURLFailure();

        void onFetchURLSuccess(String url);
    }
}
