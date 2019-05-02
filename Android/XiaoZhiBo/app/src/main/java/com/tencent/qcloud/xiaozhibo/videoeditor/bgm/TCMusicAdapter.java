package com.tencent.qcloud.xiaozhibo.videoeditor.bgm;

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;

import java.util.List;

/**
 * Created by hanszhli on 2017/6/15.
 */

public class TCMusicAdapter extends RecyclerView.Adapter<TCMusicAdapter.LinearMusicViewHolder> implements View.OnClickListener {
    private List<TCBGMInfo> mBGMList;

    public TCMusicAdapter(List<TCBGMInfo> list) {
        mBGMList = list;
    }

    @Override
    public LinearMusicViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new LinearMusicViewHolder(View.inflate(parent.getContext(), R.layout.item_editer_bgm, null));
    }

    @Override
    public void onBindViewHolder(LinearMusicViewHolder holder, int position) {
        TCBGMInfo info = mBGMList.get(position);
        holder.tvName.setText(info.getSongName() + "  —  " + info.getSingerName());
        holder.tvDuration.setText(info.getFormatDuration());
        holder.itemView.setTag(position);
        holder.itemView.setOnClickListener(this);
    }

    @Override
    public int getItemCount() {
        return mBGMList.size();
    }

    @Override
    public void onClick(View v) {
        if (mListener != null) {
            mListener.onItemClick(v, (Integer) v.getTag());
        }
    }

    public static class LinearMusicViewHolder extends RecyclerView.ViewHolder {
        TextView tvName, tvDuration;

        public LinearMusicViewHolder(View itemView) {
            super(itemView);
            tvName = (TextView) itemView.findViewById(R.id.bgm_tv_name);
            tvDuration = (TextView) itemView.findViewById(R.id.bgm_tv_duration);
        }
    }

    private OnItemClickListener mListener;

    public void setOnItemClickListener(OnItemClickListener listener) {
        mListener = listener;
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position);
    }

}
