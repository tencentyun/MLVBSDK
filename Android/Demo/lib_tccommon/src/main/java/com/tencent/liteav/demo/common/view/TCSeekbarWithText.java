package com.tencent.liteav.demo.common.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.MotionEvent;

import com.tencent.liteav.demo.common.R;

public class TCSeekbarWithText extends android.support.v7.widget.AppCompatSeekBar {
    /**
     * 文本的颜色
     */
    private int mTitleTextColor;
    /**
     * 文本的大小
     */
    private float mTitleTextSize;
    private String mTitleText = "";//文字的内容

    /**
     * 背景图片
     */
    private int img;
    private Bitmap map;
    //bitmap对应的宽高
    private float img_width, img_height;
    Paint paint;

    private float numTextWidth;
    //测量seekbar的规格
    private Rect rect_seek;
    private Paint.FontMetrics fm;

    public static final int TEXT_ALIGN_LEFT = 0x00000001;
    public static final int TEXT_ALIGN_RIGHT = 0x00000010;
    public static final int TEXT_ALIGN_CENTER_VERTICAL = 0x00000100;
    public static final int TEXT_ALIGN_CENTER_HORIZONTAL = 0x00001000;
    public static final int TEXT_ALIGN_TOP = 0x00010000;
    public static final int TEXT_ALIGN_BOTTOM = 0x00100000;
    /**
     * 文本中轴线X坐标
     */
    private float textCenterX;
    /**
     * 文本baseline线Y坐标
     */
    private float textBaselineY;
    /**
     * 文字的方位
     */
    private int textAlign;

    public TCSeekbarWithText(Context context) {
        this(context, null);
    }

    public TCSeekbarWithText(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public TCSeekbarWithText(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray array = context.getTheme().obtainStyledAttributes(attrs, R.styleable.TCSeekbarWithText, defStyleAttr, 0);
        int n = array.getIndexCount();
        for (int i = 0; i < n; i++) {
            int attr = array.getIndex(i);
            if (attr == R.styleable.TCSeekbarWithText_textsize) {
                mTitleTextSize = array.getDimension(attr, 14f);

            } else if (attr == R.styleable.TCSeekbarWithText_textcolor) {
                mTitleTextColor = array.getColor(attr, Color.WHITE);

            } else if (attr == R.styleable.TCSeekbarWithText_img) {
                img = array.getResourceId(attr, R.drawable.ic_player_slider);

            }
        }
        array.recycle();
        getImgWH();
        paint = new Paint();
        paint.setAntiAlias(true);//设置抗锯齿
        paint.setTextSize(mTitleTextSize);//设置文字大小
        paint.setColor(mTitleTextColor);//设置文字颜色
        //设置控件的padding 给提示文字留出位置
//        setPadding((int) Math.ceil(img_width) / 2, 0, (int) Math.ceil(img_height) / 2, (int) Math.ceil(img_height) + 10);
        textAlign = TEXT_ALIGN_CENTER_HORIZONTAL | TEXT_ALIGN_CENTER_VERTICAL;
    }

    /**
     * 获取图片的宽高
     */
    private void getImgWH() {
        map = BitmapFactory.decodeResource(getResources(), img);
        img_width = map.getWidth();
        img_height = map.getHeight();
    }

    @Override
    protected synchronized void onDraw(Canvas canvas) {
        rect_seek = this.getProgressDrawable().getBounds();
        Paint paints = new Paint();
        paints.setColor(getResources().getColor(android.R.color.transparent));
        paints.setAntiAlias(true);
        RectF rect = new RectF(getPaddingLeft() - 10, rect_seek.top - 10,
                getPaddingLeft() + rect_seek.right + 10, rect_seek.bottom + 10);
        canvas.drawRoundRect(rect, 15, 15, paints);

        super.onDraw(canvas);
        //定位文本绘制的位置
        setTextLocation();
        //定位文字背景图片的位置
        float bm_x = rect_seek.width() * getProgress() / getMax();
        float bm_y = rect_seek.height() + 20;
        //计算文字的中心位置在bitmap
        float text_x = rect_seek.width() * getProgress() / getMax() + (img_width - numTextWidth) / 2;
        //画背景图
//        canvas.drawBitmap(map, bm_x, bm_y, paint);
        canvas.drawText(mTitleText, text_x + numTextWidth / 4, (float) (textBaselineY + bm_y + (0.7 * img_height / 2)), paint);//画文字
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        invalidate();//监听手势滑动，不断重绘文字和背景图的显示位置
        return super.onTouchEvent(event);
    }

    public void setText(String text) {
        mTitleText = text;
    }

    /**
     * 定位文本绘制的位置
     */
    private void setTextLocation() {
        fm = paint.getFontMetrics();
        //文本的宽度
        numTextWidth = paint.measureText(mTitleText);

        float textCenterVerticalBaselineY = img_height / 2 - fm.descent + (fm.descent - fm.ascent) / 2;
        switch (textAlign) {
            case TEXT_ALIGN_CENTER_HORIZONTAL | TEXT_ALIGN_CENTER_VERTICAL:
                textCenterX = img_width / 2;
                textBaselineY = textCenterVerticalBaselineY;
                break;
            case TEXT_ALIGN_LEFT | TEXT_ALIGN_CENTER_VERTICAL:
                textCenterX = numTextWidth / 2;
                textBaselineY = textCenterVerticalBaselineY;
                break;
            case TEXT_ALIGN_RIGHT | TEXT_ALIGN_CENTER_VERTICAL:
                textCenterX = img_width - numTextWidth / 2;
                textBaselineY = textCenterVerticalBaselineY;
                break;
            case TEXT_ALIGN_BOTTOM | TEXT_ALIGN_CENTER_HORIZONTAL:
                textCenterX = img_width / 2;
                textBaselineY = img_height - fm.bottom;
                break;
            case TEXT_ALIGN_TOP | TEXT_ALIGN_CENTER_HORIZONTAL:
                textCenterX = img_width / 2;
                textBaselineY = -fm.ascent;
                break;
            case TEXT_ALIGN_TOP | TEXT_ALIGN_LEFT:
                textCenterX = numTextWidth / 2;
                textBaselineY = -fm.ascent;
                break;
            case TEXT_ALIGN_BOTTOM | TEXT_ALIGN_LEFT:
                textCenterX = numTextWidth / 2;
                textBaselineY = img_height - fm.bottom;
                break;
            case TEXT_ALIGN_TOP | TEXT_ALIGN_RIGHT:
                textCenterX = img_width - numTextWidth / 2;
                textBaselineY = -fm.ascent;
                break;
            case TEXT_ALIGN_BOTTOM | TEXT_ALIGN_RIGHT:
                textCenterX = img_width - numTextWidth / 2;
                textBaselineY = img_height - fm.bottom;
                break;
        }
    }
}
