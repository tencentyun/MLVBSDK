package com.nama;

import android.content.Context;

import com.faceunity.wrapper.faceunity;
import com.nama.module.IBodySlimModule;
import com.nama.module.IEffectModule;
import com.nama.module.IFaceBeautyModule;
import com.nama.module.IMakeupModule;
import com.nama.module.IStickerModule;
import com.nama.module.impl.BodySlimModule;
import com.nama.module.impl.FaceBeautyModule;
import com.nama.module.impl.MakeupModule;
import com.nama.module.impl.StickerModule;
import com.nama.utils.BundleUtils;
import com.nama.utils.DeviceUtils;
import com.nama.utils.LogUtils;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * 基于 Nama SDK 封装，方便集成，使用步骤：
 * <p>
 * 1. 通过 FURenderer.Builder 构造器设置合适的参数
 * 2. 美颜、美妆、贴纸和美体模块化，使用时开关参数设置 true 即可
 * 3. GL Surface 创建和销毁时，分别调用 onSurfaceCreated 和 onSurfaceDestroyed
 * 4. 相机朝向和设备方向变化时，分别调用 onCameraChanged 和 onDeviceOrientationChanged
 * 5. 处理图像时调用 onDrawFrameXXX，提供了纹理和 buffer 多种输入和输出方案
 * </p>
 */
public class FURenderer implements IFURenderer, IModuleManager {
    private static final String TAG = "FURenderer";
    /* 句柄数组下标，分别代表美颜、贴纸、美妆和美体 */
    private static final int ITEMS_ARRAY_FACE_BEAUTY = 0;
    private static final int ITEMS_ARRAY_STICKER = 1;
    private static final int ITEMS_ARRAY_MAKEUP = 2;
    private static final int ITEMS_ARRAY_BODY_SLIM = 3;
    /* 句柄数组长度 4，根据功能需要调整大小 */
    private static final int ITEMS_ARRAY_LENGTH = 4;
    /* 存放美颜、贴纸等句柄的数组 */
    private final int[] mItemsArray = new int[ITEMS_ARRAY_LENGTH];
    private final Context mContext;
    /* 递增的帧 ID */
    private int mFrameId = 0;
    /* 同时识别的最大人脸数，默认 4 */
    private int mMaxFaces = 4;
    /* 是否手动创建 EGLContext，默认不创建 */
    private boolean mIsCreateEglContext = false;
    /* 输入图像的纹理类型，默认 2D */
    private int mInputTextureType = INPUT_TEXTURE_2D;
    /* 输入图像的 buffer 类型，此项一般不用改 */
    private int mInputImageFormat = 0;
    /* 输入图像的方向，默认前置相机 270 */
    private int mInputImageOrientation = 270;
    /* 设备方向，默认竖屏 */
    private int mDeviceOrientation = 90;
    /* 人脸识别方向，默认 1，通过 createRotationMode 方法获得 */
    private int mRotationMode = faceunity.FU_ROTATION_MODE_90;
    /* 相机前后方向，默认前置相机  */
    private int mCameraFacing = CAMERA_FACING_FRONT;
    /* 任务队列 */
    private final ArrayList<Runnable> mEventQueue = new ArrayList<>(16);
    /* GL 线程 ID */
    private long              mGlThreadId;
    /* 特效模块，美颜、贴纸、美妆和美体 */
    private IFaceBeautyModule mFaceBeautyModule;
    private IStickerModule mStickerModule;
    private IMakeupModule mMakeupModule;
    private IBodySlimModule mBodySlimModule;
    /* 是否创建过特效模块，用于恢复选中效果 */
    private boolean         mIsCreatedSticker;
    private boolean mIsCreatedMakeup;
    private boolean mIsCreatedBodySlim;
    /* 是否已经全局初始化，确保只初始化一次 */
    private static boolean sIsInited;

    /**
     * SDK 日志级别
     */
    public static final class FuLogLevel {
        public static final int FU_LOG_LEVEL_TRACE = 0;
        public static final int FU_LOG_LEVEL_DEBUG = 1;
        public static final int FU_LOG_LEVEL_INFO = 2;
        public static final int FU_LOG_LEVEL_WARN = 3;
        public static final int FU_LOG_LEVEL_ERROR = 4;
        public static final int FU_LOG_LEVEL_CRITICAL = 5;
        public static final int FU_LOG_LEVEL_OFF = 6;
    }

    /**
     * 初始化系统环境，加载底层数据，并进行网络鉴权。
     * 应用使用期间只需要初始化一次，无需释放数据。
     * fuSetup 函数需要 GL 环境，必须在 SDK 其他功能接口前调用，否则会引起应用崩溃。
     *
     * @param context
     */
    public static void setup(Context context) {
        if (sIsInited) {
            return;
        }
        long startTime = System.currentTimeMillis();
        // fuSetup 需要 eglContext
        faceunity.fuCreateEGLContext();
        faceunity.fuSetLogLevel(FuLogLevel.FU_LOG_LEVEL_WARN);
        LogUtils.setLogLevel(LogUtils.DEBUG);
        // 打印设备信息
        LogUtils.info(TAG, "device info: {%s}", DeviceUtils.retrieveDeviceInfo(context));
        // 获取 Nama SDK 版本信息
        LogUtils.info(TAG, "fu nama sdk version %s", faceunity.fuGetVersion());
        // v3 不再使用，第一个参数传空字节数组即可
        faceunity.fuSetup(new byte[0], authpack.A());
        boolean isInited = isInit();
        sIsInited = isInited;
        LogUtils.info(TAG, "setup. isLibInit: %s", isInited);
        boolean isLoaded = BundleUtils.loadAiModel(context, "model/ai_face_processor.bundle", faceunity.FUAITYPE_FACEPROCESSOR);
        LogUtils.info(TAG, "load aiFaceProcessor. isLoaded: %s", isLoaded);
        // 释放创建的 eglContext
        faceunity.fuReleaseEGLContext();
        LogUtils.debug(TAG, "setup cost %dms", (int) (System.currentTimeMillis() - startTime));
    }

    /**
     * 销毁 SDK，释放资源。如需再次使用，需要调用 setup。
     */
    public static void destroy() {
        if (sIsInited) {
            BundleUtils.releaseAiModel(faceunity.FUAITYPE_FACEPROCESSOR);
            faceunity.fuDestroyLibData();
            sIsInited = isInit();
            LogUtils.debug(TAG, "destroy. isLibInit: %s", sIsInited);
        }
    }

    /**
     * SDK 是否初始化
     *
     * @return
     */
    public static boolean isInit() {
        return faceunity.fuIsLibraryInit() == 1;
    }

    /**
     * 获取 Nama SDK 版本号，例如 7_0_0_phy_8b882f6_91a980f
     *
     * @return version
     */
    public static String getVersion() {
        return faceunity.fuGetVersion();
    }

    private FURenderer(Context context) {
        mContext = context;
    }

    @Override
    public void onSurfaceCreated() {
        LogUtils.info(TAG, "onSurfaceCreated");
        mGlThreadId = Thread.currentThread().getId();
        /*
         * 创建OpenGL环境，适用于没有 OpenGL 环境时。
         * 如果调用了fuCreateEGLContext，销毁时需要调用fuReleaseEGLContext
         */
        if (mIsCreateEglContext) {
            faceunity.fuCreateEGLContext();
        }
        mRotationMode = createRotationMode();
        if (mFaceBeautyModule != null) {
            mFaceBeautyModule.create(mContext, new IEffectModule.ModuleCallback() {
                @Override
                public void onBundleCreated(int itemHandle) {
                    mItemsArray[ITEMS_ARRAY_FACE_BEAUTY] = itemHandle;
                }
            });
            mFaceBeautyModule.setMaxFaces(mMaxFaces);
            mFaceBeautyModule.setRotationMode(mRotationMode);
        }
        if (mIsCreatedSticker) {
            createStickerModule();
        }
        if (mIsCreatedMakeup) {
            createMakeupModule();
        }
        if (mIsCreatedBodySlim) {
            createBodySlimModule();
        }
    }

    @Override
    public void onSurfaceDestroyed() {
        LogUtils.info(TAG, "onSurfaceDestroyed");
        mGlThreadId = 0;
        mFrameId = 0;
        synchronized (this) {
            mEventQueue.clear();
        }
        mTrackFaceStatus = -1;
        mTrackHumanStatus = -1;
        if (mFaceBeautyModule != null) {
            mFaceBeautyModule.destroy();
        }
        if (mStickerModule != null) {
            mStickerModule.destroy();
        }
        if (mMakeupModule != null) {
            mMakeupModule.destroy();
        }
        if (mBodySlimModule != null) {
            mBodySlimModule.destroy();
        }
        for (int item : mItemsArray) {
            if (item > 0) {
                faceunity.fuDestroyItem(item);
            }
        }
        Arrays.fill(mItemsArray, 0);
        faceunity.fuDone();
        faceunity.fuOnDeviceLost();
        if (mIsCreateEglContext) {
            faceunity.fuReleaseEGLContext();
        }
    }

    @Override
    public int onDrawFrameSingleInput(int tex, int w, int h) {
        if (tex <= 0 || w <= 0 || h <= 0) {
            LogUtils.error(TAG, "onDrawFrame data is invalid");
            return 0;
        }
        prepareDrawFrame();
        int flags = createFlags();
        if (mIsRunBenchmark) {
            mCallStartTime = System.nanoTime();
        }
        int fuTex = faceunity.fuRenderToTexture(tex, w, h, mFrameId++, mItemsArray, flags);
        if (mIsRunBenchmark) {
            mSumCallTime += System.nanoTime() - mCallStartTime;
        }
        return fuTex;
    }

    @Override
    public int onDrawFrameSingleInput(byte[] img, int w, int h, int format) {
        if (img == null || w <= 0 || h <= 0) {
            LogUtils.error(TAG, "onDrawFrame data is invalid");
            return 0;
        }
        prepareDrawFrame();
        int flags = createFlags();
        flags ^= mInputTextureType;
        if (mIsRunBenchmark) {
            mCallStartTime = System.nanoTime();
        }
        int fuTex;
        switch (format) {
            case INPUT_FORMAT_I420_BUFFER:
                fuTex = faceunity.fuRenderToI420Image(img, w, h, mFrameId++, mItemsArray, flags);
                break;
            case INPUT_FORMAT_RGBA_BUFFER:
                fuTex = faceunity.fuRenderToRgbaImage(img, w, h, mFrameId++, mItemsArray, flags);
                break;
            case INPUT_FORMAT_NV21_BUFFER:
            default:
                fuTex = faceunity.fuRenderToNV21Image(img, w, h, mFrameId++, mItemsArray, flags);
                break;
        }
        if (mIsRunBenchmark) {
            mSumCallTime += System.nanoTime() - mCallStartTime;
        }
        return fuTex;
    }


    @Override
    public int onDrawFrameSingleInput(byte[] img, int w, int h, int format, byte[] readBackImg, int readBackW, int readBackH) {
        if (img == null || w <= 0 || h <= 0 || readBackImg == null || readBackW <= 0 || readBackH <= 0) {
            LogUtils.error(TAG, "onDrawFrame data is invalid");
            return 0;
        }
        prepareDrawFrame();
        int flags = createFlags();
        flags ^= mInputTextureType;
        flags |= faceunity.FU_ADM_FLAG_ENABLE_READBACK;
        if (mIsRunBenchmark) {
            mCallStartTime = System.nanoTime();
        }
        int fuTex;
        switch (format) {
            case INPUT_FORMAT_I420_BUFFER:
                fuTex = faceunity.fuRenderToI420Image(img, w, h, mFrameId++, mItemsArray, flags,
                        readBackW, readBackH, readBackImg);
                break;
            case INPUT_FORMAT_RGBA_BUFFER:
                fuTex = faceunity.fuRenderToRgbaImage(img, w, h, mFrameId++, mItemsArray, flags,
                        readBackW, readBackH, readBackImg);
                break;
            case INPUT_FORMAT_NV21_BUFFER:
            default:
                fuTex = faceunity.fuRenderToNV21Image(img, w, h, mFrameId++, mItemsArray, flags,
                        readBackW, readBackH, readBackImg);
                break;
        }
        if (mIsRunBenchmark) {
            mSumCallTime += System.nanoTime() - mCallStartTime;
        }
        return fuTex;
    }

    @Override
    public int onDrawFrameDualInput(byte[] img, int tex, int w, int h) {
        if (img == null || tex <= 0 || w <= 0 || h <= 0) {
            LogUtils.error(TAG, "onDrawFrame data is invalid");
            return 0;
        }
        prepareDrawFrame();
        int flags = createFlags();
        int rotation = mInputImageOrientation == 270 ? faceunity.FU_ADM_FLAG_TEXTURE_ROTATE_270
                : faceunity.FU_ADM_FLAG_TEXTURE_ROTATE_90;
        flags |= rotation;
        if (mIsRunBenchmark) {
            mCallStartTime = System.nanoTime();
        }
        int fuTex = faceunity.fuDualInputToTexture(img, tex, flags, w, h, mFrameId++, mItemsArray);
        if (mIsRunBenchmark) {
            mSumCallTime += System.nanoTime() - mCallStartTime;
        }
        return fuTex;
    }

    @Override
    public int onDrawFrameDualInput(byte[] img, int tex, int w, int h, byte[] readBackImg, int readBackW, int readBackH) {
        if (img == null || tex <= 0 || w <= 0 || h <= 0 || readBackImg == null || readBackW <= 0 || readBackH <= 0) {
            LogUtils.error(TAG, "onDrawFrame data is invalid");
            return 0;
        }
        prepareDrawFrame();
        int flags = createFlags();
        int rotation = mInputImageOrientation == 270 ? faceunity.FU_ADM_FLAG_TEXTURE_AND_READBACK_BUFFER_ROTATE_270
                : faceunity.FU_ADM_FLAG_TEXTURE_AND_READBACK_BUFFER_ROTATE_90;
        flags |= rotation;
        flags |= faceunity.FU_ADM_FLAG_ENABLE_READBACK;
        if (mIsRunBenchmark) {
            mCallStartTime = System.nanoTime();
        }
        int fuTex = faceunity.fuDualInputToTexture(img, tex, flags, w, h, mFrameId++, mItemsArray,
                readBackW, readBackH, readBackImg);
        if (mIsRunBenchmark) {
            mSumCallTime += System.nanoTime() - mCallStartTime;
        }
        return fuTex;
    }

    @Override
    public void queueEvent(Runnable r) {
        if (r == null) {
            return;
        }
        if (mGlThreadId == Thread.currentThread().getId()) {
            r.run();
        } else {
            synchronized (this) {
                mEventQueue.add(r);
            }
        }
    }

    @Override
    public void onDeviceOrientationChanged(int deviceOrientation) {
        if (mDeviceOrientation == deviceOrientation) {
            return;
        }
        LogUtils.debug(TAG, "onDeviceOrientationChanged() deviceOrientation: %d", deviceOrientation);
        mDeviceOrientation = deviceOrientation;
        callWhenDeviceChanged();
    }

    @Override
    public void onCameraChanged(int cameraFacing, int cameraOrientation) {
        if (mCameraFacing == cameraFacing && mInputImageOrientation == cameraOrientation) {
            return;
        }
        LogUtils.debug(TAG, "onCameraChanged() cameraFacing: %d, cameraOrientation: %d", cameraFacing, cameraOrientation);
        mCameraFacing = cameraFacing;
        mInputImageOrientation = cameraOrientation;
        callWhenDeviceChanged();
    }

    @Override
    public IFaceBeautyModule getFaceBeautyModule() {
        return mFaceBeautyModule;
    }

    @Override
    public void createStickerModule() {
        LogUtils.info(TAG, "createStickerModule: ");
        if (mStickerModule == null) {
            return;
        }
        mIsCreatedSticker = true;
        mStickerModule.create(mContext, new IEffectModule.ModuleCallback() {
            @Override
            public void onBundleCreated(int itemHandle) {
                final int oldItem = mItemsArray[ITEMS_ARRAY_STICKER];
                queueEvent(new Runnable() {
                    @Override
                    public void run() {
                        if (oldItem > 0) {
                            faceunity.fuDestroyItem(oldItem);
                        }
                    }
                });
                double isAndroid = mInputTextureType == INPUT_TEXTURE_EXTERNAL_OES ? 1.0 : 0.0;
                // 历史遗留参数，和具体贴纸有关，用于全屏贴纸道具
                mStickerModule.setItemParam("isAndroid", isAndroid);
                if (itemHandle > 0) {
                    mStickerModule.setRotationMode(mRotationMode);
                }
                mItemsArray[ITEMS_ARRAY_STICKER] = itemHandle;
            }
        });
    }

    @Override
    public IStickerModule getStickerModule() {
        return mStickerModule;
    }

    @Override
    public void destroyStickerModule() {
        LogUtils.info(TAG, "destroyStickerModule: ");
        mIsCreatedSticker = false;
        if (mStickerModule != null) {
            queueEvent(new Runnable() {
                @Override
                public void run() {
                    mStickerModule.destroy();
                    mItemsArray[ITEMS_ARRAY_STICKER] = 0;
                }
            });
        }
    }

    @Override
    public void createMakeupModule() {
        LogUtils.info(TAG, "createMakeupModule: ");
        if (mMakeupModule == null) {
            return;
        }
        mIsCreatedMakeup = true;
        mMakeupModule.create(mContext, new IEffectModule.ModuleCallback() {
            @Override
            public void onBundleCreated(int itemHandle) {
                mItemsArray[ITEMS_ARRAY_MAKEUP] = itemHandle;
            }
        });
    }

    @Override
    public IMakeupModule getMakeupModule() {
        return mMakeupModule;
    }

    @Override
    public void destroyMakeupModule() {
        LogUtils.info(TAG, "destroyMakeupModule: ");
        mIsCreatedMakeup = false;
        if (mMakeupModule != null) {
            queueEvent(new Runnable() {
                @Override
                public void run() {
                    mMakeupModule.destroy();
                    mItemsArray[ITEMS_ARRAY_MAKEUP] = 0;
                }
            });
        }
    }

    @Override
    public void createBodySlimModule() {
        LogUtils.info(TAG, "createBodySlimModule: ");
        if (mBodySlimModule == null) {
            return;
        }
        mIsCreatedBodySlim = true;
        mBodySlimModule.create(mContext, new IEffectModule.ModuleCallback() {
            @Override
            public void onBundleCreated(int itemHandle) {
                mBodySlimModule.setRotationMode(mRotationMode);
                mItemsArray[ITEMS_ARRAY_BODY_SLIM] = itemHandle;
                resetTrackStatus();
            }
        });
    }

    @Override
    public IBodySlimModule getBodySlimModule() {
        return mBodySlimModule;
    }

    @Override
    public void destroyBodySlimModule() {
        LogUtils.info(TAG, "destroyBodySlimModule: ");
        mIsCreatedBodySlim = false;
        if (mBodySlimModule != null) {
            queueEvent(new Runnable() {
                @Override
                public void run() {
                    mBodySlimModule.destroy();
                    mItemsArray[ITEMS_ARRAY_BODY_SLIM] = 0;
                }
            });
            resetTrackStatus();
        }
    }

    /**
     * 为了解决第三方推流使用 texture 时，异步读取输出纹理效果异常。如果发送 buffer，可以不设置。
     *
     * @param use 1 使用，0 不使用。默认 0，性能更优。
     */
    public void setUseTexAsync(final boolean use) {
        queueEvent(new Runnable() {
            @Override
            public void run() {
                faceunity.fuSetUseTexAsync(use ? 1 : 0);
                LogUtils.debug(TAG, "fuSetUseTexAsync: %s", use);
            }
        });
    }

    /**
     * 视频模式下，不保证每帧都检测到人脸，针对无人脸场景做了优化。如果是图片处理，要设置图片模式。
     *
     * @param mode 0 图片模式, 1 视频模式, 默认 1。
     */
    private void setFaceProcessorDetectMode(final int mode) {
        queueEvent(new Runnable() {
            @Override
            public void run() {
                faceunity.fuSetFaceProcessorDetectMode(mode);
                LogUtils.debug(TAG, "fuSetFaceProcessorDetectMode: %d", mode);
            }
        });
    }

    private void prepareDrawFrame() {
        // 计算 FPS
        benchmarkFPS();
        if (BundleUtils.isAiModelLoaded(faceunity.FUAITYPE_HUMAN_PROCESSOR)) {
            // 获取人体是否识别
            int trackHumans = faceunity.fuHumanProcessorGetNumResults();
            if (mTrackHumanStatus != trackHumans) {
                mTrackHumanStatus = trackHumans;
                if (mOnTrackStatusChangedListener != null) {
                    mOnTrackStatusChangedListener.onTrackStatusChanged(TRACK_TYPE_HUMAN, trackHumans);
                }
            }
        } else if (BundleUtils.isAiModelLoaded(faceunity.FUAITYPE_FACEPROCESSOR)) {
            // 获取人脸是否识别
            int trackFace = faceunity.fuIsTracking();
            if (mTrackFaceStatus != trackFace) {
                mTrackFaceStatus = trackFace;
                if (mOnTrackStatusChangedListener != null) {
                    mOnTrackStatusChangedListener.onTrackStatusChanged(TRACK_TYPE_FACE, trackFace);
                }
            }
        }
        // 获取错误信息，并调用回调接口
        int errorCode = faceunity.fuGetSystemError();
        if (errorCode != 0) {
            String message = faceunity.fuGetSystemErrorString(errorCode);
            LogUtils.error(TAG, "fuGetSystemError. code: %d, message: %s", errorCode, message);
            if (mOnSystemErrorListener != null) {
                mOnSystemErrorListener.onSystemError(errorCode, message);
            }
        }
        // 执行任务队列中的任务
        synchronized (this) {
            while (!mEventQueue.isEmpty()) {
                mEventQueue.remove(0).run();
            }
        }
        // 执行各个特效模块的任务
        if (mFaceBeautyModule != null) {
            mFaceBeautyModule.executeEvent();
        }
        if (mStickerModule != null) {
            mStickerModule.executeEvent();
        }
        if (mMakeupModule != null) {
            mMakeupModule.executeEvent();
        }
        if (mBodySlimModule != null) {
            mBodySlimModule.executeEvent();
        }
    }

    private void callWhenDeviceChanged() {
        int rotationMode = createRotationMode();
        LogUtils.debug(TAG, "callWhenDeviceChanged() rotationMode: %d", rotationMode);
        mRotationMode = rotationMode;
        if (mFaceBeautyModule != null) {
            mFaceBeautyModule.setRotationMode(rotationMode);
        }
        if (mMakeupModule != null) {
            mMakeupModule.setRotationMode(rotationMode);
        }
        if (mStickerModule != null) {
            mStickerModule.setRotationMode(rotationMode);
        }
        if (mBodySlimModule != null) {
            mBodySlimModule.setRotationMode(rotationMode);
        }
        queueEvent(new Runnable() {
            @Override
            public void run() {
                faceunity.fuOnCameraChange();
                faceunity.fuHumanProcessorReset();
            }
        });
    }

    /* 根据不用的 texture 类型和输入方向，修改 rotationMode */
    private int createRotationMode() {
        int rotMode = faceunity.FU_ROTATION_MODE_0;
        int deviceOrientation = mDeviceOrientation;
        int cameraType = mCameraFacing;
        int inputImageOrientation = mInputImageOrientation;
        if (inputImageOrientation == 270) {
            if (cameraType == CAMERA_FACING_FRONT) {
                if (deviceOrientation == 90) {
                    rotMode = faceunity.FU_ROTATION_MODE_0;
                } else if (deviceOrientation == 0) {
                    rotMode = faceunity.FU_ROTATION_MODE_270;
                } else if (deviceOrientation == 180) {
                    rotMode = faceunity.FU_ROTATION_MODE_90;
                } else {
                    rotMode = faceunity.FU_ROTATION_MODE_180;
                }
            } else {
                if (deviceOrientation == 90) {
                    rotMode = faceunity.FU_ROTATION_MODE_270;
                } else if (deviceOrientation == 270) {
                    rotMode = faceunity.FU_ROTATION_MODE_90;
                } else {
                    rotMode = deviceOrientation / 90;
                }
            }
        } else if (inputImageOrientation == 90) {
            if (cameraType == CAMERA_FACING_BACK) {
                if (deviceOrientation == 90) {
                    rotMode = faceunity.FU_ROTATION_MODE_0;
                } else if (deviceOrientation == 0) {
                    rotMode = faceunity.FU_ROTATION_MODE_90;
                } else if (deviceOrientation == 180) {
                    rotMode = faceunity.FU_ROTATION_MODE_270;
                } else {
                    rotMode = faceunity.FU_ROTATION_MODE_180;
                }
            } else {
                if (deviceOrientation == 0) {
                    rotMode = faceunity.FU_ROTATION_MODE_180;
                } else if (deviceOrientation == 90) {
                    rotMode = faceunity.FU_ROTATION_MODE_270;
                } else if (deviceOrientation == 270) {
                    rotMode = faceunity.FU_ROTATION_MODE_90;
                }
            }
        }
        return rotMode;
    }

    private int createFlags() {
        int inputTextureType = mInputTextureType;
        int flags = inputTextureType | mInputImageFormat;
        if (mCameraFacing != CAMERA_FACING_FRONT) {
            flags |= faceunity.FU_ADM_FLAG_FLIP_X;
        }
        return flags;
    }

    //-----------------------------人脸识别回调相关定义-----------------------------------

    private int mTrackFaceStatus = -1;
    private int mTrackHumanStatus = -1;

    public interface OnTrackStatusChangedListener {
        /**
         * 识别到的人脸或人体数量发生变化
         *
         * @param type   类型
         * @param status 数量
         */
        void onTrackStatusChanged(int type, int status);
    }

    private OnTrackStatusChangedListener mOnTrackStatusChangedListener;

    private void resetTrackStatus() {
        queueEvent(new Runnable() {
            @Override
            public void run() {
                mTrackFaceStatus = -1;
                mTrackHumanStatus = -1;
            }
        });
    }

    //-------------------------错误信息回调相关定义---------------------------------

    public interface OnSystemErrorListener {
        /**
         * SDK 发生错误时调用
         *
         * @param code    错误码
         * @param message 错误消息
         */
        void onSystemError(int code, String message);
    }

    private OnSystemErrorListener mOnSystemErrorListener;

    //------------------------------FPS 渲染时长回调相关定义------------------------------------

    private static final int NANO_IN_ONE_MILLI_SECOND = 1_000_000;
    private static final int NANO_IN_ONE_SECOND = 1_000_000_000;
    private static final int FRAME_COUNT = 100;
    private boolean mIsRunBenchmark = false;
    private int mCurrentFrameCount;
    private long mLastFrameTimestamp;
    private long mSumCallTime;
    private long mCallStartTime;
    private OnDebugListener mOnDebugListener;

    public interface OnDebugListener {
        /**
         * 统计每 10 帧的平均数据，FPS 和渲染函数调用时间
         *
         * @param fps      FPS
         * @param callTime 渲染函数调用时间
         */
        void onFpsChanged(double fps, double callTime);
    }

    private void benchmarkFPS() {
        if (!mIsRunBenchmark) {
            return;
        }
        if (++mCurrentFrameCount == FRAME_COUNT) {
            long tmp = System.nanoTime();
            double fps = (double) NANO_IN_ONE_SECOND / ((double) (tmp - mLastFrameTimestamp) / FRAME_COUNT);
            double renderTime = (double) mSumCallTime / FRAME_COUNT / NANO_IN_ONE_MILLI_SECOND;
            mLastFrameTimestamp = tmp;
            mSumCallTime = 0;
            mCurrentFrameCount = 0;

            if (mOnDebugListener != null) {
                mOnDebugListener.onFpsChanged(fps, renderTime);
            }
        }
    }

    //--------------------------------------Builder----------------------------------------

    /**
     * FURenderer Builder
     */
    public static class Builder {
        private Context context;
        private boolean isCreateEglContext;
        private int maxFaces = 4;
        private int deviceOrientation = 90;
        private int inputTextureType = INPUT_TEXTURE_2D;
        private int inputImageFormat = 0;
        private int inputImageOrientation = 270;
        private int cameraFacing = CAMERA_FACING_FRONT;
        private boolean isRunBenchmark;
        private boolean isCreateFaceBeauty = true;
        private boolean isCreateSticker = true;
        private boolean isCreateMakeup = true;
        private boolean isCreateBodySlim = true;
        private OnDebugListener onDebugListener;
        private OnTrackStatusChangedListener onTrackStatusChangedListener;
        private OnSystemErrorListener onSystemErrorListener;

        public Builder(Context context) {
            this.context = context.getApplicationContext();
        }

        /**
         * 是否手动创建 EGLContext，默认不创建
         *
         * @param isCreateEGLContext
         * @return
         */

        public Builder setCreateEglContext(boolean isCreateEGLContext) {
            this.isCreateEglContext = isCreateEGLContext;
            return this;
        }

        /**
         * 同时识别的最大人脸数，默认 4 人，最大 8 人
         *
         * @param maxFaces
         * @return
         */
        public Builder setMaxFaces(int maxFaces) {
            this.maxFaces = maxFaces;
            return this;
        }

        /**
         * 设备方向
         *
         * @param deviceOrientation
         * @return
         */
        public Builder setDeviceOrientation(int deviceOrientation) {
            this.deviceOrientation = deviceOrientation;
            return this;
        }

        /**
         * 输入图像的纹理类型
         *
         * @param inputTextureType OES 或者 2D
         * @return
         */
        public Builder setInputTextureType(int inputTextureType) {
            this.inputTextureType = inputTextureType;
            return this;
        }

        /**
         * 输入图像的方向
         *
         * @param inputImageOrientation
         * @return
         */
        public Builder setInputImageOrientation(int inputImageOrientation) {
            this.inputImageOrientation = inputImageOrientation;
            return this;
        }

        /**
         * 相机前后置方向
         *
         * @param cameraFacing
         * @return
         */
        public Builder setCameraFacing(int cameraFacing) {
            this.cameraFacing = cameraFacing;
            return this;
        }

        /**
         * 美颜模块
         *
         * @param createFaceBeauty
         * @return
         */
        public Builder setCreateFaceBeauty(boolean createFaceBeauty) {
            this.isCreateFaceBeauty = createFaceBeauty;
            return this;
        }

        /**
         * 贴纸模块
         *
         * @param createSticker
         * @return
         */
        public Builder setCreateSticker(boolean createSticker) {
            this.isCreateSticker = createSticker;
            return this;
        }

        /**
         * 美妆模块
         *
         * @param createMakeup
         * @return
         */
        public Builder setCreateMakeup(boolean createMakeup) {
            this.isCreateMakeup = createMakeup;
            return this;
        }

        /**
         * 美体模块
         *
         * @param createBodySlim
         * @return
         */
        public Builder setCreateBodySlim(boolean createBodySlim) {
            this.isCreateBodySlim = createBodySlim;
            return this;
        }

        /**
         * 是否运行 benchmark 数据统计，一般用于性能分析
         *
         * @param isRunBenchmark
         * @return
         */
        public Builder setRunBenchmark(boolean isRunBenchmark) {
            this.isRunBenchmark = isRunBenchmark;
            return this;
        }

        /**
         * FPS 和函数时长数据回调，需要开启 benchmark
         *
         * @param onDebugListener
         * @return
         */
        public Builder setOnDebugListener(OnDebugListener onDebugListener) {
            this.onDebugListener = onDebugListener;
            return this;
        }

        /**
         * 人脸和人体识别状态回调
         *
         * @param onTrackStatusChangedListener
         * @return
         */
        public Builder setOnTrackStatusChangedListener(OnTrackStatusChangedListener onTrackStatusChangedListener) {
            this.onTrackStatusChangedListener = onTrackStatusChangedListener;
            return this;
        }

        /**
         * SDK 错误信息回调
         *
         * @param onSystemErrorListener
         * @return
         */
        public Builder setOnSystemErrorListener(OnSystemErrorListener onSystemErrorListener) {
            this.onSystemErrorListener = onSystemErrorListener;
            return this;
        }

        public FURenderer build() {
            FURenderer fuRenderer = new FURenderer(context);
            fuRenderer.mIsCreateEglContext = isCreateEglContext;
            fuRenderer.mMaxFaces = maxFaces;
            fuRenderer.mDeviceOrientation = deviceOrientation;
            fuRenderer.mInputTextureType = inputTextureType;
            fuRenderer.mInputImageFormat = inputImageFormat;
            fuRenderer.mInputImageOrientation = inputImageOrientation;
            fuRenderer.mCameraFacing = cameraFacing;
            fuRenderer.mFaceBeautyModule = isCreateFaceBeauty ? new FaceBeautyModule() : null;
            fuRenderer.mStickerModule = isCreateSticker ? new StickerModule() : null;
            fuRenderer.mMakeupModule = isCreateMakeup ? new MakeupModule() : null;
            fuRenderer.mBodySlimModule = isCreateBodySlim ? new BodySlimModule() : null;
            fuRenderer.mIsRunBenchmark = isRunBenchmark;
            fuRenderer.mOnDebugListener = onDebugListener;
            fuRenderer.mOnTrackStatusChangedListener = onTrackStatusChangedListener;
            fuRenderer.mOnSystemErrorListener = onSystemErrorListener;

            LogUtils.debug(TAG, "FURenderer fields. isCreateEglContext: " + isCreateEglContext
                    + ", maxFaces: " + maxFaces + ", inputTextureType: " + inputTextureType
                    + ", inputImageFormat: " + inputImageFormat + ", inputImageOrientation: " + inputImageOrientation
                    + ", deviceOrientation: " + deviceOrientation + ", cameraFacing: " + cameraFacing
                    + ", isRunBenchmark: " + isRunBenchmark + ", isCreateFaceBeauty: " + isCreateFaceBeauty
                    + ", isCreateSticker: " + isCreateSticker + ", isCreateMakeup: " + isCreateMakeup
                    + ", isCreateBodySlim: " + isCreateBodySlim);
            return fuRenderer;
        }
    }

}