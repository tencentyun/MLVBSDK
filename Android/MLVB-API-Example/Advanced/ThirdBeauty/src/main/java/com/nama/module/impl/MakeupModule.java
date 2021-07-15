package com.nama.module.impl;

import android.content.Context;

import com.faceunity.wrapper.faceunity;
import com.nama.entity.Makeup;
import com.nama.module.IMakeupModule;
import com.nama.module.event.RenderEventQueue;
import com.nama.param.MakeupParam;
import com.nama.utils.BundleUtils;
import com.nama.utils.LogUtils;
import com.nama.utils.ThreadHelper;

/**
 * 美妆模块
 *
 * @author Richie on 2020.07.07
 */
public class MakeupModule extends AbstractEffectModule implements IMakeupModule {
    private static final String TAG = "MakeupModule";
    private Makeup mMakeup;
    private              float  mMakeupIntensity = 1.0f;
    private int mIsFlipPoints = 0;
    private Context mContext;
    private int mMakeupHandle;
    private boolean mCreatingItem;
    private OnMakeupSelectedListener mOnMakeupSelectedListener;

    @Override
    public void create(final Context context, final ModuleCallback moduleCallback) {
        if (mItemHandle > 0) {
            return;
        }
        mCreatingItem = false;
        mContext = context;
        mRenderEventQueue = new RenderEventQueue();
        ThreadHelper.getInstance().execute(new Runnable() {
            @Override
            public void run() {
                int itemMakeup = BundleUtils.loadItem(context, "graphics/face_makeup.bundle");
                if (itemMakeup <= 0) {
                    LogUtils.warn(TAG, "create face makeup item failed: %d", itemMakeup);
                    return;
                }
                mItemHandle = itemMakeup;
                setMakeupIntensity(mMakeupIntensity);
                if (mMakeup != null) {
                    selectMakeup(new Makeup(mMakeup));
                }
                if (moduleCallback != null) {
                    moduleCallback.onBundleCreated(itemMakeup);
                }
            }
        });
    }

    @Override
    public void selectMakeup(final Makeup makeup) {
        if (makeup == null) {
            return;
        }
        mCreatingItem = true;
        LogUtils.debug(TAG, "selectMakeup %s", makeup);
        ThreadHelper.getInstance().execute(new Runnable() {
            @Override
            public void run() {
                final int makeupHandle = BundleUtils.loadItem(mContext, makeup.getFilePath());
                if (makeupHandle <= 0) {
                    LogUtils.warn(TAG, "create makeup item failed");
                }
                mRenderEventQueue.add(new Runnable() {
                    @Override
                    public void run() {
                        if (mItemHandle <= 0) {
                            return;
                        }
                        int oldHandle = mMakeupHandle;
                        if (oldHandle > 0) {
                            faceunity.fuUnBindItems(mItemHandle, new int[]{oldHandle});
                            LogUtils.debug(TAG, "makeup unbind %d", oldHandle);
                        }
                        if (makeupHandle > 0) {
                            faceunity.fuBindItems(mItemHandle, new int[]{makeupHandle});
                            LogUtils.debug(TAG, "makeup bind %d", makeupHandle);
                            faceunity.fuItemSetParam(mItemHandle, MakeupParam.MAKEUP_INTENSITY, mMakeupIntensity);
                            faceunity.fuItemSetParam(mItemHandle, MakeupParam.IS_FLIP_POINTS, mIsFlipPoints);
                        }
                        if (oldHandle > 0) {
                            faceunity.fuDestroyItem(oldHandle);
                            LogUtils.debug(TAG, "makeup destroy %d", oldHandle);
                        }
                        mMakeupHandle = makeupHandle;
                        mMakeup = makeup;
                        mCreatingItem = false;

                        if (mOnMakeupSelectedListener != null) {
                            mOnMakeupSelectedListener.onMakeupSelected(makeupHandle);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void destroy() {
        if (mMakeup != null) {
            int makeupHandle = mMakeupHandle;
            if (makeupHandle > 0) {
                if (mItemHandle > 0) {
                    faceunity.fuUnBindItems(mItemHandle, new int[]{makeupHandle});
                }
                faceunity.fuDestroyItem(makeupHandle);
                LogUtils.debug(TAG, "unbind and destroy makeup %d", makeupHandle);
                mMakeupHandle = 0;
            }
        }
        mCreatingItem = false;
        super.destroy();
    }

    @Override
    public void setMakeupIntensity(float intensity) {
        mMakeupIntensity = intensity;
        if (!mCreatingItem && mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, MakeupParam.MAKEUP_INTENSITY, intensity);
        }
    }

    @Override
    public void setIsMakeupFlipPoints(final int isFlipPoints) {
        mIsFlipPoints = isFlipPoints;
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, MakeupParam.IS_FLIP_POINTS, isFlipPoints);
        }
    }

    @Override
    public void setOnMakeupSelectedListener(OnMakeupSelectedListener onMakeupSelectedListener) {
        mOnMakeupSelectedListener = onMakeupSelectedListener;
    }

}
