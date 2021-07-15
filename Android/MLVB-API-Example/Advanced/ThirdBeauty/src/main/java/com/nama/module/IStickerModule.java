package com.nama.module;


import com.nama.entity.Sticker;

/**
 * 贴纸模块接口
 *
 * @author Richie on 2020.07.07
 */
public interface IStickerModule extends IEffectModule {
    /**
     * 选择贴纸
     *
     * @param sticker
     */
    void selectSticker(Sticker sticker);

    /**
     * 设置参数
     *
     * @param key
     * @param value
     */
    void setItemParam(String key, Object value);
}
