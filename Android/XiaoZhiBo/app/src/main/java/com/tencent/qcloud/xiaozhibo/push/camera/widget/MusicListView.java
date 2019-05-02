package com.tencent.qcloud.xiaozhibo.push.camera.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;

import java.util.List;

/**
 * Created by Link on 2016/9/12.
 */
public class MusicListView extends ListView {
    private Context mContext;
    List<TCAudioControl.MediaEntity> mData = null;
    public void setData(List<TCAudioControl.MediaEntity> data){
        mData = data;
    }
    private BaseAdapter adapter;
    public BaseAdapter getAdapter(){
        return adapter;
    }
    public MusicListView(Context context){
        super(context);
        init(context);
    }
    public MusicListView(Context context, AttributeSet attrs){
        super(context,attrs);
        init(context);
    }
    private void init(Context context){
        mContext = context;
        this.setChoiceMode(CHOICE_MODE_SINGLE);

    }
    public void setupList(LayoutInflater inflater, List<TCAudioControl.MediaEntity> data){
        mData = data;
//        SimpleAdapter adapter = new SimpleAdapter(mContext,getData(),R.layout.audio_ctrl_music_item,
//                new String[]{"name","duration"},
//                new int[]{R.id.xml_music_item_name,R.id.xml_music_item_duration});
        adapter = new MusicListAdapter(inflater, data);
        setAdapter(adapter);
    }
    @Override
    public int getCount() {
        return mData.size();
    }
    static public class ViewHolder{
        ImageView selected;
        TextView name;
        TextView duration;
    }

}



class MusicListAdapter extends BaseAdapter{
    private Context mContext;
    List<TCAudioControl.MediaEntity> mData = null;
    private LayoutInflater mInflater;
    MusicListAdapter(LayoutInflater inflater, List<TCAudioControl.MediaEntity> list){
        mInflater = inflater;
        mData = list;
    }
    @Override
    public int getCount() {
        return mData.size();
    }

    @Override
    public Object getItem(int position) {
        return mData.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        MusicListView.ViewHolder holder;
        if (convertView == null){
            convertView = mInflater.inflate(R.layout.audio_ctrl_music_item,null);
            holder = new MusicListView.ViewHolder();
            holder.name = (TextView) convertView.findViewById(R.id.xml_music_item_name);
            holder.duration = (TextView) convertView.findViewById(R.id.xml_music_item_duration);
            holder.selected = (ImageView) convertView.findViewById(R.id.music_item_selected);
            convertView.setTag(holder);
        }
        else{
            holder = (MusicListView.ViewHolder)convertView.getTag();
        }
        holder.name.setText(mData.get(position).title);
        holder.duration.setText(mData.get(position).durationStr);
        holder.selected.setVisibility(mData.get(position).state == 1 ? View.VISIBLE : View.GONE);
        return convertView;
    }
}
