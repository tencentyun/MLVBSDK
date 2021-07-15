package com.tencent.mlvb.common;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RadioGroup;

/**
 * 实现自动换行的RadioGroup
 */
public class FlowRadioGroup extends RadioGroup {
    public FlowRadioGroup(Context context) {
        super(context);
    }

    public FlowRadioGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        int heightSize = MeasureSpec.getSize(heightMeasureSpec);
        int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        measureChildren(widthMeasureSpec, heightMeasureSpec);

        int maxWidth = 0;
        int totalHeight = 0;
        int lineWidth = 0;
        int maxLineHeight = 0;
        int oldHeight;
        int oldWidth;

        int count = getChildCount();
        for (int i = 0; i < count; i++) {
            View child = getChildAt(i);
            MarginLayoutParams params = (MarginLayoutParams) child.getLayoutParams();
            oldHeight = maxLineHeight;
            oldWidth = maxWidth;

            int deltaX = child.getMeasuredWidth() + params.leftMargin + params.rightMargin;
            if (lineWidth + deltaX + getPaddingLeft() + getPaddingRight() > widthSize) {
                maxWidth = Math.max(lineWidth, oldWidth);
                lineWidth = deltaX;
                totalHeight += oldHeight;
                maxLineHeight = child.getMeasuredHeight() + params.topMargin + params.bottomMargin;

            } else {
                lineWidth += deltaX;
                int deltaY = child.getMeasuredHeight() + params.topMargin + params.bottomMargin;
                maxLineHeight = Math.max(maxLineHeight, deltaY);
            }
            if (i == count - 1) {
                totalHeight += maxLineHeight;
                maxWidth = Math.max(lineWidth, oldWidth);
            }
        }
        maxWidth += getPaddingLeft() + getPaddingRight();
        totalHeight += getPaddingTop() + getPaddingBottom();
        setMeasuredDimension(widthMode == MeasureSpec.EXACTLY ? widthSize : maxWidth,
                heightMode == MeasureSpec.EXACTLY ? heightSize : totalHeight);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        int count = getChildCount();
        int preLeft = getPaddingLeft();
        int preTop = getPaddingTop();
        int maxHeight = 0;
        for (int i = 0; i < count; i++) {
            View child = getChildAt(i);
            MarginLayoutParams params = (MarginLayoutParams) child.getLayoutParams();
            if (preLeft + params.leftMargin + child.getMeasuredWidth() + params.rightMargin + getPaddingRight() > (r - l)) {
                preLeft = getPaddingLeft();
                preTop = preTop + maxHeight;
                maxHeight = getChildAt(i).getMeasuredHeight() + params.topMargin + params.bottomMargin;
            } else {
                maxHeight = Math.max(maxHeight, child.getMeasuredHeight() + params.topMargin + params.bottomMargin);
            }
            int left = preLeft + params.leftMargin;
            int top = preTop + params.topMargin;
            int right = left + child.getMeasuredWidth();
            int bottom = top + child.getMeasuredHeight();
            child.layout(left, top, right, bottom);
            preLeft += params.leftMargin + child.getMeasuredWidth() + params.rightMargin;
        }
    }
}
