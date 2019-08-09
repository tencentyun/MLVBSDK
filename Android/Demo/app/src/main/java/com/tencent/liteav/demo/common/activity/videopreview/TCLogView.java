package com.tencent.liteav.demo.common.activity.videopreview;

import android.content.Context;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.tencent.rtmp.TXLiveConstants;

import java.text.SimpleDateFormat;

/**
 * 用于先显示SDK log,上半部分显示状态,下半部分显示事件
 */
public class TCLogView extends LinearLayout{
    private TextView      mStatusTextView;
    private TextView      mEventTextView;
    private ScrollView    mStatusScrollView;
    private ScrollView    mEventScrollView;

    StringBuffer          mLogMsg = new StringBuffer("");
    private final int     mLogMsgLenLimit = 3000;

    private boolean       mDisableLog = false;

    public TCLogView(Context context) {
        this(context, null);
    }

    public TCLogView(Context context, AttributeSet attrs) {
        super(context, attrs);

        setOrientation(VERTICAL);

        mStatusTextView = new TextView(context);
        mEventTextView  = new TextView(context);
        mStatusScrollView = new ScrollView(context);
        mEventScrollView  = new ScrollView(context);

        LayoutParams statusScrollViewParams = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0);
        statusScrollViewParams.weight = 1.0f;
        mStatusScrollView.setLayoutParams(statusScrollViewParams);
        mStatusScrollView.setBackgroundColor(0x60ffffff);
        mStatusScrollView.setVerticalScrollBarEnabled(true);
        mStatusScrollView.setScrollbarFadingEnabled(true);

        LayoutParams statusParams = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        mStatusTextView.setLayoutParams(statusParams);
        mStatusTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11);
        mStatusTextView.setTypeface(Typeface.MONOSPACE, Typeface.BOLD);
        mStatusTextView.setPadding(dip2px(context, 2.0f), dip2px(context, 2.0f), dip2px(context, 2.0f), dip2px(context, 2.0f));

        mStatusScrollView.addView(mStatusTextView);

        LayoutParams scrollParams = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0);
        scrollParams.weight = 1.0f;
        mEventScrollView.setLayoutParams(scrollParams);
        mEventScrollView.setBackgroundColor(0x60ffffff);
        mEventScrollView.setVerticalScrollBarEnabled(true);
        mEventScrollView.setScrollbarFadingEnabled(true);

        FrameLayout.LayoutParams eventParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        mEventTextView.setLayoutParams(eventParams);
        mEventTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
        mEventTextView.setPadding(dip2px(context, 2.0f), dip2px(context, 2.0f), dip2px(context, 2.0f), dip2px(context, 2.0f));

        mEventScrollView.addView(mEventTextView);

        addView(mStatusScrollView);
        addView(mEventScrollView);
    }

    private int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    public void setLogText(Bundle status, Bundle event, int eventId) {
        if (mDisableLog/* || getVisibility() == GONE*/) {
            return;
        }

        if (status != null) {
            mStatusTextView.setText(getNetStatusString(status));
        }

        if (event != null) {
            String message = event.getString(TXLiveConstants.EVT_DESCRIPTION);
            if (message != null) {
                appendEventLog(eventId, message);
                mEventTextView.setText(mLogMsg.toString());
                scroll2Bottom(mEventScrollView, mEventTextView);
            }
        }
    }

    //公用打印辅助函数
    protected void appendEventLog(int event, String message) {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS");
        String date = sdf.format(System.currentTimeMillis());
        while(mLogMsg.length() >mLogMsgLenLimit ){
            int idx = mLogMsg.indexOf("\n");
            if (idx == 0)
                idx = 1;
            mLogMsg = mLogMsg.delete(0,idx);
        }
        mLogMsg = mLogMsg.append("\n" + "["+date+"]" + message);
    }

    //公用打印辅助函数
    protected String getNetStatusString(Bundle status) {
        String str = String.format("%-14s %-14s %-14s\n%-8s %-8s %-8s %-8s\n%-14s %-14s %-14s\n%-14s\n%-14s",
                "CPU:"+status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE),
                "RES:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH)+"*"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT),
                "SPD:"+status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED)+"Kbps",
                "JIT:"+status.getInt(TXLiveConstants.NET_STATUS_NET_JITTER),
                "FPS:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS),
                "GOP:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP)+"s",
                "ARA:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE)+"Kbps",
                "QUE:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE )+"|"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE),
                "DRP:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_DROP)+"|"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_DROP),
                "VRA:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE)+"Kbps",
                "SVR:"+status.getString(TXLiveConstants.NET_STATUS_SERVER_IP),
                "AUDIO:"+status.getString(TXLiveConstants.NET_STATUS_AUDIO_INFO));
        return str;
    }

    public void clearLog() {
        mLogMsg.setLength(0);
        mStatusTextView.setText("");
        mEventTextView.setText("");
    }

    public void show(boolean enable) {
        setVisibility(enable ? View.VISIBLE : View.GONE);
    }

    public void disableLog(boolean disable) {
        mDisableLog = disable;
    }

    private void scroll2Bottom(final ScrollView scroll, final View inner) {
        if (scroll == null || inner == null) {
            return;
        }
        int offset = inner.getMeasuredHeight() - scroll.getMeasuredHeight();
        if (offset < 0) {
            offset = 0;
        }
        scroll.scrollTo(0, offset);
    }
}
