package com.tencent.qcloud.xiaozhibo.videoeditor.word.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.widget.ImageView;

/**
 * Created by yuejiaoli on 2017/6/29.
 */

public class BorderImage extends ImageView {
    private int mColor = Color.WHITE;
    private int mBorderWidth = 1;

    public BorderImage(Context context) {
        super(context);
    }

    public BorderImage(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }


    //设置颜色
    public void setColor(int color) {
        mColor = color;
    }

    //设置边框宽度
    public void setBorderWidth(int width) {
        mBorderWidth = width;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        // 画边框
        Rect rec = canvas.getClipBounds();
        rec.top++;
        rec.left++;
        rec.bottom--;
        rec.right--;
        Paint paint = new Paint();
        //设置边框颜色
        paint.setColor(mColor);
        paint.setStyle(Paint.Style.STROKE);
        //设置边框宽度
        paint.setStrokeWidth(mBorderWidth);
        canvas.drawRect(rec, paint);
    }
}
