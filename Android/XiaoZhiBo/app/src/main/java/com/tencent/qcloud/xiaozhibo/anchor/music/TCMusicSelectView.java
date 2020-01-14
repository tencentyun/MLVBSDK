package com.tencent.qcloud.xiaozhibo.anchor.music;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.widget.TCActivityTitle;

import java.util.List;

/**
 * Module:   TCMusicSelectView
 * <p>
 * Function: 音乐列表的选择界面
 */
public class TCMusicSelectView extends LinearLayout{
    private TCAudioControl  mAudioCtrl;
    private TCActivityTitle TvTitle;
    private Context         mContext;
    public MusicListView    mMusicList;
    public Button           mBtnAutoSearch;

    public TCMusicSelectView (Context context, AttributeSet attrs){
        super(context,attrs);
        mContext = context;
    }

    public TCMusicSelectView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
    }

    public TCMusicSelectView(Context context) {
        super(context);
        mContext = context;
    }

    public void init(TCAudioControl audioControl, List<MusicEntity> data){
        mAudioCtrl = audioControl;
        LayoutInflater.from(mContext).inflate(R.layout.layout_music_chose,this);
        mMusicList = (MusicListView)findViewById(R.id.music_list_view);
        mMusicList.setData(data);
        mBtnAutoSearch = (Button)findViewById(R.id.music_btn_search);
        TvTitle = (TCActivityTitle)findViewById(R.id.music_ac_title);
        TvTitle.setReturnListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mAudioCtrl.mMusicSelectView.setVisibility(GONE);
                mAudioCtrl.mMusicControlPart.setVisibility(VISIBLE);
            }
        });
    }
}
