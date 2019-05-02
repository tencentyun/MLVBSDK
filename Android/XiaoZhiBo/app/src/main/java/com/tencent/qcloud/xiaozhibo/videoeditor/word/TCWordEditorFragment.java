package com.tencent.qcloud.xiaozhibo.videoeditor.word;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.videoeditor.word.widget.FloatTextProgressBar;
import com.tencent.qcloud.xiaozhibo.videoeditor.word.widget.RangeSeekBar;
import com.tencent.qcloud.xiaozhibo.videoeditor.word.widget.TCOperationViewGroup;
import com.tencent.qcloud.xiaozhibo.videoeditor.word.widget.TCWordOperationView;
import com.tencent.ugc.TXVideoEditConstants;
import com.tencent.ugc.TXVideoEditer;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static android.view.View.GONE;

/**
 * 视频添加字幕的页面
 * <p>
 * hanszhli
 */
public class TCWordEditorFragment extends Fragment implements
        WordAdapter.OnItemClickListener, RangeSeekBar.OnRangeProgressListener,
        View.OnClickListener, TXVideoEditer.TXVideoPreviewListener,
        TCWordOperationView.IWordClickListener, TCWordInputFragment.OnWordInputListener {

    private static final String TAG = TCWordEditorFragment.class.getSimpleName();

    //================================== 播放控制相关 ============================
    private static final int STATE_NONE = 0;
    private static final int STATE_PAUSE = 1;
    private static final int STATE_PLAY = 2;
    private int mCurrentState = STATE_PAUSE;

    private TCWordInputFragment mWordInputFragment;  //输入字幕的fragment

    //==================================SDK相关==================================
    private TXVideoEditer mTXVideoEditer;
    private List<TXVideoEditConstants.TXSubtitle> mSubtitleList;
    private FrameLayout mLayoutPlayer;
    private int mEndTime;
    private int mStartTime;
    private int mDuration;
    private float mSpeedLevel = 1.0f;

    //==================================头布局===================================
    private LinearLayout mLlBack;
    private TextView mTvSave;

    //==================================中部字幕移动布局===========================
    private TCOperationViewGroup mOperationViewGroup;//字幕父布局

    //==================================播放布局==================================
    private TextView mTvTips;
    private ImageView mIvPlay;
    private TextView mTvTime;
    private FloatTextProgressBar mPlayerProgress;
    private RangeSeekBar mRangeSeekBar;

    //==================================底部字幕布局==============================
    private RecyclerView mRvWord;
    private WordAdapter mWordAdapter;
    private List<TCWordInfo> mWordInfoList;


    public static TCWordEditorFragment newInstance(TXVideoEditer txVideoEditer,
                                                   int startTime, int endTime) {
        TCWordEditorFragment fragment = new TCWordEditorFragment();
        fragment.mTXVideoEditer = txVideoEditer;
        fragment.mStartTime = startTime;
        fragment.mEndTime = endTime;
        fragment.mDuration = endTime - startTime;
        return fragment;
    }

    public void setVideoRangeTime(int startTime, int endTime) {
        mStartTime = startTime;
        mEndTime = endTime;
        mDuration = mEndTime - mStartTime;
        checkSubTitleAndViewListForTime();
    }

    /**
     * 检测当前字幕是否符合当前的时间
     */
    private void checkSubTitleAndViewListForTime() {
        if (mSubtitleList != null) {
            Iterator<TXVideoEditConstants.TXSubtitle> iterator = mSubtitleList.listIterator();
            int index = -1;
            while (iterator.hasNext()) {
                index++;
                TXVideoEditConstants.TXSubtitle subtitle = iterator.next();
                TCWordInfo tcWordInfo = mWordInfoList.get(index);
                //如果起止时间都小于开始时间 那么直接移除
                if (subtitle.startTime < mStartTime && subtitle.endTime < mStartTime) {
                    iterator.remove();
                    mWordInfoList.remove(index);
                    mOperationViewGroup.removeOperationView(mOperationViewGroup.getOperationView(index));
                    continue;
                }
                if (subtitle.startTime < mStartTime) {
                    subtitle.startTime = mStartTime;
                    tcWordInfo.setStartTime(mStartTime);
                }
                if (subtitle.endTime > mEndTime) {
                    subtitle.endTime = mEndTime;
                    tcWordInfo.setEndTime(mEndTime);
                }
            }
        }
    }


    public void setSpeedLevel(float speedLevel) {
        mSpeedLevel = speedLevel;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.activity_word_editor, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initData();
        initViews(view);
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        if (!hidden) {
            requestBackKeyListener();
            //因为当下一次进入的时候，视频是直接进行播放的
            //所以不处于编辑状态，那么重置之前留下的状态
            if (mWordInputFragment == null || !mWordInputFragment.isAdded()) {
                mWordAdapter.resetCurSelectedPos(-1);//重置字幕的选中状态
                mTvTips.setVisibility(GONE);
                initPlayer();
                play();
            }
        } else {

        }
    }

    private void initPlayer() {
        mTXVideoEditer.stopPlay();
        TXVideoEditConstants.TXPreviewParam param = new TXVideoEditConstants.TXPreviewParam();
        param.videoView = mLayoutPlayer;
        param.renderMode = TXVideoEditConstants.PREVIEW_RENDER_MODE_FILL_EDGE;
        mTXVideoEditer.initWithPreview(param);

        mTvTime.setText(TCUtils.duration((mDuration)));
    }

    private void initViews(View view) {
        mLlBack = (LinearLayout) view.findViewById(R.id.back_ll);
        mLlBack.setOnClickListener(this);

        mRvWord = (RecyclerView) view.findViewById(R.id.word_rv_word);
        LinearLayoutManager layout = new LinearLayoutManager(getActivity());
        layout.setOrientation(LinearLayout.HORIZONTAL);
        mRvWord.setLayoutManager(layout);

        mWordInfoList = new ArrayList<>();
        mWordAdapter = new WordAdapter(getActivity(), mWordInfoList);
        mWordAdapter.setOnItemClickListener(this);
        mRvWord.setAdapter(mWordAdapter);

        mRangeSeekBar = (RangeSeekBar) view.findViewById(R.id.word_sb_bar);
        mRangeSeekBar.setOnRangeProgressListener(this);
        mRangeSeekBar.setVisibility(GONE);

        mOperationViewGroup = (TCOperationViewGroup) view.findViewById(R.id.word_rl_container);

        mLayoutPlayer = (FrameLayout) view.findViewById(R.id.word_fl_video_view);

        mIvPlay = (ImageView) view.findViewById(R.id.btn_play);
        mIvPlay.setOnClickListener(this);
        mTvTime = (TextView) view.findViewById(R.id.word_tv_time);
        mTvSave = (TextView) view.findViewById(R.id.btn_done);
        mTvSave.setOnClickListener(this);

        mPlayerProgress = (FloatTextProgressBar) view.findViewById(R.id.pb_player);

        mTvTips = (TextView) view.findViewById(R.id.word_tv_tip);
        mTvTips.setVisibility(GONE);
    }

    private void initData() {
        mSubtitleList = new ArrayList<TXVideoEditConstants.TXSubtitle>();
        mCurrentState = STATE_NONE;
    }

    private void notifyRecyclerView(TCWordInfo info) {
        int pos = info.getPosIndex();
        mWordInfoList.set(pos, info);

        mWordAdapter.notifyItemChanged(pos + 1);//+1的原因是因为有个+号在最前面
        //滑动到最后
        mRvWord.smoothScrollToPosition(mWordInfoList.size() - 1);
//        changeCurSelectedPos(pos);
    }

    private void notifyOperationView(TCWordInfo info) {
        int index = info.getPosIndex();
        Log.d("edit", "index:" + index);
        TCWordOperationView view = (TCWordOperationView) mOperationViewGroup.getChildAt(index);
        view.setImageBitamp(info.getBitmap());
    }

    /**
     * 添加字幕到 载体中去
     */
    private void addWordOperationView(TCWordInfo wordInfo) {
        Log.d("seq", "parent w:" + mOperationViewGroup.getWidth() + ",h:" + mOperationViewGroup.getHeight());
        TCWordOperationView view = TCWordOperationViewFactory.newOperationView(getActivity());
        view.setParentWidth(mOperationViewGroup.getWidth());
        view.setParentHeight(mOperationViewGroup.getHeight());
        view.setIWordClickListener(this);
        view.setImageBitamp(wordInfo.getBitmap());
        mOperationViewGroup.addOperationView(view);

        wordInfo.setX(view.getImageX());
        wordInfo.setY(view.getImageY());
        wordInfo.setWidth(view.getImageWidth());
    }


    /**
     * 添加字幕到 字幕列表中去
     *
     * @param wordInfo
     */
    private void addWordToRecyclerView(TCWordInfo wordInfo) {
        mWordInfoList.add(wordInfo);
        int size = mWordInfoList.size();
        //刷新最后一个item
        mWordAdapter.notifyItemChanged(size - 1);
        //滑动到最后
        mRvWord.smoothScrollToPosition(size);
        //选中当前字幕
        changeCurSelectedPos(size - 1);
    }

    /**
     * 字幕的RecyclerView的回调
     *
     * @param view
     * @param pos
     */
    @Override
    public void onClickItem(View view, int pos) {
        mOperationViewGroup.setVisibility(View.VISIBLE);
        mPlayerProgress.setVisibility(GONE);
        mRangeSeekBar.setVisibility(View.VISIBLE);
        if (mCurrentState == STATE_PLAY) {
            mCurrentState = STATE_PAUSE;
            mTXVideoEditer.pausePlay();
        }
        mTXVideoEditer.refreshOneFrame();//刷新一帧不带有字幕的原始图像
        mIvPlay.setImageResource(R.drawable.icon_word_play);
        if (pos == -1) { // 点击了+号
            showInputFragment(null);//添加字幕
        } else {
            if (pos != mWordAdapter.getCurrentSelectedPos())
                mOperationViewGroup.selectedOperationView(pos); //选中操作的View
            else {
                mOperationViewGroup.unSelectedOperationView(pos);
            }
            //重新设置当前选中的位置
            changeCurSelectedPos(pos);
        }
    }

    private void stopPlay() {
        mTXVideoEditer.stopPlay();
        mCurrentState = STATE_PAUSE;
        mIvPlay.setImageResource(R.drawable.icon_word_play);
        mTXVideoEditer.setTXVideoPreviewListener(null);
    }

    /**
     * 1.改变当前选中的Pos
     * 2.判定当前是否有选中的字幕， 有则显示Range区间，没有则不显示
     *
     * @param pos
     */
    private void changeCurSelectedPos(int pos) {
        if (pos == mWordAdapter.getCurrentSelectedPos()) {
            mTvTips.setText("选择需要编辑的字幕");
        } else {
            showRelativeTime(mWordInfoList.get(pos).getStartTime(), mWordInfoList.get(pos).getEndTime());
        }
        mTvTips.setVisibility(View.VISIBLE);
        mWordAdapter.resetCurSelectedPos(pos);
        int selectPos = mWordAdapter.getCurrentSelectedPos();
        if (selectPos == -1) { // 选中加号
            mRangeSeekBar.setVisibility(GONE);
            return;
        }
        mRangeSeekBar.setVisibility(View.VISIBLE);

        if (mDuration != 0) {
            int leftIndex = (mWordInfoList.get(pos).getStartTime() - mStartTime) * 100 / mDuration;
            int rightIndex = (mWordInfoList.get(pos).getEndTime() - mStartTime) * 100 / mDuration;
            mRangeSeekBar.setLeftIndex(leftIndex);
            mRangeSeekBar.setRightIndex(rightIndex);
        }
    }

    @Override //lp为left pointer rp为right pointer progress代表着两点当前所在的位置
    public void onSeekProgress(int startProgress, int endProgress) {
        Log.d("zimu", "onSeekProgress : startProgress :" + startProgress + ",endProgress :" + endProgress); //百分比
        int leftTime = (int) (mDuration * startProgress / 100); //ms
        int rightTime = (int) (mDuration * endProgress / 100);

        showRelativeTime(leftTime + mStartTime, rightTime + mStartTime);


        int pos = mWordAdapter.getCurrentSelectedPos();
        if (pos >= 0 && mWordInfoList.size() - 1 >= pos) {
            TCWordInfo wordInfo = mWordInfoList.get(pos);
            wordInfo.setStartTime(leftTime + mStartTime);//设置为绝对时间
            wordInfo.setEndTime(rightTime + mStartTime);//设置为绝对时间
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.back_ll:
//                mTXVideoEditer.stopPlay();
//                mTXVideoEditer.setTXVideoPreviewListener(null);
                mCurrentState = STATE_NONE;
                if (mOnWordEditorListener != null) {
                    stopPlay();
                    mOnWordEditorListener.onWordEditCancel();
                }
                break;
            case R.id.btn_done:
                save();
                if (mOnWordEditorListener != null) {
                    stopPlay();
                    mOnWordEditorListener.onWordEditFinish();
                }
                break;
            case R.id.btn_play:
                //将选中的去掉
                changeCurSelectedPos(mWordAdapter.getCurrentSelectedPos());

                play();
                break;
        }
    }

    private void play() {
        mRangeSeekBar.setVisibility(GONE);
        mPlayerProgress.setVisibility(View.VISIBLE);
        mTvTips.setVisibility(GONE);
        if (mCurrentState == STATE_PAUSE || mCurrentState == STATE_NONE) {
            stopPlay();
            addSubtitle();
            mTXVideoEditer.setTXVideoPreviewListener(this);
            mTXVideoEditer.startPlayFromTime(mStartTime, mEndTime);
            mCurrentState = STATE_PLAY;
            mIvPlay.setImageResource(R.drawable.icon_word_pause);
        } else {
            mTXVideoEditer.pausePlay();
            mCurrentState = STATE_PAUSE;
            mIvPlay.setImageResource(R.drawable.icon_word_play);
        }
    }

    /**
     * 保存字幕
     */
    private void save() {
        mSubtitleList.clear();
        for (int i = 0; i < mWordInfoList.size(); i++) {
            TCWordOperationView view = mOperationViewGroup.getOperationView(i);
            TXVideoEditConstants.TXSubtitle subTitle = new TXVideoEditConstants.TXSubtitle();
            subTitle.titleImage = view.getRotateBitmap();

            TXVideoEditConstants.TXRect rect = new TXVideoEditConstants.TXRect();
            rect.x = view.getImageX();
            rect.y = view.getImageY();

            rect.width = view.getImageWidth();
            subTitle.frame = rect;
            subTitle.startTime = mWordInfoList.get(i).getStartTime();
            subTitle.endTime = mWordInfoList.get(i).getEndTime();
            mSubtitleList.add(subTitle);
        }
        mTXVideoEditer.setSubtitleList(mSubtitleList);
    }


    @Override
    public void onResume() {
        super.onResume();
        Log.d("seq", "onResume");
        requestBackKeyListener();
    }

    private void requestBackKeyListener() {
        getView().setFocusableInTouchMode(true);
        getView().requestFocus();
        getView().setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
                    // 监听到返回按钮点击事件
                    if (mOnWordEditorListener != null) {
                        stopPlay();
                        mOnWordEditorListener.onWordEditCancel();
                    }
                    return true;
                }
                return false;
            }
        });
    }


    private void addSubtitle() {
        save();
        mOperationViewGroup.setVisibility(View.INVISIBLE);
    }

    @Override
    public void onPreviewProgress(int time) {
        mPlayerProgress.setProgress((int) (time / 1000 * mSpeedLevel - mStartTime), mDuration);
    }

    @Override
    public void onPreviewFinished() {
        mPlayerProgress.setProgress(mDuration, mDuration);
        mCurrentState = STATE_PAUSE;
        play();
    }

    @Override
    public void onStart() {
        super.onStart();
        if (!isHidden() && (mWordInputFragment == null || !mWordInputFragment.isAdded())) {
            initPlayer();
            play();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if (!isHidden()) {
            stopPlay();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
//        stopPlay();
    }

    //-----------------------------------------operationView的三个按钮回调----------------
    @Override
    public void onDeleteClick() {
        int pos = mOperationViewGroup.getSelectedPos();

        TCWordOperationView view = mOperationViewGroup.getSelectedOperationView();
        mOperationViewGroup.removeOperationView(view);

        mWordInfoList.remove(pos);
        if (mSubtitleList.size() > pos) { //新创建出来的OPView可能还未保存到Subtitle list中去，需要进行判定
            mSubtitleList.remove(pos);
            mTXVideoEditer.setSubtitleList(mSubtitleList);
        }
        mWordAdapter.notifyDataSetChanged();


    }

    @Override
    public void onEditClick() {
        int pos = mOperationViewGroup.getSelectedPos();
        Log.d("edit", "pos:" + pos);
        if (mCurrentState == STATE_PLAY) {
            mCurrentState = STATE_PAUSE;
            mTXVideoEditer.pausePlay();
        }
        TCWordInfo wordInfo = mWordInfoList.get(pos);
        showInputFragment(wordInfo);
    }


    public void showInputFragment(TCWordInfo info) {
        if (info == null) {
            mWordInputFragment = TCWordInputFragment.newInstance();
        } else {
            mWordInputFragment = TCWordInputFragment.newInstance(info);
        }
        mWordInputFragment.setOnWordInputListener(this);
        getChildFragmentManager()
                .beginTransaction()
                .replace(R.id.word_fl_input_container, mWordInputFragment, "input_fragment")
                .addToBackStack(null)
                .commit();

    }

    public void removeInputFragment() {
        if (mWordInputFragment != null && mWordInputFragment.isAdded()) {
            getChildFragmentManager().popBackStack();
            mWordInputFragment.setOnWordInputListener(null);
        }
    }

    @Override
    public void onRotateClick() {

    }
    //-----------------------------------------operationView的三个按钮回调----------------


    //------------------------字幕编辑TCWordInputFragment的回调--------------------
    @Override
    public void onEditFinish(TCWordInfo info) {
        if (info != null) {
            notifyOperationView(info);
            notifyRecyclerView(info);
        }
    }

    @Override
    public void onNewInputFinish(TCWordInfo info) {
        if (info != null) {
            int startTime = mStartTime;
            int endTime = mStartTime + mDuration / 10;
            info.setStartTime(startTime);
            info.setEndTime(endTime);
            showRelativeTime(startTime, endTime);
            info.setPosIndex(mWordInfoList.size());//分配index
            addWordOperationView(info);
            addWordToRecyclerView(info);
        }
    }

    /**
     * 这里显示的是相对时间， 而不是绝对时间
     *
     * @param absoluteStartTime 绝对时间
     * @param absoluteEndTime   绝对时间
     */
    private void showRelativeTime(int absoluteStartTime, int absoluteEndTime) {
        mTvTips.setText(String.format("左侧 : %s, 右侧 : %s ", TCUtils.duration(absoluteStartTime - mStartTime), TCUtils.duration(absoluteEndTime - mStartTime)));

    }

    @Override
    public void onCancelClick() {
        removeInputFragment();
        mRangeSeekBar.setVisibility(View.GONE);

    }

    @Override
    public void onDoneClick() {
        removeInputFragment();
    }
    //------------------------字幕编辑TCWordInputFragment的回调--------------------


    private OnWordEditorListener mOnWordEditorListener;

    public void setOnWordEditorListener(OnWordEditorListener listener) {
        mOnWordEditorListener = listener;
    }

    public interface OnWordEditorListener {
        void onWordEditCancel();

        void onWordEditFinish();
    }
}
