package com.tencent.liteav.demo.livepusher.cameralivepush;

import android.app.DialogFragment;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.Toast;

import com.tencent.liteav.demo.livepusher.R;

import java.io.File;
import java.lang.ref.WeakReference;

public class PusherBGMFragment extends DialogFragment {
    private static final String ONLINE_BGM_PATH = "http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic1.mp3";
    private EditText                            mEditLoop;      // 循环次数
    private CheckBox                            mCheckOnline;   // 在线音乐
    private WeakReference<OnBGMControlCallback> mWefCallback;
    private String                              mTestMusicPath;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.LivePusherMlvbDialogFragment);

        Context context = getActivity();
        if (context != null) {
            File sdcardDir = context.getExternalFilesDir(null);
            if (sdcardDir != null) {
                mTestMusicPath = sdcardDir.getAbsolutePath() + "/testMusic/zhouye.mp3";
            }
        }

        // 拷贝MP3文件到本地
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                if (TextUtils.isEmpty(mTestMusicPath))
                    return;
                File file = new File(mTestMusicPath);
                if (file.exists()) return;
                FileUtils.copyFilesFromAssets(PusherBGMFragment.this.getActivity(), "zhouye.mp3", mTestMusicPath);
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null) {
            getDialog().getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.livepusher_fragment_pusher_bgm, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try{
                    dismissAllowingStateLoss();
                }catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        mEditLoop = (EditText) view.findViewById(R.id.livepusher_et_bgm_loop);
        mCheckOnline = ((CheckBox) view.findViewById(R.id.livepusher_cb_online));

        ((SeekBar) view.findViewById(R.id.livepusher_sb_mic)).setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                float volume = (seekBar.getProgress() / 100.0f);   // 0 ~ 2范围
                OnBGMControlCallback callback = getCallback();
                if (callback != null) {
                    callback.onMICVolumeChange(volume);
                }
            }
        });
        ((SeekBar) view.findViewById(R.id.livepusher_sb_bgm)).setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                float volume = (seekBar.getProgress() / 100.0f);     // 0 ~ 2范围
                OnBGMControlCallback callback = getCallback();
                if (callback != null) {
                    callback.onBGMVolumeChange(volume);
                }
            }
        });
        ((SeekBar) view.findViewById(R.id.livepusher_sb_bgm_pitch)).setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                float volume = ((seekBar.getProgress() - 100) / 100f); // pitch -1 ~ 1的范围
                OnBGMControlCallback callback = getCallback();
                if (callback != null) {
                    callback.onBGMPitchChange(volume);
                }
            }
        });
        view.findViewById(R.id.livepusher_btn_start).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                pushStart();
            }
        });
        view.findViewById(R.id.livepusher_btn_resume).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnBGMControlCallback callback = getCallback();
                if (callback != null) {
                    callback.onResumeBGM();
                }
            }
        });
        view.findViewById(R.id.livepusher_btn_pause).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnBGMControlCallback callback = getCallback();
                if (callback != null) {
                    callback.onPauseBGM();
                }
            }
        });
        view.findViewById(R.id.livepusher_btn_stop).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnBGMControlCallback callback = getCallback();
                if (callback != null) {
                    callback.onStopBGM();
                }
            }
        });
    }


    public interface OnBGMControlCallback {

        void onStartPlayBGM(String url, int loopTimes, boolean isOnline);

        void onResumeBGM();

        void onPauseBGM();

        void onStopBGM();

        void onBGMVolumeChange(float volume);

        void onMICVolumeChange(float volume);

        void onBGMPitchChange(float pitch);
    }

    public void setBGMControlCallback(OnBGMControlCallback callback) {
        mWefCallback = new WeakReference<>(callback);
    }

    private OnBGMControlCallback getCallback() {
        if (mWefCallback == null) {
            return null;
        }
        return mWefCallback.get();
    }

    private void pushStart() {
        boolean isOnline = mCheckOnline.isChecked();
        if (!isOnline) {
            File file = new File(mTestMusicPath);
            if (!file.exists()) {
                Toast.makeText(getActivity(), getString(R.string.livepusher_no_file_play_fail), Toast.LENGTH_SHORT).show();
                return;
            }
        }
        int loop;
        try {
            loop = Integer.parseInt(mEditLoop.getText().toString());
        } catch (Exception e) {
            e.printStackTrace();
            loop = 1;
        }
        OnBGMControlCallback callback = getCallback();
        if (callback != null) {
            callback.onStartPlayBGM(isOnline ? ONLINE_BGM_PATH : mTestMusicPath, loop, isOnline);
        }
    }
}
