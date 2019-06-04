package com.tencent.qcloud.xiaozhibo.common.widget.beauty.download;

import java.io.File;

/**
 * Module:   DownloadListener
 *
 * Function: 下载进度和结果的回调
 *
 */
public interface DownloadListener {
    public void onProgressUpdate(int progress);

    public void onSaveSuccess(File file);

    public void onSaveFailed(File file, Exception e);

    public void onProcessEnd();
}
