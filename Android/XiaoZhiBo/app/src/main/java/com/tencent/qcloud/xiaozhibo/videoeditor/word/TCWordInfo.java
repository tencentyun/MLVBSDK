package com.tencent.qcloud.xiaozhibo.videoeditor.word;

import android.graphics.Bitmap;
import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by hanszhli on 2017/6/19.
 */

public class TCWordInfo implements Parcelable {
    private int posIndex;           // 用于记录当前字幕顺序
    private String word;            // 字幕内容
    private Bitmap bitmap;          // 生成的位图
    private int backgroundColor;    // 背景色
    private int backgroundPadding;  // 边距
    private int textColor;          // 字体颜色
    private int textSize;           // sp
    private float x;                // 相对于父布局的x坐标
    private float y;                // 相对于父布局的y坐标
    private float width;            // 图片宽
    private int startTime;          // 字幕出现的时间
    private int endTime;            // 字幕结束的时间
    private int type;               // 字幕操作类型
    private String savePath;        // 图片保存路径

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getPosIndex() {
        return posIndex;
    }

    public void setPosIndex(int posIndex) {
        this.posIndex = posIndex;
    }

    public String getWord() {
        return word;
    }

    public void setWord(String word) {
        this.word = word;
    }

    public Bitmap getBitmap() {
        return bitmap;
    }

    public void setBitmap(Bitmap bitmap) {
        this.bitmap = bitmap;
    }

    public int getBackgroundColor() {
        return backgroundColor;
    }

    public void setBackgroundColor(int backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    public int getBackgroundPadding() {
        return backgroundPadding;
    }

    public void setBackgroundPadding(int backgroundPadding) {
        this.backgroundPadding = backgroundPadding;
    }

    public int getTextColor() {
        return textColor;
    }

    public void setTextColor(int textColor) {
        this.textColor = textColor;
    }

    public int getTextSize() {
        return textSize;
    }

    public void setTextSize(int textSize) {
        this.textSize = textSize;
    }

    public float getX() {
        return x;
    }

    public void setX(float x) {
        this.x = x;
    }

    public float getY() {
        return y;
    }

    public void setY(float y) {
        this.y = y;
    }

    public int getStartTime() {
        return startTime;
    }

    public void setStartTime(int startTime) {
        this.startTime = startTime;
    }

    public int getEndTime() {
        return endTime;
    }

    public void setEndTime(int endTime) {
        this.endTime = endTime;
    }

    public String getSavePath() {
        return savePath;
    }

    public void setSavePath(String savePath) {
        this.savePath = savePath;
    }

    public void setWidth(float width) {
        this.width = width;
    }

    public float getWidth() {
        return width;
    }

    public static final Creator<TCWordInfo> CREATOR = new Creator<TCWordInfo>() {
        public TCWordInfo createFromParcel(Parcel source) {
            TCWordInfo wordInfo = new TCWordInfo();
            wordInfo.posIndex = source.readInt();
            wordInfo.word = source.readString();
            wordInfo.bitmap = source.readParcelable(Bitmap.class.getClassLoader());
            wordInfo.backgroundColor = source.readInt();
            wordInfo.backgroundPadding = source.readInt();
            wordInfo.textColor = source.readInt();
            wordInfo.textSize = source.readInt();
            wordInfo.x = source.readFloat();
            wordInfo.y = source.readFloat();
            wordInfo.startTime = source.readInt();
            wordInfo.endTime = source.readInt();
            wordInfo.type = source.readInt();
            wordInfo.savePath = source.readString();
            wordInfo.setWidth(source.readFloat());
            return wordInfo;
        }

        public TCWordInfo[] newArray(int size) {
            return new TCWordInfo[size];
        }
    };

    public int describeContents() {
        return 0;
    }

    public void writeToParcel(Parcel parcel, int flags) {
        parcel.writeInt(posIndex);
        parcel.writeString(word);
        parcel.writeParcelable(bitmap, flags);
        parcel.writeInt(backgroundColor);
        parcel.writeInt(backgroundPadding);
        parcel.writeInt(textColor);
        parcel.writeInt(textSize);
        parcel.writeFloat(x);
        parcel.writeFloat(y);
        parcel.writeInt(startTime);
        parcel.writeInt(endTime);
        parcel.writeInt(type);
        parcel.writeString(savePath);
        parcel.writeFloat(width);
    }

}
