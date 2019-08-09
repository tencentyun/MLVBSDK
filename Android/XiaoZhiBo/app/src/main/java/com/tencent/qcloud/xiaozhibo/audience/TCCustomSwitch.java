package com.tencent.qcloud.xiaozhibo.audience;

import android.content.Context;
import android.graphics.drawable.AnimationDrawable;
import android.os.Handler;
import android.util.AttributeSet;
import android.widget.ImageView;

import com.tencent.qcloud.xiaozhibo.R;

/**
 * Module:   TCCustomSwitch
 *
 * Function: 带有动画的 Switch 类
 *
 */
public class TCCustomSwitch extends ImageView {
    private boolean mChecked = false;

    private AnimationDrawable mAniDraw;
    private Handler mAnimHandler;
    private Runnable mRunnable;

    private void init(){
        mAnimHandler = new Handler();
        mRunnable = new Runnable() {
            @Override
            public void run() {
                onAnimationFinish();
            }
        };
    }

    public TCCustomSwitch(Context context) {
        super(context);
        init();
    }

    public TCCustomSwitch(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public TCCustomSwitch(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public int getTotalDuration(AnimationDrawable anidraw){
        int iDuration = 0;
        for (int i=0; i<anidraw.getNumberOfFrames(); i++){
            iDuration += anidraw.getDuration(i);
        }
        return iDuration;
    }

    /**
     * 动画播放结束
     */
    private void onAnimationFinish(){
        if (mChecked) {
            setImageResource(R.drawable.btn_switch_on);
        }else{
            setImageResource(R.drawable.btn_switch_off);
        }
    }

    /**
     * 更新switch状态并播放动画
     * @param bCheck
     * @param bPlayAnim
     */
    public void setChecked(boolean bCheck, boolean bPlayAnim){
        if (bCheck == mChecked){
            return;
        }
        mChecked = bCheck;
        if (bPlayAnim) {
            setImageResource(mChecked ? R.drawable.switch_open : R.drawable.switch_close);
            mAniDraw = (AnimationDrawable) getDrawable();
            mAniDraw.start();
            mAnimHandler.postDelayed(mRunnable, getTotalDuration(mAniDraw));
        }else{
            onAnimationFinish();
        }
    }

    public boolean getChecked(){
        return mChecked;
    }
}
