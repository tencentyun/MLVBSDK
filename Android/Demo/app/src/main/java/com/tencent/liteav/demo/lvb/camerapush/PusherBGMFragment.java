package com.tencent.liteav.demo.lvb.camerapush;

import android.app.DialogFragment;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.Toast;

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.common.utils.FileUtils;

import java.io.File;
import java.lang.ref.WeakReference;

public class PusherBGMFragment extends DialogFragment {
    private static final String LOCAL_BGM_PATH = "/sdcard/testMusic/buzuibuhui.mp3";
    private static final String ONLINE_BGM_PATH = "http://bgm-1252463788.cosgz.myqcloud.com/Flo%20Rida%20-%20Whistle.mp3";
    private EditText mEtLoop;     // 循环次数
    private CheckBox mCbOnline;   // 在线音乐
    private WeakReference<OnBGMControllCallback> mWefCallback;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.mlvb_dialog_fragment);
        // 拷贝MP3文件到本地
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                File file = new File("/sdcard/testMusic/buzuibuhui.mp3");
                if (file.exists()) return;
                FileUtils.copyFilesFromAssets(PusherBGMFragment.this.getActivity(), "buzuibuhui.mp3", "/sdcard/testMusic/buzuibuhui.mp3");
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null)
            getDialog().getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_pusher_bgm, container, false);
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
        mEtLoop = (EditText) view.findViewById(R.id.pusher_et_bgm_loop);

        mCbOnline = ((CheckBox) view.findViewById(R.id.pusher_cb_online));

        ((SeekBar) view.findViewById(R.id.pusher_sb_mic)).setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                float volume = (seekBar.getProgress() / 100.0f);   // 0 ~ 2范围
                OnBGMControllCallback callback = getCallback();
                if (callback != null) {
                    callback.onMICVolumeChange(volume);
                }
            }
        });

        ((SeekBar) view.findViewById(R.id.pusher_sb_bgm)).setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                float volume = (seekBar.getProgress() / 100.0f);     // 0 ~ 2范围
                OnBGMControllCallback callback = getCallback();
                if (callback != null) {
                    callback.onBGMVolumeChange(volume);
                }
            }
        });

        ((SeekBar) view.findViewById(R.id.pusher_sb_bgm_pitch)).setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                float volume = ((seekBar.getProgress() - 100) / 100f); // pitch -1 ~ 1的范围
                OnBGMControllCallback callback = getCallback();
                if (callback != null) {
                    callback.onBGMPitchChange(volume);
                }
            }
        });
        view.findViewById(R.id.pusher_btn_start).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean isOnline = mCbOnline.isChecked();
                if (!isOnline) {
                    File file = new File(LOCAL_BGM_PATH);
                    if (!file.exists()) {
                        Toast.makeText(v.getContext(), "本地BGM文件不存在，播放失败", Toast.LENGTH_SHORT).show();
                        return;
                    }
                }
                int loop;
                try {
                    loop = Integer.valueOf(mEtLoop.getText().toString());
                } catch (Exception e) {
                    e.printStackTrace();
                    loop = 1;
                }
                OnBGMControllCallback callback = getCallback();
                if (callback != null) {
                    callback.onStartPlayBGM(isOnline ? LOCAL_BGM_PATH : ONLINE_BGM_PATH, loop, isOnline);
                }
            }
        });

        view.findViewById(R.id.pusher_btn_resume).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnBGMControllCallback callback = getCallback();
                if (callback != null) {
                    callback.onResumeBGM();
                }
            }
        });

        view.findViewById(R.id.pusher_btn_pause).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnBGMControllCallback callback = getCallback();
                if (callback != null) {
                    callback.onPauseBGM();
                }
            }
        });

        view.findViewById(R.id.pusher_btn_stop).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                OnBGMControllCallback callback = getCallback();
                if (callback != null) {
                    callback.onStopBGM();
                }
            }
        });
    }


    public interface OnBGMControllCallback {
        void onStartPlayBGM(String url, int loopTimes, boolean isOnline);

        void onResumeBGM();

        void onPauseBGM();

        void onStopBGM();

        void onBGMVolumeChange(float volume);

        void onMICVolumeChange(float volume);

        void onBGMPitchChange(float pitch);
    }

    public void setBGMControllCallback(OnBGMControllCallback callback) {
        mWefCallback = new WeakReference<>(callback);
    }

    private OnBGMControllCallback getCallback() {
        if (mWefCallback != null)
            return mWefCallback.get();
        return null;
    }
}
