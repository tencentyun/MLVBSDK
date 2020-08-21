package com.tencent.liteav.demo.livepusher.camerapush.ui.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.Checkable;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.livepusher.R;

public class RadioButton extends LinearLayout implements Checkable {

    private Context mContext;

    private ImageView mImageView;
    private TextView  mTextView;

    private boolean mChecked;

    public RadioButton(Context context) {
        super(context);
        initialize(context);
    }

    public RadioButton(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initialize(context);
    }

    public RadioButton(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize(context);
    }

    private void initialize(Context context) {
        mContext = context;
        setOrientation(LinearLayout.HORIZONTAL);
        setGravity(Gravity.CENTER_VERTICAL);
        setClickable(true);
        initView();
    }

    private void initView() {
        mImageView = new ImageView(mContext);
        mImageView.setBackgroundResource(R.drawable.livepusher_radio_btn_no_checked);
        LayoutParams imageParams = new LayoutParams(dip2px(20), dip2px(20));
        imageParams.rightMargin = dip2px(10);

        mTextView = new TextView(mContext);
        mTextView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        mTextView.setTextColor(getResources().getColor(R.color.livepusher_text_gray));
        addView(mImageView, imageParams);
        addView(mTextView);
    }

    public void setText(String text) {
        mTextView.setText(text);
    }

    public void setTextColor(int color) {
        mTextView.setTextColor(color);
    }

    public void setImageToTextWidth(int px) {
        ViewGroup.LayoutParams layoutParams = mImageView.getLayoutParams();
        if (layoutParams != null) {
            ((LayoutParams) layoutParams).rightMargin = px;
            mImageView.setLayoutParams(layoutParams);
        }
    }

    @Override
    public void setChecked(boolean checked) {
        mChecked = checked;
        setFocusable(false);
        if (checked) {
            mImageView.setBackgroundResource(R.drawable.livepusher_radio_btn_checked);
            mTextView.setTextColor(getResources().getColor(R.color.livepusher_white));
        } else {
            mImageView.setBackgroundResource(R.drawable.livepusher_radio_btn_no_checked);
            mTextView.setTextColor(getResources().getColor(R.color.livepusher_text_gray));
        }
    }

    @Override
    public boolean isChecked() {
        return mChecked;
    }

    @Override
    public void toggle() {
        setChecked(!mChecked);
    }

    public int dip2px(float dpValue) {
        final float scale = getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }
}