package com.tencent.liteav.demo.lvb.liveplayer;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.drawable.AnimationDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.common.activity.QRCodeScanActivity;
import com.tencent.liteav.demo.common.utils.TCConstants;
import com.tencent.liteav.demo.common.view.TXPlayVisibleLogView;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.ugc.TXRecordCommon;

import org.json.JSONObject;

import java.io.File;
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
 * 腾讯云 {@link TXLivePlayer} 直播播放器使用参考 Demo
 *
 * 有以下功能参考 ：
 *
 * 1. 基本功能参考： 启动推流 {@link #startPlay()}与 结束推流 {@link #stopPlay()}
 *
 * 2. 硬件加速： 使用硬解码
 *
 * 3. 性能数据查看参考： {@link #onNetStatus(Bundle)}
 *
 * 5. 处理 SDK 回调事件参考： {@link #onPlayEvent(int, Bundle)}
 *
 * 6. 渲染角度、渲染模式切换： 横竖屏渲染、铺满与自适应渲染
 *
 * 7. 缓存策略选择：{@link #setCacheStrategy} 缓存策略：自动、极速、流畅。 极速模式：时延会尽可能低、但抗网络抖动效果不佳；流畅模式：时延较高、抗抖动能力较强
 *
 */
public class LivePlayerActivity extends Activity implements ITXLivePlayListener, View.OnClickListener{
    private static final String TAG = LivePlayerActivity.class.getSimpleName();

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

    private static final String NORMAL_PLAY_URL = "http://5815.liveplay.myqcloud.com/live/5815_89aad37e06ff11e892905cb9018cf0d4_900.flv";

    /**
     * SDK player 相关
     */
    private TXLivePlayer     mLivePlayer = null;
    private TXLivePlayConfig mPlayConfig;
    private TXCloudVideoView mPlayerView;

    /**
     * 相关控件
     */
    private ImageView        mLoadingView;
    private LinearLayout     mRootView;
    private Button           mBtnLog;
    private Button           mBtnPlay;
    private Button           mBtnRenderRotation;
    private Button           mBtnRenderMode;
    private Button           mBtnHWDecode;
    private Button           mBtnAcc;
    private Button           mBtnCacheStrategy;
    private Button           mRatioFast;
    private Button           mRatioSmooth;
    private Button           mRatioAuto;
    private ProgressBar      mRecordProgressBar;
    private TextView         mRecordTimeTV;
    private TXPlayVisibleLogView mPlayVisibleLogView;
    private LinearLayout     mLayoutCacheStrategy;
    private EditText         mRtmpUrlView;


    private int              mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP; // player 播放链接类型
    private int              mCurrentRenderMode;                           // player 渲染模式
    private int              mCurrentRenderRotation;                       // player 渲染角度
    private boolean          mHWDecode   = false;                          // 是否使用硬解码
    private int              mCacheStrategy = 0;                           // player 缓存策略
    private boolean          mIsAcc = false;                               // 播放加速流地址 (用于测试

    private boolean          mIsPlaying;
    private long             mStartPlayTS = 0;
    private int              mActivityType;
    private boolean          mRecordFlag = false;
    private boolean          mCancelRecordFlag = false;


    @Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        mCurrentRenderMode     = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;
        mCurrentRenderRotation = TXLiveConstants.RENDER_ROTATION_PORTRAIT;

        mActivityType = getIntent().getIntExtra("PLAY_TYPE", ACTIVITY_TYPE_LIVE_PLAY);

        mPlayConfig = new TXLivePlayConfig();

        setContentView();

    }


    private void setContentView() {
        setContentView(R.layout.activity_play);
        mRtmpUrlView   = (EditText) findViewById(R.id.roomid);
        Button scanBtn = (Button)findViewById(R.id.btnScan);
        scanBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LivePlayerActivity.this, QRCodeScanActivity.class);
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
        mRootView = (LinearLayout) findViewById(R.id.root);
        if (mLivePlayer == null) {
            mLivePlayer = new TXLivePlayer(this);
        }

        mPlayerView = (TXCloudVideoView) findViewById(R.id.video_view);
        mPlayerView.setLogMargin(12, 12, 110, 60);
        mPlayerView.showLog(false);
        mLoadingView = (ImageView) findViewById(R.id.loadingImageView);

        mRtmpUrlView.setHint(" 请输入或扫二维码获取播放地址");
        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            mRtmpUrlView.setText("");
            fetchPushUrl();
        } else {
//           mRtmpUrlView.setText("rtmp://live.hkstv.hk.lxdns.com/live/hks");
           mRtmpUrlView.setText(NORMAL_PLAY_URL);
        }

        mIsPlaying = false;
        mRecordProgressBar = (ProgressBar) findViewById(R.id.record_progress);
        mRecordTimeTV = (TextView) findViewById(R.id.record_time);


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
        mPlayVisibleLogView = (TXPlayVisibleLogView) findViewById(R.id.visibleLogView);

        mBtnLog = (Button) findViewById(R.id.btnLog);
        mBtnLog.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mPlayVisibleLogView.show(false);
                mPlayVisibleLogView.countUp();
                int count = mPlayVisibleLogView.getCount() % 3;
                if (count == 0) {
                    mBtnLog.setBackgroundResource(R.drawable.log_hidden);
                    mPlayerView.showLog(true);
                } else if (count == 1) {
                    mBtnLog.setBackgroundResource(R.drawable.log_hidden);
                    mPlayVisibleLogView.show(true);
                    mPlayerView.showLog(false);
                } else if (count == 2) {
                    mBtnLog.setBackgroundResource(R.drawable.log_show);
                    mPlayerView.showLog(false);
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
        mBtnCacheStrategy.setOnClickListener(new View.OnClickListener() {
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
                LivePlayerActivity.this.setCacheStrategy(CACHE_STRATEGY_FAST);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });

        mRatioSmooth = (Button)findViewById(R.id.radio_btn_smooth);
        mRatioSmooth.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerActivity.this.setCacheStrategy(CACHE_STRATEGY_SMOOTH);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });

        mRatioAuto = (Button)findViewById(R.id.radio_btn_auto);
        mRatioAuto.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerActivity.this.setCacheStrategy(CACHE_STRATEGY_AUTO);
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


        mBtnAcc = (Button) findViewById(R.id.btnAcc);
        mBtnAcc.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsAcc) {
                    mIsAcc = false;
                    mBtnCacheStrategy.setVisibility(View.VISIBLE);
                    findViewById(R.id.btnCacheStrategyMargin).setVisibility(View.VISIBLE);
                    mActivityType = ACTIVITY_TYPE_LIVE_PLAY;
                    mRtmpUrlView.setText(NORMAL_PLAY_URL);
                    mBtnAcc.setBackgroundResource(R.drawable.acc_on);
                } else {
                    mIsAcc = true;
                    mBtnCacheStrategy.setVisibility(View.GONE);
                    findViewById(R.id.btnCacheStrategyMargin).setVisibility(View.GONE);
                    mActivityType = ACTIVITY_TYPE_REALTIME_PLAY;
                    mRtmpUrlView.setText("");
                    fetchPushUrl();
                    mBtnAcc.setBackgroundResource(R.drawable.acc_off);
                }
                if (mIsPlaying) {
                    stopPlay();
                    //mIsPlaying = startPlay();
                }
            }
        });

        View view = mPlayerView.getRootView();
        view.setOnClickListener(this);

        findViewById(R.id.webrtc_link_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/454/7886"));
                startActivity(intent);
            }
        });


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

    private void enableQRCodeBtn(boolean bEnable) {
        Button btnScan = (Button) findViewById(R.id.btnScan);
        if (btnScan != null) {
            btnScan.setEnabled(bEnable);
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      Player 相关
    //
    /////////////////////////////////////////////////////////////////////////////////
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
            {
                if (!playUrl.startsWith("rtmp://")) {
                    Toast.makeText(getApplicationContext(), "低延时拉流仅支持rtmp播放方式", Toast.LENGTH_SHORT).show();
                    return false;
                } else if (!playUrl.contains("txSecret")) {
                    new AlertDialog.Builder(this)
                            .setTitle("播放出错")
                            .setMessage("低延时拉流地址需要防盗链签名，详情参考 https://cloud.tencent.com/document/product/454/7880#RealTimePlay!")
                            .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                }
                            }).setPositiveButton("确定", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            Uri uri = Uri.parse("https://cloud.tencent.com/document/product/454/7880#RealTimePlay!");
                            startActivity(new Intent(Intent.ACTION_VIEW,uri));
                            dialog.dismiss();
                        }
                    }).show();
                    return false;
                }

                mPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP_ACC;
                break;
            }
            default:
                Toast.makeText(getApplicationContext(), "播放地址不合法，目前仅支持rtmp,flv播放方式!", Toast.LENGTH_SHORT).show();
                return false;
        }
        return true;
    }

    /**
     * 开始播放
     *
     * @return
     */
    private boolean startPlay() {
        String playUrl = mRtmpUrlView.getText().toString();

        if (!checkPlayUrl(playUrl)) {
            Bundle params = new Bundle();
            params.putString(TXLiveConstants.EVT_DESCRIPTION, "检查地址合法性");
            mPlayVisibleLogView.setLogText(null, params, TXPlayVisibleLogView.CHECK_RTMP_URL_FAIL);
            return false;
        }
        Bundle params = new Bundle();
        params.putString(TXLiveConstants.EVT_DESCRIPTION, "检查地址合法性");
        mPlayVisibleLogView.setLogText(null, params, TXPlayVisibleLogView.CHECK_RTMP_URL_OK);

        mBtnPlay.setBackgroundResource(R.drawable.play_pause);
        mRootView.setBackgroundColor(0xff000000);

        mLivePlayer.setPlayerView(mPlayerView);

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

    private void stopPlay() {
        mPlayVisibleLogView.clear();

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
        mPlayVisibleLogView.setLogText(null, param, event);
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
            Log.d(TAG, "size "+param.getInt(TXLiveConstants.EVT_PARAM1) + "x" + param.getInt(TXLiveConstants.EVT_PARAM2));
            streamRecord(false);
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
        Log.d(TAG, "Current status, CPU:" + status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE) +
                ", RES:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT) +
                ", SPD:" + status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps" +
                ", FPS:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS) +
                ", ARA:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps" +
                ", VRA:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps");

        mPlayVisibleLogView.setLogText(status, null, 0);
    }



    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      权限检测相关
    //
    /////////////////////////////////////////////////////////////////////////////////
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


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      录制相关
    //
    /////////////////////////////////////////////////////////////////////////////////
    private void streamRecord(boolean runFlag) {
        mRecordFlag = runFlag;
        if (runFlag) {
            mLivePlayer.setVideoRecordListener(new TXRecordCommon.ITXVideoRecordListener() {
                @Override
                public void onRecordEvent(int event, Bundle param) {

                }

                @Override
                public void onRecordProgress(long milliSecond) {
                    if (mCancelRecordFlag) {
                        return;
                    }
                    Log.d(TAG, "onRecordProgress:" + milliSecond);
                    mRecordTimeTV.setText(String.format("%02d:%02d",milliSecond/1000/60, milliSecond/1000%60));
                    int progress = (int)(milliSecond  /  1000);
                    if (progress < 60) {
                        mRecordProgressBar.setProgress(progress);
                    } else {
                        mLivePlayer.stopRecord();
                    }
                }

                @Override
                public void onRecordComplete(TXRecordCommon.TXRecordResult result) {
                    Log.d(TAG, "onRecordComplete. errcode = " + result.retCode + ", errmsg = " + result.descMsg + ", output = " + result.videoPath + ", cover = " + result.coverPath);
                    if (mCancelRecordFlag) {
                        if (result.videoPath != null) {
                            File f = new File(result.videoPath);
                            if (f.exists()) f.delete();
                        }
                        if (result.coverPath != null) {
                            File f = new File(result.coverPath);
                            if (f.exists()) f.delete();
                        }
                    } else {
                        if (result.retCode == TXRecordCommon.RECORD_RESULT_OK) {
                            stopPlay();
//                            Intent intent = null;
//                            intent = new Intent(getApplicationContext(), TCVideoPreviewActivity.class);
//                            if (intent != null) {
//                                intent.putExtra(TCConstants.VIDEO_RECORD_TYPE, TCConstants.VIDEO_RECORD_TYPE_PUBLISH);
//                                intent.putExtra(TCConstants.VIDEO_RECORD_RESULT, result.retCode);
//                                intent.putExtra(TCConstants.VIDEO_RECORD_DESCMSG, result.descMsg);
//                                intent.putExtra(TCConstants.VIDEO_RECORD_VIDEPATH, result.videoPath);
//                                intent.putExtra(TCConstants.VIDEO_RECORD_COVERPATH, result.coverPath);
//                                startActivity(intent);
//                                finish();
//                            }

                        }
                    }
                }
            });
            mCancelRecordFlag = false;
            mLivePlayer.startRecord(TXRecordCommon.RECORD_TYPE_STREAM_SOURCE);
            findViewById(R.id.record).setBackgroundResource(R.drawable.stop_record);
        } else {
            mLivePlayer.stopRecord();
            mRecordTimeTV.setText("00:00");
            mRecordProgressBar.setProgress(0);
            findViewById(R.id.record).setBackgroundResource(R.drawable.start_record);
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      Activity 声明周期相关
    //
    /////////////////////////////////////////////////////////////////////////////////

    @Override
    public void onBackPressed() {
        stopPlay();
        super.onBackPressed();
    }


    @Override
    public void onStop(){
        super.onStop();
        mCancelRecordFlag = true;
        streamRecord(false);
    }

    @Override
	public void onDestroy() {
		super.onDestroy();
		if (mLivePlayer != null) {
            mLivePlayer.stopPlay(true);
            mLivePlayer = null;
        }
        if (mPlayerView != null){
            mPlayerView.onDestroy();
            mPlayerView = null;
        }
        mPlayConfig = null;
        Log.d(TAG,"vrender onDestroy");
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

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btnStreamRecord:
                findViewById(R.id.play_pannel).setVisibility(View.GONE);
                findViewById(R.id.record_layout).setVisibility(View.VISIBLE);
                break;
            case R.id.record:
                streamRecord(!mRecordFlag);
                break;
            case R.id.close_record:
                findViewById(R.id.play_pannel).setVisibility(View.VISIBLE);
                findViewById(R.id.record_layout).setVisibility(View.GONE);
            case R.id.retry_record:
                mCancelRecordFlag = true;
                streamRecord(false);
                break;
            default:
                mLayoutCacheStrategy.setVisibility(View.GONE);
        }
    }



    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      缓存策略配置
    //
    /////////////////////////////////////////////////////////////////////////////////
    public void setCacheStrategy(int nCacheStrategy) {
        if (mCacheStrategy == nCacheStrategy)   return;
        mCacheStrategy = nCacheStrategy;

        switch (nCacheStrategy) {
            case CACHE_STRATEGY_FAST:
                mPlayConfig.setAutoAdjustCacheTime(true);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_FAST);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayConfig);

                mPlayVisibleLogView.setCacheTime(CACHE_TIME_FAST);
                break;

            case CACHE_STRATEGY_SMOOTH:
                mPlayConfig.setAutoAdjustCacheTime(false);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mLivePlayer.setConfig(mPlayConfig);

                mPlayVisibleLogView.setCacheTime(CACHE_TIME_SMOOTH);
                break;

            case CACHE_STRATEGY_AUTO:
                mPlayConfig.setAutoAdjustCacheTime(true);
                mPlayConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayConfig);

                mPlayVisibleLogView.setCacheTime(CACHE_TIME_SMOOTH);
                break;

            default:
                break;
        }
    }



    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      网络请求 测试代码
    //
    /////////////////////////////////////////////////////////////////////////////////
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
        WeakReference<LivePlayerActivity> mPlayer;
        public TXFechPushUrlCall(LivePlayerActivity pusher) {
            mPlayer = new WeakReference<LivePlayerActivity>(pusher);
        }

        @Override
        public void onFailure(Call call, IOException e) {
            final LivePlayerActivity player = mPlayer.get();
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
                final LivePlayerActivity player = mPlayer.get();
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
                    player.mFetching = false;
                }

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