package com.tencent.qcloud.xiaozhibo.videoeditor.bgm;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.videoeditor.Edit;
import com.tencent.qcloud.xiaozhibo.videoeditor.RangeSlider;


/**
 * Created by hanszhli on 2017/6/15.
 * <p>
 * 音频操作面板
 */
public class TCBGMEditView extends RelativeLayout implements RangeSlider.OnRangeChangeListener {

    private String TAG = TCBGMEditView.class.getSimpleName();

    private TCReversalSeekBar mTCReversalSeekBar;
    private TextView mTvTip, mTvDelete, mTvMusicName;
    private LinearLayout mLlMainPanel;
    private RelativeLayout mRlMusicInfo;
    private TCMusicChooseLayout mRlChoseMusic;
    private RangeSlider mRangeSlider;
    private long mDuration;
    private long mStartPos;
    private long mEndPos;

    private Edit.OnBGMChangeListener mBGMPanelEventListener;

    public TCBGMEditView(Context context) {
        super(context);

        init();
    }

    public TCBGMEditView(Context context, AttributeSet attrs) {
        super(context, attrs);

        init();
    }

    public TCBGMEditView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        init();
    }

    public void setIBGMPanelEventListener(Edit.OnBGMChangeListener listener) {
        mBGMPanelEventListener = listener;
    }

    private void init() {
        View.inflate(getContext(), R.layout.item_bgm_edit_view, this);
        initEditMusicView();
    }

    public float getProgress() {
        return mTCReversalSeekBar.getProgress();
    }


    private void initEditMusicView() {
        mTvTip = (TextView) findViewById(R.id.bgm_tv_tip);
        mTvMusicName = (TextView) findViewById(R.id.bgm_tv_music_name);
        mTvDelete = (TextView) findViewById(R.id.bgm_tv_delete);
        mTvDelete.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mLlMainPanel.setVisibility(GONE);
                mRlChoseMusic.setVisibility(VISIBLE);
                if (mBGMPanelEventListener != null) {
                    mBGMPanelEventListener.onBGMDelete();
                }
            }
        });
        mRlMusicInfo = (RelativeLayout) findViewById(R.id.bgm_rl_bgm_info);
        mRlMusicInfo.setVisibility(GONE);

        mRangeSlider = (RangeSlider) findViewById(R.id.bgm_range_slider);
        mRangeSlider.setRangeChangeListener(this);

        mLlMainPanel = (LinearLayout) findViewById(R.id.bgm_ll_main_panel);
        mRlChoseMusic = (TCMusicChooseLayout) findViewById(R.id.bgm_rl_chose);
        mRlChoseMusic.setOnItemClickListener(new TCMusicAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                boolean success = setBGMInfo(mRlChoseMusic.getMusicList().get(position));
                if (success) {
                    mRlChoseMusic.setVisibility(GONE);
                    mLlMainPanel.setVisibility(VISIBLE);
                }
            }
        });
        mTCReversalSeekBar = (TCReversalSeekBar) findViewById(R.id.bgm_sb_voice);
        mTCReversalSeekBar.setOnSeekProgressListener(new TCReversalSeekBar.OnSeekProgressListener() {
            @Override
            public void onSeekDown() {

            }

            @Override
            public void onSeekUp() {

            }

            @Override
            public void onSeekProgress(float progress) {
                if (mBGMPanelEventListener != null) {
                    mBGMPanelEventListener.onBGMSeekChange(progress);
                }
            }
        });
    }


    public long getSegmentFrom() {
        return mStartPos;
    }

    public long getSegmentTo() {
        return mEndPos;
    }

    public boolean setBGMInfo(TCBGMInfo bgmInfo) {
        if (bgmInfo == null) {
            return false;
        }
        mRlMusicInfo.setVisibility(VISIBLE);
        mDuration = bgmInfo.getDuration();
        mStartPos = 0;
        mEndPos = (int) mDuration;
        mTvMusicName.setText(bgmInfo.getSongName() + " — " + bgmInfo.getSingerName() + "   " + bgmInfo.getFormatDuration());


        resetViews();
        if (mBGMPanelEventListener != null) {
            return mBGMPanelEventListener.onBGMInfoSetting(bgmInfo);
        }
        return false;
    }


    /**
     * 重置游标以及Tips
     */
    private void resetViews() {
        mRangeSlider.resetRangePos();
        mTvTip.setText("截取所需音频片段");
    }


    @Override
    public void onKeyDown(int type) {
        if (mBGMPanelEventListener != null) {
            mBGMPanelEventListener.onBGMRangeKeyDown();
        }
    }


    @Override
    public void onKeyUp(int type, int leftPinIndex, int rightPinIndex) {
        long leftTime = mDuration * leftPinIndex / 100; //ms
        long rightTime = mDuration * rightPinIndex / 100;

        if (type == RangeSlider.TYPE_LEFT) {
            mStartPos = leftTime;
        } else {
            mEndPos = rightTime;
        }
        if (mBGMPanelEventListener != null) {
            mBGMPanelEventListener.onBGMRangeKeyUp( mStartPos,  mEndPos);
        }
        mTvTip.setText(String.format("左侧 : %s, 右侧 : %s ", TCUtils.duration(leftTime), TCUtils.duration(rightTime)));
    }
}
