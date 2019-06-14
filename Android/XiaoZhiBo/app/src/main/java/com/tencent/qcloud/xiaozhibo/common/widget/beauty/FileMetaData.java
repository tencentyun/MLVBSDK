package com.tencent.qcloud.xiaozhibo.common.widget.beauty;

/**
 * Module:   FileMetaData
 *
 * Function: 特效文件的属性类
 *
 */
public class FileMetaData {
    public String id;
    public String url;
    public String path;
    public String thumbPath;

    public FileMetaData(String id, String path, String url, String thumbPath) {
        this.id = id;
        this.path = path;
        this.url = url;
        this.thumbPath = thumbPath;
    }
}
