package com.nama;


import com.nama.module.IBodySlimModule;
import com.nama.module.IFaceBeautyModule;
import com.nama.module.IMakeupModule;
import com.nama.module.IStickerModule;

/**
 * 模块管理
 *
 * @author Richie on 2020.07.08
 */
public interface IModuleManager {

    /**
     * 获取美颜模块
     *
     * @return
     */
    IFaceBeautyModule getFaceBeautyModule();

    /**
     * 创建贴纸模块
     */
    void createStickerModule();

    /**
     * 获取贴纸模块
     *
     * @return
     */
    IStickerModule getStickerModule();

    /**
     * 销毁贴纸模块
     */
    void destroyStickerModule();

    /**
     * 创建美妆模块
     */
    void createMakeupModule();

    /**
     * 获取美妆模块
     *
     * @return
     */
    IMakeupModule getMakeupModule();

    /**
     * 销毁美妆模块
     */
    void destroyMakeupModule();

    /**
     * 创建美体模块
     */
    void createBodySlimModule();

    /**
     * 获取美体模块
     *
     * @return
     */
    IBodySlimModule getBodySlimModule();

    /**
     * 销毁美体模块
     */
    void destroyBodySlimModule();
}
