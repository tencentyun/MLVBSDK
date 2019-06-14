package com.tencent.liteav.demo.common.widget;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.SeekBar;

import com.tencent.liteav.demo.R;

/**
 * Created by linkzhzhu on 2017/7/18.
 */

public class MusicSettingPannel extends FrameLayout implements SeekBar.OnSeekBarChangeListener , View.OnClickListener {
    public static final int MUSICPARAM_BGM_PATH = 0;
    public static final int MUSICPARAM_START = 1;
    public static final int MUSICPARAM_STOP = 2;
    public static final int MUSICPARAM_PAUSE = 3;
    public static final int MUSICPARAM_RESUME = 4;
    public static final int MUSICPARAM_MIC_VOLUME = 5;
    public static final int MUSICPARAM_BGM_VOLUME = 6;

    static public class MusicParams{
        public String BGMPath;
        public float  MICVolume;
        public float  BGMVolume;
    }

    public interface IOnMusicParamsChangeListener{
        void onMusicParamsChange(MusicParams params, int key);
    }

    public void setListener(IOnMusicParamsChangeListener listener){
        mListener = listener;
    }

    public MusicSettingPannel(@NonNull Context context) {
        this(context, null);
    }

    public MusicSettingPannel(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        View view = LayoutInflater.from(context).inflate(R.layout.music_pannel, this);
        mContext = context;
        initView(view);
    }

    private void initView(View view) {

        mBGMVolumeSeekbar = (SeekBar) view.findViewById(R.id.music_bgm_volume_seekbar);
        mBGMVolumeSeekbar.setOnSeekBarChangeListener(this);

        mMICVolumeSeekbar = (SeekBar) view.findViewById(R.id.music_mic_volume_seekbar);
        mMICVolumeSeekbar.setOnSeekBarChangeListener(this);

        mBtnPlay = (Button)view.findViewById(R.id.btnPlay);
        mBtnPlay.setOnClickListener(this);
        mBtnPause = (Button)view.findViewById(R.id.btnPause);
        mBtnPause.setOnClickListener(this);
        mBtnStop = (Button)view.findViewById(R.id.btnStop);
        mBtnStop.setOnClickListener(this);
    }

    public MusicParams getMusicParams() {
        MusicParams params = new MusicParams();
        params.BGMVolume = (float) mBGMVolumeSeekbar.getProgress() / mBGMVolumeSeekbar.getMax();
        params.MICVolume = (float) mMICVolumeSeekbar.getProgress() / mMICVolumeSeekbar.getMax();
        return params;
    }


    @Override
    public void onClick(View v) {
        if(v.getId() == R.id.btnPlay){
            if(mListener != null){
                mListener.onMusicParamsChange(null, MUSICPARAM_START);
            }
        }
        else if(v.getId() == R.id.btnPause){
            if(mListener != null){
                if(!mPause){
                    mPause = true;
                    mListener.onMusicParamsChange(null, MUSICPARAM_PAUSE);
                }
                else {
                    mPause = false;
                    mListener.onMusicParamsChange(null, MUSICPARAM_RESUME);
                }
            }
        }
        else if(v.getId() == R.id.btnStop){
            if(mListener != null){
                mListener.onMusicParamsChange(null, MUSICPARAM_STOP);
            }
        }
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        if (seekBar.getId() == R.id.music_mic_volume_seekbar) {
            if(mListener != null){
                MusicParams params = new MusicParams();
                params.MICVolume = (float) progress / mMICVolumeSeekbar.getMax();
                mListener.onMusicParamsChange(params, MUSICPARAM_MIC_VOLUME);
            }
        }
        else if (seekBar.getId() == R.id.music_bgm_volume_seekbar) {
            MusicParams params = new MusicParams();
            params.BGMVolume = (float) progress / mBGMVolumeSeekbar.getMax();
            mListener.onMusicParamsChange(params, MUSICPARAM_BGM_VOLUME);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    private Context                         mContext;
    private SeekBar                         mBGMVolumeSeekbar;
    private SeekBar                         mMICVolumeSeekbar;
    private IOnMusicParamsChangeListener    mListener;
    private Button                          mBtnPlay;
    private Button                          mBtnPause;
    private Button                          mBtnStop;
    private boolean                         mPause;
}
