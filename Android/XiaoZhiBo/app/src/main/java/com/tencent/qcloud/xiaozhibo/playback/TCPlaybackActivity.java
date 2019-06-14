package com.tencent.qcloud.xiaozhibo.playback;

import android.app.Activity;
import android.app.FragmentTransaction;
import android.app.Service;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.audience.TCAudienceActivity;
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.ui.ErrorDialogFragment;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.widget.TCUserAvatarListAdapter;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.main.videolist.ui.TCVideoListFragment;
import com.tencent.rtmp.ITXVodPlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXVodPlayConfig;
import com.tencent.rtmp.TXVodPlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.lang.ref.WeakReference;
import java.util.Locale;


/**
 * Module:   TCPlaybackActivity
 *
 * Function: 回放观看界面
 *
 * 1. TXVodPlayer 的使用：开始和结束播放 {@link TCPlaybackActivity#startPlay()} 和 {@link TCPlaybackActivity#stopPlay(boolean)}
 *
 * 2. 事件处理以及网络回调：{@link TCPlaybackActivity#onPlayEvent(TXVodPlayer, int, Bundle)} 和 {@link TCPlaybackActivity#onNetStatus(TXVodPlayer, Bundle)}
 *
 **/
public class TCPlaybackActivity extends Activity implements View.OnClickListener, ITXVodPlayListener {
    private static final String TAG = TCAudienceActivity.class.getSimpleName();

    // 播放相关
    private TXCloudVideoView                mTXCloudVideoView;                  // 播放预览的 view
    private TXVodPlayer                     mTXVodPlayer;                       // 点播播放器
    private TXVodPlayConfig                 mTXConfig = new TXVodPlayConfig();  // 点播配置

    private ImageView                       mIvAvatar;                          // 头像
    private TextView                        mTvPusherName;                      // 主播名称
    private TextView                        mTvViewed;                          // 已观看数量

    //头像列表控件
    private RecyclerView                    mRvAvatarList;
    private TCUserAvatarListAdapter         mAvatarListAdapter;

    private ImageView                       mIvCover;                           // 封面图
    private SeekBar                         mSbProgress;                        // 播放进度
    private ImageView                       mIvPlay;                            // 播放暂停按钮
    private TextView                        mTvProgress;


    private long                            mViewedCount;                       // 已观看的人数
    private String                          mPusherNickname;                    // 主播昵称
    private String                          mPusherId;                          // 主播Id
    private String                          mPlayUrl = "";                      // 播放地址
    private String                          mFileId = "";                       // 回放视频的 fileId
    private String                          mTimeStamp = "";                    // 时间戳
    private String                          mPusherAvatar;                      // 主播头像


    //点播相关
    private long                            mTrackingTouchTS;
    private boolean                         mStartSeek;                         // 是否在
    private boolean                         mVideoPause;                        // 是否暂停
    private boolean                         mPlaying;                           // 是否正在播放

    private String                          mCoverUrl = "";
    private String                          mTitle = ""; //标题

    //log相关
    private boolean                         mShowLog;

    private ErrorDialogFragment             mErrDlgFragment = new ErrorDialogFragment();
    private long                            mStartPlayPts;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mStartPlayPts = System.currentTimeMillis();

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        setContentView(R.layout.activity_vod_play);

        Intent intent = getIntent();
        mPusherId = intent.getStringExtra(TCConstants.PUSHER_ID);
        mPlayUrl = intent.getStringExtra(TCConstants.PLAY_URL);
        mPusherNickname = intent.getStringExtra(TCConstants.PUSHER_NAME);
        mPusherAvatar = intent.getStringExtra(TCConstants.PUSHER_AVATAR);
        mViewedCount = Long.decode(intent.getStringExtra(TCConstants.MEMBER_COUNT));
        mFileId = intent.getStringExtra(TCConstants.FILE_ID);
        mTimeStamp = intent.getStringExtra(TCConstants.TIMESTAMP);
        mTitle = intent.getStringExtra(TCConstants.ROOM_TITLE);
        mCoverUrl = getIntent().getStringExtra(TCConstants.COVER_PIC);

        mTXVodPlayer = new TXVodPlayer(this);

        initView();

        startPlay();

        initPhoneListener();
    }


    private void initView() {
        //左上直播信息
        mTvPusherName = (TextView) findViewById(R.id.anchor_tv_broadcasting_time);
        mTvPusherName.setText(TCUtils.getLimitString(mPusherNickname, 10));
        findViewById(R.id.anchor_iv_record_ball).setVisibility(View.GONE);
        mIvAvatar = (ImageView) findViewById(R.id.anchor_iv_head_icon);
        TCUtils.showPicWithUrl(this, mIvAvatar, mPusherAvatar, R.drawable.face);

        mTvViewed = (TextView) findViewById(R.id.anchor_tv_member_counts);

        //初始化观众列表
        mRvAvatarList = (RecyclerView) findViewById(R.id.anchor_rv_avatar);
        mRvAvatarList.setVisibility(View.VISIBLE);
        mAvatarListAdapter = new TCUserAvatarListAdapter(this, mPusherId);
        mRvAvatarList.setAdapter(mAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRvAvatarList.setLayoutManager(linearLayoutManager);
        mTvViewed.setText(String.format(Locale.CHINA, "%d", mViewedCount));

        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.anchor_video_view);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);
        mTvProgress = (TextView) findViewById(R.id.progress_time);
        mIvPlay = (ImageView) findViewById(R.id.play_btn);
        mSbProgress = (SeekBar) findViewById(R.id.seekbar);
        mSbProgress.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean bFromUser) {
                if (mTvProgress != null) {
                    mTvProgress.setText(String.format(Locale.CHINA, "%02d:%02d:%02d/%02d:%02d:%02d", progress / 3600, (progress % 3600) / 60, (progress % 3600) % 60, seekBar.getMax() / 3600, (seekBar.getMax() % 3600) / 60, (seekBar.getMax() % 3600) % 60));
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                mStartSeek = true;
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mTXVodPlayer.seek(seekBar.getProgress());
                mTrackingTouchTS = System.currentTimeMillis();
                mStartSeek = false;
            }
        });

        mIvCover = (ImageView) findViewById(R.id.background);
        TCUtils.blurBgPic(this, mIvCover, mCoverUrl, R.drawable.bg);
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      Play 开始与停止播放
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    private void startPlay() {
        mTXConfig.setCacheFolderPath(Environment.getExternalStorageDirectory().getPath() + "/xzbcache");
        mTXConfig.setMaxCacheItems(3);
        mIvCover.setVisibility(View.VISIBLE);
        mTXVodPlayer.setPlayerView(mTXCloudVideoView);
        mTXVodPlayer.setRenderRotation(TXLiveConstants.RENDER_ROTATION_PORTRAIT);
        mTXVodPlayer.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);
        mTXVodPlayer.setVodListener(this);
        mTXVodPlayer.setConfig(mTXConfig);
        mTXVodPlayer.setAutoPlay(true);
        int result;
        result = mTXVodPlayer.startPlay(mPlayUrl);

        if (0 != result) {
            Intent rstData = new Intent();
            if (-1 == result) {
                Log.d(TAG, "非腾讯云链接，若要放开限制请联系腾讯云商务团队");
                rstData.putExtra(TCConstants.ACTIVITY_RESULT, "非腾讯云链接，若要放开限制请联系腾讯云商务团队");
            } else {
                Log.d(TAG,"视频流播放失败，Error:");
                rstData.putExtra(TCConstants.ACTIVITY_RESULT, "非腾讯云链接，若要放开限制请联系腾讯云商务团队");
            }
            stopPlay(true);
            setResult(TCVideoListFragment.START_LIVE_PLAY, rstData);
            finish();
        } else {
            mPlaying = true;
        }
    }

    private void stopPlay(boolean clearLastFrame) {
        if (mTXVodPlayer != null) {
            mTXVodPlayer.setVodListener(null);
            mTXVodPlayer.stopPlay(clearLastFrame);
            mPlaying = false;
        }
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      播放器事件监听
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    @Override
    public void onNetStatus(TXVodPlayer player, Bundle status) {
        if (status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) > status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT)) {
            mTXVodPlayer.setRenderRotation(TXLiveConstants.RENDER_ROTATION_LANDSCAPE);
        } else {
            mTXVodPlayer.setRenderRotation(TXLiveConstants.RENDER_ROTATION_PORTRAIT);
        }
    }


    @Override
    public void onPlayEvent(TXVodPlayer player, int event, Bundle param) {
        report(event);
        if (event == TXLiveConstants.PLAY_EVT_PLAY_PROGRESS) {
            if (mStartSeek) {
                return;
            }
            int progress = param.getInt(TXLiveConstants.EVT_PLAY_PROGRESS);
            int duration = param.getInt(TXLiveConstants.EVT_PLAY_DURATION);
            long curTS = System.currentTimeMillis();
            // 避免滑动进度条松开的瞬间可能出现滑动条瞬间跳到上一个位置
            if (Math.abs(curTS - mTrackingTouchTS) < 500) {
                return;
            }
            mTrackingTouchTS = curTS;

            if (mSbProgress != null) {
                mSbProgress.setProgress(progress);
            }
            if (mTvProgress != null) {
                mTvProgress.setText(String.format(Locale.CHINA, "%02d:%02d:%02d/%02d:%02d:%02d", progress / 3600, (progress % 3600) / 60, progress % 60, duration / 3600, (duration % 3600) / 60, duration % 60));
            }

            if (mSbProgress != null) {
                mSbProgress.setMax(duration);
            }
        } else if (event == TXLiveConstants.PLAY_ERR_NET_DISCONNECT) {

            showErrorAndQuit("网络异常，请检查网络");

        } else if (event == TXLiveConstants.PLAY_EVT_PLAY_END) {
            stopPlay(false);
            mVideoPause = false;
            if (mTvProgress != null) {
                mTvProgress.setText(String.format(Locale.CHINA, "%s", "00:00:00/00:00:00"));
            }
            if (mSbProgress != null) {
                mSbProgress.setProgress(0);
            }
            if (mIvPlay != null) {
                mIvPlay.setBackgroundResource(R.drawable.play_start);
            }
            mIvCover.setVisibility(View.VISIBLE);
        } else if (event == TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME) {
            mIvCover.setVisibility(View.GONE);

        }
    }


    private void showErrorAndQuit(String errorMsg) {
        stopPlay(true);

        Intent rstData = new Intent();
        rstData.putExtra(TCConstants.ACTIVITY_RESULT, errorMsg);
        setResult(TCVideoListFragment.START_LIVE_PLAY, rstData);

        if (!mErrDlgFragment.isAdded() && !this.isFinishing()) {
            Bundle args = new Bundle();
            args.putString("errorMsg", errorMsg);
            mErrDlgFragment.setArguments(args);
            mErrDlgFragment.setCancelable(false);

            //此处不使用用.show(...)的方式加载dialogfragment，避免IllegalStateException
            FragmentTransaction transaction = getFragmentManager().beginTransaction();
            transaction.add(mErrDlgFragment, "loading");
            transaction.commitAllowingStateLoss();
        }

    }
    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      点击事件
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_vod_back:
                finish();
                break;
            case R.id.play_btn: {
                if (mPlaying) {
                    if (mVideoPause) {
                        mTXVodPlayer.resume();
                        if (mIvPlay != null) {
                            mIvPlay.setBackgroundResource(R.drawable.play_pause);
                        }
                    } else {
                        mTXVodPlayer.pause();
                        if (mIvPlay != null) {
                            mIvPlay.setBackgroundResource(R.drawable.play_start);
                        }
                    }
                    mVideoPause = !mVideoPause;
                } else {
                    if (mIvPlay != null) {
                        mIvPlay.setBackgroundResource(R.drawable.play_pause);
                    }
                    startPlay();
                }

            }
            break;
            case R.id.btn_vod_share:
                break;
            case R.id.btn_vod_log:
                showLog();
                break;
            default:
                break;
        }
    }

    private void showLog() {
        mShowLog = !mShowLog;
        if (mTXCloudVideoView != null) {
            mTXCloudVideoView.showLog(mShowLog);
        }
        int resId = mShowLog ? R.drawable.icon_log_on : R.drawable.icon_log_off;
        ImageView vodLog = (ImageView) findViewById(R.id.btn_vod_log);
        if (vodLog != null) vodLog.setBackgroundResource(resId);
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      Activity 生命周期相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    protected void onResume() {
        super.onResume();
        if (!mVideoPause) {
            mTXVodPlayer.resume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        mTXVodPlayer.pause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        stopPlay(true);
        mTXVodPlayer = null;

        unInitPhoneListener();

        long endPushPts = System.currentTimeMillis();
        long diff = (endPushPts - mStartPlayPts) / 1000;
        TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY_DURATION, TCUserMgr.getInstance().getUserId(), diff, "点播播放时长", null);
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      电话监听相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    private static class TXPhoneStateListener extends PhoneStateListener {
        WeakReference<TXVodPlayer> mPlayer;

        public TXPhoneStateListener(TXVodPlayer player) {
            mPlayer = new WeakReference<TXVodPlayer>(player);
        }

        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            TXVodPlayer player = mPlayer.get();
            switch (state) {
                //电话等待接听
                case TelephonyManager.CALL_STATE_RINGING:
                    if (player != null) player.setMute(true);
                    break;
                //电话接听
                case TelephonyManager.CALL_STATE_OFFHOOK:
                    if (player != null) player.setMute(true);
                    break;
                //电话挂机
                case TelephonyManager.CALL_STATE_IDLE:
                    if (player != null) player.setMute(false);
                    break;
            }
        }
    }

    private PhoneStateListener mPhoneListener = null;

    /**
     * 监听电话状态
     */
    private void initPhoneListener() {
        mPhoneListener = new TXPhoneStateListener(mTXVodPlayer);
        TelephonyManager tm = (TelephonyManager) this.getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);
    }


    /**
     * 解除电话监听
     */
    private void unInitPhoneListener() {
        TelephonyManager tm = (TelephonyManager) this.getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_NONE);
        mPhoneListener = null;
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      小直播 ELK 数据上报（您不需要关注）
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    /**
     * 小直播ELK上报内容
     *
     * @param event
     */
    private void report(int event) {
        switch (event) {
            case TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME:
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), 0, "视频播放成功", null);
                break;
            case TXLiveConstants.PLAY_ERR_NET_DISCONNECT:
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -1, "网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放", null);
                break;
            case TXLiveConstants.PLAY_ERR_GET_RTMP_ACC_URL_FAIL:
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -2, "获取加速拉流地址失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_FILE_NOT_FOUND:
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -3, "播放文件不存在", null);
                break;
            case TXLiveConstants.PLAY_ERR_HEVC_DECODE_FAIL:
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -4, "H265解码失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_HLS_KEY:
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -5, "HLS解码Key获取失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_GET_PLAYINFO_FAIL:
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -6, "获取点播文件信息失败", null);
                break;

        }
    }

}
