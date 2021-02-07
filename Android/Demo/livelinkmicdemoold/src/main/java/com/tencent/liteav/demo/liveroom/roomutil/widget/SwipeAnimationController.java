package com.tencent.liteav.demo.liveroom.roomutil.widget;

import android.animation.ValueAnimator;
import android.content.Context;
import android.util.Log;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.ViewConfiguration;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.AnticipateOvershootInterpolator;
import android.view.animation.LayoutAnimationController;
import android.widget.RelativeLayout;

import com.tencent.liteav.demo.liveroom.R;

/**
 * Created by Administrator on 2016/8/21
 * 滑动动画控制类
 */
public class SwipeAnimationController {

    private static final String TAG = "SwipeAnimationController";

    private Context         mContext;
    private RelativeLayout  mViewGroup;

    private boolean         mIsMoving = false;
    private float           mInitX;
    private float           mInitY;
    private float           mTouchSlop;
    private float           mScreenWidth;

    private Animation       mAnimation;
    private ValueAnimator   mValueAnimator;

    private LayoutAnimationController mController;

    public SwipeAnimationController(Context context) {
        this.mContext = context;

        mScreenWidth = context.getResources().getDisplayMetrics().widthPixels;
        mTouchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
        mValueAnimator = new ValueAnimator();
        mValueAnimator.setInterpolator(new AnticipateOvershootInterpolator());
        mValueAnimator.setDuration(200);
        mValueAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                int x = (Integer) animation.getAnimatedValue();
                mViewGroup.setTranslationX(x);

            }
        });
        mAnimation = AnimationUtils.loadAnimation(mContext, R.anim.mlvb_anim_slice_in_right);
        mAnimation.setDuration(150);
        mAnimation.setInterpolator(new AccelerateDecelerateInterpolator());
        mController = new LayoutAnimationController(mAnimation);
        mController.setOrder(LayoutAnimationController.ORDER_REVERSE);
    }

    public void setAnimationView(RelativeLayout viewGroup) {
        this.mViewGroup = viewGroup;
    }

    public boolean isMoving() {
        return mIsMoving;
    }

    public boolean processEvent(MotionEvent event) {


        if (mValueAnimator.isRunning()) {
            return true;
        }

        VelocityTracker mVelTracker = VelocityTracker.obtain();

        int pointId = -1;
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                //记录初始位置
                mInitX = event.getRawX();
                mInitY = event.getRawY();
                mVelTracker.addMovement(event);
                break;
            case MotionEvent.ACTION_MOVE:
                float dx = event.getRawX() - mInitX;
                float dy = event.getRawY() - mInitY;
                //根据初始位置计算移动方向与距离，判断是否为滑动手势
                if (!mIsMoving) {
                    if (Math.abs(dx) > mTouchSlop && Math.abs(dx) > Math.abs(dy)) {
                        mIsMoving = true;
                    }
                }
                break;
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                int distance = (int) (event.getRawX() - mInitX);
                mVelTracker.addMovement(event);
                mVelTracker.computeCurrentVelocity(100);
                //获取x方向上的速度
                float velocityX = mVelTracker.getXVelocity(pointId);

                Log.d(TAG, "mVelocityX is " + velocityX);
                if (mIsMoving) {
                    //假如为滑动手势，启动相应动画（右滑隐藏 左滑出现）
                    if (distance >= mContext.getResources().getDisplayMetrics().widthPixels / 5 || velocityX > 1000f) {
                        if (mViewGroup.getTranslationX() == 0) {
                            mValueAnimator.setIntValues(0, (int) mScreenWidth);
                            mValueAnimator.start();
                        }
                    } else if (distance < 0 - mContext.getResources().getDisplayMetrics().widthPixels / 5) {
                        if (mViewGroup.getTranslationX() > 0) {

                            mViewGroup.setLayoutAnimation(null);
                            mViewGroup.setTranslationX((int) mScreenWidth);
                            mViewGroup.setLayoutAnimation(mController);
                            mViewGroup.startLayoutAnimation();
                            mViewGroup.setTranslationX(0);
                        }

                    }
                    mIsMoving = false;
                }

                mInitX = 0;
                mInitY = 0;

                mVelTracker.clear();
                mVelTracker.recycle();
                break;
        }
        return true;
    }
}
