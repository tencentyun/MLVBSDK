package com.nama.module.impl;

import android.content.Context;

import com.faceunity.wrapper.faceunity;
import com.nama.module.IFaceBeautyModule;
import com.nama.module.event.RenderEventQueue;
import com.nama.param.BeautificationParam;
import com.nama.utils.BundleUtils;
import com.nama.utils.LogUtils;
import com.nama.utils.ThreadHelper;

/**
 * 美颜模块
 *
 * @author Richie on 2020.07.07
 */
public class FaceBeautyModule extends AbstractEffectModule implements IFaceBeautyModule {
    private static final String TAG = "FaceBeautyModule";
    /* 美颜和滤镜的默认参数，具体的参数定义，请看 BeautificationParam 类 */
    private int mIsBeautyOn = 1; // 美颜开启
    private String mFilterName = BeautificationParam.ZIRAN_1;// 滤镜名称：自然 1
    private float mFilterLevel = 0.4f;// 滤镜程度
    private float mBlurLevel = 0.7f;// 磨皮程度
    private float mColorLevel = 0.3f;// 美白
    private float mRedLevel = 0.3f;// 红润
    private float mEyeBright = 0.0f;// 亮眼
    private float mToothWhiten = 0.0f;// 美牙
    private float mCheekThinning = 0f;// 瘦脸
    private float mCheekV = 0.5f;// V脸
    private float mCheekNarrow = 0f;// 窄脸
    private float mCheekSmall = 0f;// 小脸
    private float mEyeEnlarging = 0.4f;// 大眼
    private float mIntensityChin = 0.3f;// 下巴
    private float mIntensityForehead = 0.3f;// 额头
    private float mIntensityMouth = 0.4f;// 嘴形
    private float mIntensityNose = 0.5f;// 瘦鼻
    private float mRemovePouchStrength = 0f; // 去黑眼圈
    private float mRemoveNasolabialFoldsStrength = 0f; // 去法令纹
    private float mIntensitySmile = 0f; // 微笑嘴角
    private float mIntensityCanthus = 0f; // 开眼角
    private float mIntensityPhiltrum = 0.5f; // 调节人中
    private float mIntensityLongNose = 0.5f; // 鼻子长度
    private float mIntensityEyeSpace = 0.5f; // 眼睛间距
    private float mIntensityEyeRotate = 0.5f; // 眼睛角度

    @Override
    public void create(final Context context, final ModuleCallback moduleCallback) {
        if (mItemHandle > 0) {
            return;
        }
        mRenderEventQueue = new RenderEventQueue();
        ThreadHelper.getInstance().execute(new Runnable() {
            @Override
            public void run() {
                final int itemFaceBeauty = BundleUtils.loadItem(context, "graphics/face_beautification.bundle");
                if (itemFaceBeauty <= 0) {
                    LogUtils.warn(TAG, "load face beauty item failed %d", itemFaceBeauty);
                    return;
                }
                mItemHandle = itemFaceBeauty;

                setIsBeautyOn(mIsBeautyOn);
                setFilterName(mFilterName);
                setFilterLevel(mFilterLevel);
                mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.HEAVY_BLUR, 0.0);
                mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.BLUR_TYPE, 2.0); // 精细磨皮
                setBlurLevel(mBlurLevel);
                setColorLevel(mColorLevel);
                setRedLevel(mRedLevel);
                setEyeBright(mEyeBright);
                setToothWhiten(mToothWhiten);
                mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.FACE_SHAPE, 4.0); // 精细变形
                mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.FACE_SHAPE_LEVEL, 1.0); // 精细变形程度
                setEyeEnlarging(mEyeEnlarging);
                setCheekThinning(mCheekThinning);
                setCheekNarrow(mCheekNarrow);
                setCheekSmall(mCheekSmall);
                setCheekV(mCheekV);
                setIntensityNose(mIntensityNose);
                setIntensityChin(mIntensityChin);
                setIntensityForehead(mIntensityForehead);
                setIntensityMouth(mIntensityMouth);
                setRemovePouchStrength(mRemovePouchStrength);
                setRemoveNasolabialFoldsStrength(mRemoveNasolabialFoldsStrength);
                setIntensitySmile(mIntensitySmile);
                setIntensityCanthus(mIntensityCanthus);
                setIntensityPhiltrum(mIntensityPhiltrum);
                setIntensityLongNose(mIntensityLongNose);
                setIntensityEyeSpace(mIntensityEyeSpace);
                setIntensityEyeRotate(mIntensityEyeRotate);

                LogUtils.debug(TAG, "face beauty param: isBeautyOn:" + mIsBeautyOn + ", filterName:"
                        + mFilterName + ", filterLevel:" + mFilterLevel + ", blurLevel:" + mBlurLevel + ", colorLevel:"
                        + mColorLevel + ", redLevel:" + mRedLevel + ", eyeBright:" + mEyeBright + ", toothWhiten:"
                        + mToothWhiten + ", eyeEnlarging:" + mEyeEnlarging + ", cheekThinning:" + mCheekThinning + ", cheekNarrow:"
                        + mCheekNarrow + ", cheekSmall:" + mCheekSmall + ", cheekV:" + mCheekV + ", intensityNose:"
                        + mIntensityNose + ", intensityChin:" + mIntensityChin + ", intensityForehead:"
                        + mIntensityForehead + ", intensityMouth:" + mIntensityMouth + ", removePouchStrength:"
                        + mRemovePouchStrength + ", removeNasolabialFoldsStrength:" + mRemoveNasolabialFoldsStrength + ", intensitySmile:"
                        + mIntensitySmile + ", intensityCanthus:" + mIntensityCanthus + ", intensityPhiltrum:"
                        + mIntensityPhiltrum + ", intensityLongNose:" + mIntensityLongNose + ", intensityEyeSpace:"
                        + mIntensityEyeSpace + ", eyeRotate:" + mIntensityEyeRotate);

                if (moduleCallback != null) {
                    moduleCallback.onBundleCreated(itemFaceBeauty);
                }
            }
        });
    }

    @Override
    public void setMaxFaces(final int maxFaces) {
        if (maxFaces <= 0 || mRenderEventQueue == null) {
            return;
        }
        mRenderEventQueue.add(new Runnable() {
            @Override
            public void run() {
                faceunity.fuSetMaxFaces(maxFaces);
                LogUtils.debug(TAG, "setMaxFaces : %d", maxFaces);
            }
        });
    }

    @Override
    public void setIsBeautyOn(int isBeautyOn) {
        if (mIsBeautyOn == isBeautyOn) {
            return;
        }
        mIsBeautyOn = isBeautyOn;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.IS_BEAUTY_ON, isBeautyOn);
        }
    }

    @Override
    public void setFilterName(String name) {
        mFilterName = name;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.FILTER_NAME, name);
        }
    }

    @Override
    public void setFilterLevel(float level) {
        mFilterLevel = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.FILTER_LEVEL, level);
        }
    }

    @Override
    public void setBlurLevel(float level) {
        mBlurLevel = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.BLUR_LEVEL, 6.0 * level);
        }
    }

    @Override
    public void setColorLevel(float level) {
        mColorLevel = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.COLOR_LEVEL, level);
        }
    }

    @Override
    public void setRedLevel(float level) {
        mRedLevel = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.RED_LEVEL, level);
        }
    }

    @Override
    public void setEyeBright(float level) {
        mEyeBright = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.EYE_BRIGHT, level);
        }
    }

    @Override
    public void setToothWhiten(float level) {
        mToothWhiten = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.TOOTH_WHITEN, level);
        }
    }

    @Override
    public void setEyeEnlarging(float level) {
        mEyeEnlarging = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.EYE_ENLARGING, level);
        }
    }

    @Override
    public void setCheekThinning(float level) {
        mCheekThinning = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.CHEEK_THINNING, level);
        }
    }

    @Override
    public void setCheekNarrow(float level) {
        mCheekNarrow = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.CHEEK_NARROW, level);
        }
    }

    @Override
    public void setCheekSmall(float level) {
        mCheekSmall = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.CHEEK_SMALL, level);
        }
    }

    @Override
    public void setCheekV(float level) {
        mCheekV = level;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.CHEEK_V, level);
        }
    }

    @Override
    public void setIntensityChin(float intensity) {
        mIntensityChin = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_CHIN, intensity);
        }
    }

    @Override
    public void setIntensityForehead(float intensity) {
        mIntensityForehead = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_FOREHEAD, intensity);
        }
    }

    @Override
    public void setIntensityNose(float intensity) {
        mIntensityNose = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_NOSE, intensity);
        }
    }

    @Override
    public void setIntensityMouth(float intensity) {
        mIntensityMouth = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_MOUTH, intensity);
        }
    }

    @Override
    public void setRemovePouchStrength(float strength) {
        mRemovePouchStrength = strength;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.REMOVE_POUCH_STRENGTH, strength);
        }
    }

    @Override
    public void setRemoveNasolabialFoldsStrength(float strength) {
        mRemoveNasolabialFoldsStrength = strength;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.REMOVE_NASOLABIAL_FOLDS_STRENGTH, strength);
        }
    }

    @Override
    public void setIntensitySmile(float intensity) {
        mIntensitySmile = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_SMILE, intensity);
        }
    }

    @Override
    public void setIntensityCanthus(float intensity) {
        mIntensityCanthus = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_CANTHUS, intensity);
        }
    }

    @Override
    public void setIntensityPhiltrum(float intensity) {
        mIntensityPhiltrum = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_PHILTRUM, intensity);
        }
    }

    @Override
    public void setIntensityLongNose(float intensity) {
        mIntensityLongNose = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_LONG_NOSE, intensity);
        }
    }

    @Override
    public void setIntensityEyeSpace(float intensity) {
        mIntensityEyeSpace = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_EYE_SPACE, intensity);
        }
    }

    @Override
    public void setIntensityEyeRotate(float intensity) {
        mIntensityEyeRotate = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BeautificationParam.INTENSITY_EYE_ROTATE, intensity);
        }
    }

}