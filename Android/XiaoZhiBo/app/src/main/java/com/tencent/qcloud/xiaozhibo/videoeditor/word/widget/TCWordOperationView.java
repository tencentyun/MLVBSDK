package com.tencent.qcloud.xiaozhibo.videoeditor.word.widget;

/**
 * Created by hanszhli on 2017/6/20.
 */

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.xiaozhibo.R;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * 文字操作的View（基于Bitmap的内容，所以一切Bitmap都支持）
 * <p>
 * 单手进行缩放，旋转，平移操作
 */
public class TCWordOperationView extends View {
    /**
     * 图片的最大缩放比例
     */
    private static final float MAX_SCALE = 4.0f;

    /**
     * 图片的最小缩放比例
     */
    private static final float MIN_SCALE = 0.3f;

    /**
     * 控制缩放，旋转图标所在四个点得位置
     */
    private static final int LEFT_TOP = 0;
    private static final int RIGHT_TOP = 1;
    private static final int RIGHT_BOTTOM = 2;
    private static final int LEFT_BOTTOM = 3;

    /**
     * 一些默认的常量
     */
    private static final int DEFAULT_FRAME_PADDING = 0;
    private static final int DEFAULT_FRAME_WIDTH = 2;
    private static final int DEFAULT_FRAME_COLOR = Color.WHITE;
    private static final float DEFAULT_SCALE = 1.0f;
    private static final float DEFAULT_DEGREE = 0;
    private static final int DEFAULT_CONTROL_LOCATION = RIGHT_TOP;
    private static final boolean DEFAULT_EDITABLE = true;
    private static final int DEFAULT_OTHER_DRAWABLE_WIDTH = 50;
    private static final int DEFAULT_OTHER_DRAWABLE_HEIGHT = 50;


    private boolean isMeasured;

    /**
     * 用于旋转缩放的Bitmap
     */
    private Bitmap mBitmap;

    /**
     * SingleTouchView的中心点坐标，相对于其父类布局而言的
     */
    private PointF mCenterPoint = new PointF();

    /**
     * View的宽度和高度，随着图片的旋转而变化(不包括控制旋转，缩放图片的宽高)
     */
    private int mViewWidth, mViewHeight;

    /**
     * 图片的旋转角度
     */
    private float mDegree = DEFAULT_DEGREE;

    /**
     * 图片的缩放比例
     */
    private float mScale = DEFAULT_SCALE;

    /**
     * 用于缩放，旋转，平移的矩阵
     */
    private Matrix matrix = new Matrix();

    /**
     * SingleTouchView距离父类布局的左间距
     */
    private int mViewPaddingLeft;

    /**
     * SingleTouchView距离父类布局的上间距
     */
    private int mViewPaddingTop;

    /**
     * 图片四个点坐标
     */
    private Point mLTPoint;
    private Point mRTPoint;
    private Point mRBPoint;
    private Point mLBPoint;
    /**
     * 用于编辑的控制点的坐标
     */
    private Point mEditPoint = new Point();

    private Drawable mEditDrawble;

    private int mEditDrawableWidth, mEditDrawableHeight;


    /**
     * 用于删除的控制点的坐标
     */
    private Point mDeletePoint = new Point();

    private Drawable mDeleteDrawable;

    private int mDeleteDrawbleWidth, mDeleteDrawableHeight;

    /**
     * 用于缩放，旋转的控制点的坐标
     */
    private Point mControlPoint = new Point();

    /**
     * 用于缩放，旋转的图标
     */
    private Drawable mControlDrawable;

    /**
     * 缩放，旋转图标的宽和高
     */
    private int mControlDrawableWidth, mControlDrawableHeight;

    /**
     * 画外围框的Path
     */
    private Path mPath = new Path();

    /**
     * 画外围框的画笔
     */
    private Paint mPaint;

    /**
     * 初始状态
     */
    private static final int STATUS_INIT = 0;

    /**
     * 拖动状态
     */
    private static final int STATUS_DRAG = 1;

    /**
     * 旋转或者放大状态
     */
    private static final int STATUS_ROTATE_ZOOM = 2;
    /**
     * 点击编辑状态
     */
    private static final int STATUS_EDIT = 3;
    /**
     * 点击删除状态
     */
    private static final int STATUS_DELETE = 4;

    /**
     * 当前所处的状态
     */
    private int mStatus = STATUS_INIT;

    /**
     * 外边框与图片之间的间距, 单位是dip
     */
    private int mFramePadding = DEFAULT_FRAME_PADDING;

    /**
     * 外边框颜色
     */
    private int frameColor = DEFAULT_FRAME_COLOR;

    /**
     * 外边框线条粗细, 单位是 dip
     */
    private int frameWidth = DEFAULT_FRAME_WIDTH;

    /**
     * 是否处于可以缩放，平移，旋转状态
     */
    private boolean isEditable = DEFAULT_EDITABLE;

    private DisplayMetrics metrics;


    private PointF mPreMovePointF = new PointF();
    private PointF mCurMovePointF = new PointF();

    /**
     * 图片在旋转时x方向的偏移量
     */
    private int offsetX;
    /**
     * 图片在旋转时y方向的偏移量
     */
    private int offsetY;

    /**
     * 控制图标所在的位置（比如左上，右上，左下，右下）
     */
    private int mControlLocation = RIGHT_BOTTOM;

    private int mEditLocation = RIGHT_TOP;

    private int mDeleteLocatoin = LEFT_TOP;
    private int mX;
    private int mY;
    private int width;
    private int mParentW;
    private int mParentH;

    public TCWordOperationView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public TCWordOperationView(Context context) {
        this(context, null);
    }

    public TCWordOperationView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        obtainStyledAttributes(attrs);
        init();
    }

    /**
     * 获取自定义属性
     *
     * @param attrs
     */
    private void obtainStyledAttributes(AttributeSet attrs) {
        metrics = getContext().getResources().getDisplayMetrics();
        mFramePadding = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, DEFAULT_FRAME_PADDING, metrics);
        frameWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, DEFAULT_FRAME_WIDTH, metrics);

        TypedArray mTypedArray = getContext().obtainStyledAttributes(attrs, R.styleable.TCWordOperationView);

        Drawable srcDrawable = mTypedArray.getDrawable(R.styleable.TCWordOperationView_src);
        mBitmap = drawable2Bitmap(srcDrawable);

        mFramePadding = mTypedArray.getDimensionPixelSize(R.styleable.TCWordOperationView_framePadding, mFramePadding);
        frameWidth = mTypedArray.getDimensionPixelSize(R.styleable.TCWordOperationView_frameWidth, frameWidth);
        frameColor = mTypedArray.getColor(R.styleable.TCWordOperationView_frameColor, DEFAULT_FRAME_COLOR);
        mScale = mTypedArray.getFloat(R.styleable.TCWordOperationView_scale, DEFAULT_SCALE);
        mDegree = mTypedArray.getFloat(R.styleable.TCWordOperationView_degree, DEFAULT_DEGREE);
        mControlDrawable = mTypedArray.getDrawable(R.styleable.TCWordOperationView_controlDrawable);
        mControlLocation = mTypedArray.getInt(R.styleable.TCWordOperationView_controlLocation, RIGHT_BOTTOM);

        mEditDrawble = mTypedArray.getDrawable(R.styleable.TCWordOperationView_editDrawable);
        mEditLocation = mTypedArray.getInt(R.styleable.TCWordOperationView_editLocation, RIGHT_TOP);

        mDeleteDrawable = mTypedArray.getDrawable(R.styleable.TCWordOperationView_deleteDrawable);
        mDeleteLocatoin = mTypedArray.getInt(R.styleable.TCWordOperationView_deleteLocation, LEFT_TOP);

        isEditable = mTypedArray.getBoolean(R.styleable.TCWordOperationView_editable, DEFAULT_EDITABLE);

        mTypedArray.recycle();
    }


    private void init() {
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setColor(frameColor);
        mPaint.setStrokeWidth(frameWidth);
        mPaint.setStyle(Paint.Style.STROKE);

        if (mControlDrawable != null) {
            mControlDrawableWidth = (int) (mControlDrawable.getIntrinsicWidth() * 1.5);
            mControlDrawableHeight = (int) (mControlDrawable.getIntrinsicHeight() * 1.5);
        }
        if (mEditDrawble != null) {
            mEditDrawableWidth = (int) (mEditDrawble.getIntrinsicWidth() * 1.5);
            mEditDrawableHeight = (int) (mEditDrawble.getIntrinsicHeight() * 1.5);
        }
        if (mDeleteDrawable != null) {
            mDeleteDrawbleWidth = (int) (mDeleteDrawable.getIntrinsicWidth() * 1.5);
            mDeleteDrawableHeight = (int) (mDeleteDrawable.getIntrinsicHeight() * 1.5);
        }

        transformDraw();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (!isMeasured) {
            //获取SingleTouchView所在父布局的中心点
            ViewGroup mViewGroup = (ViewGroup) getParent();
            if (null != mViewGroup) {
                int parentWidth = mViewGroup.getWidth();
                int parentHeight = mViewGroup.getHeight();
                mCenterPoint.set(parentWidth / 2, parentHeight / 2);
            }
            isMeasured = true;
            adjustLayout();
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
    }

    /**
     * 调整View的大小，位置
     */
    private void adjustLayout() {
        if (mCenterPoint.x <= 0 || mCenterPoint.y <= 0) {
            mCenterPoint.set(mParentW / 2, mParentH / 2);
        }
        int actualWidth = mViewWidth + mControlDrawableWidth;
        int actualHeight = mViewHeight + mControlDrawableHeight;
        int newPaddingLeft = (int) (mCenterPoint.x - actualWidth / 2);
        int newPaddingTop = (int) (mCenterPoint.y - actualHeight / 2);

        if (mViewPaddingLeft != newPaddingLeft || mViewPaddingTop != newPaddingTop) {
            mViewPaddingLeft = newPaddingLeft;
            mViewPaddingTop = newPaddingTop;
        }
        layout(newPaddingLeft, newPaddingTop, newPaddingLeft + actualWidth, newPaddingTop + actualHeight);
        this.mX = newPaddingLeft + mControlDrawableWidth / 2;
        this.mY = newPaddingTop + mControlDrawableHeight / 2;
        this.width = mViewWidth;
    }

    private IWordClickListener mClickListener = null;

    public void setIWordClickListener(IWordClickListener listener) {
        mClickListener = listener;
    }

    public void setParentWidth(int parentW) {
        mParentW = parentW;
    }

    public void setParentHeight(int parentH) {
        mParentH = parentH;
    }

    public interface IWordClickListener {
        void onDeleteClick();

        void onEditClick();

        void onRotateClick();
    }

    /**
     * 设置旋转图
     *
     * @param bitmap
     */
    public void setImageBitamp(Bitmap bitmap) {
        if (this.mBitmap != null && bitmap != null && !this.mBitmap.equals(bitmap)) {
            this.mBitmap.recycle();
        }
        this.mBitmap = bitmap;
        mScale = 1.0f;
        mDegree = 0;
        mFramePadding = 0;
        transformDraw();
    }

    public Bitmap getImageBitmap() {
        return this.mBitmap;
    }

    public Bitmap getRotateBitmap() {
        Bitmap bitmap = Bitmap.createBitmap(this.mBitmap, 0, 0, this.mBitmap.getWidth(), this.mBitmap.getHeight(), matrix, true);
        return bitmap;
    }

    public int getImageX() {
        return this.mX;
    }


    public int getImageY() {
        return this.mY;
    }

    public int getImageWidth() {
        return this.width;
    }

    /**
     * 设置旋转图
     *
     * @param drawable
     */
    public void setImageDrawable(Drawable drawable) {
        this.mBitmap = drawable2Bitmap(drawable);
        transformDraw();
    }

    /**
     * 从Drawable中获取Bitmap对象
     *
     * @param drawable
     * @return
     */
    private Bitmap drawable2Bitmap(Drawable drawable) {
        try {
            if (drawable == null) {
                return null;
            }

            if (drawable instanceof BitmapDrawable) {
                return ((BitmapDrawable) drawable).getBitmap();
            }

            int intrinsicWidth = drawable.getIntrinsicWidth();
            int intrinsicHeight = drawable.getIntrinsicHeight();
            Bitmap bitmap = Bitmap.createBitmap(
                    intrinsicWidth <= 0 ? DEFAULT_OTHER_DRAWABLE_WIDTH
                            : intrinsicWidth,
                    intrinsicHeight <= 0 ? DEFAULT_OTHER_DRAWABLE_HEIGHT
                            : intrinsicHeight, Bitmap.Config.ARGB_8888);

            Canvas canvas = new Canvas(bitmap);
            drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
            drawable.draw(canvas);
            return bitmap;
        } catch (OutOfMemoryError e) {
            return null;
        }

    }

    /**
     * 根据id设置旋转图
     *
     * @param resId
     */
    public void setImageResource(int resId) {
        Drawable drawable = getContext().getResources().getDrawable(resId);
        setImageDrawable(drawable);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        //每次draw之前调整View的位置和大小
        super.onDraw(canvas);

        if (mBitmap == null) return;
        canvas.drawBitmap(mBitmap, matrix, mPaint);


        //处于可编辑状态才画边框和控制图标
        if (isEditable) {
            mPath.reset();
            mPath.moveTo(mLTPoint.x, mLTPoint.y);
            mPath.lineTo(mRTPoint.x, mRTPoint.y);
            mPath.lineTo(mRBPoint.x, mRBPoint.y);
            mPath.lineTo(mLBPoint.x, mLBPoint.y);
            mPath.lineTo(mLTPoint.x, mLTPoint.y);
            mPath.lineTo(mRTPoint.x, mRTPoint.y);
            canvas.drawPath(mPath, mPaint);
            //画旋转, 缩放图标

            if (mControlDrawable != null) {
                mControlDrawable.setBounds(mControlPoint.x - mControlDrawableWidth / 2,
                        mControlPoint.y - mControlDrawableHeight / 2, mControlPoint.x + mControlDrawableWidth
                                / 2, mControlPoint.y + mControlDrawableHeight / 2);
                mControlDrawable.draw(canvas);
            }

            if (mEditDrawble != null) {
                mEditDrawble.setBounds(mEditPoint.x - mControlDrawableWidth / 2,
                        mEditPoint.y - mControlDrawableHeight / 2, mEditPoint.x + mControlDrawableWidth
                                / 2, mEditPoint.y + mControlDrawableHeight / 2);
                mEditDrawble.draw(canvas);
            }

            if (mDeleteDrawable != null) {
                mDeleteDrawable.setBounds(mDeletePoint.x - mControlDrawableWidth / 2,
                        mDeletePoint.y - mControlDrawableHeight / 2, mDeletePoint.x + mControlDrawableWidth
                                / 2, mDeletePoint.y + mControlDrawableHeight / 2);
                mDeleteDrawable.draw(canvas);
            }
        }
        adjustLayout();
    }


    /**
     * 设置Matrix, 强制刷新
     */
    private void transformDraw() {
        if (mBitmap == null) return;
        int bitmapWidth = (int) (mBitmap.getWidth() * mScale);
        int bitmapHeight = (int) (mBitmap.getHeight() * mScale);
        computeRect(-mFramePadding, -mFramePadding, bitmapWidth + mFramePadding, bitmapHeight + mFramePadding, mDegree);

        //设置缩放比例
        matrix.setScale(mScale, mScale);
        //绕着图片中心进行旋转
        matrix.postRotate(mDegree % 360, bitmapWidth / 2, bitmapHeight / 2);
        //设置画该图片的起始点
        matrix.postTranslate(offsetX + mControlDrawableWidth / 2, offsetY + mControlDrawableHeight / 2);

        adjustLayout();
    }


    public boolean onTouchEvent(MotionEvent event) {
        if (!isEditable) {
            return super.onTouchEvent(event);
        }
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mPreMovePointF.set(event.getX() + mViewPaddingLeft, event.getY() + mViewPaddingTop);

                mStatus = judgeStatus(event.getX(), event.getY());

                break;
            case MotionEvent.ACTION_UP:
                if (mClickListener != null/* && (mStatus == STATUS_DELETE || mStatus == STATUS_EDIT)*/) {
                    //再次判定抬起点 是否处于icon的范围之内
                    int secondJudgeState = judgeStatus(event.getX(), event.getY());
                    //满足才触发回调
                    if (mStatus == STATUS_EDIT && secondJudgeState == mStatus) {
                        mClickListener.onEditClick();
                    }
                    if (mStatus == STATUS_DELETE && secondJudgeState == mStatus) {
                        mClickListener.onDeleteClick();
                    }
                    if (mStatus == STATUS_ROTATE_ZOOM || mStatus == STATUS_DRAG) {
                        mClickListener.onRotateClick();
                    }
                }
                mStatus = STATUS_INIT;
                break;
            case MotionEvent.ACTION_MOVE:
                mCurMovePointF.set(event.getX() + mViewPaddingLeft, event.getY() + mViewPaddingTop);
                if (mStatus == STATUS_ROTATE_ZOOM) {
                    float scale = 1f;

                    int halfBitmapWidth = mBitmap.getWidth() / 2;
                    int halfBitmapHeight = mBitmap.getHeight() / 2;

                    //图片某个点到图片中心的距离
                    float bitmapToCenterDistance = (float) Math.sqrt(halfBitmapWidth * halfBitmapWidth + halfBitmapHeight * halfBitmapHeight);

                    //移动的点到图片中心的距离
                    float moveToCenterDistance = distance4PointF(mCenterPoint, mCurMovePointF);

                    //计算缩放比例
                    scale = moveToCenterDistance / bitmapToCenterDistance;


                    //缩放比例的界限判断
                    if (scale <= MIN_SCALE) {
                        scale = MIN_SCALE;
                    } else if (scale >= MAX_SCALE) {
                        scale = MAX_SCALE;
                    }


                    // 角度
                    double a = distance4PointF(mCenterPoint, mPreMovePointF);
                    double b = distance4PointF(mPreMovePointF, mCurMovePointF);
                    double c = distance4PointF(mCenterPoint, mCurMovePointF);

                    double cosb = (a * a + c * c - b * b) / (2 * a * c);

                    if (cosb >= 1) {
                        cosb = 1f;
                    }

                    double radian = Math.acos(cosb);
                    float newDegree = (float) radianToDegree(radian);

                    //center -> proMove的向量， 我们使用PointF来实现
                    PointF centerToProMove = new PointF((mPreMovePointF.x - mCenterPoint.x), (mPreMovePointF.y - mCenterPoint.y));

                    //center -> curMove 的向量
                    PointF centerToCurMove = new PointF((mCurMovePointF.x - mCenterPoint.x), (mCurMovePointF.y - mCenterPoint.y));

                    //向量叉乘结果, 如果结果为负数， 表示为逆时针， 结果为正数表示顺时针
                    float result = centerToProMove.x * centerToCurMove.y - centerToProMove.y * centerToCurMove.x;

                    if (result < 0) {
                        newDegree = -newDegree;
                    }

                    mDegree = mDegree + newDegree;
                    mScale = scale;

                    transformDraw();
                } else if (mStatus == STATUS_DRAG) {
                    // 修改中心点
                    mCenterPoint.x += mCurMovePointF.x - mPreMovePointF.x;
                    mCenterPoint.y += mCurMovePointF.y - mPreMovePointF.y;
                    System.out.println(this + "move = " + mCenterPoint);

                    adjustLayout();
                }

                mPreMovePointF.set(mCurMovePointF);
                break;
        }
        return true;
    }


    /**
     * 获取四个点和View的大小
     *
     * @param left
     * @param top
     * @param right
     * @param bottom
     * @param degree
     */
    private void computeRect(int left, int top, int right, int bottom, float degree) {
        Point lt = new Point(left, top);
        Point rt = new Point(right, top);
        Point rb = new Point(right, bottom);
        Point lb = new Point(left, bottom);
        Point cp = new Point((left + right) / 2, (top + bottom) / 2);
        mLTPoint = obtainRotationPoint(cp, lt, degree);
        mRTPoint = obtainRotationPoint(cp, rt, degree);
        mRBPoint = obtainRotationPoint(cp, rb, degree);
        mLBPoint = obtainRotationPoint(cp, lb, degree);

        //计算X坐标最大的值和最小的值
        int maxCoordinateX = getMaxValue(mLTPoint.x, mRTPoint.x, mRBPoint.x, mLBPoint.x);
        int minCoordinateX = getMinValue(mLTPoint.x, mRTPoint.x, mRBPoint.x, mLBPoint.x);
        ;

        mViewWidth = maxCoordinateX - minCoordinateX;


        //计算Y坐标最大的值和最小的值
        int maxCoordinateY = getMaxValue(mLTPoint.y, mRTPoint.y, mRBPoint.y, mLBPoint.y);
        int minCoordinateY = getMinValue(mLTPoint.y, mRTPoint.y, mRBPoint.y, mLBPoint.y);

        mViewHeight = maxCoordinateY - minCoordinateY;


        //View中心点的坐标
        Point viewCenterPoint = new Point((maxCoordinateX + minCoordinateX) / 2, (maxCoordinateY + minCoordinateY) / 2);

        offsetX = mViewWidth / 2 - viewCenterPoint.x;
        offsetY = mViewHeight / 2 - viewCenterPoint.y;


        int halfDrawableWidth = mControlDrawableWidth / 2;
        int halfDrawableHeight = mControlDrawableHeight / 2;

        //将Bitmap的四个点的X的坐标移动offsetX + halfDrawableWidth
        mLTPoint.x += (offsetX + halfDrawableWidth);
        mRTPoint.x += (offsetX + halfDrawableWidth);
        mRBPoint.x += (offsetX + halfDrawableWidth);
        mLBPoint.x += (offsetX + halfDrawableWidth);

        //将Bitmap的四个点的Y坐标移动offsetY + halfDrawableHeight
        mLTPoint.y += (offsetY + halfDrawableHeight);
        mRTPoint.y += (offsetY + halfDrawableHeight);
        mRBPoint.y += (offsetY + halfDrawableHeight);
        mLBPoint.y += (offsetY + halfDrawableHeight);

        mControlPoint = locatePoint(mControlLocation);
        mEditPoint = locatePoint(mEditLocation);
        mDeletePoint = locatePoint(mDeleteLocatoin);
    }

    /**
     * 根据位置判断控制图标处于那个点
     *
     * @return
     */
    private Point locatePoint(int location) {
        switch (location) {
            case LEFT_TOP:
                return mLTPoint;
            case RIGHT_TOP:
                return mRTPoint;
            case RIGHT_BOTTOM:
                return mRBPoint;
            case LEFT_BOTTOM:
                return mLBPoint;
        }
        return mLTPoint;
    }


    /**
     * 获取变长参数最大的值
     *
     * @param array
     * @return
     */
    public int getMaxValue(Integer... array) {
        List<Integer> list = Arrays.asList(array);
        Collections.sort(list);
        return list.get(list.size() - 1);
    }


    /**
     * 获取变长参数最大的值
     *
     * @param array
     * @return
     */
    public int getMinValue(Integer... array) {
        List<Integer> list = Arrays.asList(array);
        Collections.sort(list);
        return list.get(0);
    }


    /**
     * 获取旋转某个角度之后的点
     *
     * @param source
     * @param degree
     * @return
     */
    private Point obtainRotationPoint(Point center, Point source, float degree) {
        //两者之间的距离
        Point disPoint = new Point();
        disPoint.x = source.x - center.x;
        disPoint.y = source.y - center.y;

        //没旋转之前的弧度
        double originRadian = 0;

        //没旋转之前的角度
        double originDegree = 0;

        //旋转之后的角度
        double resultDegree = 0;

        //旋转之后的弧度
        double resultRadian = 0;

        //经过旋转之后点的坐标
        Point resultPoint = new Point();

        double distance = Math.sqrt(disPoint.x * disPoint.x + disPoint.y * disPoint.y);
        if (disPoint.x == 0 && disPoint.y == 0) {
            return center;
            // 第一象限
        } else if (disPoint.x >= 0 && disPoint.y >= 0) {
            // 计算与x正方向的夹角
            originRadian = Math.asin(disPoint.y / distance);

            // 第二象限
        } else if (disPoint.x < 0 && disPoint.y >= 0) {
            // 计算与x正方向的夹角
            originRadian = Math.asin(Math.abs(disPoint.x) / distance);
            originRadian = originRadian + Math.PI / 2;

            // 第三象限
        } else if (disPoint.x < 0 && disPoint.y < 0) {
            // 计算与x正方向的夹角
            originRadian = Math.asin(Math.abs(disPoint.y) / distance);
            originRadian = originRadian + Math.PI;
        } else if (disPoint.x >= 0 && disPoint.y < 0) {
            // 计算与x正方向的夹角
            originRadian = Math.asin(disPoint.x / distance);
            originRadian = originRadian + Math.PI * 3 / 2;
        }

        // 弧度换算成角度
        originDegree = radianToDegree(originRadian);
        resultDegree = originDegree + degree;

        // 角度转弧度
        resultRadian = degreeToRadian(resultDegree);

        resultPoint.x = (int) Math.round(distance * Math.cos(resultRadian));
        resultPoint.y = (int) Math.round(distance * Math.sin(resultRadian));
        resultPoint.x += center.x;
        resultPoint.y += center.y;

        return resultPoint;
    }

    /**
     * 弧度换算成角度
     *
     * @return
     */
    private double radianToDegree(double radian) {
        return radian * 180 / Math.PI;
    }


    /**
     * 角度换算成弧度
     *
     * @param degree
     * @return
     */
    private double degreeToRadian(double degree) {
        return degree * Math.PI / 180;
    }

    /**
     * 根据点击的位置判断是否点中控制旋转，缩放的图片， 初略的计算
     *
     * @param x
     * @param y
     * @return
     */
    private int judgeStatus(float x, float y) {
        PointF touchPoint = new PointF(x, y);
        PointF controlPointF = new PointF(mControlPoint);

        //点击的点到控制旋转，缩放点的距离
        float distanceToControl = distance4PointF(touchPoint, controlPointF);

        //如果两者之间的距离小于 控制图标的宽度，高度的最小值，则认为点中了控制图标
        if (distanceToControl < Math.min(mControlDrawableWidth / 2, mControlDrawableHeight / 2)) {
            return STATUS_ROTATE_ZOOM;
        }

        float disToEdit = distance4PointF(touchPoint, new PointF(mEditPoint));
        if (disToEdit < Math.min(mEditDrawableWidth / 2, mEditDrawableHeight / 2)) {
            return STATUS_EDIT;
        }

        float disToDelete = distance4PointF(touchPoint, new PointF(mDeletePoint));
        if (disToDelete < Math.min(mDeleteDrawbleWidth / 2, mDeleteDrawableHeight / 2)) {
            return STATUS_DELETE;
        }
        return STATUS_DRAG;

    }


    public float getImageDegree() {
        return mDegree;
    }

    /**
     * 设置图片旋转角度
     *
     * @param degree
     */
    public void setImageDegree(float degree) {
        if (this.mDegree != degree) {
            this.mDegree = degree;
            transformDraw();
        }
    }

    public float getImageScale() {
        return mScale;
    }

    /**
     * 设置图片缩放比例
     *
     * @param scale
     */
    public void setImageScale(float scale) {
        if (this.mScale != scale) {
            this.mScale = scale;
            transformDraw();
        }
    }


//    public Drawable getmControlDrawable() {
//        return mControlDrawable;
//    }
//
//    /**
//     * 设置控制图标
//     *
//     * @param drawable
//     */
//    public void setControlDrawable(Drawable drawable) {
//        this.mControlDrawable = drawable;
//        mControlDrawableWidth = drawable.getIntrinsicWidth();
//        mControlDrawableHeight = drawable.getIntrinsicHeight();
//        transformDraw();
//    }
//
//    public int getFramePadding() {
//        return mFramePadding;
//    }
//
//    public void setFramePadding(int mFramePadding) {
//        if (this.mFramePadding == mFramePadding)
//            return;
//        this.mFramePadding = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, mFramePadding, metrics);
//        transformDraw();
//    }
//
//    public int getFrameColor() {
//        return frameColor;
//    }
//
//    public void setFrameColor(int frameColor) {
//        if (this.frameColor == frameColor)
//            return;
//        this.frameColor = frameColor;
//        mPaint.setColor(frameColor);
//        invalidate();
//    }
//
//    public int getFrameWidth() {
//        return frameWidth;
//    }
//
//    public void setFrameWidth(int frameWidth) {
//        if (this.frameWidth == frameWidth)
//            return;
//        this.frameWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, frameWidth, metrics);
//        mPaint.setStrokeWidth(frameWidth);
//        invalidate();
//    }
//
//    /**
//     * 设置控制图标的位置, 设置的值只能选择LEFT_TOP ，RIGHT_TOP， RIGHT_BOTTOM，LEFT_BOTTOM
//     */
//    public void setmControlLocation(int location) {
//        if (this.mControlLocation == location)
//            return;
//        this.mControlLocation = location;
//        transformDraw();
//    }
//
//    public int getmControlLocation() {
//        return mControlLocation;
//    }


//    public PointF getCenterPoint() {
//        return mCenterPoint;
//    }
//
//    /**
//     * 设置图片中心点位置，相对于父布局而言
//     *
//     * @param mCenterPoint
//     */
//    public void setCenterPoint(PointF mCenterPoint) {
//        this.mCenterPoint = mCenterPoint;
//        adjustLayout();
//    }


    public boolean isEditable() {
        return isEditable;
    }

    /**
     * 设置是否处于可缩放，平移，旋转状态
     *
     * @param isEditable
     */
    public void setEditable(boolean isEditable) {
        this.isEditable = isEditable;
        invalidate();
    }

    /**
     * 两个点之间的距离
     *
     * @return
     */
    private float distance4PointF(PointF pf1, PointF pf2) {
        float disX = pf2.x - pf1.x;
        float disY = pf2.y - pf1.y;
        return (float) Math.sqrt(disX * disX + disY * disY);
    }


}