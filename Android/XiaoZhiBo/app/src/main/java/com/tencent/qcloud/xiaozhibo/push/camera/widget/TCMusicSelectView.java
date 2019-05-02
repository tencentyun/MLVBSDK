package com.tencent.qcloud.xiaozhibo.push.camera.widget;

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
 * Created by Link on 2016/9/14.
 */
public class TCMusicSelectView extends LinearLayout{

    static private final  String TAG = TCMusicSelectView.class.getSimpleName();
    private TCAudioControl mAudioCtrl;
    private TCActivityTitle atTitle;
    private Button          mBtnMenuSelect;
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

    public void init(TCAudioControl audioControl, List<TCAudioControl.MediaEntity> data){
        mAudioCtrl = audioControl;
        LayoutInflater.from(mContext).inflate(R.layout.audio_ctrl_music_list,this);
        mMusicList = (MusicListView)findViewById(R.id.xml_music_list_view);
        mMusicList.setData(data);
        mBtnAutoSearch = (Button)findViewById(R.id.btn_auto_search);
        atTitle = (TCActivityTitle)findViewById(R.id.xml_music_select_activity);
        atTitle.setReturnListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mAudioCtrl.mMusicSelectView.setVisibility(GONE);
                mAudioCtrl.mMusicControlPart.setVisibility(VISIBLE);
            }
        });
//        mBtnMenuSelect = (Button)findViewById(R.id.btn_menu_select);
//        mBtnMenuSelect.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
//                intent.setType("audio/*");//设置类型，我这里是任意类型，任意后缀的可以这样写。
//                intent.addCategory(Intent.CATEGORY_OPENABLE);
//                Intent wrapIntent = Intent.createChooser(intent,null);
//                ((Activity)mContext).startActivityForResult(wrapIntent,mAudioCtrl.REQUESTCODE);
//            }
//        });
    }


}
