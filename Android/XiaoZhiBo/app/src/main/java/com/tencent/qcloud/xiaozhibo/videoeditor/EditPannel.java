package com.tencent.qcloud.xiaozhibo.videoeditor;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.videoeditor.bgm.TCBGMEditView;
import com.tencent.qcloud.xiaozhibo.videoeditor.bgm.TCBGMInfo;
import com.tencent.qcloud.xiaozhibo.videoeditor.word.widget.TCWordEditView;
import com.tencent.ugc.TXVideoEditConstants;

import java.util.ArrayList;

/**
 * 总的控制面盘
 * <p>
 * 包含：裁剪 滤镜 BGM调理 字幕
 */
public class EditPannel extends LinearLayout implements View.OnClickListener {
    private static final String TAG = "EditPannel";
    public static final int CMD_SPEED = 1;
    public static final int CMD_FILTER = 2;
    /***********************各个接口的回调************************/
    private Edit.OnCutChangeListener mOnCutChangeListener;
    private Edit.OnSpeedChangeListener mOnSpeedChangeListener;
    private Edit.OnFilterChangeListener mOnFilterChangeListener;
    private Edit.OnBGMChangeListener mOnBGMChangeListener;
    private Edit.OnWordChangeListener mOnWordChangeListener;

    private TCVideoEditView mCutView;                           // 裁剪模块的View
    private TCBGMEditView mBGMEditView;                         // BGM模块的View
    private TCWordEditView mWordEditView;                       // 添加字幕的View
    private TCHorizontalScrollView mFilterSV;                   // 滤镜的View
    private ArrayAdapter<Integer> mFilterAdapter;               // 滤镜的Adapter

    private LinearLayout mCutLL, mFilterLL, mBgmLL, mWordLL;    // 上述各个View的载体 用于控制显示隐藏

    private ImageButton mCutBtn, mFilterBtn, mBgmBtn, mWordBtn; // 底部的按钮

    private CheckBox mSpeedCB;                                  // 开启or关闭加速的按钮


    private Context mContext;

    public EditPannel(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        init();
    }

    private void init() {
        View view = LayoutInflater.from(mContext).inflate(R.layout.edit_pannel, this);
        mCutLL = (LinearLayout) view.findViewById(R.id.cut_ll);
        mFilterLL = (LinearLayout) view.findViewById(R.id.filter_ll);
        mBgmLL = (LinearLayout) view.findViewById(R.id.bgm_ll);
        mWordLL = (LinearLayout) view.findViewById(R.id.word_ll);

        mBGMEditView = (TCBGMEditView) view.findViewById(R.id.panel_bgm_edit);
        mWordEditView = (TCWordEditView) view.findViewById(R.id.panel_word_edit);
        mCutView = (TCVideoEditView) view.findViewById(R.id.editView);
        mFilterSV = (TCHorizontalScrollView) view.findViewById(R.id.filter_sv);
        mCutBtn = (ImageButton) view.findViewById(R.id.btn_cut);
        mBgmBtn = (ImageButton) view.findViewById(R.id.btn_music);
        mFilterBtn = (ImageButton) view.findViewById(R.id.btn_filter);
        mWordBtn = (ImageButton) view.findViewById(R.id.btn_word);
        mSpeedCB = (CheckBox) view.findViewById(R.id.cb_speed);

        mCutLL.setVisibility(VISIBLE);
        mFilterLL.setVisibility(GONE);

        mCutBtn.setOnClickListener(this);
        mFilterBtn.setOnClickListener(this);
        mBgmBtn.setOnClickListener(this);
        mWordBtn.setOnClickListener(this);
        mSpeedCB.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mSpeedCB.setSelected(isChecked);
                if (mOnSpeedChangeListener != null) {
                    mOnSpeedChangeListener.onSpeedChange(isChecked ? 2 : 1);
                }
            }
        });

        initFilter();
    }

    private void initFilter() {
        final ArrayList<Integer> filterIDList = new ArrayList<Integer>();
        filterIDList.add(R.drawable.orginal);
        filterIDList.add(R.drawable.langman);
        filterIDList.add(R.drawable.qingxin);
        filterIDList.add(R.drawable.weimei);
        filterIDList.add(R.drawable.fennen);
        filterIDList.add(R.drawable.huaijiu);
        filterIDList.add(R.drawable.landiao);
        filterIDList.add(R.drawable.qingliang);
        filterIDList.add(R.drawable.rixi);
        mFilterAdapter = new ArrayAdapter<Integer>(mContext, 0, filterIDList) {

            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                if (convertView == null) {
                    LayoutInflater inflater = LayoutInflater.from(getContext());
                    convertView = inflater.inflate(R.layout.filter_layout, null);
                }
                ImageView view = (ImageView) convertView.findViewById(R.id.filter_image);
                if (position == 0) {
                    ImageView view_tint = (ImageView) convertView.findViewById(R.id.filter_image_tint);
                    if (view_tint != null)
                        view_tint.setVisibility(View.VISIBLE);
                }
                view.setTag(position);
                view.setImageDrawable(getResources().getDrawable(getItem(position)));
                view.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        int index = (int) view.getTag();
                        selectFilter(index);
                        if (mOnFilterChangeListener != null) {
                            Bitmap bmp = getFilterBitmap(index);
                            mOnFilterChangeListener.onFilterChange(bmp);
                        }
                    }
                });
                return convertView;
            }
        };
        mFilterSV.setAdapter(mFilterAdapter);
    }

    public float getBGMVolumeProgress() {
        return mBGMEditView.getProgress();
    }

    /**
     * 设置裁剪Listener
     *
     * @param listener
     */
    public void setCutChangeListener(Edit.OnCutChangeListener listener) {
        mOnCutChangeListener = listener;
        mCutView.setCutChangeListener(listener);

    }

    /**
     * 设置加速Listener
     *
     * @param listener
     */
    public void setSpeedChangeListener(Edit.OnSpeedChangeListener listener) {
        mOnSpeedChangeListener = listener;
    }

    /**
     * 设置滤镜Listener
     *
     * @param listener
     */
    public void setFilterChangeListener(Edit.OnFilterChangeListener listener) {
        mOnFilterChangeListener = listener;
    }

    /**
     * 设置背景音Listener
     *
     * @param listener
     */
    public void setBGMChangeListener(Edit.OnBGMChangeListener listener) {
        mOnBGMChangeListener = listener;
        mBGMEditView.setIBGMPanelEventListener(listener);
    }

    /**
     * 设置字幕Listener
     *
     * @param listener
     */
    public void setWordChangeListener(Edit.OnWordChangeListener listener) {
        mOnWordChangeListener = listener;
        mWordEditView.setIWordEventListener(listener);
    }

    public void setBGMInfo(TCBGMInfo bgmInfo) {
        mBGMEditView.setBGMInfo(bgmInfo);
    }

    /**
     * 获取视频的裁剪起点
     *
     * @return
     */
    public int getSegmentFrom() {
        return mCutView.getSegmentFrom();
    }

    /**
     * 获取视频的裁剪终点
     *
     * @return
     */
    public int getSegmentTo() {
        return mCutView.getSegmentTo();
    }


    /**
     * 获取BGM的播放起点
     *
     * @return
     */
    public long getBGMSegmentFrom() {
        return mBGMEditView.getSegmentFrom();
    }

    /**
     * 获取BGM的播放终点
     *
     * @return
     */
    public long getBGMSegmentTo() {
        return mBGMEditView.getSegmentTo();
    }


    /**
     * 添加视频缩略图展示
     *
     * @param index
     * @param bitmap
     */
    public void addBitmap(int index, Bitmap bitmap) {
        mCutView.addBitmap(index, bitmap);
    }

    public void setMediaFileInfo(TXVideoEditConstants.TXVideoInfo videoInfo) {
        mCutView.setMediaFileInfo(videoInfo);
    }

    /**
     * 选中滤镜
     *
     * @param index
     */
    private void selectFilter(int index) {
        ViewGroup group = (ViewGroup) mFilterSV.getChildAt(0);
        for (int i = 0; i < mFilterAdapter.getCount(); i++) {
            View v = group.getChildAt(i);
            ImageView IVTint = (ImageView) v.findViewById(R.id.filter_image_tint);
            if (IVTint != null) {
                if (i == index) {
                    IVTint.setVisibility(View.VISIBLE);
                } else {
                    IVTint.setVisibility(View.INVISIBLE);
                }
            }
        }
    }

    private static Bitmap decodeResource(Resources resources, int id) {
        TypedValue value = new TypedValue();
        resources.openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(resources, id, opts);
    }

    private Bitmap getFilterBitmap(int index) {
        Bitmap bmp = null;
        switch (index) {
            case 1:
                bmp = decodeResource(getResources(), R.drawable.filter_langman);
                break;
            case 2:
                bmp = decodeResource(getResources(), R.drawable.filter_qingxin);
                break;
            case 3:
                bmp = decodeResource(getResources(), R.drawable.filter_weimei);
                break;
            case 4:
                bmp = decodeResource(getResources(), R.drawable.filter_fennen);
                break;
            case 5:
                bmp = decodeResource(getResources(), R.drawable.filter_huaijiu);
                break;
            case 6:
                bmp = decodeResource(getResources(), R.drawable.filter_landiao);
                break;
            case 7:
                bmp = decodeResource(getResources(), R.drawable.filter_qingliang);
                break;
            case 8:
                bmp = decodeResource(getResources(), R.drawable.filter_rixi);
                break;
            default:
                bmp = null;
                break;
        }
        return bmp;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_cut:
                chagneToCutView();
                break;
            case R.id.btn_filter:
                changeToFilterView();
                break;
            case R.id.btn_music:
                changeToMusicView();
                break;
            case R.id.btn_word:
                changeToWordView();
                break;
        }
    }

    private void changeToWordView() {
        mCutLL.setVisibility(GONE);
        mFilterLL.setVisibility(GONE);
        mBgmLL.setVisibility(GONE);
        mWordLL.setVisibility(VISIBLE);

        mCutBtn.setImageResource(R.drawable.ic_cut);
        mFilterBtn.setImageResource(R.drawable.ic_beautiful);
        mBgmBtn.setImageResource(R.drawable.ic_music);
        mWordBtn.setImageResource(R.drawable.ic_word_press);
    }

    private void changeToMusicView() {
        mCutLL.setVisibility(GONE);
        mFilterLL.setVisibility(GONE);
        mBgmLL.setVisibility(VISIBLE);
        mWordLL.setVisibility(GONE);

        mCutBtn.setImageResource(R.drawable.ic_cut);
        mFilterBtn.setImageResource(R.drawable.ic_beautiful);
        mBgmBtn.setImageResource(R.drawable.ic_music_pressed);
        mWordBtn.setImageResource(R.drawable.ic_word);
    }

    private void changeToFilterView() {
        mCutLL.setVisibility(GONE);
        mFilterLL.setVisibility(VISIBLE);
        mBgmLL.setVisibility(GONE);
        mWordLL.setVisibility(GONE);

        mCutBtn.setImageResource(R.drawable.ic_cut);
        mFilterBtn.setImageResource(R.drawable.ic_beautiful_press);
        mBgmBtn.setImageResource(R.drawable.ic_music);
        mWordBtn.setImageResource(R.drawable.ic_word);
    }

    private void chagneToCutView() {
        mCutLL.setVisibility(VISIBLE);
        mFilterLL.setVisibility(GONE);
        mBgmLL.setVisibility(GONE);
        mWordLL.setVisibility(GONE);

        mCutBtn.setImageResource(R.drawable.ic_cut_press);
        mFilterBtn.setImageResource(R.drawable.ic_beautiful);
        mBgmBtn.setImageResource(R.drawable.ic_music);
        mWordBtn.setImageResource(R.drawable.ic_word);
    }
}
