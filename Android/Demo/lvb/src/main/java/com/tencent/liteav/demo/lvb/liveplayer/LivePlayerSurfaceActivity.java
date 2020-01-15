package com.tencent.liteav.demo.lvb.liveplayer;

import android.Manifest;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.AnimationDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.lvb.R;
import com.tencent.liteav.demo.lvb.common.activity.QRCodeScanActivity;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;

import org.json.JSONObject;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * 使用Surface模式进行直播播放的Activity
 */
public class LivePlayerSurfaceActivity extends Activity implements ITXLivePlayListener, OnClickListener{
    private static final String TAG = LivePlayerSurfaceActivity.class.getSimpleName();

    private TXLivePlayer     mLivePlayer = null;
    private boolean mIsPlaying;
    private TextureView mTextureView;
    private Surface mSurface;
    private int mSurfaceWidth, mSurfaceHeight;
    private ImageView        mLoadingView;
    private boolean          mHWDecode   = false;
    private LinearLayout     mRootView;

    private Button           mBtnLog;
    private Button           mBtnPlay;
    private Button           mBtnRenderRotation;
    private Button           mBtnRenderMode;
    private Button           mBtnHWDecode;

    private static final int  CACHE_STRATEGY_FAST  = 1;  //极速
    private static final int  CACHE_STRATEGY_SMOOTH = 2;  //流畅
    private static final int  CACHE_STRATEGY_AUTO = 3;  //自动

    private static final float  CACHE_TIME_FAST = 1.0f;
    private static final float  CACHE_TIME_SMOOTH = 5.0f;

    public static final int ACTIVITY_TYPE_PUBLISH      = 1;
    public static final int ACTIVITY_TYPE_LIVE_PLAY    = 2;
    public static final int ACTIVITY_TYPE_VOD_PLAY     = 3;
    public static final int ACTIVITY_TYPE_LINK_MIC     = 4;
    public static final int ACTIVITY_TYPE_REALTIME_PLAY = 5;

    private int              mCacheStrategy = 0;
    private Button           mBtnCacheStrategy;
    private Button           mRatioFast;
    private Button           mRatioSmooth;
    private Button           mRatioAuto;

    private LinearLayout     mLayoutCacheStrategy;
    protected EditText       mRtmpUrlView;

    private int              mCurrentRenderMode;
    private int              mCurrentRenderRotation;

    private int              mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;
    private TXLivePlayConfig mPlayConfig;
    private long             mStartPlayTS = 0;
    protected int            mActivityType;

    private boolean mIsLogShow = false;
    private String mPlayUrl = "";
    private boolean isFullScreen = true;
    private CheckBox mCbSurface;
    @Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        mCurrentRenderMode     = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;
        mCurrentRenderRotation = TXLiveConstants.RENDER_ROTATION_PORTRAIT;

        mActivityType = getIntent().getIntExtra("TYPE", ACTIVITY_TYPE_LIVE_PLAY);

        mPlayConfig = new TXLivePlayConfig();

        setContentView();

        LinearLayout backLL = (LinearLayout)findViewById(R.id.back_ll);
        backLL.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                stopPlay();
                finish();
            }
        });
        TextView titleTV = (TextView) findViewById(R.id.title_tv);
        titleTV.setText(getIntent().getStringExtra("TITLE"));

        checkPublishPermission();

        Button btnPlay = (Button) findViewById(R.id.btnPlay);
        if (btnPlay != null) {
            registerForContextMenu(btnPlay);
        }
        getWindow().addFlags(WindowManager.LayoutParams.
                FLAG_KEEP_SCREEN_ON);


        //just test
        findViewById(R.id.video_btn_change_size).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isFullScreen = !isFullScreen;
                if (isFullScreen) {
                    ViewGroup.LayoutParams params = mTextureView.getLayoutParams();
                    params.width = ViewGroup.LayoutParams.MATCH_PARENT;
                    params.height = ViewGroup.LayoutParams.MATCH_PARENT;
                    mTextureView.setLayoutParams(params);
                } else {
                    ViewGroup.LayoutParams params = mTextureView.getLayoutParams();
                    params.width = 720;
                    params.height = 720;
                    mTextureView.setLayoutParams(params);
                }
            }
        });
    }

    @Override
    public void onBackPressed() {
        stopPlay();
        super.onBackPressed();
    }

    private boolean checkPublishPermission() {
        if (Build.VERSION.SDK_INT >= 23) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (permissions.size() != 0) {
                ActivityCompat.requestPermissions(this,
                        permissions.toArray(new String[0]),
                        100);
                return false;
            }
        }

        return true;
    }

    void initView() {
        mRtmpUrlView   = (EditText) findViewById(R.id.roomid);

        Button scanBtn = (Button)findViewById(R.id.btnScan);
        scanBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LivePlayerSurfaceActivity.this, QRCodeScanActivity.class);
                startActivityForResult(intent, 100);
            }
        });
        scanBtn.setEnabled(true);
        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)scanBtn.getLayoutParams();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                params.removeRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            }
            scanBtn.setLayoutParams(params);
        }
    }

    public void setContentView() {
        super.setContentView(R.layout.activity_play_surface);
        initView();

        mRootView = (LinearLayout) findViewById(R.id.root);
        if (mLivePlayer == null){
            mLivePlayer = new TXLivePlayer(this);
        }

        mCbSurface = (CheckBox) findViewById(R.id.video_cb_surface);
        mCbSurface.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked && mSurface == null)  {
                    if (mTextureView.getSurfaceTexture() != null)
                        mSurface = new Surface(mTextureView.getSurfaceTexture());
                    if (mLivePlayer.isPlaying()) //处于推流中才显示
                        mTextureView.setVisibility(View.VISIBLE);
                } else {
                    mTextureView.setVisibility(View.GONE);
                    if (mSurface != null) {
                        mSurface.release();
                    }
                    mSurface = null;
                }
                mLivePlayer.setSurface(mSurface);
                mLivePlayer.setSurfaceSize(mTextureView.getWidth(), mTextureView.getHeight());
            }
        });
//        mPlayerView = (TXCloudVideoView) findViewById(R.id.video_view);
        mTextureView = (TextureView) findViewById(R.id.video_view);
        mTextureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                if (mSurface != null) {
                    mSurface.release();
                }
                if (mCbSurface.isChecked()) {
                    mSurface = new Surface(surface);
                }

                mSurfaceWidth = width;
                mSurfaceHeight = height;

                if (mLivePlayer != null && mLivePlayer.isPlaying()) {
                    mLivePlayer.setSurface(mSurface);
                    mLivePlayer.setSurfaceSize(mSurfaceWidth, mSurfaceHeight);
                }
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
                mSurfaceWidth = width;
                mSurfaceHeight = height;
                if (mLivePlayer != null) {
                    mLivePlayer.setSurfaceSize(width, height);
                }
            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                if (mSurface != null) {
                    mSurface.release();
                    mSurfaceHeight = 0;
                    mSurfaceWidth = 0;
                    mSurface = null;
                }
                if (mCbSurface.isChecked()) {
                    if (mLivePlayer!= null && mLivePlayer.isPlaying()) {
                        mLivePlayer.setSurface(mSurface);
                    }
                }
                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surface) {

            }
        });
//        mPlayerView.setLogMargin(12, 12, 110, 60);
//        mPlayerView.showLog(false);
        mLoadingView = (ImageView) findViewById(R.id.loadingImageView);

        mRtmpUrlView.setHint(" 请输入或扫二维码获取播放地址");
        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            mRtmpUrlView.setText("");
        } else {
           mRtmpUrlView.setText("http://5815.liveplay.myqcloud.com/live/5815_89aad37e06ff11e892905cb9018cf0d4.flv");
        }

        mIsPlaying = false;

        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            Button btnNew = (Button)findViewById(R.id.btnNew);
            btnNew.setVisibility(View.VISIBLE);
            btnNew.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    fetchPushUrl();
                }
            });
        }

        mBtnPlay = (Button) findViewById(R.id.btnPlay);
        mBtnPlay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "click playbtn isplay:" + mIsPlaying +" playtype:"+mPlayType);
                if (mIsPlaying) {
                    stopPlay();
                } else {
                    mIsPlaying = startPlay();
                }
            }
        });

        mBtnLog = (Button) findViewById(R.id.btnLog);
        mBtnLog.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsLogShow) {
                    mIsLogShow = false;
                    mBtnLog.setBackgroundResource(R.drawable.log_show);
//                    mPlayerView.showLog(false);
                } else {
                    mIsLogShow = true;
                    mBtnLog.setBackgroundResource(R.drawable.log_hidden);
//                    mPlayerView.showLog(true);
                }
            }
        });

        //横屏|竖屏
        mBtnRenderRotation = (Button) findViewById(R.id.btnOrientation);
        mBtnRenderRotation.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLivePlayer == null) {
                    return;
                }

                if (mCurrentRenderRotation == TXLiveConstants.RENDER_ROTATION_PORTRAIT) {
                    mBtnRenderRotation.setBackgroundResource(R.drawable.portrait);
                    mCurrentRenderRotation = TXLiveConstants.RENDER_ROTATION_LANDSCAPE;
                } else if (mCurrentRenderRotation == TXLiveConstants.RENDER_ROTATION_LANDSCAPE) {
                    mBtnRenderRotation.setBackgroundResource(R.drawable.landscape);
                    mCurrentRenderRotation = TXLiveConstants.RENDER_ROTATION_PORTRAIT;
                }

                mLivePlayer.setRenderRotation(mCurrentRenderRotation);
            }
        });

        //平铺模式
        mBtnRenderMode = (Button) findViewById(R.id.btnRenderMode);
        mBtnRenderMode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLivePlayer == null) {
                    return;
                }

                if (mCurrentRenderMode == TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN) {
                    mBtnRenderMode.setBackgroundResource(R.drawable.fill_mode);
                    mCurrentRenderMode = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;
                } else if (mCurrentRenderMode == TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION) {
                    mBtnRenderMode.setBackgroundResource(R.drawable.adjust_mode);
                    mCurrentRenderMode = TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN;
                }
                mLivePlayer.setRenderMode(mCurrentRenderMode);

            }
        });

        //硬件解码
        mBtnHWDecode = (Button) findViewById(R.id.btnHWDecode);
        mBtnHWDecode.getBackground().setAlpha(mHWDecode ? 255 : 100);
        mBtnHWDecode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mHWDecode = !mHWDecode;
                mBtnHWDecode.getBackground().setAlpha(mHWDecode ? 255 : 100);

                if (mHWDecode) {
                    Toast.makeText(getApplicationContext(), "已开启硬件解码加速，切换会重启播放流程!", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(getApplicationContext(), "已关闭硬件解码加速，切换会重启播放流程!", Toast.LENGTH_SHORT).show();
                }

                if (mIsPlaying) {
                    stopPlay();
                    mIsPlaying = startPlay();
                }
            }
        });

        //缓存策略
        mBtnCacheStrategy = (Button)findViewById(R.id.btnCacheStrategy);
        mLayoutCacheStrategy = (LinearLayout)findViewById(R.id.layoutCacheStrategy);
        mBtnCacheStrategy.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutCacheStrategy.setVisibility(mLayoutCacheStrategy.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
            }
        });

        this.setCacheStrategy(CACHE_STRATEGY_AUTO);

        mRatioFast = (Button)findViewById(R.id.radio_btn_fast);
        mRatioFast.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerSurfaceActivity.this.setCacheStrategy(CACHE_STRATEGY_FAST);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });

        mRatioSmooth = (Button)findViewById(R.id.radio_btn_smooth);
        mRatioSmooth.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerSurfaceActivity.this.setCacheStrategy(CACHE_STRATEGY_SMOOTH);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });

        mRatioAuto = (Button)findViewById(R.id.radio_btn_auto);
        mRatioAuto.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerSurfaceActivity.this.setCacheStrategy(CACHE_STRATEGY_AUTO);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });

        Button help = (Button)findViewById(R.id.btnHelp);
        help.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                jumpToHelpPage();
            }
        });

        // 低延时直播不需要播放策略和截流录制
        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            mBtnCacheStrategy.setVisibility(View.GONE);
            findViewById(R.id.btnCacheStrategyMargin).setVisibility(View.GONE);
            findViewById(R.id.btnStreamRecord).setVisibility(View.GONE);
            findViewById(R.id.btnStreamRecordMargin).setVisibility(View.GONE);
        }

        View view = mTextureView.getRootView();
        view.setOnClickListener(this);

        findViewById(R.id.webrtc_link_button).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/454/7886"));
                startActivity(intent);
            }
        });
    }

    @Override
	public void onDestroy() {
		super.onDestroy();
		if (mLivePlayer != null) {
            mLivePlayer.stopPlay(true);
            mLivePlayer = null;
        }
//        if (mPlayerView != null){
//            mPlayerView.onDestroy();
//            mPlayerView = null;
//        }
        mPlayConfig = null;
        Log.d(TAG,"vrender onDestroy");
	}

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onStop(){
        super.onStop();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            default:
                mLayoutCacheStrategy.setVisibility(View.GONE);
        }
    }

    private boolean checkPlayUrl(final String playUrl) {
        if (TextUtils.isEmpty(playUrl) || (!playUrl.startsWith("http://") && !playUrl.startsWith("https://") && !playUrl.startsWith("rtmp://")  && !playUrl.startsWith("/"))) {
            Toast.makeText(getApplicationContext(), "播放地址不合法，直播目前仅支持rtmp,flv播放方式!", Toast.LENGTH_SHORT).show();
            return false;
        }

        switch (mActivityType) {
            case ACTIVITY_TYPE_LIVE_PLAY:
            {
                if (playUrl.startsWith("rtmp://")) {
                    mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;
                } else if ((playUrl.startsWith("http://") || playUrl.startsWith("https://"))&& playUrl.contains(".flv")) {
                    mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_FLV;
                } else {
                    Toast.makeText(getApplicationContext(), "播放地址不合法，直播目前仅支持rtmp,flv播放方式!", Toast.LENGTH_SHORT).show();
                    return false;
                }
            }
                break;
            case ACTIVITY_TYPE_REALTIME_PLAY:
                mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP_ACC;
                break;
            default:
                Toast.makeText(getApplicationContext(), "播放地址不合法，目前仅支持rtmp,flv播放方式!", Toast.LENGTH_SHORT).show();
                return false;
        }
        return true;
    }

    protected void enableQRCodeBtn(boolean bEnable) {
        Button btnScan = (Button) findViewById(R.id.btnScan);
        if (btnScan != null) {
            btnScan.setEnabled(bEnable);
        }
    }

    private boolean startPlay() {
        mTextureView.setVisibility(View.VISIBLE);
        String playUrl = mRtmpUrlView.getText().toString();

        if (!checkPlayUrl(playUrl)) {
            return false;
        }

        mBtnPlay.setBackgroundResource(R.drawable.play_pause);
        mRootView.setBackgroundColor(0xff000000);
        if (mCbSurface.isChecked()) {
            mLivePlayer.setSurface(mSurface);
            mLivePlayer.setSurfaceSize(mSurfaceWidth, mSurfaceHeight);
        }

        mLivePlayer.setPlayListener(this);
        // 硬件加速在1080p解码场景下效果显著，但细节之处并不如想象的那么美好：
        // (1) 只有 4.3 以上android系统才支持
        // (2) 兼容性我们目前还仅过了小米华为等常见机型，故这里的返回值您先不要太当真
        mLivePlayer.enableHardwareDecode(mHWDecode);
        mLivePlayer.setRenderRotation(mCurrentRenderRotation);
        mLivePlayer.setRenderMode(mCurrentRenderMode);
        //设置播放器缓存策略
        //这里将播放器的策略设置为自动调整，调整的范围设定为1到4s，您也可以通过setCacheTime将播放器策略设置为采用
        //固定缓存时间。如果您什么都不调用，播放器将采用默认的策略（默认策略为自动调整，调整范围为1到4s）
        //mLivePlayer.setCacheTime(5);
        // HashMap<String, String> headers = new HashMap<>();
        // headers.put("Referer", "qcloud.com");
        // mPlayConfig.setHeaders(headers);

        mLivePlayer.setConfig(mPlayConfig);
        mPlayUrl = playUrl;
        int result = mLivePlayer.startPlay(playUrl,mPlayType); // result返回值：0 success;  -1 empty url; -2 invalid url; -3 invalid playType;
        if (result != 0) {
            mBtnPlay.setBackgroundResource(R.drawable.play_start);
            mRootView.setBackgroundResource(R.drawable.main_bkg);
            return false;
        }

        Log.w("video render","timetrack start play");

        startLoadingAnimation();

        enableQRCodeBtn(false);

        mStartPlayTS = System.currentTimeMillis();

        return true;
    }

    private  void stopPlay() {
        mTextureView.setVisibility(View.GONE);
        enableQRCodeBtn(true);
        mBtnPlay.setBackgroundResource(R.drawable.play_start);
        mRootView.setBackgroundResource(R.drawable.main_bkg);
        stopLoadingAnimation();
        if (mLivePlayer != null) {
            mLivePlayer.stopRecord();
            mLivePlayer.setPlayListener(null);
            mLivePlayer.stopPlay(true);
        }
        mIsPlaying = false;
    }

    @Override
    public void onPlayEvent(int event, Bundle param) {
        String playEventLog = "receive event: " + event + ", " + param.getString(TXLiveConstants.EVT_DESCRIPTION);
        Log.d(TAG, playEventLog);

        if (event == TXLiveConstants.PLAY_EVT_PLAY_BEGIN) {
            stopLoadingAnimation();
            Log.d("AutoMonitor", "PlayFirstRender,cost=" +(System.currentTimeMillis()-mStartPlayTS));
        } else if (event == TXLiveConstants.PLAY_ERR_NET_DISCONNECT || event == TXLiveConstants.PLAY_EVT_PLAY_END) {
            stopPlay();
        } else if (event == TXLiveConstants.PLAY_EVT_PLAY_LOADING){
            startLoadingAnimation();
        } else if (event == TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME) {
            stopLoadingAnimation();
        } else if (event == TXLiveConstants.PLAY_EVT_CHANGE_RESOLUTION) {
        } else if (event == TXLiveConstants.PLAY_EVT_CHANGE_ROTATION) {
            return;
        }

        if (event < 0) {
            Toast.makeText(getApplicationContext(), param.getString(TXLiveConstants.EVT_DESCRIPTION), Toast.LENGTH_SHORT).show();
        }

    }

    //公用打印辅助函数
    protected String getNetStatusString(Bundle status) {
        String str = String.format("%-14s %-14s %-12s\n%-8s %-8s %-8s %-8s\n%-14s %-14s\n%-14s %-14s",
                "CPU:"+status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE),
                "RES:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH)+"*"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT),
                "SPD:"+status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED)+"Kbps",
                "JIT:"+status.getInt(TXLiveConstants.NET_STATUS_NET_JITTER),
                "FPS:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS),
                "GOP:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP)+"s",
                "ARA:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE)+"Kbps",
                "QUE:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE)
                        +"|"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE)
                        +","+status.getInt(TXLiveConstants.NET_STATUS_V_SUM_CACHE_SIZE)
                        +","+status.getInt(TXLiveConstants.NET_STATUS_V_DEC_CACHE_SIZE)
                        +"|"+status.getInt(TXLiveConstants.NET_STATUS_AV_RECV_INTERVAL)
                        +","+status.getInt(TXLiveConstants.NET_STATUS_AV_PLAY_INTERVAL)
                        +","+String.format("%.1f", status.getFloat(TXLiveConstants.NET_STATUS_AUDIO_CACHE_THRESHOLD)).toString(),
                "VRA:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE)+"Kbps",
                "SVR:"+status.getString(TXLiveConstants.NET_STATUS_SERVER_IP),
                "AUDIO:"+status.getString(TXLiveConstants.NET_STATUS_AUDIO_INFO));
        return str;
    }

    @Override
    public void onNetStatus(Bundle status) {
        String str = getNetStatusString(status);
        Log.d(TAG, "Current status, CPU:"+status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE)+
                ", RES:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH)+"*"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT)+
                ", SPD:"+status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED)+"Kbps"+
                ", FPS:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS)+
                ", ARA:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE)+"Kbps"+
                ", VRA:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE)+"Kbps");
        }

    public void setCacheStrategy(int nCacheStrategy) {
        if (mCacheStrategy == nCacheStrategy)   return;
        mCacheStrategy = nCacheStrategy;

        switch (nCacheStrategy) {
            case CACHE_STRATEGY_FAST:
                mPlayConfig.setAutoAdjustCacheTime(true);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_FAST);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayConfig);
                break;

            case CACHE_STRATEGY_SMOOTH:
                mPlayConfig.setAutoAdjustCacheTime(false);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mLivePlayer.setConfig(mPlayConfig);
                break;

            case CACHE_STRATEGY_AUTO:
                mPlayConfig.setAutoAdjustCacheTime(true);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayConfig);
                break;

            default:
                break;
        }
    }

    private void startLoadingAnimation() {
        if (mLoadingView != null) {
            mLoadingView.setVisibility(View.VISIBLE);
            ((AnimationDrawable)mLoadingView.getDrawable()).start();
        }
    }

    private void stopLoadingAnimation() {
        if (mLoadingView != null) {
            mLoadingView.setVisibility(View.GONE);
            ((AnimationDrawable)mLoadingView.getDrawable()).stop();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode != 100 || data ==null || data.getExtras() == null || TextUtils.isEmpty(data.getExtras().getString("result"))) {
            return;
        }
        String result = data.getExtras().getString("result");
        if (mRtmpUrlView != null) {
            mRtmpUrlView.setText(result);
        }
    }

    private void fetchPushUrl() {
        if (mFetching) return;
        mFetching = true;
        if (mFetchProgressDialog == null) {
            mFetchProgressDialog = new ProgressDialog(this);
            mFetchProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);// 设置进度条的形式为圆形转动的进度条
            mFetchProgressDialog.setCancelable(false);// 设置是否可以通过点击Back键取消
            mFetchProgressDialog.setCanceledOnTouchOutside(false);// 设置在点击Dialog外是否取消Dialog进度条
        }
        mFetchProgressDialog.show();
        if (mOkHttpClient == null) {
            mOkHttpClient = new OkHttpClient().newBuilder()
                    .connectTimeout(10, TimeUnit.SECONDS)
                    .readTimeout(10, TimeUnit.SECONDS)
                    .writeTimeout(10, TimeUnit.SECONDS)
                    .build();
        }

        String reqUrl = "https://lvb.qcloud.com/weapp/utils/get_test_rtmpaccurl";
        Request request = new Request.Builder()
                .url(reqUrl)
                .addHeader("Content-Type","application/json; charset=utf-8")
                .build();
        Log.d(TAG, "start fetch push url");
        if (mFechCallback == null) {
            mFechCallback = new TXFechPushUrlCall(this);
        }
        mOkHttpClient.newCall(request).enqueue(mFechCallback);
    }

    private static class TXFechPushUrlCall implements Callback {
        WeakReference<LivePlayerSurfaceActivity> mPlayer;
        public TXFechPushUrlCall(LivePlayerSurfaceActivity pusher) {
            mPlayer = new WeakReference<LivePlayerSurfaceActivity>(pusher);
        }

        @Override
        public void onFailure(Call call, IOException e) {
            final LivePlayerSurfaceActivity player = mPlayer.get();
            if (player != null) {
                player.mFetching = false;
                player.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(player, "获取测试地址失败。", Toast.LENGTH_SHORT).show();
                        player.mFetchProgressDialog.dismiss();
                    }
                });
            }
            Log.e(TAG, "fetch push url failed ");
        }

        @Override
        public void onResponse(Call call, Response response) throws IOException {
            if (response.isSuccessful()) {
                String rspString = response.body().string();
                final LivePlayerSurfaceActivity player = mPlayer.get();
                if (player != null) {
                    try {
                        JSONObject jsonRsp = new JSONObject(rspString);
                        final String playUrl = jsonRsp.optString("url_rtmpacc");
                        player.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                player.mRtmpUrlView.setText(playUrl);
                                Toast.makeText(player, "测试地址的影像来自在线UTC时间的录屏推流，推流工具采用移动直播 Windows SDK + VCam。", Toast.LENGTH_LONG).show();
                                player.mFetchProgressDialog.dismiss();
                            }
                        });

                    } catch(Exception e){
                        Log.e(TAG, "fetch push url error ");
                        Log.e(TAG, e.toString());
                    }

                } else {
                    player.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(player, "获取测试地址失败。", Toast.LENGTH_SHORT).show();
                            player.mFetchProgressDialog.dismiss();
                        }
                    });
                    Log.e(TAG, "fetch push url failed code: " + response.code());
                }
                player.mFetching = false;
            }
        }
    };
    private TXFechPushUrlCall mFechCallback = null;
    //获取推流地址
    private OkHttpClient mOkHttpClient = null;
    private boolean mFetching = false;
    private ProgressDialog mFetchProgressDialog;

    private void jumpToHelpPage() {
        Uri uri = Uri.parse("https://cloud.tencent.com/document/product/454/7886");
        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            uri = Uri.parse("https://cloud.tencent.com/document/product/454/7886#RealTimePlay");
        }
        startActivity(new Intent(Intent.ACTION_VIEW,uri));
    }
}