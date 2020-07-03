package com.tencent.liteav.demo.liveplayer;

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
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.liveplayer.view.PlayerVisibleLogView;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;

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

import com.tencent.liteav.demo.liveplayer.utils.Constants;

/**
 * 腾讯云 {@link TXLivePlayer} 直播播放器使用参考 Demo
 * 有以下功能参考 ：
 * - 基本功能参考： 启动推流 {@link #startPlay()}与 结束推流 {@link #stopPlay()}
 * - 硬件加速： 使用硬解码
 * - 性能数据查看参考： {@link #onNetStatus(Bundle)}
 * - 处理 SDK 回调事件参考： {@link #onPlayEvent(int, Bundle)}
 * - 渲染角度、渲染模式切换： 横竖屏渲染、铺满与自适应渲染
 * - 缓存策略选择：{@link #setCacheStrategy} 缓存策略：自动、极速、流畅。 极速模式：时延会尽可能低、但抗网络抖动效果不佳；流畅模式：时延较高、抗抖动能力较强
 */
public class LivePlayerActivity extends Activity implements ITXLivePlayListener {
    private static final String  TAG = LivePlayerActivity.class.getSimpleName();

    private static final float CACHE_TIME_FAST              = 1.0f;
    private static final float CACHE_TIME_SMOOTH            = 5.0f;

    public static final int    ACTIVITY_TYPE_PUBLISH        = 1;
    public static final int    ACTIVITY_TYPE_LIVE_PLAY      = 2;
    public static final int    ACTIVITY_TYPE_VOD_PLAY       = 3;
    public static final int    ACTIVITY_TYPE_LINK_MIC       = 4;
    public static final int    ACTIVITY_TYPE_REALTIME_PLAY  = 5;

    private static final int   BACKGROUND_OPAQUE            = 255;      //背景不透明值
    private static final int   BACKGROUND_TRANSLUCENT       = 100;      //背景半透明值
    private static final int   CACHE_STRATEGY_FAST          = 1;        //极速
    private static final int   CACHE_STRATEGY_SMOOTH        = 2;        //流畅
    private static final int   CACHE_STRATEGY_AUTO          = 3;        //自动
    private static final int   ACTIVITY_SCAN_REQUEST_CODE   = 100;      //启动二维码扫描Activity的请求码
    private static final int   PERMISSION_REQUEST_CODE      = 100;      //申请权限的请求码

    private TXLivePlayer         mLivePlayer;               //直播拉流的视频播放器
    private TXLivePlayConfig     mPlayerConfig;             //TXLivePlayer 播放配置项
    private TXCloudVideoView     mPlayerView;               //播放器的视频渲染View

    private ImageView            mImageLoading;             //显示视频缓冲动画
    private LinearLayout         mLayoutRoot;               //视频暂停时更新背景
    private Button               mButtonQRCodeScan;         //二维码扫描按钮
    private Button               mButtonPlay;               //视频的播放控制按钮
    private Button               mButtonLog;                //展示播放器日志的按钮，分为两种日志展示模式
    private Button               mButtonHWDecode;           //切换软/硬编码模式
    private Button               mButtonRenderRotation;     //调整视频播放方向：横屏、竖屏
    private Button               mButtonRenderMode;         //调整视频渲染模式：全屏、自适应
    private Button               mButtonCacheStrategy;      //设置视频的缓存策略
    private Button               mRatioFastCache;           //极速缓存模式
    private Button               mRatioSmoothCache;         //流畅缓存模式
    private Button               mRatioAutoCache;           //自动缓存模式
    private Button               mButtonAcc;                //切换超低时延视频源，测试专用；
    private PlayerVisibleLogView mPlayerVisibleLogView;     //可视化日志的展示View
    private LinearLayout         mLayoutCacheStrategy;      //显示所有缓存模式的View
    private EditText             mEditRTMPURL;              //编辑视频源URL的文本框
    private ProgressDialog       mProgressDialogFetch;      //加载超低时延视频时展示的进度条，测试专用；

    private int                 mActivityType;
    private int                 mCacheStrategy = 0;         //Player缓存策略
    private long                mStartPlayTS   = 0;         //保存开始播放的时间戳，测试专用
    private boolean             mIsPlaying;                 //记录当前是否在播放视频
    private boolean             mFetching = false;          //是否正在获取视频源，测试专用
    private boolean             mIsAcc    = false;          //是否播放超低时延视频，测试专用
    private boolean             mHWDecode = false;          //是否启用了硬解码
    private int                 mCurrentPlayType       = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;                //Player 当前播放链接类型
    private int                 mCurrentRenderMode     = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;   //Player 当前渲染模式
    private int                 mCurrentRenderRotation = TXLiveConstants.RENDER_ROTATION_PORTRAIT;        //Player 当前渲染角度

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.liveplayer_activity_live_player);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        mActivityType = getIntent().getIntExtra(Constants.INTENT_ACTIVITY_TYPE, ACTIVITY_TYPE_LIVE_PLAY);

        initView();
    }

    private void initView() {
        mLayoutRoot = (LinearLayout) findViewById(R.id.root);
        TextView titleText = (TextView) findViewById(R.id.tv_title);
        titleText.setText(getIntent().getStringExtra(Constants.INTENT_ACTIVITY_TITLE));

        initRTMPURLEdit();
        initQRCodeScanButton();
        initPlayView();
        initLogView();
        initPlayButton();
        initHWDecodeButton();
        initRenderRotationButton();
        initRenderModeButton();
        initCacheStrategyButton();
        initAccButton();
        initNavigationHelp();
        initNavigationBack();

        requestPermissions();
    }

    private void initRTMPURLEdit() {
        mEditRTMPURL = (EditText) findViewById(R.id.roomid);
        mEditRTMPURL.setHint(R.string.liveplayer_hint_rtmp_url_edit);
        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            mEditRTMPURL.setText("");
            fetchPushURL();
        } else {
            mEditRTMPURL.setText(Constants.NORMAL_PLAY_URL);
        }
    }

    private void initQRCodeScanButton() {
        mButtonQRCodeScan = (Button) findViewById(R.id.btnScan);
        mButtonQRCodeScan.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LivePlayerActivity.this, QRCodeScanActivity.class);
                startActivityForResult(intent, ACTIVITY_SCAN_REQUEST_CODE);
            }
        });
        mButtonQRCodeScan.setEnabled(true);
        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mButtonQRCodeScan.getLayoutParams();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                params.removeRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            }
            mButtonQRCodeScan.setLayoutParams(params);
        }
    }

    private void initPlayView() {
        mPlayerConfig = new TXLivePlayConfig();
        mLivePlayer = (mLivePlayer != null) ? mLivePlayer : new TXLivePlayer(this);

        mPlayerView = (TXCloudVideoView) findViewById(R.id.video_view);
        mPlayerView.setLogMargin(12, 12, 110, 60);
        mPlayerView.showLog(false);
        mImageLoading = (ImageView) findViewById(R.id.iv_loading);

    }

    private void initLogView() {
        mPlayerVisibleLogView = (PlayerVisibleLogView) findViewById(R.id.visible_log_view);

        mButtonLog = (Button) findViewById(R.id.btn_log);
        mButtonLog.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mPlayerVisibleLogView.show(false);
                mPlayerVisibleLogView.clickCountUp();
                int count = mPlayerVisibleLogView.getClickCount() % 3;
                if (count == 0) {
                    mButtonLog.setBackgroundResource(R.drawable.liveplayer_log_info_btn_hidden);
                    mPlayerView.showLog(true);
                } else if (count == 1) {
                    mButtonLog.setBackgroundResource(R.drawable.liveplayer_log_info_btn_hidden);
                    mPlayerVisibleLogView.show(true);
                    mPlayerView.showLog(false);
                } else if (count == 2) {
                    mButtonLog.setBackgroundResource(R.drawable.liveplayer_log_info_btn_show);
                    mPlayerView.showLog(false);
                }
            }
        });
    }

    private void initPlayButton() {
        mButtonPlay = (Button) findViewById(R.id.btn_play);
        mButtonPlay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "click playbtn isplay:" + mIsPlaying + " playtype:" + mCurrentPlayType);
                if (mIsPlaying) {
                    stopPlay();
                } else {
                    mIsPlaying = startPlay();
                }
            }
        });
    }

    private void initHWDecodeButton() {

        mButtonHWDecode = (Button) findViewById(R.id.btn_hw_decode);
        mButtonHWDecode.getBackground().setAlpha(mHWDecode ? BACKGROUND_OPAQUE : BACKGROUND_TRANSLUCENT);
        mButtonHWDecode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mHWDecode = !mHWDecode;
                mButtonHWDecode.getBackground().setAlpha(mHWDecode ? BACKGROUND_OPAQUE : BACKGROUND_TRANSLUCENT);

                if (mHWDecode) {
                    Toast.makeText(getApplicationContext(), R.string.liveplayer_toast_start_hw_decode, Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(getApplicationContext(), R.string.liveplayer_toast_close_hw_decode, Toast.LENGTH_SHORT).show();
                }

                if (mIsPlaying) {
                    stopPlay();
                    mIsPlaying = startPlay();
                }
            }
        });
    }

    private void initRenderRotationButton() {
        mButtonRenderRotation = (Button) findViewById(R.id.btn_orientation);
        mButtonRenderRotation.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLivePlayer == null) {
                    return;
                }

                if (mCurrentRenderRotation == TXLiveConstants.RENDER_ROTATION_PORTRAIT) {
                    mButtonRenderRotation.setBackgroundResource(R.drawable.liveplayer_render_rotate_portrait);
                    mCurrentRenderRotation = TXLiveConstants.RENDER_ROTATION_LANDSCAPE;
                } else if (mCurrentRenderRotation == TXLiveConstants.RENDER_ROTATION_LANDSCAPE) {
                    mButtonRenderRotation.setBackgroundResource(R.drawable.liveplayer_render_rotate_landscape);
                    mCurrentRenderRotation = TXLiveConstants.RENDER_ROTATION_PORTRAIT;
                }

                mLivePlayer.setRenderRotation(mCurrentRenderRotation);
            }
        });
    }

    private void initRenderModeButton() {
        mButtonRenderMode = (Button) findViewById(R.id.btn_render_mode);
        mButtonRenderMode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLivePlayer == null) {
                    return;
                }

                if (mCurrentRenderMode == TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN) {
                    mButtonRenderMode.setBackgroundResource(R.drawable.liveplayer_render_mode_fill);
                    mCurrentRenderMode = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;
                } else if (mCurrentRenderMode == TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION) {
                    mButtonRenderMode.setBackgroundResource(R.drawable.liveplayer_adjust_mode_btn);
                    mCurrentRenderMode = TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN;
                }
                mLivePlayer.setRenderMode(mCurrentRenderMode);

            }
        });
    }

    private void initCacheStrategyButton() {
        mLayoutCacheStrategy = (LinearLayout) findViewById(R.id.layout_cache_strategy);
        mButtonCacheStrategy = (Button) findViewById(R.id.btn_cache_strategy);
        mButtonCacheStrategy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutCacheStrategy.setVisibility(mLayoutCacheStrategy.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
            }
        });

        this.setCacheStrategy(CACHE_STRATEGY_AUTO);

        mRatioFastCache = (Button) findViewById(R.id.radio_btn_fast);
        mRatioFastCache.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerActivity.this.setCacheStrategy(CACHE_STRATEGY_FAST);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });

        mRatioSmoothCache = (Button) findViewById(R.id.radio_btn_smooth);
        mRatioSmoothCache.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerActivity.this.setCacheStrategy(CACHE_STRATEGY_SMOOTH);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });

        mRatioAutoCache = (Button) findViewById(R.id.radio_btn_auto);
        mRatioAutoCache.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LivePlayerActivity.this.setCacheStrategy(CACHE_STRATEGY_AUTO);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });
    }

    private void initAccButton() {

        mButtonAcc = (Button) findViewById(R.id.btn_acc);
        mButtonAcc.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsAcc) {
                    mIsAcc = false;
                    mButtonCacheStrategy.setVisibility(View.VISIBLE);
                    findViewById(R.id.btn_cache_strategy_margin).setVisibility(View.VISIBLE);
                    mActivityType = ACTIVITY_TYPE_LIVE_PLAY;
                    mEditRTMPURL.setText(Constants.NORMAL_PLAY_URL);
                    mButtonAcc.setBackgroundResource(R.drawable.liveplayer_acc_btn_on);
                } else {
                    mIsAcc = true;
                    mButtonCacheStrategy.setVisibility(View.GONE);
                    findViewById(R.id.btn_cache_strategy_margin).setVisibility(View.GONE);
                    mActivityType = ACTIVITY_TYPE_REALTIME_PLAY;
                    mEditRTMPURL.setText("");
                    fetchPushURL();
                    mButtonAcc.setBackgroundResource(R.drawable.liveplayer_acc_btn_off);
                }
                if (mIsPlaying) {
                    stopPlay();
                }
            }
        });

    }

    private void initNavigationHelp() {
        findViewById(R.id.btn_trtc_link).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(Constants.LIVE_PLAYER_DOCUMENT_URL));
                startActivity(intent);
            }
        });

    }

    private void initNavigationBack() {
        findViewById(R.id.nav_back).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                stopPlay();
                finish();
            }
        });
    }

    private boolean checkPlayURL(final String playURL) {
        if (TextUtils.isEmpty(playURL)) {
            Toast.makeText(this.getApplicationContext(), R.string.liveplayer_warning_res_url_empty, Toast.LENGTH_SHORT).show();
            return false;
        }

        if (!playURL.startsWith("http://") && !playURL.startsWith("https://")
                        && !playURL.startsWith("rtmp://") && !playURL.startsWith("/")) {
            Toast.makeText(this.getApplicationContext(), R.string.liveplayer_warning_res_url_invalid, Toast.LENGTH_SHORT).show();
            return false;
        }

        boolean isLiveRTMP = playURL.startsWith("rtmp://");
        boolean isLiveFLV = (playURL.startsWith("http://") || playURL.startsWith("https://")) && playURL.contains(".flv");

        if (mActivityType == ACTIVITY_TYPE_LIVE_PLAY) {
            if (isLiveRTMP) {
                mCurrentPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP;
                return true;
            }
            if (isLiveFLV) {
                mCurrentPlayType = TXLivePlayer.PLAY_TYPE_LIVE_FLV;
                return true;
            }
            Toast.makeText(this.getApplicationContext(), R.string.liveplayer_warning_res_url_invalid, Toast.LENGTH_SHORT).show();
            return false;
        }

        if (mActivityType == ACTIVITY_TYPE_REALTIME_PLAY) {
            if (!isLiveRTMP) {
                Toast.makeText(this.getApplicationContext(), R.string.liveplayer_warning_low_latency_format, Toast.LENGTH_SHORT).show();
                return false;
            }

            if (!playURL.contains("txSecret")) {
                new AlertDialog.Builder(this)
                        .setTitle(R.string.liveplayer_error_play_video)
                        .setMessage(R.string.liveplayer_warning_low_latency_singed)
                        .setNegativeButton(R.string.liveplayer_btn_cancel, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).setPositiveButton(R.string.liveplayer_btn_ok, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                Uri uri = Uri.parse(Constants.LIVE_PLAYER_REAL_TIME_PLAY_DOCUMENT_URL);
                                startActivity(new Intent(Intent.ACTION_VIEW, uri));
                                dialog.dismiss();
                            }
                        }).show();
                return false;
            }

            mCurrentPlayType = TXLivePlayer.PLAY_TYPE_LIVE_RTMP_ACC;
            return true;
        }

        Toast.makeText(this.getApplicationContext(), R.string.liveplayer_warning_res_url_invalid, Toast.LENGTH_SHORT).show();
        return false;
    }

    private boolean startPlay() {
        String playURL = mEditRTMPURL.getText().toString();

        if (!checkPlayURL(playURL)) {
            Bundle params = new Bundle();
            params.putString(TXLiveConstants.EVT_DESCRIPTION, this.getString(R.string.liveplayer_warning_checkout_res_url));
            mPlayerVisibleLogView.setLogText(null, params, PlayerVisibleLogView.CHECK_RTMP_URL_FAIL);
            return false;
        }

        /**
         * 更新UI相关
         * */
        Bundle params = new Bundle();
        params.putString(TXLiveConstants.EVT_DESCRIPTION, this.getString(R.string.liveplayer_warning_checkout_res_url));
        mPlayerVisibleLogView.setLogText(null, params, PlayerVisibleLogView.CHECK_RTMP_URL_OK);
        mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_pause_btn);
        mLayoutRoot.setBackgroundColor(getResources().getColor(R.color.liveplayer_black));
        enableQRCodeScanButton(false);
        startLoadingAnimation();

        mLivePlayer.setPlayerView(mPlayerView);
        mLivePlayer.setPlayListener(this);

        /**
         * 硬件加速在1080p解码场景下效果显著，但细节之处并不如想象的那么美好：
         * - 只有 4.3 以上android系统才支持
         * - 兼容性我们目前还仅过了小米华为等常见机型，故这里的返回值您先不要太当真
         *  */
        mLivePlayer.enableHardwareDecode(mHWDecode);
        mLivePlayer.setRenderRotation(mCurrentRenderRotation);
        mLivePlayer.setRenderMode(mCurrentRenderMode);
        mPlayerConfig.setEnableMessage(true);
        mLivePlayer.setConfig(mPlayerConfig);

        /**
         * result返回值：
         * 0 success; -1 empty url; -2 invalid url; -3 invalid playType;
         * */
        int result = mLivePlayer.startPlay(playURL, mCurrentPlayType);
        if (result != 0) {
            mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_start_btn);
            mLayoutRoot.setBackgroundResource(R.drawable.liveplayer_main_bkg);
            return false;
        }
        Log.d("video render", "timetrack start play");
        mStartPlayTS = System.currentTimeMillis();
        return true;
    }

    private void stopPlay() {
        mPlayerVisibleLogView.clear();

        enableQRCodeScanButton(true);
        mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_start_btn);
        mLayoutRoot.setBackgroundResource(R.drawable.liveplayer_main_bkg);
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
        Log.d(TAG, "receive event: " + event + ", " + param.getString(TXLiveConstants.EVT_DESCRIPTION));
        mPlayerVisibleLogView.setLogText(null, param, event);
        switch (event) {
            case TXLiveConstants.PLAY_EVT_PLAY_BEGIN:
                stopLoadingAnimation();
                Log.d("AutoMonitor", "PlayFirstRender,cost=" + (System.currentTimeMillis() - mStartPlayTS));
                break;

            case TXLiveConstants.PLAY_ERR_NET_DISCONNECT:
            case TXLiveConstants.PLAY_EVT_PLAY_END:
                stopPlay();
                break;

            case TXLiveConstants.PLAY_EVT_PLAY_LOADING:
                startLoadingAnimation();
                break;

            case TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME:
                stopLoadingAnimation();
                break;

            case TXLiveConstants.PLAY_EVT_CHANGE_RESOLUTION:
                Log.d(TAG, "size " + param.getInt(TXLiveConstants.EVT_PARAM1) + "x" + param.getInt(TXLiveConstants.EVT_PARAM2));
                break;

            case TXLiveConstants.PLAY_EVT_CHANGE_ROTATION:
                break;

            case TXLiveConstants.PLAY_EVT_GET_MESSAGE:
                if (param != null) {
                    byte data[] = param.getByteArray(TXLiveConstants.EVT_GET_MSG);
                    String seiMessage = "";
                    if (data != null && data.length > 0) {
                        try {
                            seiMessage = new String(data, "UTF-8");
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    Toast.makeText(getApplicationContext(), seiMessage, Toast.LENGTH_SHORT).show();
                }
                break;
        }

        if (event < 0) {
            Toast.makeText(this.getApplicationContext(), param.getString(TXLiveConstants.EVT_DESCRIPTION), Toast.LENGTH_SHORT).show();
        }

    }

    @Override
    public void onNetStatus(Bundle status) {
        Log.d(TAG, "Current status, CPU:" + status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE) +
                ", RES:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT) +
                ", SPD:" + status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps" +
                ", FPS:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS) +
                ", ARA:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps" +
                ", VRA:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps");

        mPlayerVisibleLogView.setLogText(status, null, 0);
    }

    @Override
    public void onBackPressed() {
        stopPlay();
        super.onBackPressed();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mLivePlayer != null) {
            mLivePlayer.stopPlay(true);
            mLivePlayer = null;
        }
        if (mPlayerView != null) {
            mPlayerView.onDestroy();
            mPlayerView = null;
        }
        mPlayerConfig = null;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode != ACTIVITY_SCAN_REQUEST_CODE || data == null || data.getExtras() == null
                || TextUtils.isEmpty(data.getExtras().getString(Constants.INTENT_SCAN_RESULT))) {
            return;
        }
        String result = data.getExtras().getString(Constants.INTENT_SCAN_RESULT);
        if (mEditRTMPURL != null) {
            mEditRTMPURL.setText(result);
        }
    }

    private boolean requestPermissions() {
        if (Build.VERSION.SDK_INT >= 23) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA)) {
                permissions.add(Manifest.permission.CAMERA);
            }
            if (permissions.size() != 0) {
                ActivityCompat.requestPermissions(this, permissions.toArray(new String[0]), PERMISSION_REQUEST_CODE);
                return false;
            }
        }
        return true;
    }

    public void setCacheStrategy(int nCacheStrategy) {
        if (mCacheStrategy == nCacheStrategy) return;
        mCacheStrategy = nCacheStrategy;

        switch (nCacheStrategy) {
            case CACHE_STRATEGY_FAST:
                mPlayerConfig.setAutoAdjustCacheTime(true);
                mPlayerConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_FAST);
                mPlayerConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayerConfig);

                mPlayerVisibleLogView.setCacheTime(CACHE_TIME_FAST);
                break;

            case CACHE_STRATEGY_SMOOTH:
                mPlayerConfig.setAutoAdjustCacheTime(false);
                mPlayerConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayerConfig.setMinAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mLivePlayer.setConfig(mPlayerConfig);

                mPlayerVisibleLogView.setCacheTime(CACHE_TIME_SMOOTH);
                break;

            case CACHE_STRATEGY_AUTO:
                mPlayerConfig.setAutoAdjustCacheTime(true);
                mPlayerConfig.setMaxAutoAdjustCacheTime(CACHE_TIME_SMOOTH);
                mPlayerConfig.setMinAutoAdjustCacheTime(CACHE_TIME_FAST);
                mLivePlayer.setConfig(mPlayerConfig);

                mPlayerVisibleLogView.setCacheTime(CACHE_TIME_SMOOTH);
                break;

            default:
                break;
        }
    }

    /**
     * 网络请求 测试代码
     * */
    private void fetchPushURL() {
        if (mFetching) {
            return;
        }
        mFetching = true;
        if (mProgressDialogFetch == null) {
            mProgressDialogFetch = new ProgressDialog(this);
            // 设置进度条的形式为圆形转动的进度条
            mProgressDialogFetch.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            // 设置是否可以通过点击Back键取消
            mProgressDialogFetch.setCancelable(false);
            // 设置在点击Dialog外是否取消Dialog进度条
            mProgressDialogFetch.setCanceledOnTouchOutside(false);
        }
        mProgressDialogFetch.show();

        OkHttpClient mOkHttpClient = new OkHttpClient().newBuilder()
                    .connectTimeout(10, TimeUnit.SECONDS)
                    .readTimeout(10, TimeUnit.SECONDS)
                    .writeTimeout(10, TimeUnit.SECONDS)
                    .build();

        Request request = new Request.Builder()
                .url(Constants.RTMP_ACC_TEST_URL)
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build();

        Log.d(TAG, "start fetch push url");
        TXFetchPushUrlCall fetchCallback = new TXFetchPushUrlCall(this);
        mOkHttpClient.newCall(request).enqueue(fetchCallback);
    }

    private void startLoadingAnimation() {
        if (mImageLoading != null) {
            mImageLoading.setVisibility(View.VISIBLE);
            ((AnimationDrawable) mImageLoading.getDrawable()).start();
        }
    }

    private void stopLoadingAnimation() {
        if (mImageLoading != null) {
            mImageLoading.setVisibility(View.GONE);
            ((AnimationDrawable) mImageLoading.getDrawable()).stop();
        }
    }

    private void enableQRCodeScanButton(boolean enable) {
        if (mButtonQRCodeScan != null) {
            mButtonQRCodeScan.setEnabled(enable);
        }
    }

    private static class TXFetchPushUrlCall implements Callback {
        WeakReference<LivePlayerActivity> mPlayer;

        public TXFetchPushUrlCall(LivePlayerActivity pusher) {
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
                        Toast.makeText(player, R.string.liveplayer_error_get_test_res, Toast.LENGTH_SHORT).show();
                        player.mProgressDialogFetch.dismiss();
                    }
                });
            }
            Log.e(TAG, "fetch push url failed");
        }

        @Override
        public void onResponse(Call call, Response response) throws IOException {
            if (response.isSuccessful()) {
                String rspString = response.body().string();
                final LivePlayerActivity player = mPlayer.get();
                if (player != null) {
                    try {
                        JSONObject jsonRsp = new JSONObject(rspString);
                        final String playURL = jsonRsp.optString("url_rtmpacc");
                        player.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                player.mEditRTMPURL.setText(playURL);
                                Toast.makeText(player, R.string.liveplayer_toast_fetch_test_res, Toast.LENGTH_LONG).show();
                                player.mProgressDialogFetch.dismiss();
                            }
                        });

                    } catch (Exception e) {
                        Log.e(TAG, "fetch push url error ");
                        Log.e(TAG, e.toString());
                    }
                    player.mFetching = false;
                }

            }
        }
    }

}