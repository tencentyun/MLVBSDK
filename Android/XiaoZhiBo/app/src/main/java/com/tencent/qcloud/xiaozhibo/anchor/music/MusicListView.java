package com.tencent.qcloud.xiaozhibo.anchor.music;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.BaseAdapter;
import android.widget.ListView;

import java.util.List;

/**
 * Module:   MusicListView
 * <p>
 * Function: 音乐列表的 ListView
 */
public class MusicListView extends ListView {
    private List<TCAudioControl.MediaEntity> mData;
    private BaseAdapter mAdapter;

    public BaseAdapter getAdapter() {
        return mAdapter;
    }

    public MusicListView(Context context) {
        super(context);
        this.setChoiceMode(CHOICE_MODE_SINGLE);
    }

    public MusicListView(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.setChoiceMode(CHOICE_MODE_SINGLE);
    }

    public void setupList(LayoutInflater inflater, List<TCAudioControl.MediaEntity> data) {
        mData = data;
        mAdapter = new MusicListAdapter(inflater, data);
        setAdapter(mAdapter);
    }

    public void setData(List<TCAudioControl.MediaEntity> data) {
        mData = data;
    }
    @Override
    public int getCount() {
        return mData.size();
    }
}



