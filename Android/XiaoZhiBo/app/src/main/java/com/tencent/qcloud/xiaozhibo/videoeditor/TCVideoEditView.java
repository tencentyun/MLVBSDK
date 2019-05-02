package com.tencent.qcloud.xiaozhibo.videoeditor;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.rtmp.TXLog;
import com.tencent.ugc.TXVideoEditConstants;

public class TCVideoEditView extends RelativeLayout implements RangeSlider.OnRangeChangeListener {

    private String TAG = TCVideoEditView.class.getSimpleName();

    private Context mContext;

    private TextView mTvTip;
    private RecyclerView mRecyclerView;
    private RangeSlider mRangeSlider;

    private long mVideoDuration;
    private long mVideoStartPos;
    private long mVideoEndPos;

    private TCVideoEditerAdapter mAdapter;

    private Edit.OnCutChangeListener mRangeChangeListener;

    public TCVideoEditView(Context context) {
        super(context);

        init(context);
    }

    public TCVideoEditView(Context context, AttributeSet attrs) {
        super(context, attrs);

        init(context);
    }

    public TCVideoEditView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        init(context);
    }

    private void init(Context context) {
        mContext = context;

        LayoutInflater inflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        inflater.inflate(R.layout.item_edit_view, this, true);

        mTvTip = (TextView) findViewById(R.id.tv_tip);

        mRangeSlider = (RangeSlider) findViewById(R.id.range_slider);
        mRangeSlider.setRangeChangeListener(this);

        mRecyclerView = (RecyclerView) findViewById(R.id.recycler_view);
        LinearLayoutManager manager = new LinearLayoutManager(mContext);
        manager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRecyclerView.setLayoutManager(manager);

        mAdapter = new TCVideoEditerAdapter(mContext);
        mRecyclerView.setAdapter(mAdapter);
    }

    /**
     * 设置裁剪Listener
     *
     * @param listener
     */
    public void setCutChangeListener(Edit.OnCutChangeListener listener) {
        mRangeChangeListener = listener;
    }

    public int getSegmentFrom() {
        return (int) mVideoStartPos;
    }

    public int getSegmentTo() {
        return (int) mVideoEndPos;
    }

    public void setMediaFileInfo(TXVideoEditConstants.TXVideoInfo videoInfo) {
        if (videoInfo == null) {
            return;
        }
        mVideoDuration = videoInfo.duration;

        mVideoStartPos = 0;
        mVideoEndPos = mVideoDuration;
    }

    public void addBitmap(int index, Bitmap bitmap) {
        mAdapter.add(index, bitmap);
    }

    @Override
    public void onKeyDown(int type) {
        if (mRangeChangeListener != null) {
            mRangeChangeListener.onCutChangeKeyDown();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (mAdapter != null) {
            TXLog.i(TAG, "onDetachedFromWindow: 清除所有bitmap");
            mAdapter.recycleAllBitmap();
        }
    }

    @Override
    public void onKeyUp(int type, int leftPinIndex, int rightPinIndex) {
        int leftTime = (int) (mVideoDuration * leftPinIndex / 100); //ms
        int rightTime = (int) (mVideoDuration * rightPinIndex / 100);

        if (type == RangeSlider.TYPE_LEFT) {
            mVideoStartPos = leftTime;
        } else {
            mVideoEndPos = rightTime;
        }
        if (mRangeChangeListener != null) {
            mRangeChangeListener.onCutChangeKeyUp((int) mVideoStartPos, (int) mVideoEndPos);
        }
        mTvTip.setText(String.format("左侧 : %s, 右侧 : %s ", TCUtils.duration(leftTime), TCUtils.duration(rightTime)));
    }

}
