package com.tencent.liteav.demo.livepusher.camerapush.ui.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.kyleduo.switchbutton.SwitchButton;
import com.tencent.liteav.demo.livepusher.R;

/**
 * 单选面板，例如画质选择面板
 */
public class CheckSelectView extends LinearLayout {

    private Context mContext;

    private CheckSelectView.CheckSelectListener mCheckSelectListener;

    public interface CheckSelectListener {
        void onChecked(int position, boolean enable);
    }

    public CheckSelectView(@NonNull Context context) {
        super(context);
        initialize(context);
    }

    public CheckSelectView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initialize(context);
    }

    public CheckSelectView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize(context);
    }

    public void setData(String[] data, boolean[] enables) {
        for (int i = 0; i < data.length; i++) {
            final int position = i;
            ItemView itemView = new ItemView(mContext);
            itemView.setText(data[i]);
            itemView.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    onChecked(position, isChecked);
                }
            });
            if (enables != null && i < enables.length) {
                itemView.setChecked(enables[i]);
            }
            addView(itemView);
        }
    }

    public void setChecked(int position, boolean enable) {
        if (position >= 0 && position < getChildCount()) {
            View child = getChildAt(position);
            if (child instanceof ItemView) {
                ((ItemView) child).setChecked(enable);
            }
        }
    }

    public void showItem(int position) {
        if (position >= 0 && position < getChildCount()) {
            View child = getChildAt(position);
            if (child instanceof ItemView) {
                child.setVisibility(View.VISIBLE);
            }
        }
    }

    public void hideItem(int position) {
        if (position >= 0 && position < getChildCount()) {
            View child = getChildAt(position);
            if (child instanceof ItemView) {
                child.setVisibility(View.GONE);
            }
        }
    }

    public void setCheckSelectListener(CheckSelectListener checkSelectListener) {
        mCheckSelectListener = checkSelectListener;
    }

    private void initialize(Context context) {
        mContext = context;
        setPadding(dip2px(20), 0, dip2px(20), 0);
        setOrientation(VERTICAL);
        setGravity(Gravity.CENTER_VERTICAL);
    }

    private void onChecked(int position, boolean enable) {
        if (mCheckSelectListener != null) {
            mCheckSelectListener.onChecked(position, enable);
        }
    }

    private int dip2px(float dpValue) {
        final float scale = getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    private class ItemView extends RelativeLayout {

        private TextView mTextView;
        private SwitchButton mSwitchButton;

        public ItemView(Context context) {
            super(context);
            init();
        }

        private void init() {
            LayoutParams layoutParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
            layoutParams.topMargin = dip2px(10);
            setLayoutParams(layoutParams);

            mSwitchButton = new SwitchButton(mContext);
            mSwitchButton.setThumbDrawableRes(R.drawable.livepusher_thumb);
            mSwitchButton.setBackDrawableRes(R.drawable.livepusher_swicth_button_selector);
            LayoutParams switchParams = new LayoutParams(dip2px(48), dip2px(28));
            switchParams.addRule(ALIGN_PARENT_RIGHT);

            mTextView = new TextView(mContext);
            mTextView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
            mTextView.setTextColor(getResources().getColor(R.color.livepusher_white));
            addView(mTextView);
            addView(mSwitchButton, switchParams);
        }

        public void setChecked(boolean enable) {
            mSwitchButton.setChecked(enable);
        }

        public void setText(String text) {
            mTextView.setText(text);
        }

        public void setOnCheckedChangeListener(CompoundButton.OnCheckedChangeListener onCheckedChangeListener) {
            mSwitchButton.setOnCheckedChangeListener(onCheckedChangeListener);
        }
    }
}
