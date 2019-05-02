package com.tencent.qcloud.xiaozhibo.videoeditor.word.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by hanszhli on 2017/6/22.
 * <p>
 * 用于统一管理{@link TCWordOperationView}的layout
 */
public class TCOperationViewGroup extends FrameLayout {
    private List<TCWordOperationView> mOperationViews;
    private int mLastSelectedPos = -1;

    public TCOperationViewGroup(Context context) {
        super(context);
        init();
    }


    public TCOperationViewGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public TCOperationViewGroup(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        mOperationViews = new ArrayList<TCWordOperationView>();
    }

    public void addOperationView(TCWordOperationView view) {
        mOperationViews.add(view);
        selectedOperationView(mOperationViews.size() - 1);
        addView(view);
    }

    public void removeOperationView(TCWordOperationView view) {
        int viewIndex = mOperationViews.indexOf(view);
        mOperationViews.remove(view);
        mLastSelectedPos = viewIndex - 1;
        removeView(view);
    }

    public TCWordOperationView getOperationView(int index) {
        return mOperationViews.get(index);
    }


    public void selectedOperationView(int pos) {
        if (pos < mOperationViews.size() && pos >= 0) {
            if (mLastSelectedPos != -1)
                mOperationViews.get(mLastSelectedPos).setEditable(false);//不显示编辑的边框
            mOperationViews.get(pos).setEditable(true);//显示编辑的边框
            mLastSelectedPos = pos;
        }
    }

    public void unSelectedOperationView(int pos) {
        if (pos < mOperationViews.size() && mLastSelectedPos != -1) {
            mOperationViews.get(mLastSelectedPos).setEditable(false);//不显示编辑的边框
            mLastSelectedPos = -1;
        }
    }

    public TCWordOperationView getSelectedOperationView() {
        return mOperationViews.get(mLastSelectedPos);
    }

    public int getSelectedPos() {
        return mLastSelectedPos;
    }


}
