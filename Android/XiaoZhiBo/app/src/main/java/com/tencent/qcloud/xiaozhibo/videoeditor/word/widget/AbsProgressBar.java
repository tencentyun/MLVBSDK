package com.tencent.qcloud.xiaozhibo.videoeditor.word.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;


/**
 * Created by woniu on 16/7/8.
 */
public class AbsProgressBar extends View {

    protected Context context;

    /**
     * 画笔
     */
    protected Paint paint;

    /**
     * 整个控件宽度
     */
    protected float width;

    /**
     * 整个控件高度
     */
    protected float height;

    /**
     * 进度条未填充颜色
     */
    protected int backgroundColor;

    /**
     * 文字颜色
     */
    protected int textColor;

    /**
     * 进度条
     */
    protected int progress;
    protected String currentTime;

    public AbsProgressBar(Context context) {
        super(context);
        this.context = context;
        initPaint();
    }

    public AbsProgressBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
        init(context, attrs);
        initPaint();
    }

    public AbsProgressBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        init(context, attrs);
        initPaint();
    }

    /**
     * 初始化
     *
     * @param context
     * @param attrs
     */
    private void init(Context context, AttributeSet attrs) {
        final TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.absProgressBar);
        progress = a.getInteger(R.styleable.absProgressBar_progress, 0);
        backgroundColor = a.getColor(R.styleable.absProgressBar_backgroundColor, 0xfff4f4f4);
        textColor = a.getColor(R.styleable.absProgressBar_textColor, 0xffffffff);

        setProgress(0, progress);
        a.recycle();
    }


    /**
     * 初始化画笔
     */
    protected void initPaint() {
        if (paint == null) {
            paint = new Paint();
        } else {
            paint.reset();
        }
        paint.setAntiAlias(true);
    }

    /**
     * 获取各元素尺寸
     */
    protected void getDimension() {
        width = getWidth();
        height = getHeight();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        getDimension();
        final int saveCount = canvas.save();
        drawProgress(canvas);
        drawText(canvas);
        canvas.restoreToCount(saveCount);
    }

    /**
     * 绘制进度
     *
     * @param canvas
     */
    public void drawProgress(Canvas canvas) {

    }

    /**
     * 绘制文字
     *
     * @param canvas
     */
    public void drawText(Canvas canvas) {

    }


    /**
     * dp转px
     *
     * @param dpValue
     * @return
     */
    public float dip2px(float dpValue) {
        final float scale = this.context.getResources().getDisplayMetrics().density;
        return dpValue * scale + 0.5f;
    }


    /**
     * 设置进度
     *
     * @param currentTime
     * @param endTime
     */
    public void setProgress(int currentTime, int endTime) {
        Log.d("setProgress:", currentTime * 100f / endTime + "%");
        this.currentTime = TCUtils.duration(currentTime);
        this.progress = (int) (currentTime * 100f / endTime);
        invalidate();
    }

    /**
     * 设置无填充色
     *
     * @param backgroundColor
     */
    public void setBackgroundColor(int backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    /**
     * 设置文字颜色
     *
     * @param textColor
     */
    public void setTextColor(int textColor) {
        this.textColor = textColor;
    }

}
