package com.tencent.qcloud.xiaozhibo.common.utils;


import java.io.Serializable;

public class TCVideoFileInfo implements Serializable {
    private int fileId;
    private String filePath;
    private String fileName;
    private String thumbPath;
    private boolean isSelected = false;
    private long duration;

    public TCVideoFileInfo() {
    }

    public TCVideoFileInfo(int fileId, String filePath, String fileName, String thumbPath, int duration) {
        this.fileId = fileId;
        this.filePath = filePath;
        this.fileName = fileName;
        this.thumbPath = thumbPath;
        this.duration = duration;
    }

//    protected TCVideoFileInfo(Parcel in) {
//        this.fileId = in.readInt();
//        this.filePath = in.readString();
//        this.fileName = in.readString();
//        this.thumbPath = in.readString();
//        this.duration = in.readInt();
//        this.isSelected = in.readByte() != 0;
//    }

//    public static final Creator<TCVideoFileInfo> CREATOR = new Creator<TCVideoFileInfo>() {
//        @Override
//        public TCVideoFileInfo createFromParcel(Parcel in) {
//            return new TCVideoFileInfo(in);
//        }
//
//        @Override
//        public TCVideoFileInfo[] newArray(int size) {
//            return new TCVideoFileInfo[size];
//        }
//    };

//    @Override
//    public int describeContents() {
//        return 0;
//    }

//    @Override
//    public void writeToParcel(Parcel parcel, int i) {
//        parcel.writeInt(fileId);
//        parcel.writeString(filePath);
//        parcel.writeString(fileName);
//        parcel.writeString(thumbPath);
//        parcel.writeInt(duration);
//        parcel.writeByte((byte) (isSelected ? 1 : 0));
//    }

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
