package com.tencent.liteav.demo.common.utils;

import java.io.File;

/**
 * ****************************************************************************
 * 版权声明：腾讯科技版权所有
 * Copyright(C)2008-2013 Tencent All Rights Reserved
 *
 * @author yonnielu
 * v 1.0.0
 * Create at 2013-08-06 8:00 PM
 * <p/>
 * *****************************************************************************
 */
public interface HttpFileListener {
    public void onProgressUpdate(int progress);

    public void onSaveSuccess(File file);

    public void onSaveFailed(File file, Exception e);

    public void onProcessEnd();
}
