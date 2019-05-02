package com.tencent.qcloud.xiaozhibo.common.widget.beautysetting.utils;

import java.io.File;

/**
 * ****************************************************************************
 * 版权声明：腾讯科技版权所有
 * Copyright(C)2008-2013 Tencent All Rights Reserved
 *
 * @author yonnielu
 * v 1.0.0
 * Create at 2013-08-06 7:55 PM
 * <p/>
 * *****************************************************************************
 */
public interface HttpBaseListener {
    /**
     * HTTP请求失败
     */
    public void onGetResponseFailed(File file, Exception e, int statusCode);

    /**
     * 关闭reader失败
     *
     * @param e
     */
    public void onCloseReaderFailed(File file, Exception e);

}
