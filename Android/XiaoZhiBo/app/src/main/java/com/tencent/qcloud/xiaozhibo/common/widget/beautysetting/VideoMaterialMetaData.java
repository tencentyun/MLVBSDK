package com.tencent.qcloud.xiaozhibo.common.widget.beautysetting;

/**
 * Created by linkzhzhu on 2017/3/13.
 */
public class VideoMaterialMetaData {
    public String id;
    public String url;
    public String path;
    public String thumbPath;

    public VideoMaterialMetaData(String id, String path, String url, String thumbPath) {
        this.id = id;
        this.path = path;
        this.url = url;
        this.thumbPath = thumbPath;
    }
}
