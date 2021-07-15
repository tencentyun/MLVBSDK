package com.nama.entity;

/**
 * 道具贴纸
 *
 * @author Richie on 2019.12.20
 */
public class Sticker {
    private int iconId;
    private String filePath;
    private String description;

    public Sticker(Sticker sticker) {
        this(sticker.iconId, sticker.filePath, sticker.description);
    }

    public Sticker(int iconId, String filePath, String description) {
        this.iconId = iconId;
        this.filePath = filePath;
        this.description = description;
    }

    public int getIconId() {
        return iconId;
    }

    public void setIconId(int iconId) {
        this.iconId = iconId;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Sticker sticker = (Sticker) o;
        return filePath != null ? filePath.equals(sticker.filePath) : sticker.filePath == null;
    }

    @Override
    public int hashCode() {
        return filePath != null ? filePath.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "Sticker{" +
                "filePath='" + filePath + '\'' +
                ", description='" + description + '\'' +
                '}';
    }

}
