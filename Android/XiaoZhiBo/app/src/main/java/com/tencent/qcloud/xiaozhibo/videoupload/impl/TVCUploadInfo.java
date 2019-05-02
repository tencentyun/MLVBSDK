package com.tencent.qcloud.xiaozhibo.videoupload.impl;

import android.text.TextUtils;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 视频上传参数
 */
public class TVCUploadInfo {
    private String fileType;
    private String filePath;
    private long fileLastModTime;
    private String coverType;
    private String coverPath;
    private long coverLastModTime;

    private String fileName = null;
    private long videoFileSize = 0;
    private long coverFileSize = 0;
    private String coverName;

    /**
     * 创建上传参数
     * @param fileType  文件类型
     * @param filePath  文件本地路径
     * @param coverType 封面图片类型
     * @param coverPath 封面图片本地路径
     */
    public TVCUploadInfo(String fileType, String filePath, String coverType, String coverPath){
        this.fileType = fileType;
        this.filePath = filePath;
        this.coverType = coverType;
        this.coverPath = coverPath;
    }

    public TVCUploadInfo(String fileType, String filePath, String coverType, String coverPath, String fileName){
        this.fileType = fileType;
        this.filePath = filePath;
        this.coverType = coverType;
        this.coverPath = coverPath;
        this.fileName = fileName;
    }

    public String getFileType() {
        return fileType;
    }

    public String getFilePath() {
        return filePath;
    }

    public String getCoverImgType() {
        return coverType;
    }

    public String getCoverPath() {
        return coverPath;
    }

    public boolean isNeedCover(){
        return !TextUtils.isEmpty(coverType) && !TextUtils.isEmpty(coverPath);
    }

    public String getFileName(){
        if (null == fileName) {
            int pos = filePath.lastIndexOf('/');
            if (-1 == pos) {
                pos = 0;
            } else {
                pos++;
            }
            fileName = filePath.substring(pos);
        }

        return fileName;
    }
    
    public String getCoverName(){
        if (null == coverName) {
            int pos = coverPath.lastIndexOf('/');
            if (-1 == pos) {
                pos = 0;
            } else {
                pos++;
            }
            coverName = coverPath.substring(pos);
        }
        return coverName;
    }

    public long getFileSize() {
        if (0 == videoFileSize){
            Log.i("getFileSize", "getFileSize: "+filePath);
            File file = new File(filePath);
            try {
                if (file.exists()) {
                    FileInputStream fis = new FileInputStream(file);
                    videoFileSize = fis.available();
                }
            }catch (Exception e){
                Log.e("getFileSize", "getFileSize: "+e);
            }
        }
        return videoFileSize;
    }

    public long getCoverFileSize() {
        if (0 == coverFileSize){
            Log.i("getCoverFileSize", "getCoverFileSize: "+coverPath);
            File file = new File(coverPath);
            try {
                if (file.exists()) {
                    FileInputStream fis = new FileInputStream(file);
                    coverFileSize = fis.available();
                }
            }catch (Exception e){
                Log.e("getCoverFileSize", "getCoverFileSize: "+e);
            }
        }
        return coverFileSize;
    }

    public long getCoverLastModifyTime() {
        if (0 ==  coverLastModTime){
            File f = new File(coverPath);
            coverLastModTime = f.lastModified();
        }
        return coverLastModTime;
    }

    public long getFileLastModifyTime() {
        if (0 ==  fileLastModTime){
            File f = new File(filePath);
            fileLastModTime = f.lastModified();
        }
        return fileLastModTime;
    }

    public boolean isContainSpecialCharacters(String string){
        String regEx = "[/ : * ? \" < >]";
        Pattern pattern = Pattern.compile(regEx);
        Matcher matcher = pattern.matcher(string);
        return matcher.find();
    }
}
