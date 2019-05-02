package com.tencent.qcloud.xiaozhibo.videoeditor.word.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.RectF;
import android.graphics.Shader;
import android.util.AttributeSet;

import com.tencent.qcloud.xiaozhibo.R;


public class CustomProgressBar extends AbsProgressBar {

    /**
     * 进度条填充起始色
     */
    protected int startFillColor;

    /**
     * 进度条填充中间色
     */
    protected int middleFillColor;

    /**
     * 进度条填充结束颜色
     */
    protected int endFillColor;

    /**
     * 进度条宽度
     */
    protected float progressWidth;

    /**
     * 指示圆点颜色
     */
    private int arrowPointColor;

    public CustomProgressBar(Context context) {
        super(context);
    }

    public CustomProgressBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public CustomProgressBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        final TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.progressBar);
        startFillColor = a.getColor(R.styleable.progressBar_startFillColor, 0xffff0000);
        middleFillColor = a.getColor(R.styleable.progressBar_middleFillColor, 0xffff0000);
        endFillColor = a.getColor(R.styleable.progressBar_endFillColor, 0xffff0000);
        arrowPointColor = a.getColor(R.styleable.progressBar_arrowPointColor, 0xffffffff);
        a.recycle();
    }


    @Override
    protected void getDimension() {
        super.getDimension();
        progressWidth = (float) (progress / 100.0 * width);
    }

    @Override
    public void drawProgress(Canvas canvas) {
        if (progressWidth < height / 2 - dip2px(2)) {
            //绘制无填充背景
            paint.setColor(backgroundColor);
            RectF rectF = new RectF(0, 0, width, height);
            canvas.drawRoundRect(rectF, height / 2, height / 2, paint);

            //绘制中间圆心
            paint.setColor(arrowPointColor);
            canvas.drawCircle(height / 2, height / 2, height / 2 - dip2px(2), paint);
        } else if (progressWidth > height / 2 - dip2px(2)) {
            //绘制无填充背景
            paint.setColor(backgroundColor);
            RectF backgroundRectF = new RectF(0, 0, width, height);
            canvas.drawRoundRect(backgroundRectF, height / 2, height / 2, paint);

            //绘制填充背景
            paint.setShader(getShader(progressWidth));
            RectF fillRectF = new RectF(0, 0, progressWidth, height);
            canvas.drawRoundRect(fillRectF, height / 2, height / 2, paint);

            //绘制中间圆心
            initPaint();
            paint.setColor(arrowPointColor);
            canvas.drawCircle(progressWidth - height / 2, height / 2, height / 2 - dip2px(2), paint);
        } else {
            //绘制填充背景
            paint.setShader(getShader(progressWidth));
            RectF fillRectF = new RectF(0, 0, progressWidth, height);
            canvas.drawRoundRect(fillRectF, height / 2, height / 2, paint);

            //绘制中间圆心
            initPaint();
            paint.setColor(arrowPointColor);
            canvas.drawCircle(progressWidth - height / 2, height / 2, height / 2 - dip2px(2), paint);
        }
    }

    /**
     * 获取Shader
     *
     * @return
     */
    protected Shader getShader(float width) {
        int colors[] = new int[3];
        float positions[] = new float[3];

        // 第1个点
        colors[0] = startFillColor;
        positions[0] = 0;

        // 第2个点
        colors[1] = middleFillColor;
        positions[1] = 0.5f;

        // 第3个点
        colors[2] = endFillColor;
        positions[2] = 1;


        LinearGradient shader = new LinearGradient(
                0, 0,
                width, 0,
                colors,
                positions,
                Shader.TileMode.MIRROR);

        return shader;
    }

    /**
     * 设置开始填充色
     *
     * @param startFillColor
     */
    public void setStartFillColor(int startFillColor) {
        this.startFillColor = startFillColor;
    }

    /**
     * 设置填充中间色
     *
     * @param middleFillColor
     */
    public void setMiddleFillColor(int middleFillColor) {
        this.middleFillColor = middleFillColor;
    }

    /**
     * 设置填充结束色
     *
     * @param endFillColor
     */
    public void setEndFillColor(int endFillColor) {
        this.endFillColor = endFillColor;
    }

    /**
     * 设置指示点颜色
     *
     * @param arrowPointColor
     */
    public void setArrowPointColor(int arrowPointColor) {
        this.arrowPointColor = arrowPointColor;
    }

}
