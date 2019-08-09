package com.tencent.liteav.demo.ugccommon;


import java.io.Serializable;

public class TCVideoFileInfo implements Serializable {
    public static final int FILE_TYPE_VIDEO = 0;
    public static final int FILE_TYPE_PICTURE = 1;

    private int fileId;
    private String filePath;
    private String fileName;
    private String thumbPath;
    private boolean isSelected = false;
    private long duration;
    private int fileType = FILE_TYPE_VIDEO;

    public TCVideoFileInfo() {
    }

    public TCVideoFileInfo(int fileId, String filePath, String fileName, String thumbPath, int duration) {
        this.fileId = fileId;
        this.filePath = filePath;
        this.fileName = fileName;
        this.thumbPath = thumbPath;
        this.duration = duration;
    }

    public int getFileId() {
        return this.fileId;
    }

    public void setFileId(int fileId) {
        this.fileId = fileId;
    }

    public String getFilePath() {
         return this.filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getFileName() {
        return this.fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public void setSelected(boolean selected) {
        this.isSelected = selected;
    }

    public boolean isSelected() {
        return this.isSelected;
    }

    public void setThumbPath(String thumbPath) {
        this.thumbPath = thumbPath;
    }

    public String getThumbPath() {
        return this.thumbPath;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public long getDuration() {
        return duration;
    }

    public int getFileType() {
        return fileType;
    }

    public void setFileType(int fileType) {
        this.fileType = fileType;
    }

    @Override
    public String toString() {
        return "TCVideoFileInfo{" +
                "fileId=" + fileId +
                ", filePath='" + filePath + '\'' +
                ", fileName='" + fileName + '\'' +
                ", thumbPath='" + thumbPath + '\'' +
                ", isSelected=" + isSelected +
                ", duration=" + duration +
                '}';
    }
}
