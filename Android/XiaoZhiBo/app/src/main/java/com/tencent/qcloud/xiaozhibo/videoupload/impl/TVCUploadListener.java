package com.tencent.qcloud.xiaozhibo.videoupload.impl;

/**
 * 视频上传接口
 */
public interface TVCUploadListener {
    /**
     * 上传成功
     * @param fileId    文件id
     * @param playUrl   点播url
     * @param coverUrl  封面地址
     */
    void onSucess(String fileId, String playUrl, String coverUrl);

    /**
     * 上传失败
     * @param errCode   错误码
     * @param errMsg    错误描述
     */
    void onFailed(int errCode, String errMsg);

    /**
     * 上传进度
     * @param currentSize    已上传文件大小
     * @param totalSize      文件总大小
     */
    void onProgress(long currentSize, long totalSize);
}
