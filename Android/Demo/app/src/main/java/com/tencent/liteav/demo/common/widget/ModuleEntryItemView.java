package com.tencent.liteav.demo.common.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.R;

public class ModuleEntryItemView extends FrameLayout {

    private TextView mNameTV;
    private ImageView mIconIV;
    private LinearLayout mContentView;


    public ModuleEntryItemView(Context context) {
        this(context, null);
    }

    public ModuleEntryItemView(Context context, AttributeSet attrs) {
        super(context, attrs);

        inflate(context, R.layout.module_entry_item, this);

        mContentView = (LinearLayout) findViewById(R.id.item_ll);
        mNameTV = (TextView) findViewById(R.id.name_tv);
        mIconIV = (ImageView) findViewById(R.id.icon_iv);
    }

    public void setContent(String name, int iconId) {
        mNameTV.setText(name);
        mIconIV.setImageResource(iconId);
    }

    public void setBackgroudId(int id) {
        mContentView.setBackgroundResource(id);
    }
}
