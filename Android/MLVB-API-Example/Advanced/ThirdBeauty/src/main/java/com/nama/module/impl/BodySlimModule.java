package com.nama.module.impl;

import android.content.Context;

import com.faceunity.wrapper.faceunity;
import com.nama.module.IBodySlimModule;
import com.nama.module.event.RenderEventQueue;
import com.nama.param.BodySlimParam;
import com.nama.utils.BundleUtils;
import com.nama.utils.LogUtils;
import com.nama.utils.ThreadHelper;

/**
 * 美体模块
 *
 * @author Richie on 2020.07.07
 */
public class BodySlimModule extends AbstractEffectModule implements IBodySlimModule {
    private static final String TAG = "BodySlimModule";
    /* 美体的默认参数，具体的参数定义，请看 BodySlimParam 类 */
    private float mBodySlimStrength = 0.0f; // 瘦身
    private float mLegSlimStrength = 0.0f; // 长腿
    private float mWaistSlimStrength = 0.0f; // 细腰
    private float mShoulderSlimStrength = 0.5f; // 美肩
    private float mHipSlimStrength = 0.0f; // 美胯
    private float mHeadSlimStrength = 0.0f; // 小头
    private float mLegThinSlimStrength = 0.0f; // 瘦腿
    private int mMaxHumans = 1; // 同时识别的最大人体数，目前只支持 1 人

    @Override
    public void create(final Context context, final ModuleCallback moduleCallback) {
        if (mItemHandle > 0) {
            return;
        }
        mRenderEventQueue = new RenderEventQueue();
        ThreadHelper.getInstance().execute(new Runnable() {
            @Override
            public void run() {
                final int itemBodySlim = BundleUtils.loadItem(context, "graphics/body_slim.bundle");
                if (itemBodySlim <= 0) {
                    LogUtils.warn(TAG, "create body slim item failed: %d", itemBodySlim);
                    return;
                }
                boolean isLoaded = BundleUtils.loadAiModel(context, "model/ai_human_processor.bundle", faceunity.FUAITYPE_HUMAN_PROCESSOR);
                if (!isLoaded) {
                    LogUtils.warn(TAG, "load human processor failed");
                    return;
                }
                mItemHandle = itemBodySlim;

                setBodySlimIntensity(mBodySlimStrength);
                setLegSlimIntensity(mLegSlimStrength);
                setWaistSlimIntensity(mWaistSlimStrength);
                setShoulderSlimIntensity(mShoulderSlimStrength);
                setHipSlimIntensity(mHipSlimStrength);
                setHeadSlimIntensity(mHeadSlimStrength);
                setLegThinSlimIntensity(mLegThinSlimStrength);

                if (moduleCallback != null) {
                    moduleCallback.onBundleCreated(itemBodySlim);
                }
            }
        });
    }

    @Override
    public void setRotationMode(int rotationMode) {
        super.setRotationMode(rotationMode);
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.ORIENTATION, rotationMode);
        }
    }

    @Override
    public void destroy() {
        super.destroy();
        BundleUtils.releaseAiModel(faceunity.FUAITYPE_HUMAN_PROCESSOR);
    }

    @Override
    public void setMaxHumans(final int maxHumans) {
        if (maxHumans != 1 || mRenderEventQueue == null) {
            return;
        }
        mMaxHumans = maxHumans;
        mRenderEventQueue.add(new Runnable() {
            @Override
            public void run() {
                faceunity.fuHumanProcessorSetMaxHumans(maxHumans);
                LogUtils.debug(TAG, "setMaxHumans : %d", maxHumans);
            }
        });
    }

    @Override
    public void setBodySlimIntensity(float intensity) {
        mBodySlimStrength = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.BODY_SLIM_STRENGTH, intensity);
        }
    }

    @Override
    public void setLegSlimIntensity(float intensity) {
        mLegSlimStrength = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.LEG_SLIM_STRENGTH, intensity);
        }
    }

    @Override
    public void setWaistSlimIntensity(float intensity) {
        mWaistSlimStrength = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.WAIST_SLIM_STRENGTH, intensity);
        }
    }

    @Override
    public void setShoulderSlimIntensity(float intensity) {
        mShoulderSlimStrength = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.SHOULDER_SLIM_STRENGTH, intensity);
        }
    }

    @Override
    public void setHipSlimIntensity(float intensity) {
        mHipSlimStrength = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.HIP_SLIM_STRENGTH, intensity);
        }
    }

    @Override
    public void setHeadSlimIntensity(float intensity) {
        mHeadSlimStrength = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.HEAD_SLIM, intensity);
        }
    }

    @Override
    public void setLegThinSlimIntensity(float intensity) {
        mLegThinSlimStrength = intensity;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, BodySlimParam.LEG_SLIM, intensity);
        }
    }

}
