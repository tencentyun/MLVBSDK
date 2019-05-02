package com.tencent.qcloud.xiaozhibo.common.widget.beautysetting.utils;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by kevinxing on 2016/8/5.
 */
public class VideoMaterialDownloadManager {
    private Map<String, VideoMaterialDownloadProgress> mDPMap;
    private static VideoMaterialDownloadManager instance = new VideoMaterialDownloadManager();

    public static VideoMaterialDownloadManager getInstance() {
        return instance;
    }

    private VideoMaterialDownloadManager() {
        mDPMap = new HashMap<>();
    }

    public VideoMaterialDownloadProgress get(String id, String url) {
        VideoMaterialDownloadProgress downloadProgress = mDPMap.get(url);
        if (downloadProgress == null) {
            downloadProgress = new VideoMaterialDownloadProgress(id, url);
            mDPMap.put(url, downloadProgress);
        }
        return downloadProgress;
    }
}
