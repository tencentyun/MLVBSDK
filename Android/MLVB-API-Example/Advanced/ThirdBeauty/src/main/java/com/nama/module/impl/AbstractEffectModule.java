package com.nama.module.impl;

import com.faceunity.wrapper.faceunity;
import com.nama.module.IEffectModule;
import com.nama.module.event.RenderEventQueue;
import com.nama.utils.LogUtils;

/**
 * 特效模块基类
 *
 * @author Richie on 2020.07.07
 */
public abstract class AbstractEffectModule implements IEffectModule {
    private static final String           TAG = "AbstractEffectModule";
    protected            int              mItemHandle;
    protected            int              mRotationMode;
    protected            RenderEventQueue mRenderEventQueue;

    @Override
    public void setRotationMode(final int rotationMode) {
        mRotationMode = rotationMode;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.add(new Runnable() {
                @Override
                public void run() {
                    faceunity.fuSetDefaultRotationMode(rotationMode);
                    LogUtils.debug(TAG, "%s fuSetDefaultRotationMode : %d", AbstractEffectModule.this.getClass().getSimpleName(), rotationMode);
                }
            });
        }
    }

    @Override
    public void executeEvent() {
        if (mRenderEventQueue != null) {
            mRenderEventQueue.executeAndClear();
        }
    }

    @Override
    public void destroy() {
        if (mItemHandle > 0) {
            faceunity.fuDestroyItem(mItemHandle);
            LogUtils.debug(TAG, "%s destroy item %d", getClass().getSimpleName(), mItemHandle);
            mItemHandle = 0;
        }
    }

}