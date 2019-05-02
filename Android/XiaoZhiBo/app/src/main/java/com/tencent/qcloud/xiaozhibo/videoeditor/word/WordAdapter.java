package com.tencent.qcloud.xiaozhibo.videoeditor.word;

import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.videoeditor.word.widget.BorderImage;

import java.util.List;

/**
 * Created by hanszhli on 2017/6/19.
 */

public class WordAdapter extends RecyclerView.Adapter<WordAdapter.WordViewHolder> implements View.OnClickListener {
    private Context mContext;
    private List<TCWordInfo> mList;
    private OnItemClickListener mOnItemClickListener;
    private int mSelectedPos = -1;//选中的数据位置

    public WordAdapter(Context context, List<TCWordInfo> list) {
        mList = list;
        mContext = context;
        //配合getItemId以及RecyclerView 的 findViewHolderForItemId进行对ViewHolder的查找，请务必开启
        this.setHasStableIds(true);
    }

    @Override
    public WordViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new WordViewHolder(View.inflate(parent.getContext(), R.layout.item_word, null));
    }

    @Override
    public void onBindViewHolder(WordViewHolder holder, int position) {
        //注意这里的position都要-1 因为+号多了一位，为了保持数据对应。 所以需要-1
        position -= 1;
        if (position != -1) {
            TCWordInfo info = mList.get(position);
            //利用tag记录view的位置 用于OnItemClick的回调位置传参

            holder.tvWord.setTag(position);

            holder.tvWord.setText(info.getWord());
            holder.tvWord.setVisibility(View.VISIBLE);
            holder.tvWord.setOnClickListener(this);
            holder.ivAdd.setVisibility(View.GONE);
        } else {
            holder.tvWord.setVisibility(View.GONE);

            holder.ivAdd.setTag(position);
            holder.ivAdd.setVisibility(View.VISIBLE);
            holder.ivAdd.setOnClickListener(this);
        }

        if (position == mSelectedPos) {
            setTextViewStyle(holder.tvWord, true);
        } else {
            setTextViewStyle(holder.tvWord, false);
        }
        holder.ivAdd.setColor(Color.WHITE);
        holder.ivAdd.setBorderWidth(1);
    }

    @Override
    public int getItemCount() {
        return mList.size() + 1;
    }


    @Override
    public void onClick(View v) {
        if (mOnItemClickListener != null)
            mOnItemClickListener.onClickItem(v, (Integer) v.getTag());
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mOnItemClickListener = listener;
    }

    // 设定Item的id为position
    // 请务必重写该方法,否则resetCurSelectedPos中的findViewHolderForItemId会出现错误
    @Override
    public long getItemId(int position) {
        return position;
    }

    /**
     * 重置上一个选中的样式，并且当前选中pos的样式
     *
     * @param pos
     */
    public void resetCurSelectedPos(int pos) {
        //将当前的选中item修改掉
        if (mSelectedPos != pos) {
            int lastPos = mSelectedPos;
            mSelectedPos = pos;
            //刷新旧的item
            if (lastPos != -1)//如果不是0号位， 那么需要刷新一下
                notifyItemChanged(lastPos + 1);
            //刷新新的item
            notifyItemChanged(mSelectedPos + 1);
        } else {
            //如果相同 则重置状态
            mSelectedPos = -1;
            notifyItemChanged(pos + 1);
        }
    }

    /**
     * 获取当前选中的位置
     *
     * @return
     */
    public int getCurrentSelectedPos() {
        return mSelectedPos;
    }

    private void setTextViewStyle(TextView tv, boolean isSelected) {
        if (isSelected) {
            tv.setBackgroundResource(R.drawable.shape_word_bg_press);
            tv.setTextColor(mContext.getResources().getColor(R.color.colorGreen));
        } else {
            tv.setBackgroundResource(R.drawable.shape_word_bg_normal);
            tv.setTextColor(Color.WHITE);
        }
    }

    public interface OnItemClickListener {
        void onClickItem(View view, int pos);
    }

    public static class WordViewHolder extends RecyclerView.ViewHolder {
        TextView tvWord;
        BorderImage ivAdd;

        public WordViewHolder(View itemView) {
            super(itemView);
            tvWord = (TextView) itemView.findViewById(R.id.item_tv_word);
            ivAdd = (BorderImage) itemView.findViewById(R.id.item_iv_add);
        }
    }
}
