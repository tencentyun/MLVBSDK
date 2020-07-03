package com.tencent.liteav.demo.livepusher.cameralivepush;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.tencent.liteav.demo.livepusher.R;

import java.text.SimpleDateFormat;
import java.util.ArrayList;

public class VisibleLogListAdapter extends RecyclerView.Adapter<VisibleLogListAdapter.ViewHolder> {

    public static final int TYPE_CATON  = 1;
    public static final int TYPE_DROP   = 2;

    private final Context       mContext;
    private ArrayList<String>   mData = new ArrayList<String>();
    private int                 mType;

    public VisibleLogListAdapter(Context context) {
        mContext = context.getApplicationContext();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = View.inflate(parent.getContext(), R.layout.livepusher_item_visible_log, null);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        String catonNum = mData.get(position);
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
        String date = sdf.format(System.currentTimeMillis());
        String string;
        if (mType == TYPE_CATON) {
            string = mContext.getResources().getString(R.string.livepusher_caton_warning, catonNum, date);
        } else {
            string = mContext.getResources().getString(R.string.livepusher_drop_warning, date);
        }
        holder.warning.setText(string);
    }

    @Override
    public int getItemCount() {
        return mData.size();
    }

    public void add(String catonNum) {
        try {
            this.mData.add(catonNum);
        } catch (Exception e) {
            e.printStackTrace();
        }
        notifyDataSetChanged();
    }

    public void clear() {
        this.mData.clear();
        notifyDataSetChanged();
    }

    public void setType(int type) {
        mType = type;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {

        private TextView warning;

        public ViewHolder(final View itemView) {
            super(itemView);
            warning = (TextView) itemView.findViewById(R.id.livepusher_tv_warning);
        }
    }
}
