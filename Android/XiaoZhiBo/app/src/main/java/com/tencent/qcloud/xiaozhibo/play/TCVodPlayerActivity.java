package com.tencent.qcloud.xiaozhibo.play;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.FragmentTransaction;
import android.app.Service;
import android.content.Intent;
import android.media.MediaMetadataRetriever;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.activity.ErrorDialogFragment;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.widget.TCUserAvatarListAdapter;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.mainui.list.TCLiveListFragment;
import com.tencent.rtmp.ITXVodPlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXVodPlayConfig;
import com.tencent.rtmp.TXVodPlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.umeng.socialize.ShareAction;
import com.umeng.socialize.UMShareAPI;
import com.umeng.socialize.UMShareListener;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMWeb;

import java.io.UnsupportedEncodingException;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Locale;


/**
 * Created by RTMP on 2016/8/4
 */
public class TCVodPlayerActivity extends Activity implements View.OnClickListener, ITXVodPlayListener {
    private static final String TAG = TCLivePlayerActivity.class.getSimpleName();

    protected TXCloudVideoView mTXCloudVideoView;

    private TXVodPlayer mTXVodPlayer;
    private TXVodPlayConfig mTXConfig = new TXVodPlayConfig();

    protected Handler mHandler = new Handler();

    private ImageView mHeadIcon;
    private ImageView mRecordBall;
    private TextView mtvPuserName;
    private TextView mMemberCount;

    private String mPusherAvatar;

    private long mCurrentMemberCount = 0;
    private boolean mPlaying = false;
    private String mPusherNickname;
    protected String mPusherId;
    protected String mPlayUrl = "http://2527.vod.myqcloud.com/2527_000007d04afea41591336f60841b5774dcfd0001.f0.flv";
    private String mFileId = "";
    protected String mUserId = "";
    protected String mNickname = "";
    protected String mHeadPic = "";
    private String mTimeStamp = "";

    //头像列表控件
    private RecyclerView mUserAvatarList;
    private TCUserAvatarListAdapter mAvatarListAdapter;

    //点播相关
    private long mTrackingTouchTS = 0;
    private boolean mStartSeek = false;
    private boolean mVideoPause = false;
    private SeekBar mSeekBar;
    private ImageView mPlayIcon;
    private TextView mTextProgress;

    protected ImageView mBgImageView;

    //分享相关
    private UMImage mImage = null;
    private SHARE_MEDIA mShare_meidia = SHARE_MEDIA.WEIXIN;
    private String mShareUrl = TCConstants.SVR_LivePlayShare_URL;
    private String mCoverUrl = "";
    private String mTitle = ""; //标题

    //log相关
    protected boolean mShowLog = false;

    private int mRecordType;
    private int mWidth, mHeight;
    private float mVideoScale;

    private ErrorDialogFragment mErrDlgFragment;
    private long mStartPushPts;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mStartPushPts = System.currentTimeMillis();

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
        mCurrentMemberCount = Long.decode(intent.getStringExtra(TCConstants.MEMBER_COUNT));
        mFileId = intent.getStringExtra(TCConstants.FILE_ID);
        mTimeStamp = intent.getStringExtra(TCConstants.TIMESTAMP);
        mTitle = intent.getStringExtra(TCConstants.ROOM_TITLE);
        mUserId = TCUserMgr.getInstance().getUserId();
        mNickname = TCUserMgr.getInstance().getNickname();
        mHeadPic = TCUserMgr.getInstance().getHeadPic();

        mRecordType = intent.getIntExtra(TCConstants.VIDEO_RECORD_TYPE, 0);

        initView();

        if(mRecordType != TCConstants.VIDEO_RECORD_TYPE_UGC_RECORD){
            mBgImageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
        }else{
            try {
                MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
                mediaMetadataRetriever.setDataSource(mPlayUrl, new HashMap<String, String>());
                String widthStr = mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);
                String heightStr = mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);
                mediaMetadataRetriever.release();
                if( !TextUtils.isEmpty(widthStr) && !TextUtils.isEmpty(heightStr)){
                    mWidth = Integer.parseInt(widthStr);
                    mHeight = Integer.parseInt(heightStr);
                    if(mWidth != 0 && mHeight != 0){
                        mVideoScale = mHeight / (float)mWidth;
                    }
                    if(mVideoScale != 1 && (mVideoScale < 1.3f || mVideoScale > 1.4f)){
                        mBgImageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                mBgImageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
            }
        }

        mCoverUrl = getIntent().getStringExtra(TCConstants.COVER_PIC);
        TCUtils.blurBgPic(this, mBgImageView, mCoverUrl, R.drawable.bg);

        initSharePara();
        mPhoneListener = new TXPhoneStateListener(mTXVodPlayer);
        TelephonyManager tm = (TelephonyManager) this.getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);

        mTXVodPlayer = new TXVodPlayer(this);

        startPlay();
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

            if (mSeekBar != null) {
                mSeekBar.setProgress(progress);
            }
            if (mTextProgress != null) {
                mTextProgress.setText(String.format(Locale.CHINA, "%02d:%02d:%02d/%02d:%02d:%02d", progress / 3600, (progress%3600) / 60, progress % 60, duration / 3600, (duration%3600) / 60, duration % 60));
            }

            if (mSeekBar != null) {
                mSeekBar.setMax(duration);
            }
        } else if (event == TXLiveConstants.PLAY_ERR_NET_DISCONNECT) {

            showErrorAndQuit(TCConstants.ERROR_MSG_NET_DISCONNECTED);

        } else if (event == TXLiveConstants.PLAY_EVT_PLAY_END) {
            stopPlay(false);
            mVideoPause = false;
            if (mTextProgress != null) {
                mTextProgress.setText(String.format(Locale.CHINA, "%s","00:00:00/00:00:00"));
            }
            if (mSeekBar != null) {
                mSeekBar.setProgress(0);
            }
            if (mPlayIcon != null) {
                mPlayIcon.setBackgroundResource(R.drawable.play_start);
            }
            mBgImageView.setVisibility(View.VISIBLE);
        }
        else if (event == TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME) {
            mBgImageView.setVisibility(View.GONE);

        }
    }

    /**
     * 小直播ELK上报内容
     * @param event
     */
    private void report(int event) {
        switch (event) {
            case TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), 0, "视频播放成功", null);
                break;
            case TXLiveConstants.PLAY_ERR_NET_DISCONNECT :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -1, "网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放", null);
                break;
            case TXLiveConstants.PLAY_ERR_GET_RTMP_ACC_URL_FAIL :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -2, "获取加速拉流地址失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_FILE_NOT_FOUND :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -3, "播放文件不存在", null);
                break;
            case TXLiveConstants.PLAY_ERR_HEVC_DECODE_FAIL :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -4, "H265解码失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_HLS_KEY :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -5, "HLS解码Key获取失败", null);
                break;
            case TXLiveConstants.PLAY_ERR_GET_PLAYINFO_FAIL :
                TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY, TCUserMgr.getInstance().getUserId(), -6, "获取点播文件信息失败", null);
                break;

        }
    }

    @Override
    public void onNetStatus(TXVodPlayer player, Bundle status) {
        if(status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) > status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT)) {
            mTXVodPlayer.setRenderRotation(TXLiveConstants.RENDER_ROTATION_LANDSCAPE);
        } else  {
            mTXVodPlayer.setRenderRotation(TXLiveConstants.RENDER_ROTATION_PORTRAIT);
        }
    }

    static class TXPhoneStateListener extends PhoneStateListener {
        WeakReference<TXVodPlayer> mPlayer;
        public TXPhoneStateListener(TXVodPlayer player) {
            mPlayer = new WeakReference<TXVodPlayer>(player);
        }
        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            TXVodPlayer player = mPlayer.get();
            switch(state){
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
    };
    private PhoneStateListener mPhoneListener = null;

    private void initView() {
        //左上直播信息
        mtvPuserName = (TextView) findViewById(R.id.tv_broadcasting_time);
        mtvPuserName.setText(TCUtils.getLimitString(mPusherNickname, 10));
        mRecordBall = (ImageView) findViewById(R.id.iv_record_ball);
        mRecordBall.setVisibility(View.GONE);
        mHeadIcon = (ImageView) findViewById(R.id.iv_head_icon);
        showHeadIcon(mHeadIcon, mPusherAvatar);
        mMemberCount = (TextView) findViewById(R.id.tv_member_counts);

        //初始化观众列表
        mUserAvatarList = (RecyclerView) findViewById(R.id.rv_user_avatar);
        mUserAvatarList.setVisibility(View.VISIBLE);
        mAvatarListAdapter = new TCUserAvatarListAdapter(this, mPusherId);
        mUserAvatarList.setAdapter(mAvatarListAdapter);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mUserAvatarList.setLayoutManager(linearLayoutManager);
        mMemberCount.setText(String.format(Locale.CHINA, "%d", mCurrentMemberCount));

        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.video_view);
        mTXCloudVideoView.setLogMargin(10, 10, 45, 55);
        mTextProgress = (TextView) findViewById(R.id.progress_time);
        mPlayIcon = (ImageView) findViewById(R.id.play_btn);
        mSeekBar = (SeekBar) findViewById(R.id.seekbar);
        mSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean bFromUser) {
                if (mTextProgress != null) {
                    mTextProgress.setText(String.format(Locale.CHINA, "%02d:%02d:%02d/%02d:%02d:%02d", progress / 3600, (progress%3600)/60, (progress%3600) % 60, seekBar.getMax() / 3600, (seekBar.getMax()%3600) / 60, (seekBar.getMax()%3600) % 60));
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

        mBgImageView = (ImageView) findViewById(R.id.background);
    }

    /**
     * 加载主播头像
     *
     * @param view   view
     * @param avatar 头像链接
     */
    private void showHeadIcon(ImageView view, String avatar) {
        TCUtils.showPicWithUrl(this,view,avatar,R.drawable.face);
    }

    public String getInnerSDCardPath() {
        return Environment.getExternalStorageDirectory().getPath();
    }

    protected void startPlay() {
        mTXConfig.setCacheFolderPath(getInnerSDCardPath()+"/xzbcache");
        mTXConfig.setMaxCacheItems(3);
        mBgImageView.setVisibility(View.VISIBLE);
        mTXVodPlayer.setPlayerView(mTXCloudVideoView);
        mTXVodPlayer.setRenderRotation(TXLiveConstants.RENDER_ROTATION_PORTRAIT);
        if(mRecordType == TCConstants.VIDEO_RECORD_TYPE_UGC_RECORD){
            if(mWidth != 0 && mHeight != 0){
                if(mVideoScale == 1 || (mVideoScale > 1.3f && mVideoScale < 1.4f)){
                    mTXVodPlayer.setRenderMode(TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION);
                }else {
                    mTXVodPlayer.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);
                }
            }else{
                mTXVodPlayer.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);
            }
        }else{
            mTXVodPlayer.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);
        }
        mTXVodPlayer.setVodListener(this);
        mTXVodPlayer.setConfig(mTXConfig);
        mTXVodPlayer.setAutoPlay(true);
        int result;
        result = mTXVodPlayer.startPlay(mPlayUrl);

        if (0 != result) {
            Intent rstData = new Intent();
            if (-1 == result) {
                Log.d(TAG, TCConstants.ERROR_MSG_NOT_QCLOUD_LINK);
                rstData.putExtra(TCConstants.ACTIVITY_RESULT,TCConstants.ERROR_MSG_NOT_QCLOUD_LINK);
            } else {
                Log.d(TAG, TCConstants.ERROR_RTMP_PLAY_FAILED);
                rstData.putExtra(TCConstants.ACTIVITY_RESULT,TCConstants.ERROR_MSG_NOT_QCLOUD_LINK);
            }
            stopPlay(true);
            setResult(TCLiveListFragment.START_LIVE_PLAY,rstData);
            finish();
        } else {
            mPlaying = true;
        }
    }

    protected void stopPlay(boolean clearLastFrame) {
        if (mTXVodPlayer != null) {
            mTXVodPlayer.setVodListener(null);
            mTXVodPlayer.stopPlay(clearLastFrame);
            mPlaying = false;
        }
    }

    protected void showErrorAndQuit(String errorMsg) {
        stopPlay(true);

        Intent rstData = new Intent();
        rstData.putExtra(TCConstants.ACTIVITY_RESULT,errorMsg);
        setResult(TCLiveListFragment.START_LIVE_PLAY,rstData);

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
                        if (mPlayIcon != null) {
                            mPlayIcon.setBackgroundResource(R.drawable.play_pause);
                        }
                    } else {
                        mTXVodPlayer.pause();
                        if (mPlayIcon != null) {
                            mPlayIcon.setBackgroundResource(R.drawable.play_start);
                        }
                    }
                    mVideoPause = !mVideoPause;
                } else {
                    if (mPlayIcon != null) {
                        mPlayIcon.setBackgroundResource(R.drawable.play_pause);
                    }
                    startPlay();
                }

            }
            break;
            case R.id.btn_vod_share:
                showShareDialog();
                break;
            case R.id.btn_vod_log:
                showLog();
            break;
            default:
                break;
        }
    }

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
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        stopPlay(true);
        mTXVodPlayer = null;

        TelephonyManager tm = (TelephonyManager) this.getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_NONE);
        mPhoneListener = null;

        long endPushPts = System.currentTimeMillis();
        long diff = (endPushPts - mStartPushPts) / 1000 ;
        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_VOD_PLAY_DURATION, TCUserMgr.getInstance().getUserId(), diff, "点播播放时长", null);
    }

    private void initSharePara() {
        try {
            mShareUrl = mShareUrl + "?sdkappid=" + java.net.URLEncoder.encode(String.valueOf(TCUserMgr.getInstance().getSDKAppID()), "utf-8")
                    + "&acctype=" + java.net.URLEncoder.encode(TCUserMgr.getInstance().getAccountType(), "utf-8")
                    + "&userid=" +java.net.URLEncoder.encode(mPusherId, "utf-8")
                    + "&type=" + java.net.URLEncoder.encode(String.valueOf(1), "utf-8")
                    + "&fileid=" + java.net.URLEncoder.encode(String.valueOf(mFileId), "utf-8")
                    + "&ts=" + java.net.URLEncoder.encode(mTimeStamp, "utf-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        if (mCoverUrl == null || mCoverUrl.isEmpty()) {
            mImage= new UMImage(TCVodPlayerActivity.this.getApplicationContext(), R.drawable.bg);
        } else {
            mImage= new UMImage(TCVodPlayerActivity.this.getApplicationContext(), mCoverUrl);
        }
    }

    /**
     * 展示分享界面
     */
    private void showShareDialog() {

        View view = getLayoutInflater().inflate(R.layout.share_dialog, null);
        final AlertDialog mDialog = new AlertDialog.Builder(this,R.style.ConfirmDialogStyle).create();
        mDialog.show();// 显示创建的AlertDialog，并显示，必须放在Window设置属性之前

        Window window =mDialog.getWindow();
        if (window != null) {
            window.setContentView(view);//这一步必须指定，否则不出现弹窗
            WindowManager.LayoutParams mParams = window.getAttributes();
            mParams.width = android.view.WindowManager.LayoutParams.MATCH_PARENT;
            mParams.height = android.view.WindowManager.LayoutParams.WRAP_CONTENT;
            window.setGravity(Gravity.BOTTOM); // 此处可以设置dialog显示的位置
            window.setBackgroundDrawableResource(android.R.color.white);
            window.setAttributes(mParams);
        }

        Button btn_wx = (Button) view.findViewById(R.id.btn_share_wx);
        Button btn_circle = (Button) view.findViewById(R.id.btn_share_circle);
        Button btn_qq = (Button) view.findViewById(R.id.btn_share_qq);
        Button btn_qzone = (Button) view.findViewById(R.id.btn_share_qzone);
        Button btn_wb = (Button) view.findViewById(R.id.btn_share_wb);
        Button btn_cancle = (Button) view.findViewById(R.id.btn_share_cancle);

        btn_wx.setOnClickListener(mShareBtnClickListen);
        btn_circle.setOnClickListener(mShareBtnClickListen);
        btn_qq.setOnClickListener(mShareBtnClickListen);
        btn_qzone.setOnClickListener(mShareBtnClickListen);
        btn_wb.setOnClickListener(mShareBtnClickListen);
        btn_cancle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mDialog.dismiss();
            }
        });
    }

    private View.OnClickListener mShareBtnClickListen = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            switch (view.getId()) {
                case R.id.btn_share_wx:
                    mShare_meidia = SHARE_MEDIA.WEIXIN;
                    break;
                case R.id.btn_share_circle:
                    mShare_meidia = SHARE_MEDIA.WEIXIN_CIRCLE;
                    break;
                case R.id.btn_share_qq:
                    mShare_meidia = SHARE_MEDIA.QQ;
                    break;
                case R.id.btn_share_qzone:
                    mShare_meidia = SHARE_MEDIA.QZONE;
                    break;
                case R.id.btn_share_wb:
                    mShare_meidia = SHARE_MEDIA.SINA;
                    break;
                default:
                    break;
            }

            ShareAction shareAction = new ShareAction(TCVodPlayerActivity.this);

            UMWeb web = new UMWeb(mShareUrl);
            web.setThumb(mImage);
            web.setTitle(mTitle);
            shareAction.withMedia(web);
            shareAction.withText(mtvPuserName.getText() + "正在直播");
            shareAction.setCallback(umShareListener);
            shareAction.setPlatform(mShare_meidia).share();
        }
    };

    private UMShareListener umShareListener = new UMShareListener() {
        @Override
        public void onStart(SHARE_MEDIA platform) {
            Log.d("plat","platform" + platform);
        }

        @Override
        public void onResult(SHARE_MEDIA platform) {
            Log.d("plat","platform"+platform);
            Toast.makeText(TCVodPlayerActivity.this, platform + " 分享成功啦", Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onError(SHARE_MEDIA platform, Throwable t) {
            Toast.makeText(TCVodPlayerActivity.this,"分享失败"+t.getMessage(),Toast.LENGTH_LONG).show();
        }

        @Override
        public void onCancel(SHARE_MEDIA platform) {
            Toast.makeText(TCVodPlayerActivity.this,platform + " 分享取消了", Toast.LENGTH_SHORT).show();
        }
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /** attention to this below ,must add this**/
        UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);
        com.umeng.socialize.utils.Log.d("result","onActivityResult");
    }

    protected void showLog() {
        mShowLog = !mShowLog;
        if (mTXCloudVideoView != null) {
            mTXCloudVideoView.showLog(mShowLog);
        }
        int resId = mShowLog ? R.drawable.icon_log_on: R.drawable.icon_log_off;
        ImageView vodLog = (ImageView) findViewById(R.id.btn_vod_log);
        if (vodLog != null) vodLog.setBackgroundResource(resId);
    }

}
