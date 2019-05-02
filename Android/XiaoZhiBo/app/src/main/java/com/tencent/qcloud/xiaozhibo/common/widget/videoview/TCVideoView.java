package com.tencent.qcloud.xiaozhibo.common.widget.videoview;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import com.tencent.rtmp.ui.TXCloudVideoView;

/**
 * TCVideoView在TXCloudVideoView上面叠加一个logview,用于显示sdk 内部状态及事件
 */
public class TCVideoView extends TXCloudVideoView {

    private TCLogView mTXLogView = null;
    private Context mContext;

    public TCVideoView(Context context) {
		this(context,null);
	}

	public TCVideoView(Context context, AttributeSet attrs) {
		super(context,attrs);
        mContext = context;
        mTXLogView = new TCLogView(context);
        addView(mTXLogView, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        mTXLogView.setVisibility(GONE);
	}

    //--------------------------下面的代码用于在视频浮层显示Log和事件------------------------
    public void disableLog(boolean disable) {
        //mTXLogView.disableLog(disable);

        disableLog(disable, true);
    }

    public void disableLog(boolean disable, boolean padding) {
        if (mTXLogView != null) {
            if (disable) {
                mTXLogView.setVisibility(GONE);
            } else {
                removeView(mTXLogView);
                float scale = mContext.getResources().getDisplayMetrics().density;
                FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
                if (padding) {
                    params.topMargin = (int) (45 * scale + 0.5);
                    params.bottomMargin = (int) (55 * scale + 0.5);
                    params.leftMargin = (int) (10 * scale + 0.5);
                    params.rightMargin = (int) (10 * scale + 0.5);
                }
                addView(mTXLogView, params);
                mTXLogView.setVisibility(VISIBLE);
            }
        }
    }

    public void clearLog() {
        if (mTXLogView != null) {
            mTXLogView.clearLog();
        }
    }

    public void setLogText(Bundle status, Bundle event, int eventId) {
        if (mTXLogView != null) {
            mTXLogView.setLogText(status, event, eventId);
        }
    }
}
