package com.tencent.liteav.demo.common.view;

import android.content.Context;
import android.database.DataSetObserver;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Adapter;


public class TXHorizontalPickerView extends android.widget.HorizontalScrollView {

    public TXHorizontalPickerView(Context context) {
        super(context);
        initialize();
    }

    public TXHorizontalPickerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initialize();
    }

    public TXHorizontalPickerView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize();
    }

    private DataSetObserver observer;

    public void setAdapter(Adapter adapter) {
        if (this.adapter != null) {
            this.adapter.unregisterDataSetObserver(observer);
        }
        this.adapter = adapter;
        adapter.registerDataSetObserver(observer);
        updateAdapter();
    }

    private void updateAdapter() {
        ViewGroup group = (ViewGroup) getChildAt(0);
        group.removeAllViews();

        for (int i = 0; i < adapter.getCount(); i++) {
            View view = adapter.getView(i, null, group);
            group.addView(view);
        }
    }

    private Adapter adapter;

    void initialize() {
        observer = new DataSetObserver() {
            @Override
            public void onChanged() {
                super.onChanged();
                updateAdapter();
            }

            @Override
            public void onInvalidated() {
                super.onInvalidated();
                ((ViewGroup) getChildAt(0)).removeAllViews();
            }
        };
    }

    public void setClicked(int position) {
        ((ViewGroup) getChildAt(0)).getChildAt(position).performClick();
    }
}