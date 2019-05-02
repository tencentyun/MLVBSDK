package com.tencent.qcloud.xiaozhibo.videoeditor;

import android.app.Dialog;
import android.app.Service;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.utils.TCVideoFileInfo;
import com.tencent.qcloud.xiaozhibo.common.widget.VideoWorkProgressFragment;
import com.tencent.qcloud.xiaozhibo.videoeditor.bgm.TCBGMInfo;
import com.tencent.qcloud.xiaozhibo.videoeditor.word.TCWordEditorFragment;
import com.tencent.qcloud.xiaozhibo.videopublish.TCVideoPublisherActivity;
import com.tencent.rtmp.TXLog;
import com.tencent.ugc.TXVideoEditConstants;
import com.tencent.ugc.TXVideoEditer;
import com.tencent.ugc.TXVideoInfoReader;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static com.tencent.qcloud.xiaozhibo.videoeditor.PlayState.STATE_CUT;

/**
 * UGC短视频裁剪
 */
public class TCVideoEditerActivity extends FragmentActivity implements View.OnClickListener,
        TXVideoEditer.TXVideoGenerateListener, TXVideoInfoReader.OnSampleProgrocess, TXVideoEditer.TXVideoPreviewListener, TCWordEditorFragment.OnWordEditorListener
        , Edit.OnBGMChangeListener, Edit.OnCutChangeListener, Edit.OnFilterChangeListener, Edit.OnSpeedChangeListener, Edit.OnWordChangeListener {

    private static final String TAG = TCVideoEditerActivity.class.getSimpleName();
    private static final int MSG_LOAD_VIDEO_INFO = 1000;
    private static final int MSG_RET_VIDEO_INFO = 1001;

    private int mCurrentState = PlayState.STATE_NONE;

    private TextView mTvDone;
    private TextView mTvCurrent;
    private TextView mTvDuration;
    private ImageButton mBtnPlay;
    private FrameLayout mVideoView;
    private LinearLayout mLayoutEditer;
    private Button mDialogBtnSave;
    private Button mDialogBtnPublish;
    private Button mDialogBtnOnlyPublish;

    private Dialog mDialog;
    private VideoWorkProgressFragment mWorkProgressDialog;
    private ProgressBar mLoadProgress;

    private EditPannel mEditPannel;
    /**************************SDK*****************************/

    private TXVideoEditer mTXVideoEditer;
    private TCVideoFileInfo mTCVideoFileInfo;
    private TXVideoInfoReader mTXVideoInfoReader;
    private TXVideoEditConstants.TXGenerateResult mResult;
    private TXVideoEditConstants.TXVideoInfo mTXVideoInfo;

    private String mVideoOutputPath;
    private BackGroundHandler mHandler;
    private TCWordEditorFragment mTCWordEditorFragment;

    private int mCutVideoDuration;              //裁剪的视频时长

    private boolean mPublish = false;
    private boolean mNoCache = false;

    private Bitmap mWaterMarkLogo;              // 水印LOGO
    private boolean mIsStopManually;            // 标记是否手动停止
    private float mSpeedLevel = 1.0f;           // 加速大小
    private String mBGMPath;                    // BGM路径


    class BackGroundHandler extends Handler {

        public BackGroundHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_LOAD_VIDEO_INFO:
                    TXVideoEditConstants.TXVideoInfo videoInfo = mTXVideoInfoReader.getVideoFileInfo(mTCVideoFileInfo.getFilePath());
                    if (videoInfo == null) {
                        mLoadProgress.setVisibility(View.GONE);

                        showUnSupportDialog("暂不支持Android 4.3以下的系统");
                        return;
                    }
                    Message mainMsg = new Message();
                    mainMsg.what = MSG_RET_VIDEO_INFO;
                    mainMsg.obj = videoInfo;
                    mMainHandler.sendMessage(mainMsg);
                    break;
            }

        }
    }

    private Handler mMainHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MSG_RET_VIDEO_INFO:
                    mTXVideoInfo = (TXVideoEditConstants.TXVideoInfo) msg.obj;

                    TXVideoEditConstants.TXPreviewParam param = new TXVideoEditConstants.TXPreviewParam();
                    param.videoView = mVideoView;
                    param.renderMode = TXVideoEditConstants.PREVIEW_RENDER_MODE_FILL_EDGE;
                    int ret = mTXVideoEditer.setVideoPath(mTCVideoFileInfo.getFilePath());
                    mTXVideoEditer.initWithPreview(param);
                    if (ret < 0) {
                        showUnSupportDialog("本机型暂不支持此视频格式");
                        return;
                    }

                    handleOp(Action.DO_SEEK_VIDEO, 0, (int) mTXVideoInfo.duration);
                    mLoadProgress.setVisibility(View.GONE);
                    mTvDone.setClickable(true);
                    mBtnPlay.setClickable(true);

                    mEditPannel.setMediaFileInfo(mTXVideoInfo);
                    String duration = TCUtils.duration(mTXVideoInfo.duration);
                    String position = TCUtils.duration(0);

                    mTvCurrent.setText(position);
                    mTvDuration.setText(duration);
                    break;
            }
        }
    };
    private HandlerThread mBGMHandlerThread;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        setContentView(R.layout.activity_video_editer);

        initViews();
        initData();
    }

    @Override
    protected void onDestroy() {

        TelephonyManager tm = (TelephonyManager) this.getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_NONE);

        mBGMHandlerThread.quit();
        handleOp(Action.DO_CANCEL_VIDEO, 0, 0);


        mTXVideoInfoReader.cancel();
        mTXVideoEditer.setTXVideoPreviewListener(null);
        mTXVideoEditer.setVideoGenerateListener(null);
        mTXVideoEditer.release();
        super.onDestroy();
    }

    private void initViews() {

        mEditPannel = (EditPannel) findViewById(R.id.edit_pannel);
        mEditPannel.setCutChangeListener(this);
        mEditPannel.setFilterChangeListener(this);
        mEditPannel.setBGMChangeListener(this);
        mEditPannel.setWordChangeListener(this);
        mEditPannel.setSpeedChangeListener(this);


        mTvCurrent = (TextView) findViewById(R.id.tv_current);
        mTvDuration = (TextView) findViewById(R.id.tv_duration);

        mVideoView = (FrameLayout) findViewById(R.id.video_view);

        mBtnPlay = (ImageButton) findViewById(R.id.btn_play);
        mBtnPlay.setOnClickListener(this);
        mBtnPlay.setClickable(false);

        mTvDone = (TextView) findViewById(R.id.btn_done);
        mTvDone.setOnClickListener(this);
        mTvDone.setClickable(false);

        mLayoutEditer = (LinearLayout) findViewById(R.id.layout_editer);
        mLayoutEditer.setEnabled(true);

        findViewById(R.id.back_tv).setOnClickListener(this);
        mLoadProgress = (ProgressBar) findViewById(R.id.progress_load);
        initWorkProgressPopWin();
    }

    private void initWorkProgressPopWin() {
        if (mWorkProgressDialog == null) {
            mWorkProgressDialog = new VideoWorkProgressFragment();
            mWorkProgressDialog.setOnClickStopListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mTvDone.setClickable(true);
                    mTvDone.setEnabled(true);
                    mWorkProgressDialog.dismiss();
                    Toast.makeText(TCVideoEditerActivity.this, "取消视频生成", Toast.LENGTH_SHORT).show();
                    mWorkProgressDialog.setProgress(0);
                    mCurrentState = PlayState.STATE_NONE;
                    if (mTXVideoEditer != null) {
                        mTXVideoEditer.cancel();
                    }
                }
            });
        }
        mWorkProgressDialog.setProgress(0);
    }

    private synchronized boolean handleOp(int state, int startPlayTime, int endPlayTime) {
        switch (state) {
            case Action.DO_PLAY_VIDEO:
                if (mCurrentState == PlayState.STATE_NONE) {
                    mTXVideoEditer.startPlayFromTime(startPlayTime, endPlayTime);
                    mCurrentState = PlayState.STATE_PLAY;
                    return true;
                } else if (mCurrentState == PlayState.STATE_PAUSE) {
                    mTXVideoEditer.resumePlay();
                    mCurrentState = PlayState.STATE_PLAY;
                    return true;
                }
                break;
            case Action.DO_PAUSE_VIDEO:
                if (mCurrentState == PlayState.STATE_PLAY) {
                    mTXVideoEditer.pausePlay();
                    mCurrentState = PlayState.STATE_PAUSE;
                    return true;
                }
                break;
            case Action.DO_SEEK_VIDEO:
                if (mCurrentState == STATE_CUT) {
                    return false;
                }
                if (mCurrentState == PlayState.STATE_PLAY || mCurrentState == PlayState.STATE_PAUSE) {
                    mTXVideoEditer.stopPlay();
                }
                mTXVideoEditer.startPlayFromTime(startPlayTime, endPlayTime);
                mCurrentState = PlayState.STATE_PLAY;
                return true;
            case Action.DO_CUT_VIDEO:
                if (mCurrentState == PlayState.STATE_PLAY || mCurrentState == PlayState.STATE_PAUSE) {
                    mTXVideoEditer.stopPlay();
                }
                startTranscode();
                mCurrentState = STATE_CUT;
                return true;
            case Action.DO_CANCEL_VIDEO:
                if (mCurrentState == PlayState.STATE_PLAY || mCurrentState == PlayState.STATE_PAUSE) {
                    mTXVideoEditer.stopPlay();
                } else if (mCurrentState == STATE_CUT) {
                    mTXVideoEditer.cancel();
                }
                mCurrentState = PlayState.STATE_NONE;
                return true;
        }
        return false;
    }

    private void initData() {
        //初始化后台Thread线程
        mBGMHandlerThread = new HandlerThread("LoadData");
        mBGMHandlerThread.start();
        mHandler = new BackGroundHandler(mBGMHandlerThread.getLooper());

        mTCVideoFileInfo = (TCVideoFileInfo) getIntent().getSerializableExtra(TCConstants.INTENT_KEY_SINGLE_CHOOSE);
        mTXVideoInfoReader = TXVideoInfoReader.getInstance();

        //初始化SDK编辑
        mTXVideoEditer = new TXVideoEditer(this);
        mTXVideoEditer.setTXVideoPreviewListener(this);

        //加载视频基本信息
        mHandler.sendEmptyMessage(MSG_LOAD_VIDEO_INFO);

        //设置电话监听
        mPhoneListener = new TXPhoneStateListener(this);
        TelephonyManager tm = (TelephonyManager) this.getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);

        //加载缩略图
        mTXVideoInfoReader.getSampleImages(TCConstants.THUMB_COUNT, mTCVideoFileInfo.getFilePath(), this);

        //导入水印
        mWaterMarkLogo = BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher);
    }

    private void createThumbFile() {
        AsyncTask<Void, String, String> task = new AsyncTask<Void, String, String>() {
            @Override
            protected String doInBackground(Void... voids) {
                File outputVideo = new File(mVideoOutputPath);
                if (outputVideo == null || !outputVideo.exists())
                    return null;
                Bitmap bitmap = mTXVideoInfoReader.getSampleImage(0, mVideoOutputPath);
                if (bitmap == null)
                    return null;
                String mediaFileName = outputVideo.getAbsolutePath();
                if (mediaFileName.lastIndexOf(".") != -1) {
                    mediaFileName = mediaFileName.substring(0, mediaFileName.lastIndexOf("."));
                }
                String folder = mediaFileName;
                File appDir = new File(folder);
                if (!appDir.exists()) {
                    appDir.mkdirs();
                }

                String fileName = "thumbnail" + ".jpg";
                File file = new File(appDir, fileName);
                if (file.exists())
                    file.delete();
                try {
                    FileOutputStream fos = new FileOutputStream(file);
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
                    fos.flush();
                    fos.close();
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                mTCVideoFileInfo.setThumbPath(file.getAbsolutePath());
                return null;
            }

            @Override
            protected void onPostExecute(String s) {
                publishVideo();
            }
        };
        task.execute();
    }


    @Override
    protected void onResume() {
        super.onResume();
        if (mTCWordEditorFragment == null || mTCWordEditorFragment.isHidden()) {
            if (mCurrentState == PlayState.STATE_PAUSE && !mIsStopManually) {
                handleOp(Action.DO_PLAY_VIDEO, mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
                mBtnPlay.setImageResource(mCurrentState == PlayState.STATE_PLAY ? R.drawable.ic_pause : R.drawable.ic_play);
            }
        }
    }

    @Override
    protected void onRestart() {
        super.onRestart();
//        if (mCurrentState == PlayState.STATE_NONE || mTCWordEditorFragment != null) {//说明是取消合成之后
//            handleOp(Action.DO_SEEK_VIDEO, 0, (int) mTXVideoInfo.duration);
//            mBtnPlay.setImageResource(R.drawable.ic_pause);
//        }
    }

    @Override
    protected void onStart() {
        super.onStart();

    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mCurrentState == STATE_CUT) {
            handleOp(Action.DO_CANCEL_VIDEO, 0, 0);
            if (mWorkProgressDialog != null && mWorkProgressDialog.isAdded()) {
                mWorkProgressDialog.dismiss();
            }
        } else {
            mIsStopManually = false;
            handleOp(Action.DO_PAUSE_VIDEO, 0, 0);
            mBtnPlay.setImageResource(mCurrentState == PlayState.STATE_PLAY ? R.drawable.ic_pause : R.drawable.ic_play);
        }
        mTvDone.setClickable(true);
        mTvDone.setEnabled(true);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_done:
                showDialog();
                break;
            case R.id.back_tv:
                mTXVideoInfoReader.cancel();
                handleOp(Action.DO_CANCEL_VIDEO, 0, 0);
                mTXVideoEditer.setTXVideoPreviewListener(null);
                mTXVideoEditer.setVideoGenerateListener(null);
                finish();
                break;
            case R.id.dialog_btn_save:
                mPublish = false;
                dismissDialog();
                doSave();
                break;
            case R.id.dialog_btn_publish:
                mPublish = true;
                mNoCache = false;
                dismissDialog();
                doSave();
                break;
            case R.id.only_publish:
                mNoCache = true;
                mPublish = true;
                dismissDialog();
                doSave();
                break;
            case R.id.btn_play:
                mIsStopManually = !mIsStopManually;
                playVideo();
                break;

        }
    }

    private void publishVideo() {
        Intent intent = new Intent(getApplicationContext(), TCVideoPublisherActivity.class);
        intent.putExtra(TCConstants.VIDEO_RECORD_TYPE, TCConstants.VIDEO_RECORD_TYPE_PLAY);
        intent.putExtra(TCConstants.VIDEO_RECORD_VIDEPATH, mVideoOutputPath);
        intent.putExtra(TCConstants.VIDEO_RECORD_COVERPATH, mTCVideoFileInfo.getThumbPath());
        intent.putExtra(TCConstants.VIDEO_RECORD_NO_CACHE, mNoCache);
        startActivity(intent);
    }

    private void showDialog() {
        if (mDialog == null) {
            mDialog = new Dialog(this, R.style.dialog_bottom_full);

            mDialog.setCanceledOnTouchOutside(true);
            mDialog.setCancelable(true);

            Window window = mDialog.getWindow();
            window.setGravity(Gravity.BOTTOM);

            View view = View.inflate(this, R.layout.dialog_ugcedit_publish, null);

            mDialogBtnSave = (Button) view.findViewById(R.id.dialog_btn_save);
            mDialogBtnSave.setOnClickListener(this);
            mDialogBtnPublish = (Button) view.findViewById(R.id.dialog_btn_publish);
            mDialogBtnPublish.setOnClickListener(this);
            mDialogBtnOnlyPublish = (Button) view.findViewById(R.id.only_publish);
            mDialogBtnOnlyPublish.setOnClickListener(this);

            window.setContentView(view);
            window.setLayout(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT);
        }
        mDialog.show();
    }

    private void dismissDialog() {
        if (mDialog != null && mDialog.isShowing()) {
            mDialog.dismiss();
        }
    }


    private void playVideo() {
        if (mCurrentState == PlayState.STATE_PLAY) {
            handleOp(Action.DO_PAUSE_VIDEO, 0, 0);
        } else {
            handleOp(Action.DO_PLAY_VIDEO, mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
        }
        mBtnPlay.setImageResource(mCurrentState == PlayState.STATE_PLAY ? R.drawable.ic_pause : R.drawable.ic_play);
    }


    private void doTranscode() {
        mTvDone.setEnabled(false);
        mTvDone.setClickable(false);

        mTXVideoInfoReader.cancel();
        mLayoutEditer.setEnabled(false);
        handleOp(Action.DO_CUT_VIDEO, 0, 0);
    }

    private void startTranscode() {
        mBtnPlay.setImageResource(R.drawable.ic_play);
        mCutVideoDuration = mEditPannel.getSegmentTo() - mEditPannel.getSegmentFrom();
        mWorkProgressDialog.setProgress(0);
        mWorkProgressDialog.setCancelable(false);
        mWorkProgressDialog.show(getFragmentManager(), "progress_dialog");
        try {
            mTXVideoEditer.setCutFromTime(mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());

            String outputPath = Environment.getExternalStorageDirectory() + File.separator + TCConstants.DEFAULT_MEDIA_PACK_FOLDER;
            File outputFolder = new File(outputPath);

            if (!outputFolder.exists()) {
                outputFolder.mkdirs();
            }
            String current = String.valueOf(System.currentTimeMillis() / 1000);
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
            String time = sdf.format(new Date(Long.valueOf(current + "000")));
            String saveFileName = String.format("TXVideo_%s.mp4", time);
            mVideoOutputPath = outputFolder + "/" + saveFileName;
            mTXVideoEditer.setVideoGenerateListener(this);
            mTXVideoEditer.generateVideo(TXVideoEditConstants.VIDEO_COMPRESSED_540P, mVideoOutputPath);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void doSave() {
        mTvDone.setEnabled(false);
        mTvDone.setClickable(false);

        mTXVideoInfoReader.cancel();
        mTXVideoEditer.stopPlay();
        mLayoutEditer.setEnabled(false);
        doTranscode();
    }

    /**
     * 错误框方法
     */
    private void showUnSupportDialog(String text) {
        final Dialog dialog = new Dialog(TCVideoEditerActivity.this, R.style.ConfirmDialogStyle);
        View v = LayoutInflater.from(TCVideoEditerActivity.this).inflate(R.layout.dialog_ugc_tip, null);
        dialog.setContentView(v);
        TextView title = (TextView) dialog.findViewById(R.id.tv_title);
        TextView msg = (TextView) dialog.findViewById(R.id.tv_msg);
        Button ok = (Button) dialog.findViewById(R.id.btn_ok);
        title.setText("视频编辑失败");
        msg.setText(text);
        ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dialog.dismiss();
            }
        });
        dialog.show();
    }

    /********************************************* SDK回调**************************************************/
    @Override
    public void onGenerateProgress(final float progress) {
        final int prog = (int) (progress * 100);
        mWorkProgressDialog.setProgress(prog);
    }

    @Override
    public void onGenerateComplete(TXVideoEditConstants.TXGenerateResult result) {
        if (mWorkProgressDialog != null && mWorkProgressDialog.isAdded()) {
            mWorkProgressDialog.dismiss();
        }
        if (result.retCode == TXVideoEditConstants.GENERATE_RESULT_OK) {
            updateMediaStore();
            if (mTXVideoInfo != null) {
                mResult = result;
            }
            if (mPublish) {
                createThumbFile();
                mPublish = false;
            } else {
                finish();
            }
        } else {
            TXVideoEditConstants.TXGenerateResult ret = result;
            Toast.makeText(TCVideoEditerActivity.this, ret.descMsg, Toast.LENGTH_SHORT).show();
            mTvDone.setEnabled(true);
            mTvDone.setClickable(true);
        }

        mCurrentState = PlayState.STATE_NONE;

    }

    private void updateMediaStore() {
        Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        scanIntent.setData(Uri.fromFile(new File(mVideoOutputPath)));
        sendBroadcast(scanIntent);
    }

    @Override
    public void sampleProcess(int number, Bitmap bitmap) {
        int num = number;
        Bitmap bmp = bitmap;
        mEditPannel.addBitmap(num, bmp);
        TXLog.d(TAG, "number = " + number + ",bmp = " + bitmap);
    }


    @Override
    public void onPreviewProgress(int time) {
        if (mTvCurrent != null) {
            mTvCurrent.setText(TCUtils.duration((long) (time / 1000 * mSpeedLevel)));
        }
    }

    @Override
    public void onPreviewFinished() {
        TXLog.d(TAG, "---------------onPreviewFinished-----------------");
        handleOp(Action.DO_SEEK_VIDEO, mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
    }


    /********************************************* 裁剪**************************************************/
    @Override
    public void onCutChangeKeyDown() {
        mBtnPlay.setImageResource(R.drawable.ic_play);
    }

    @Override
    public void onCutChangeKeyUp(int startTime, int endTime) {
        mBtnPlay.setImageResource(R.drawable.ic_pause);
        handleOp(Action.DO_SEEK_VIDEO, mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
    }

    /********************************************* 加速**************************************************/
    @Override //开启加速的回调
    public void onSpeedChange(float speed) {
        //开启变速时候，建议停止播放。 然后设置变速，再次重新播放，能够有效避免界面卡顿，引起体验不好的问题。
        mTXVideoEditer.stopPlay();
        mCurrentState = PlayState.STATE_CANCEL;

        mSpeedLevel = speed;
//        mTXVideoEditer.setSpeedLevel(mSpeedLevel);
        List<TXVideoEditConstants.TXSpeed> list = new ArrayList<>(1);
        TXVideoEditConstants.TXSpeed txspeed = new TXVideoEditConstants.TXSpeed();
        txspeed.startTime = 0;                                         // 开始时间
        txspeed.endTime = mTXVideoInfo.duration;                       // 结束时间
        if(speed == 1.0f){
            txspeed.speedLevel = TXVideoEditConstants.SPEED_LEVEL_NORMAL;
        } else if (speed == 2.0f){
            txspeed.speedLevel = TXVideoEditConstants.SPEED_LEVEL_FAST;    // 快速
        }
        // 添加到分段变速中
        list.add(txspeed);

        // 设入SDK
        mTXVideoEditer.setSpeedList(list);

        mTXVideoEditer.startPlayFromTime(mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
        mCurrentState = PlayState.STATE_PLAY;

    }

    /********************************************* 滤镜*************************** ***********************/
    @Override //选择了具体滤镜的回调
    public void onFilterChange(Bitmap bitmap) {
        mTXVideoEditer.setFilter(bitmap);
    }

    /********************************************* 背景音**************************************************/
    @Override //BGM的音量的改变回调
    public void onBGMSeekChange(float progress) {
        mTXVideoEditer.setBGMVolume(mEditPannel.getBGMVolumeProgress());
        mTXVideoEditer.setVideoVolume(1 - mEditPannel.getBGMVolumeProgress());
    }

    @Override //移除BGM回调
    public void onBGMDelete() {
        mTXVideoEditer.setBGM(null);
    }

    @Override //选中BGM的回调
    public boolean onBGMInfoSetting(TCBGMInfo info) {
        mTXVideoEditer.setBGMVolume(mEditPannel.getBGMVolumeProgress());
        mTXVideoEditer.setVideoVolume(1 - mEditPannel.getBGMVolumeProgress());
        mBGMPath = info.getPath();
        if (!TextUtils.isEmpty(mBGMPath)) {
            int result = mTXVideoEditer.setBGM(mBGMPath);
            if (result != 0) {
                showUnSupportDialog("背景音仅支持MP3格式音频");
            }
            return result == 0;//设置成功
        }
        return false;
    }

    @Override //开始滑动BGM区间的回调
    public void onBGMRangeKeyDown() {

    }

    @Override //BGM起止时间的回调
    public void onBGMRangeKeyUp(long startTime, long endTime) {
        if (!TextUtils.isEmpty(mBGMPath)) {
            mTXVideoEditer.setBGMStartTime(startTime, endTime);
        }
    }

    /********************************************* 字幕**************************************************/
    @Override //点击添加字幕的回调
    public void onWordClick() {
        if (mTCWordEditorFragment == null) {
            mTCWordEditorFragment = TCWordEditorFragment.newInstance(mTXVideoEditer,
                    mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
            mTCWordEditorFragment.setOnWordEditorListener(TCVideoEditerActivity.this);
            mTCWordEditorFragment.setSpeedLevel(mSpeedLevel);
            getSupportFragmentManager()
                    .beginTransaction()
                    .replace(R.id.editer_fl_word_container, mTCWordEditorFragment, "editor_word_fragment")
                    .commit();
        } else {
            mTCWordEditorFragment.setVideoRangeTime(mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
            mTCWordEditorFragment.setSpeedLevel(mSpeedLevel);
            getSupportFragmentManager()
                    .beginTransaction()
                    .show(mTCWordEditorFragment)
                    .commit();
        }
    }

    /********************************************* 字幕Fragment回调**************************************************/

    @Override //从字幕的Fragment取消回来的回调
    public void onWordEditCancel() {
        removeWordEditorFragment();
        resetAndPlay();
    }


    @Override //从字幕的Fragment点击保存回来的hi掉
    public void onWordEditFinish() {
        removeWordEditorFragment();
        resetAndPlay();
    }


    private void removeWordEditorFragment() {
        if (mTCWordEditorFragment != null && mTCWordEditorFragment.isAdded()) {
            getSupportFragmentManager().beginTransaction().hide(mTCWordEditorFragment).commit();
        }
    }

    /**
     * 从字幕编辑回来之后，要重新设置Video的容器，以及监听进度回调
     */
    private void resetAndPlay() {
        TXVideoEditConstants.TXPreviewParam param = new TXVideoEditConstants.TXPreviewParam();
        param.videoView = mVideoView;
        param.renderMode = TXVideoEditConstants.PREVIEW_RENDER_MODE_FILL_EDGE;
        mTXVideoEditer.initWithPreview(param);
        mTXVideoEditer.startPlayFromTime(mEditPannel.getSegmentFrom(), mEditPannel.getSegmentTo());
        mTXVideoEditer.setTXVideoPreviewListener(this);
    }


    /*********************************************监听电话状态**************************************************/
    static class TXPhoneStateListener extends PhoneStateListener {
        WeakReference<TCVideoEditerActivity> mJoiner;

        public TXPhoneStateListener(TCVideoEditerActivity joiner) {
            mJoiner = new WeakReference<TCVideoEditerActivity>(joiner);
        }

        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            TCVideoEditerActivity joiner = mJoiner.get();
            if (joiner == null) return;
            switch (state) {
                case TelephonyManager.CALL_STATE_RINGING:  //电话等待接听
                case TelephonyManager.CALL_STATE_OFFHOOK:  //电话接听
                    if (joiner.mCurrentState == PlayState.STATE_CUT) {
                        joiner.handleOp(Action.DO_CANCEL_VIDEO, 0, 0);
                        if (joiner.mWorkProgressDialog != null && joiner.mWorkProgressDialog.isAdded()) {
                            joiner.mWorkProgressDialog.dismiss();
                        }
                        joiner.mBtnPlay.setImageResource(R.drawable.ic_pause);
                    } else {
                        joiner.handleOp(Action.DO_PAUSE_VIDEO, 0, 0);
                        if (joiner.mBtnPlay != null) {
                            joiner.mBtnPlay.setImageResource(joiner.mCurrentState == PlayState.STATE_PLAY ? R.drawable.ic_pause : R.drawable.ic_play);
                        }
                    }
                    if (joiner.mTvDone != null) {
                        joiner.mTvDone.setClickable(true);
                        joiner.mTvDone.setEnabled(true);
                    }
                    break;
                //电话挂机
                case TelephonyManager.CALL_STATE_IDLE:
                    joiner.mBtnPlay.setImageResource(R.drawable.ic_pause);
                    if (joiner.mTXVideoEditer != null && joiner.mEditPannel != null)
                        joiner.handleOp(Action.DO_PLAY_VIDEO, joiner.mEditPannel.getSegmentFrom(), joiner.mEditPannel.getSegmentTo());
                    break;
            }
        }
    }

    ;
    private PhoneStateListener mPhoneListener = null;

}
