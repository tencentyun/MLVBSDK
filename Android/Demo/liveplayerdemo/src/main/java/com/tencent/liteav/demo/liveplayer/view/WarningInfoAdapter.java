package com.tencent.liteav.demo.liveplayer.view;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.tencent.liteav.demo.liveplayer.R;

import java.text.SimpleDateFormat;
import java.util.ArrayList;

public class WarningInfoAdapter extends RecyclerView.Adapter<WarningInfoAdapter.ViewHolder> {

    public static final int    TYPE_FREEZE     = 1;            //Warning类型：视频卡顿
    public static final int    TYPE_DROP_FRAME = 2;            //Warning类型：视频丢帧
    public static final String TIME_FORMAT     = "HH:mm:ss";   //Warning信息显示的日期格式

    private Context             mContext;
    private int                 mWarningType;                           //Warning类型，当前包含卡顿和丢帧两种
    private ArrayList<String>   mWarningDataList = new ArrayList<>();   //用来保存LiteAV SDK返回回来的Warning信息

    public WarningInfoAdapter(Context context){
        mContext = context.getApplicationContext();;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = View.inflate(parent.getContext(), R.layout.liveplayer_item_warning_info_recycle, null);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        String freezeNum = mWarningDataList.get(position);
        String currentTime = new SimpleDateFormat(TIME_FORMAT).format(System.currentTimeMillis());

        String warningInfo = String.format(mContext.getString(R.string.liveplayer_warning_video_drop_frame), currentTime);
        if (mWarningType == TYPE_FREEZE) {
            warningInfo = String.format(mContext.getString(R.string.liveplayer_warning_video_freeze), freezeNum, currentTime);
        }

        holder.warningText.setText(warningInfo);
    }

    @Override
    public int getItemCount() {
        return mWarningDataList.size();
    }

    public void addWarningData(String warningData) {
        try {
            this.mWarningDataList.add(warningData);
        } catch (Exception e) {
            e.printStackTrace();
        }
        notifyDataSetChanged();
    }

    public void clearWarningData() {
        this.mWarningDataList.clear();
        notifyDataSetChanged();
    }

    public void setWarningType(int warningType) {
        mWarningType = warningType;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {

        private TextView warningText;

        public ViewHolder(final View itemView) {
            super(itemView);
            warningText = (TextView) itemView.findViewById(R.id.tv_warning);
        }
    }
}
