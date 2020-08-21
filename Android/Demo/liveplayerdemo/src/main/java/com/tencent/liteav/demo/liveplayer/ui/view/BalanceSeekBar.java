package com.tencent.liteav.demo.liveplayer.ui.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.support.v7.widget.AppCompatSeekBar;
import android.util.AttributeSet;

import com.tencent.liteav.demo.liveplayer.R;

/**
 * 平衡点 View
 */
public class BalanceSeekBar extends AppCompatSeekBar {
    private Paint  mPaint;            //定义此控件的画笔对象
    private String mTitleText = "";   //保存此SeekBar的文本信息

    public BalanceSeekBar(Context context) {
        this(context, null);
    }

    public BalanceSeekBar(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public BalanceSeekBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        mPaint = mPaint != null ? mPaint : new Paint();
        mPaint.setAntiAlias(true);

        TypedArray typedArray = context.getTheme().obtainStyledAttributes(attrs,
                R.styleable.LivePlayerTCSeekBarWithText, defStyleAttr, 0);

        for (int i = 0; i < typedArray.getIndexCount(); i++) {
            int attr = typedArray.getIndex(i);
            if (attr == R.styleable.LivePlayerTCSeekBarWithText_textSize) {
                mPaint.setTextSize(typedArray.getDimension(attr, 14f));
            } else if (attr == R.styleable.LivePlayerTCSeekBarWithText_textColor) {
                mPaint.setColor(typedArray.getColor(attr, Color.BLACK));
            }
        }
        typedArray.recycle();
    }

    @Override
    protected synchronized void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        // 测量文本队形的宽度
        float textWidth = mPaint.measureText(mTitleText);
        // 使用Paint对象中绘制Text对象的测量类
        Paint.FontMetrics fontMetrics = mPaint.getFontMetrics();
        // 此SeekBar中用于绘制进度条的矩形对象
        Rect seekRect = this.getProgressDrawable().getBounds();

        /**
         * 因为文本需要跟随滑块一起并显示到滑块底部，此处是计算滑动块下方文字坐标:
         * - x: seekRect的宽度*当前进度（百分比）+ 字符宽度
         * - y: 此控件的高度/2 + （测量到的Text的descent -ascent）/2 （此y值并非相较于屏幕原点开始的y值）
         * */
        float x = seekRect.width() * getProgress() / getMax() + textWidth;
        float y = getHeight() / 2 + (fontMetrics.descent - fontMetrics.ascent) / 2;

        canvas.drawText(mTitleText, x, y, mPaint);
    }

    public void setText(String text) {
        mTitleText = text;
    }
}