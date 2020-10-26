package com.tencent.liteav.demo.livepusher.camerapush.model;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.database.ContentObserver;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.view.Surface;
import android.view.View;

import com.tencent.liteav.demo.livepusher.R;
import com.tencent.liteav.demo.livepusher.camerapush.ui.view.PusherSettingFragment;
import com.tencent.rtmp.ITXLivePushListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePushConfig;
import com.tencent.rtmp.TXLivePusher;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;

import static com.tencent.liteav.demo.beauty.utils.ResourceUtils.getString;

/**
 * 腾讯云 {@link TXLivePusher} 推流器使用参考 Demo
 *
 * 有以下功能参考 ：
 *
 * - 基本功能参考： 启动推流 {@link #startPush()} 与 结束推流 {@link #stopPush()} ()}
 *
 * - 场景化配置参考：{@link PusherSettingFragment} 与 {@link #setPushScene(int, boolean)} 您可以根据您的 App 使用设定不同的推流场景，SDK 内部会自动选择相关配置，让您可以快速搭建
 *    注：一般客户建议直接使用场景化配置；若您是专业级客户，推荐您参考 {@link TXLivePushConfig} 进行个性化配置
 *
 * - 性能数据查看参考： {@link #onNetStatus(Bundle)}
 *
 * - 处理 SDK 回调事件参考： {@link #onPushEvent(int, Bundle)}
 *
 * - 混响、变声、码率自适应、硬件加速等使用参考： {@link PusherSettingFragment} 与 {@link PusherSettingFragment.OnSettingChangeListener}
 *
 * - 横屏推流使用参考：该功能较为复杂，需要区分Activity是否可以旋转。
 *      A. 不可旋转情况下开启横屏推流：直接参考 {@link #setHomeOrientation(boolean)} 即可
 *      B. 可旋转情况下开启横屏推流，参考： {@link ActivityRotationObserver} 与 {@link #setRotationForActivity()}
 *
 */
public class CameraPushImpl implements CameraPush, ITXLivePushListener {

    private static final String TAG = "CameraPushImpl";

    private Context          mContext;
    private TXLivePusher     mLivePusher;
    private TXLivePushConfig mLivePushConfig;
    private TXCloudVideoView mPusherView;

    private OnLivePusherCallback mOnLivePusherCallback;

    private Bitmap mWaterMarkBitmap;

    private String mPusherURL = "";

    private boolean mIsPushing             = false;
    private boolean mIsResume              = false;
    private boolean mIsWaterMarkEnable     = true;
    private boolean mIsDebugInfo           = false;
    private boolean mIsMuteAudio           = false;
    private boolean mIsPrivateMode         = false;
    private boolean mIsLandscape           = true;
    private boolean mIsMirrorEnable        = false;
    private boolean mIsFocusEnable         = false;
    private boolean mIsZoomEnable          = false;
    private boolean mIsPureAudio           = false;
    private boolean mIsEarMonitoringEnable = false;
    private boolean mIsHWAcc               = false;
    private boolean mFrontCamera           = true;
    private boolean mIsEnableAdjustBitrate = false;
    private boolean mIsFlashLight          = false;

    private int mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
    private int mAudioChannels;
    private int mAudioSample;
    private int mQualityType;

    /**
     * 默认美颜参数
     */
    private int mBeautyLevel    = 5;                                   // 美颜等级
    private int mBeautyStyle    = TXLiveConstants.BEAUTY_STYLE_SMOOTH; // 美颜样式
    private int mWhiteningLevel = 3;                                   // 美白等级
    private int mRuddyLevel     = 2;                                   // 红润等级

    public CameraPushImpl(Context context, TXCloudVideoView pusherView) {
        initialize(context, pusherView);
    }

    @Override
    public void setURL(String pushURL) {
        mPusherURL = pushURL;
    }

    @Override
    public void startPush() {
        int resultCode = Constants.PLAY_STATUS_SUCCESS;
        String tRTMPURL = "";
        if (!TextUtils.isEmpty(mPusherURL)) {
            String url[] = mPusherURL.split("###");
            if (url.length > 0) {
                tRTMPURL = url[0];
            }
        }

        if (TextUtils.isEmpty(tRTMPURL) || (!tRTMPURL.trim().toLowerCase().startsWith("rtmp://"))) {
            resultCode = Constants.PLAY_STATUS_INVALID_URL;
        } else {
            // 显示本地预览的View
            mPusherView.setVisibility(View.VISIBLE);
            // 添加播放回调
            mLivePusher.setPushListener(this);
            // 添加后台垫片推流参数
            Bitmap bitmap = decodeResource(mContext.getResources(), R.drawable.livepusher_pause_publish);
            mLivePushConfig.setPauseImg(bitmap);
            mLivePushConfig.setPauseImg(300, 5);
            mLivePushConfig.setPauseFlag(TXLiveConstants.PAUSE_FLAG_PAUSE_VIDEO);// 设置暂停时，只停止画面采集，不停止声音采集。

            // 设置推流分辨率
            mLivePushConfig.setVideoResolution(mVideoResolution);

            // 如果当前Activity可以自动旋转的话，那么需要进行设置
            if (isActivityCanRotation(mContext)) {
                setRotationForActivity();
            }
            // 开启麦克风推流相关
            mLivePusher.setMute(mIsMuteAudio);

            // 横竖屏推流相关
            int renderRotation = 0;
            if (mIsLandscape) {
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
                renderRotation = 0;
            } else {
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT);
                renderRotation = 90; // 因为采集旋转了，那么保证本地渲染是正的，则设置渲染角度为90度。
            }
            mLivePusher.setRenderRotation(renderRotation);

            //根据activity方向调整横竖屏
            setRotationForActivity();

            // 是否开启观众端镜像观看
            mLivePusher.setMirror(mIsMirrorEnable);
            // 是否打开调试信息
            mPusherView.showLog(mIsDebugInfo);

            // 是否添加水印
            if (mIsWaterMarkEnable) {
                mLivePushConfig.setWatermark(mWaterMarkBitmap, 0.02f, 0.05f, 0.2f);
            } else {
                mLivePushConfig.setWatermark(null, 0, 0, 0);
            }

            // 是否打开曝光对焦
            mLivePushConfig.setTouchFocus(mIsFocusEnable);
            // 是否打开手势放大预览画面
            mLivePushConfig.setEnableZoom(mIsZoomEnable);
            mLivePushConfig.enablePureAudioPush(mIsPureAudio);
            mLivePushConfig.enableAudioEarMonitoring(mIsEarMonitoringEnable);
            // 设置推流配置
            mLivePusher.setConfig(mLivePushConfig);
            // 设置场景
            setPushScene(mQualityType, mIsEnableAdjustBitrate);

            // 设置声道，必须在 TXLivePusher.setVideoQuality 之后，TXLivePusher.startPusher之前设置才能生效
            mLivePushConfig.setAudioChannels(mAudioChannels);
            // 设置音频采样率，必须在 TXLivePusher.setVideoQuality 之后，TXLivePusher.startPusher之前设置才能生效
            mLivePushConfig.setAudioSampleRate(mAudioSample);
            mLivePusher.setConfig(mLivePushConfig);

            // 设置本地预览View
            mLivePusher.startCameraPreview(mPusherView);
            if (!mFrontCamera) mLivePusher.switchCamera();
            // 发起推流
            resultCode = mLivePusher.startPusher(tRTMPURL.trim());

            mIsPushing = true;
        }
        Log.i(TAG, "start: mIsResume -> " + mIsResume);
        if (mOnLivePusherCallback != null) {
            mOnLivePusherCallback.onPushStart(resultCode);
        }
    }

    @Override
    public void stopPush() {
        if (!mIsPushing) {
            return;
        }
        // 停止本地预览
        mLivePusher.stopCameraPreview(true);
        // 移除监听
        mLivePusher.setPushListener(null);
        // 停止推流
        mLivePusher.stopPusher();
        // 隐藏本地预览的View
        mPusherView.setVisibility(View.GONE);
        // 移除垫片图像
        mLivePushConfig.setPauseImg(null);
        mIsPrivateMode = false;
        mIsPushing = false;
        if (mOnLivePusherCallback != null) {
            mOnLivePusherCallback.onPushStop();
        }
    }

    @Override
    public void togglePush() {
        if (mIsPushing) {
            stopPush();
        } else {
            startPush();
        }
    }

    @Override
    public void resume() {
        Log.i(TAG, "resume: mIsResume -> " + mIsResume);
        if (mIsResume) {
            return;
        }
        if (mPusherView != null) {
            mPusherView.onResume();
        }
        if (mIsPushing && mLivePusher != null) {
            // 如果当前是隐私模式，那么不resume
            if (!mIsPrivateMode) {
                mLivePusher.resumePusher();
            }
        }
        mIsResume = true;
        if (mOnLivePusherCallback != null) {
            mOnLivePusherCallback.onPushResume();
        }
    }

    @Override
    public void resumePush() {
        mLivePusher.resumePusher();
    }

    @Override
    public void pause() {
        Log.i(TAG, "pause: mIsResume -> " + mIsResume);
        if (mPusherView != null) {
            mPusherView.onPause();
        }
        if (mIsPushing && mLivePusher != null) {
            // 如果当前已经是隐私模式，那么则不pause
            if (!mIsPrivateMode) {
                mLivePusher.pausePusher();
            }
        }
        mIsResume = false;
        if (mOnLivePusherCallback != null) {
            mOnLivePusherCallback.onPushPause();
        }
    }

    @Override
    public void pausePush() {
        mLivePusher.pausePusher();
    }

    @Override
    public void destroy() {
        stopPush();
        mPusherView.onDestroy();
        unInitPhoneListener();
    }

    @Override
    public void switchCamera() {
        mFrontCamera = !mFrontCamera;
        mLivePusher.switchCamera();
    }

    @Override
    public TXLivePusher getTXLivePusher() {
        return mLivePusher;
    }

    @Override
    public boolean isPushing() {
        return mIsPushing;
    }

    @Override
    public void setHomeOrientation(boolean isLandscape) {
        mIsLandscape = isLandscape;
        int renderRotation;
        if (isLandscape) {  // 横屏
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT);
            renderRotation = 90; // 因为采集旋转了，那么保证本地渲染是正的，则设置渲染角度为90度。
        } else {            // 竖屏
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
            renderRotation = 0;
        }
        if (mLivePusher.isPushing()) {
            mLivePusher.setConfig(mLivePushConfig);
            mLivePusher.setRenderRotation(renderRotation);
        }
    }

    @Override
    public void setPrivateMode(boolean enable) {
        mIsPrivateMode = enable;
        // 隐私模式下，会进入垫片推流
        if (mIsPushing) {
            if (enable) {
                mLivePusher.pausePusher();
            } else {
                mLivePusher.resumePusher();
            }
        }
    }

    @Override
    public void setMute(boolean enable) {
        mIsMuteAudio = enable;
        mLivePusher.setMute(enable);
    }

    @Override
    public void setMirror(boolean enable) {
        mIsMirrorEnable = enable;
        mLivePusher.setMirror(enable);
    }

    @Override
    public void turnOnFlashLight(boolean enable) {
        mIsFlashLight = enable;
        mLivePusher.turnOnFlashLight(enable);
    }

    @Override
    public void showLog(boolean enable) {
        mIsDebugInfo = enable;
        mPusherView.showLog(enable);
    }

    @Override
    public void setWatermark(boolean enable) {
        mIsWaterMarkEnable = enable;
        if (enable) {
            mLivePushConfig.setWatermark(mWaterMarkBitmap, 0.02f, 0.05f, 0.2f);
        } else {
            mLivePushConfig.setWatermark(null, 0, 0, 0);
        }
        if (mLivePusher.isPushing()) {
            // 水印变更不需要重启推流，直接应用配置项即可
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    @Override
    public void setTouchFocus(boolean enable) {
        mIsFocusEnable = enable;
        mLivePushConfig.setTouchFocus(enable);
        if (mLivePusher.isPushing()) {
            stopPush();
            startPush();
        }
    }

    @Override
    public void setEnableZoom(boolean enable) {
        mIsZoomEnable = enable;
        mLivePushConfig.setEnableZoom(enable);
        if (mLivePusher.isPushing()) {
            stopPush();
            startPush();
        }
    }

    @Override
    public void snapshot() {
        mLivePusher.snapshot(new TXLivePusher.ITXSnapshotListener() {
            @Override
            public void onSnapshot(Bitmap bitmap) {
                saveSnapshotBitmap(bitmap);
            }
        });
    }

    @Override
    public void sendMessage(String msg) {
        mLivePusher.sendMessage(msg.getBytes());
    }

    @Override
    public void setHardwareAcceleration(boolean enable) {
        mIsHWAcc = enable;
        if (enable) {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_HARDWARE); // 启动硬编
        } else {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_SOFTWARE); // 启动软编
        }
        if (mLivePusher.isPushing()) {
            // 硬件加速变更不需要重启推流，直接应用配置项即可
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    @Override
    public void setAdjustBitrate(boolean enable, int qualityType) {
        mIsEnableAdjustBitrate = enable;
        setPushScene(qualityType, enable);
    }

    @Override
    public void setQuality(boolean enable, int type) {
        setPushScene(type, enable);
    }

    @Override
    public void enableAudioEarMonitoring(boolean enable) {
        mIsEarMonitoringEnable = enable;
        if (mLivePusher != null) {
            TXLivePushConfig config = mLivePusher.getConfig();
            config.enableAudioEarMonitoring(enable);
            mLivePusher.setConfig(config);
        }
    }

    @Override
    public void enablePureAudioPush(boolean enable) {
        mIsPureAudio = enable;
    }

    @Override
    public void setAudioQuality(int channel, int sampleRate) {
        mAudioChannels = channel;
        mAudioSample = sampleRate;
        if (mLivePusher != null) {
            TXLivePushConfig config = mLivePusher.getConfig();
            config.setAudioChannels(channel);
            config.setAudioSampleRate(sampleRate);
            mLivePusher.setConfig(config);
        }
    }

    private void initialize(Context context, TXCloudVideoView pusherView) {
        mContext = context;
        mLivePusher = new TXLivePusher(context);
        mPusherView = pusherView;
        mLivePushConfig = new TXLivePushConfig();
        mLivePushConfig.setVideoEncodeGop(5);
        mLivePusher.setConfig(mLivePushConfig);
        // 设置美颜
        mLivePusher.setBeautyFilter(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
        mWaterMarkBitmap = decodeResource(mContext.getResources(), R.drawable.livepusher_watermark);
        initListener();
    }

    @Override
    public void onPushEvent(int event, Bundle param) {
        String msg = param.getString(TXLiveConstants.EVT_DESCRIPTION);
        String pushEventLog = getString(R.string.livepusher_receive_event) + event + ", " + msg;
        Log.d(TAG, pushEventLog);

        // 如果开始推流，设置了隐私模式。 需要在回调里面设置，不能直接start之后直接pause
        if (event == TXLiveConstants.PUSH_EVT_PUSH_BEGIN) {
            if (mIsPrivateMode) {
                pausePush();
            }
        }
        if (event == TXLiveConstants.PUSH_ERR_NET_DISCONNECT
                || event == TXLiveConstants.PUSH_ERR_INVALID_ADDRESS
                || event == TXLiveConstants.PUSH_ERR_OPEN_CAMERA_FAIL
                || event == TXLiveConstants.PUSH_ERR_OPEN_MIC_FAIL) {
            // 遇到以上错误，则停止推流
            stopPush();
        } else if (event == TXLiveConstants.PUSH_WARNING_HW_ACCELERATION_FAIL) {
            // 开启硬件加速失败
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_SOFTWARE);
            mLivePusher.setConfig(mLivePushConfig);
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_RESOLUTION) {
            Log.d(TAG, "change resolution to " + param.getInt(TXLiveConstants.EVT_PARAM2) + ", bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_BITRATE) {
            Log.d(TAG, "change bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_EVT_OPEN_CAMERA_SUCC) {
            // 只有后置摄像头可以打开闪光灯，若默认需要开启闪光灯。 那么在打开摄像头成功后，才可以进行配置。 若果当前是前置，设定无效；若是后置，打开闪光灯。
            turnOnFlashLight(mIsFlashLight);
        }

        if (mOnLivePusherCallback != null) {
            mOnLivePusherCallback.onPushEvent(event, param);
        }
    }

    @Override
    public void onNetStatus(Bundle bundle) {
        if (mOnLivePusherCallback != null) {
            mOnLivePusherCallback.onNetStatus(bundle);
        }
    }

    /**
     * 根据当前 Activity 的旋转方向，配置推流器
     */
    @Override
    public void setRotationForActivity() {
        // 自动旋转打开，Activity随手机方向旋转之后，需要改变推流方向
        int mobileRotation = ((Activity) mContext).getWindowManager().getDefaultDisplay().getRotation();
        int pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
        switch (mobileRotation) {
            case Surface.ROTATION_0:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
                break;
            case Surface.ROTATION_180:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_UP;
                break;
            case Surface.ROTATION_90:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT;
                break;
            case Surface.ROTATION_270:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_LEFT;
                break;
            default:
                break;
        }

        mLivePusher.setRenderRotation(0);                                   // 因为activity也旋转了，本地渲染相对正方向的角度为0。
        mLivePushConfig.setHomeOrientation(pushRotation);                   // 根据Activity方向，设置采集角度

        if (mLivePusher.isPushing()) {                                      // 当前正在推流，
            mLivePusher.setConfig(mLivePushConfig);
            if (!mIsPrivateMode) {                       // 不是隐私模式，则开启摄像头推流。
                mLivePusher.stopCameraPreview(true);
                mLivePusher.startCameraPreview(mPusherView);
            }
        }
    }

    @Override
    public void setOnLivePusherCallback(OnLivePusherCallback callback) {
        mOnLivePusherCallback = callback;
    }

    /**
     * 设置推流场景
     * <p>
     * SDK 内部将根据具体场景，进行推流 分辨率、码率、FPS、是否启动硬件加速、是否启动回声消除 等进行配置
     * <p>
     * 适用于一般客户，方便快速进行配置
     * <p>
     * 专业客户，推荐通过 {@link TXLivePushConfig} 进行逐一配置
     */
    private void setPushScene(int type, boolean enableAdjustBitrate) {
        Log.i(TAG, "setPushScene: type = " + type + " enableAdjustBitrate = " + enableAdjustBitrate);
        mQualityType = type;
        mIsEnableAdjustBitrate = enableAdjustBitrate;
        // 码率、分辨率自适应都关闭
        boolean autoResolution = false;
        switch (type) {
            case TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION:     /*360p*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION:         /*540p*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION:        /*720p*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_ULTRA_DEFINITION:        /*1080p*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_ULTRA_DEFINITION, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_1080_1920;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER:  /*连麦大主播*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER:   /*连麦小主播*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_320_480;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT:      /*实时*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT, enableAdjustBitrate, autoResolution);
                    mVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                }
                break;
            default:
                break;
        }
        // 设置场景化配置后，SDK 内部会根据场景自动选择相关的配置参数，所以我们这里把内部的config获取出来，赋值到外部。
        mLivePushConfig = mLivePusher.getConfig();

        // 是否开启硬件加速
        if (mIsHWAcc) {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_HARDWARE);
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    private void runOnUiThread(Runnable runnable) {
        ((Activity) mContext).runOnUiThread(runnable);
    }

    private TXPhoneStateListener mPhoneListener;
    private ActivityRotationObserver mActivityRotationObserver;

    /**
     * 初始化电话监听、系统是否打开旋转监听
     */
    private void initListener() {
        mPhoneListener = new TXPhoneStateListener();
        TelephonyManager tm = (TelephonyManager) mContext.getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);
        mActivityRotationObserver = new ActivityRotationObserver(new Handler(Looper.getMainLooper()));
        mActivityRotationObserver.startObserver();
    }

    /**
     * 销毁
     */
    private void unInitPhoneListener() {
        TelephonyManager tm = (TelephonyManager) mContext.getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_NONE);
        mActivityRotationObserver.stopObserver();
    }

    /**
     * 判断系统 "自动旋转" 设置功能是否打开
     *
     * @return false---Activity可根据重力感应自动旋转
     */
    private boolean isActivityCanRotation(Context context) {
        int flag = Settings.System.getInt(context.getContentResolver(), Settings.System.ACCELEROMETER_ROTATION, 0);
        return flag != 0;
    }

    /**
     * 获取资源图片
     *
     * @param resources
     * @param id
     * @return
     */
    private Bitmap decodeResource(Resources resources, int id) {
        TypedValue value = new TypedValue();
        resources.openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(resources, id, opts);
    }

    /**
     * 保存并分享图片
     *
     * @param bmp
     */
    private void saveSnapshotBitmap(final Bitmap bmp) {
        if (bmp == null) {
            if (mOnLivePusherCallback != null) {
                mOnLivePusherCallback.onSnapshot(null);
            }
            return;
        }
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                String bitmapFileName = UUID.randomUUID().toString();//通过UUID生成字符串文件名
                FileOutputStream out = null;
                File sdcardDir = mContext.getExternalFilesDir(null);
                if (sdcardDir == null) {
                    Log.e(TAG, "sdcardDir is null");
                    return;
                }
                final String path = sdcardDir + File.separator + bitmapFileName + ".png";
                final File file = new File(path);
                try {
                    file.getParentFile().mkdirs();
                    if (!file.exists()) {
                        file.createNewFile();
                    }
                    out = new FileOutputStream(file);
                    bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (out != null) {
                            out.flush();
                            out.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (mOnLivePusherCallback != null) {
                            mOnLivePusherCallback.onSnapshot(file);
                        }
                    }
                });
            }
        });
    }

    /**
     * 电话监听
     */
    private class TXPhoneStateListener extends PhoneStateListener {

        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            Log.i(TAG, "onCallStateChanged: state -> " + state);
            switch (state) {
                case TelephonyManager.CALL_STATE_RINGING:   //电话等待接听
                case TelephonyManager.CALL_STATE_OFFHOOK:   //电话接听
                    pause();
                    break;
                case TelephonyManager.CALL_STATE_IDLE:      //电话挂机
                    resume();
                    break;
            }
        }
    }

    /**
     * 观察屏幕旋转设置变化
     */
    private class ActivityRotationObserver extends ContentObserver {
        ContentResolver mResolver;

        public ActivityRotationObserver(Handler handler) {
            super(handler);
            mResolver = mContext.getContentResolver();
        }

        //屏幕旋转设置改变时调用
        @Override
        public void onChange(boolean selfChange) {
            super.onChange(selfChange);
            if (isActivityCanRotation(mContext)) {
                setRotationForActivity();
            } else {
                // 恢复到正方向
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
                // 恢复渲染角度
                mLivePusher.setRenderRotation(0);
                if (mLivePusher.isPushing()) {
                    mLivePusher.setConfig(mLivePushConfig);
                }
            }
            if (mOnLivePusherCallback != null) {
                mOnLivePusherCallback.onActivityRotationObserverChange(selfChange);
            }
        }

        public void startObserver() {
            mResolver.registerContentObserver(Settings.System.getUriFor(Settings.System.ACCELEROMETER_ROTATION), false, this);
        }

        public void stopObserver() {
            mResolver.unregisterContentObserver(this);
        }
    }

    public class PhoneStateReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Log.d(TAG, "PhoneStateReceiver action: " + action);
        }
    }
}
