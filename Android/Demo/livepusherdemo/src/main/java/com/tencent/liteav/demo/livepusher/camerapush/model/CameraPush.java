package com.tencent.liteav.demo.livepusher.camerapush.model;

import android.os.Bundle;

import com.tencent.rtmp.TXLivePusher;

import java.io.File;

/**
 * 推流常用接口
 */
public interface CameraPush {

    void setURL(String pushURL);

    /**
     * 开始推流
     */
    void startPush();

    /**
     * 停止推流
     */
    void stopPush();

    void togglePush();

    /**
     * 恢复推流
     */
    void resume();

    void resumePush();

    /**
     * 暂停推流
     */
    void pause();

    void pausePush();

    /**
     * 销毁推流
     */
    void destroy();

    /**
     * 切换摄像头
     */
    void switchCamera();

    void setRotationForActivity();

    void setOnLivePusherCallback(OnLivePusherCallback callback);

    TXLivePusher getTXLivePusher();

    boolean isPushing();

    /**
     * 设置横竖屏推流
     *
     * @param isPortrait
     */
    void setHomeOrientation(boolean isPortrait);

    /**
     * 设置是否开隐私模式
     *
     * @param enable
     */
    void setPrivateMode(boolean enable);

    /**
     * 设置是否开启静音推流
     *
     * @param enable
     */
    void setMute(boolean enable);

    /**
     * 设置开启或关闭观众端镜像
     *
     * @param enable
     */
    void setMirror(boolean enable);

    /**
     * 设置开启或关闭后置摄像头闪光灯
     *
     * @param enable
     */
    void turnOnFlashLight(boolean enable);

    /**
     * 设置开启或关闭 Debug 面板
     *
     * @param enable
     */
    void showLog(boolean enable);

    /**
     * 设置开启或关闭水印
     *
     * @param enable
     */
    void setWatermark(boolean enable);

    /**
     * 设置开启或关闭手动对焦
     *
     * @param enable
     */
    void setTouchFocus(boolean enable);

    /**
     * 设置开启或关闭双手缩放
     *
     * @param enable
     */
    void setEnableZoom(boolean enable);

    /**
     * 设置截图
     */
    void snapshot();

    /**
     * 设置发送sei消息
     */
    void sendMessage(String string);

    /**
     * 设置硬件加速
     *
     * @param enable
     */
    void setHardwareAcceleration(boolean enable);

    /**
     * 设置码率自适应
     *
     * @param enable
     */
    void setAdjustBitrate(boolean enable, int qualityType);

    /**
     * 设置视频编码质量
     *
     * @param type
     */
    void setQuality(boolean enable, int type);

    /**
     * 设置耳返开关
     *
     * @param enable
     */
    void enableAudioEarMonitoring(boolean enable);

    void enablePureAudioPush(boolean enable);

    /**
     * 设置音质选择（声道设置）
     * 语音(speech)：16000，单声道
     * 标准(default)：48000，单声道
     * 音乐(music)：48000，双声道
     *
     * @param channel    单声道 1，双声道 2
     * @param sampleRate 音频采样率
     */
    void setAudioQuality(int channel, int sampleRate);

    interface OnLivePusherCallback {
        /**
         * result返回值：
         * 0 success; -1 invalid url; -3 invalid playType; -4 invalid rtmp url; -5 invalid secret rtmp url
         */
        void onPushStart(int code);

        void onPushResume();

        void onPushPause();

        void onPushStop();

        void onSnapshot(File file);

        void onPushEvent(int event, Bundle param);

        void onNetStatus(Bundle status);

        void onActivityRotationObserverChange(boolean selfChange);
    }
}
