package com.tencent.qcloud.xiaozhibo.videoeditor.bgm;

import android.content.Context;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

import com.tencent.qcloud.xiaozhibo.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by hanszhli on 2017/6/15.
 */

public class TCMusicChooseLayout extends RelativeLayout {
    private RecyclerView mRecyclerView;
    private RelativeLayout mRlEmpty, mRlLoading, mRlRoot;
    private TCMusicAdapter mMusicListAdapter;
    private List<TCBGMInfo> mMusicList;

    public TCMusicChooseLayout(Context context) {
        super(context);
        init();

    }

    public TCMusicChooseLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public TCMusicChooseLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        View view = View.inflate(getContext(), R.layout.layout_chose_music, this);
        mRlRoot = (RelativeLayout) view.findViewById(R.id.chose_rl_root);
        mRlEmpty = (RelativeLayout) view.findViewById(R.id.chose_rl_empty);
        mRecyclerView = (RecyclerView) view.findViewById(R.id.chose_rv_music);
        mRlLoading = (RelativeLayout) view.findViewById(R.id.chose_rl_loading_music);
        initMusicList();
    }

    private void initMusicList() {
        mRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        mMusicList = new ArrayList<>();
        mMusicListAdapter = new TCMusicAdapter(mMusicList);
        mRecyclerView.setAdapter(mMusicListAdapter);
        mRlLoading.setVisibility(View.VISIBLE);
        //延迟500ms在进行歌曲加载， 避免与外部线程竞争
        this.postDelayed(new Runnable() {
            @Override
            public void run() {
                loadMusicAndSetAdapter();
            }
        }, 500);
    }

    private void loadMusicAndSetAdapter() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                mMusicList.clear();
                mMusicList.addAll(TCMusicManager.getInstance(getContext()).getAllMusic());
                //切换到主线程
                post(new Runnable() {
                    @Override
                    public void run() {
                        mRlLoading.setVisibility(View.GONE);
                        if (mMusicList != null && mMusicList.size() > 0) {
                            mMusicListAdapter.notifyDataSetChanged();
                            mRecyclerView.setAdapter(mMusicListAdapter);
                        } else {
                            mRlEmpty.setVisibility(View.VISIBLE);
                        }
                    }
                });
            }
        }).start();
    }


    public void setOnItemClickListener(TCMusicAdapter.OnItemClickListener listener) {
        mMusicListAdapter.setOnItemClickListener(listener);
    }

    public List<TCBGMInfo> getMusicList() {
        return mMusicList;
    }

}
