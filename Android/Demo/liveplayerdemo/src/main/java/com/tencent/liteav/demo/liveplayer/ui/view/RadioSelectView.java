package com.tencent.liteav.demo.liveplayer.ui.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Checkable;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.liveplayer.R;

public class RadioSelectView extends FrameLayout implements View.OnClickListener {

    private Context             mContext;

    private TextView            mTextTitle;
    private LinearLayout        mLayoutRadio;

    private RadioSelectListener mRadioSelectListener;

    private int mSelectPosition = -1;

    public interface RadioSelectListener {
        void onClose();

        void onChecked(int prePosition, RadioButton preRadioButton, int curPosition, RadioButton curRadioButton);
    }

    public RadioSelectView(@NonNull Context context) {
        super(context);
        initialize(context);
    }

    public RadioSelectView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initialize(context);
    }

    public RadioSelectView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize(context);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.liveplayer_tv_close) {
            if (mRadioSelectListener != null) {
                mRadioSelectListener.onClose();
            }
        }
    }

    public void setTitle(String title) {
        mTextTitle.setText(title);
    }

    public void setTitle(@StringRes int resId) {
        mTextTitle.setText(getResources().getString(resId));
    }

    public void setData(@NonNull String[] data, int selectPosition) {
        mLayoutRadio.removeAllViews();
        for (int i = 0; i < data.length; i++) {
            final int position = i;
            RadioButton radioButton = new RadioButton(mContext);
            radioButton.setText(data[i]);
            radioButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mSelectPosition != position) {
                        setChecked(position);
                    }
                }
            });
            mLayoutRadio.addView(radioButton);
        }
        setChecked(selectPosition);
    }

    public void setChecked(int position) {
        if (position >= 0 && position < mLayoutRadio.getChildCount()) {
            View child = mLayoutRadio.getChildAt(position);
            if (child instanceof RadioButton) {
                RadioButton curRadioButton = (RadioButton) child;
                curRadioButton.setChecked(true);
                if (mSelectPosition != -1) {
                    RadioButton preRadioButton = (RadioButton) mLayoutRadio.getChildAt(mSelectPosition);
                    preRadioButton.setChecked(false);
                    onChecked(mSelectPosition, preRadioButton, position, curRadioButton);
                } else {
                    onChecked(-1, null, position, curRadioButton);
                }
                mSelectPosition = position;
            }
        }
    }

    public void setRadioSelectListener(RadioSelectListener radioSelectListener) {
        mRadioSelectListener = radioSelectListener;
    }

    private void initialize(Context context) {
        mContext = context;
        LayoutInflater.from(context).inflate(R.layout.liveplayer_view_radio_select, this);
        initView();
    }

    private void initView() {
        mTextTitle = (TextView) findViewById(R.id.liveplayer_tv_title);
        mLayoutRadio = (LinearLayout) findViewById(R.id.liveplayer_rg_content);
        findViewById(R.id.liveplayer_tv_close).setOnClickListener(this);
    }

    private void onChecked(int prePosition, RadioButton preRadioButton, int curPosition, RadioButton curRadioButton) {
        if (mRadioSelectListener != null) {
            mRadioSelectListener.onChecked(prePosition, preRadioButton, curPosition, curRadioButton);
        }
    }

    public class RadioButton extends LinearLayout implements Checkable {

        private Context mContext;
        private ImageView mImageView;
        private TextView mTextView;

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
            setPadding(0, dip2px(10), 0, dip2px(10));
            initView();
        }

        private void initView() {
            mImageView = new ImageView(mContext);
            mImageView.setBackgroundResource(R.drawable.liveplayer_radio_btn_no_checked);
            LinearLayout.LayoutParams imageParams = new LinearLayout.LayoutParams(dip2px(20), dip2px(20));
            imageParams.rightMargin = dip2px(10);

            mTextView = new TextView(mContext);
            mTextView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
            mTextView.setTextColor(getResources().getColor(R.color.liveplayer_text_gray));
            addView(mImageView, imageParams);
            addView(mTextView);
        }

        public void setText(String text) {
            mTextView.setText(text);
        }

        @Override
        public void setChecked(boolean checked) {
            mChecked = checked;
            if (checked) {
                mImageView.setBackgroundResource(R.drawable.liveplayer_radio_btn_checked);
                mTextView.setTextColor(getResources().getColor(R.color.liveplayer_white));
            } else {
                mImageView.setBackgroundResource(R.drawable.liveplayer_radio_btn_no_checked);
                mTextView.setTextColor(getResources().getColor(R.color.liveplayer_text_gray));
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
}
