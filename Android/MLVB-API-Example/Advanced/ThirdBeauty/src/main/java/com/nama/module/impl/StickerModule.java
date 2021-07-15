package com.nama.module.impl;

import android.content.Context;

import com.nama.entity.Sticker;
import com.nama.module.IStickerModule;
import com.nama.module.event.RenderEventQueue;
import com.nama.utils.BundleUtils;
import com.nama.utils.LogUtils;
import com.nama.utils.ThreadHelper;


/**
 * 贴纸模块
 *
 * @author Richie on 2020.07.07
 */
public class StickerModule extends AbstractEffectModule implements IStickerModule {
    private static final String TAG = "StickerModule";
    private Context        mContext;
    private Sticker mSticker;
    private ModuleCallback mModuleCallback;

    @Override
    public void create(Context context, ModuleCallback moduleCallback) {
        mRenderEventQueue = new RenderEventQueue();
        mContext = context;
        mModuleCallback = moduleCallback;
        if (mSticker != null) {
            selectSticker(new Sticker(mSticker));
        }
    }

    @Override
    public void setRotationMode(int rotationMode) {
        super.setRotationMode(rotationMode);
        if (mRenderEventQueue != null) {
            // rotationMode 参数是用于旋转普通道具
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, "rotationMode", rotationMode);
            // rotationAngle 参数是用于旋转普通道具
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, "rotationAngle", rotationMode * 90);
        }
    }

    @Override
    public void selectSticker(final Sticker sticker) {
        if (sticker == null) {
            return;
        }
        LogUtils.debug(TAG, "selectSticker %s", sticker);
        mSticker = sticker;
        ThreadHelper.getInstance().execute(new Runnable() {
            @Override
            public void run() {
                final int itemSticker = BundleUtils.loadItem(mContext, sticker.getFilePath());
                if (itemSticker <= 0) {
                    LogUtils.warn(TAG, "create item failed");
                }
                mItemHandle = itemSticker;
                if (mModuleCallback != null) {
                    mModuleCallback.onBundleCreated(itemSticker);
                }
            }
        });
    }

    @Override
    public void setItemParam(String key, Object value) {
        if (mRenderEventQueue != null) {
            mRenderEventQueue.addItemSetParamEvent(mItemHandle, key, value);
        }
    }

}
