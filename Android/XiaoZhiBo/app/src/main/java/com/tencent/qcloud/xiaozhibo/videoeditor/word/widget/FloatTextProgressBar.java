package com.tencent.qcloud.xiaozhibo.videoeditor.word.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;

import com.tencent.qcloud.xiaozhibo.R;


public class FloatTextProgressBar extends CustomProgressBar {

    /**
     * 进度条高度
     */
    private float progressHeight;

    /**
     * 浮动框宽度
     */
    private float floatRectWidth;

    /**
     * 浮动框高度
     */
    private float floatRectHeight;

    /**
     * 三角形宽度
     */
    private float triangleWidth;

    /**
     * 浮动框左右边距
     */
    private float margin;

    /**
     * 文字大小
     */
    private float textSize;

    /**
     * 三角形颜色
     */
    private int triangleColor;

    /**
     * 浮动框颜色
     */
    private int rectColor;

    /**
     * 进度条填充颜色
     */
    protected int fillColor;

    public FloatTextProgressBar(Context context) {
        super(context);
    }

    public FloatTextProgressBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public FloatTextProgressBar(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);
    }

    @Override
    protected void getDimension() {
        super.getDimension();
        progressHeight = height / 5;
        floatRectWidth = height / 5 * 4;
        floatRectHeight = height / 9 * 4;
        triangleWidth = height / 7 * 2;
        margin = dip2px(3);
        textSize = height / 4;
    }

    private void init(AttributeSet attrs) {
        final TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.floatTextProgressBar);
        fillColor = a.getColor(R.styleable.floatTextProgressBar_fillColor, 0xffff0000);
        triangleColor = a.getColor(R.styleable.floatTextProgressBar_triangleColor, 0xffff0000);
        rectColor = a.getColor(R.styleable.floatTextProgressBar_rectColor, 0xffff0000);
        a.recycle();
    }

    @Override
    public void drawProgress(Canvas canvas) {
        //绘制未填充进度条
        paint.setColor(backgroundColor);
        RectF backgroundRectF = new RectF(0, height - progressHeight, width, height);
        canvas.drawRoundRect(backgroundRectF, progressHeight / 2, progressHeight / 2, paint);

        //绘制填充条
        paint.setColor(fillColor);
        RectF fillRectF = new RectF(0, height - progressHeight, progressWidth, height);
        canvas.drawRoundRect(fillRectF, progressHeight / 2, progressHeight / 2, paint);

        drawFloatRect(canvas);
    }


    /**
     * 绘制浮动框
     *
     * @param canvas
     */
    private void drawFloatRect(Canvas canvas) {

        if (progressWidth < floatRectWidth + margin) {
            //绘制浮动框
            paint.setColor(rectColor);
            RectF floatRectF = new RectF(margin, 0, margin + floatRectWidth, floatRectHeight);
            canvas.drawRoundRect(floatRectF, dip2px(2), dip2px(2), paint);

            //绘制三角形
            paint.setColor(triangleColor);
            Path path = new Path();
            path.moveTo(margin + floatRectWidth / 2 - triangleWidth / 2, height / 7 * 3);
            path.lineTo(margin + floatRectWidth / 2 + triangleWidth / 2, height / 7 * 3);
            path.lineTo(margin + floatRectWidth / 2, floatRectWidth / 4 + height / 7 * 3);
            path.close();
            canvas.drawPath(path, paint);
        } else if (width - progressWidth < floatRectWidth + margin) {
            //绘制浮动框
            paint.setColor(rectColor);
            RectF floatRectF = new RectF(width - floatRectWidth - margin, 0, width - margin, floatRectHeight);
            canvas.drawRoundRect(floatRectF, dip2px(2), dip2px(2), paint);

            //绘制三角形
            paint.setColor(triangleColor);
            Path path = new Path();
            path.moveTo(width - margin - floatRectWidth / 2 - triangleWidth / 2, height / 7 * 3);
            path.lineTo(width - margin - floatRectWidth / 2 + triangleWidth / 2, height / 7 * 3);
            path.lineTo(width - margin - floatRectWidth / 2, floatRectWidth / 4 + height / 7 * 3);
            path.close();
            canvas.drawPath(path, paint);
        } else {
            //绘制浮动框
            paint.setColor(rectColor);
            RectF floatRectF = new RectF(progressWidth - floatRectWidth / 2, 0, progressWidth + floatRectWidth / 2, floatRectHeight);
            canvas.drawRoundRect(floatRectF, dip2px(2), dip2px(2), paint);

            //绘制三角形
            paint.setColor(triangleColor);
            Path path = new Path();
            path.moveTo(progressWidth - triangleWidth / 2, height / 7 * 3);
            path.lineTo(progressWidth + triangleWidth / 2, height / 7 * 3);
            path.lineTo(progressWidth, floatRectWidth / 4 + height / 7 * 3);
            path.close();
            canvas.drawPath(path, paint);
        }
    }

    @Override
    public void drawText(Canvas canvas) {
        paint.setColor(textColor);
        paint.setTextSize(textSize);
        float textWidth = paint.measureText(this.currentTime);
        if (progressWidth < floatRectWidth + margin) {
            canvas.drawText(this.currentTime, margin + floatRectWidth / 2 - textWidth / 2, floatRectHeight / 2 + textSize / 4, paint);
        } else if (width - progressWidth < floatRectWidth + margin) {
            canvas.drawText(this.currentTime, width - margin - floatRectWidth / 2 - textWidth / 2, floatRectHeight / 2 + textSize / 4, paint);
        } else {
            canvas.drawText(this.currentTime, progressWidth - textWidth / 2, floatRectHeight / 2 + textSize / 4, paint);
        }
    }

    /**
     * 设置填充色
     *
     * @param fillColor
     */
    public void setFillColor(int fillColor) {
        this.fillColor = fillColor;
    }

    /**
     * 设置浮动框颜色
     *
     * @param rectColor
     */
    public void setRectColor(int rectColor) {
        this.rectColor = rectColor;
    }

    /**
     * 设置三角形颜色
     *
     * @param triangleColor
     */
    public void setTriangleColor(int triangleColor) {
        this.triangleColor = triangleColor;
    }
}
