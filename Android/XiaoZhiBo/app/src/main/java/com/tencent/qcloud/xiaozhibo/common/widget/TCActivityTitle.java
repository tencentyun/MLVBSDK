package com.tencent.qcloud.xiaozhibo.common.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;


/**
 * Module:   TCActivityTitle
 *
 * Function: 标题样式布局
 *
 */
public class TCActivityTitle extends RelativeLayout {

    private String titleText;
    private boolean canBack;
    private String backText;
    private String moreText;

    private TextView tvReturn;
    private TextView tvTitle;
    private TextView tvMore;


    public TCActivityTitle(Context context, AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.view_title, this);
        TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.TCActivityTitle, 0, 0);
        try {
            titleText = ta.getString(R.styleable.TCActivityTitle_titleText);
            canBack = ta.getBoolean(R.styleable.TCActivityTitle_canBack, true);
            backText = ta.getString(R.styleable.TCActivityTitle_backText);
            moreText = ta.getString(R.styleable.TCActivityTitle_moreText);
            setUpView();
        } finally {
            ta.recycle();
        }
    }

    private void setUpView(){
        tvReturn = (TextView)findViewById(R.id.menu_return);
        tvReturn.setTextColor(getResources().getColor(R.color.white));
        tvTitle = (TextView)findViewById(R.id.title);
        tvMore = (TextView)findViewById(R.id.menu_more);


        if (!canBack){
            tvReturn.setVisibility(View.GONE);
        }

        tvReturn.setText(backText);
        tvMore.setText(moreText);
        tvTitle.setText(titleText);
    }

    /**
     * 设置标题
     * @param title 标题
     */
    public void setTitle(String title){
        titleText = title;
        tvTitle.setText(title);
    }

    /**
     * 设置扩展消息
     * @param title 扩展消息
     */
    public void setMoreText(String title){
        moreText = title;
        tvMore.setText(title);
    }

    /**
     * 设置返回文案
     * @param strReturn 返回文案
     */
    public void setReturnText(String strReturn){
        backText = strReturn;
        tvReturn.setText(strReturn);
    }

    /**
     * 设置返回消息事件
     * @param listener 返回消息listener
     */
    public void setReturnListener(OnClickListener listener){
        tvReturn.setOnClickListener(listener);
    }

    /**
     * 设置扩展事件
     * @param listener 扩展事件listener
     */
    public void setMoreListener(OnClickListener listener){
        if (!TextUtils.isEmpty(moreText)) {
            tvMore.setOnClickListener(listener);
        }
    }
}
