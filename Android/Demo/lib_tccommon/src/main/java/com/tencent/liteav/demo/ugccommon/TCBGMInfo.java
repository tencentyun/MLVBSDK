package com.tencent.liteav.demo.ugccommon;

/**
 * Created by hanszhli on 2017/7/7.
 */

public class TCBGMInfo {

    private String path;                                      // BGM音频路径
    private long duration;                                    // 音频总时长(ms)
    private String formatDuration;                            // 已经格式化过的时长(分钟:秒)
    private String singerName;                                // 歌手名字
    private String songName;                                  // 歌曲名字

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public long getDuration() {
        return duration;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public String getFormatDuration() {
        return formatDuration;
    }

    public void setFormatDuration(String formatDuration) {
        this.formatDuration = formatDuration;
    }

    public String getSingerName() {
        return singerName;
    }

    public void setSingerName(String singerName) {
        this.singerName = singerName;
    }

    public String getSongName() {
        return songName;
    }

    public void setSongName(String songName) {
        this.songName = songName;
    }

    @Override
    public String toString() {
        return "TCBGMInfo{" +
                "path='" + path + '\'' +
                ", duration=" + duration +
                ", formatDuration='" + formatDuration + '\'' +
                ", singerName='" + singerName + '\'' +
                ", songName='" + songName + '\'' +
                '}';
    }
}
