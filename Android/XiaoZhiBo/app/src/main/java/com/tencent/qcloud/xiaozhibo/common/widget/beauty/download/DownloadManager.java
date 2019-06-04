package com.tencent.qcloud.xiaozhibo.common.widget.beauty.download;

import java.util.HashMap;
import java.util.Map;

/**
 * Module:   DownloadManager
 *
 * Function: 文件下载管理类
 *
 */
public class DownloadManager {
    private Map<String, DownloadTask> mDPMap;
    private static DownloadManager instance = new DownloadManager();

    public static DownloadManager getInstance() {
        return instance;
    }

    private DownloadManager() {
        mDPMap = new HashMap<>();
    }

    public DownloadTask get(String id, String url) {
        DownloadTask downloadProgress = mDPMap.get(url);
        if (downloadProgress == null) {
            downloadProgress = new DownloadTask(id, url);
            mDPMap.put(url, downloadProgress);
        }
        return downloadProgress;
    }
}
