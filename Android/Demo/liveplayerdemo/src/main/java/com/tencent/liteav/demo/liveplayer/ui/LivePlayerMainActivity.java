package com.tencent.liteav.demo.liveplayer.ui;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
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
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.liveplayer.R;
import com.tencent.liteav.demo.liveplayer.model.Constants;
import com.tencent.liteav.demo.liveplayer.model.LivePlayer;
import com.tencent.liteav.demo.liveplayer.model.LivePlayerImpl;
import com.tencent.liteav.demo.liveplayer.ui.view.LogInfoWindow;
import com.tencent.liteav.demo.liveplayer.ui.view.RadioSelectView.RadioButton;
import com.tencent.liteav.demo.liveplayer.ui.view.RadioSelectView;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.ArrayList;
import java.util.List;

/**
 * 腾讯云 {@link TXLivePlayer} 直播播放器使用参考 Demo
 * 有以下功能参考 ：
 * - 基本功能参考： 启动推流 {@link LivePlayer#startPlay()}与 结束推流 {@link LivePlayer#stopPlay()}
 * - 硬件加速： 使用硬解码
 * - 性能数据查看参考： {@link #onNetStatus(Bundle)}
 * - 处理 SDK 回调事件参考： {@link #onPlayEvent(int, Bundle)}
 * - 渲染角度、渲染模式切换： 横竖屏渲染、铺满与自适应渲染
 * - 缓存策略选择：{@link LivePlayer#setCacheStrategy} 缓存策略：自动、极速、流畅。 极速模式：时延会尽可能低、但抗网络抖动效果不佳；流畅模式：时延较高、抗抖动能力较强
 */
public class LivePlayerMainActivity extends Activity implements LivePlayer.OnLivePlayerCallback {

    private static final String TAG = "LivePlayerActivity";

    private static final int PERMISSION_REQUEST_CODE = 100;      //申请权限的请求码

    private Context         mContext;

    private ImageView       mImageLoading;          //显示视频缓冲动画
    private RelativeLayout  mLayoutRoot;            //视频暂停时更新背景
    private ImageView       mImageRoot;             //背景icon
    private ImageButton     mButtonPlay;            //视频的播放控制按钮
    private ImageButton     mButtonRenderRotation;  //调整视频播放方向：横屏、竖屏
    private ImageButton     mButtonRenderMode;      //调整视频渲染模式：全屏、自适应
    private ImageButton     mButtonCacheStrategy;   //设置视频的缓存策略
    private ImageView       mImageCacheStrategyShadow;
    private ImageButton     mButtonAcc;             //切换超低时延视频源，测试专用；
    private ImageButton     mImageLogInfo;
    private RadioSelectView mLayoutCacheStrategy;   //显示所有缓存模式的View
    private RadioSelectView mLayoutHWDecode;        //显示所有缓存模式的View

    private LogInfoWindow   mLogInfoWindow;

    private LivePlayer      mLivePlayer;

    private int             mLogClickCount = 0;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        setContentView(R.layout.liveplayer_activity_live_player_main);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        initialize();
    }

    private void initialize() {
        mLayoutRoot = (RelativeLayout) findViewById(R.id.liveplayer_rl_root);
        mImageRoot = (ImageView) findViewById(R.id.liveplayer_iv_root);
        initPlayView();
        initLogInfo();
        initPlayButton();
        initHWDecodeButton();
        initRenderRotationButton();
        initRenderModeButton();
        initCacheStrategyButton();
        initAccButton();
        initNavigationBack();
        requestPermissions();
        initRTMPURL();

        // 初始化完成之后自动播放
        mLivePlayer.startPlay();
    }

    private void initRTMPURL() {
        int activityType = getIntent().getIntExtra(Constants.INTENT_ACTIVITY_TYPE, Constants.ACTIVITY_TYPE_LIVE_PLAY);
        String playURL = getIntent().getStringExtra(Constants.INTENT_URL);
        if (activityType == Constants.ACTIVITY_TYPE_REALTIME_PLAY) {
            if (TextUtils.isEmpty(playURL)) {
                mLivePlayer.setPlayURL(Constants.ACTIVITY_TYPE_LIVE_PLAY, Constants.NORMAL_PLAY_URL);
                mButtonCacheStrategy.setClickable(true);
                mImageCacheStrategyShadow.setVisibility(View.GONE);
            } else {
                mLivePlayer.setPlayURL(Constants.ACTIVITY_TYPE_REALTIME_PLAY, playURL);
                mButtonCacheStrategy.setClickable(false);
                mImageCacheStrategyShadow.setVisibility(View.VISIBLE);
            }
        } else {
            if (TextUtils.isEmpty(playURL)) {
                mLivePlayer.setPlayURL(activityType, Constants.NORMAL_PLAY_URL);
            } else {
                mLivePlayer.setPlayURL(activityType, playURL);
            }
            mButtonCacheStrategy.setClickable(true);
            mImageCacheStrategyShadow.setVisibility(View.GONE);
        }
    }

    private void initPlayView() {
        TXCloudVideoView videoView = (TXCloudVideoView) findViewById(R.id.liveplayer_video_view);
        videoView.setLogMargin(12, 12, 110, 60);
        mLivePlayer = new LivePlayerImpl(mContext, videoView);
        mLivePlayer.setOnLivePlayerCallback(this);
        mImageLoading = (ImageView) findViewById(R.id.liveplayer_iv_loading);
    }

    private void initPlayButton() {
        mButtonPlay = (ImageButton) findViewById(R.id.liveplayer_btn_play);
        mButtonPlay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mLivePlayer.togglePlay();
            }
        });
    }

    private void initHWDecodeButton() {
        mLayoutHWDecode = (RadioSelectView) findViewById(R.id.liveplayer_rsv_decode);
        findViewById(R.id.liveplayer_btn_decode).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutHWDecode.setVisibility(View.VISIBLE);
            }
        });
        mLayoutHWDecode.setTitle(R.string.liveplayer_hw_decode);
        String[] stringArray = getResources().getStringArray(R.array.liveplayer_hw_decode);
        mLayoutHWDecode.setData(stringArray, 1);
        mLayoutHWDecode.setRadioSelectListener(new RadioSelectView.RadioSelectListener() {
            @Override
            public void onClose() {
                mLayoutHWDecode.setVisibility(View.GONE);
            }

            @Override
            public void onChecked(int prePosition, RadioButton preRadioButton, int curPosition, RadioButton curRadioButton) {
                mLayoutHWDecode.setVisibility(View.GONE);
                if (curPosition == 0) {
                    Toast.makeText(getApplicationContext(), R.string.liveplayer_toast_start_hw_decode, Toast.LENGTH_SHORT).show();
                } else if (curPosition == 1) {
                    Toast.makeText(getApplicationContext(), R.string.liveplayer_toast_close_hw_decode, Toast.LENGTH_SHORT).show();
                }
                mLivePlayer.setHWDecode(curPosition);
            }
        });
    }

    private void initRenderRotationButton() {
        mButtonRenderRotation = (ImageButton) findViewById(R.id.liveplayer_btn_render_rotate_landscape);
        mButtonRenderRotation.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                int renderRotation = mLivePlayer.getRenderRotation();
                if (renderRotation == TXLiveConstants.RENDER_ROTATION_PORTRAIT) {
                    mButtonRenderRotation.setBackgroundResource(R.drawable.liveplayer_render_rotate_portrait);
                    renderRotation = TXLiveConstants.RENDER_ROTATION_LANDSCAPE;
                } else if (renderRotation == TXLiveConstants.RENDER_ROTATION_LANDSCAPE) {
                    mButtonRenderRotation.setBackgroundResource(R.drawable.liveplayer_render_rotate_landscape);
                    renderRotation = TXLiveConstants.RENDER_ROTATION_PORTRAIT;
                }
                mLivePlayer.setRenderRotation(renderRotation);
            }
        });
    }

    private void initRenderModeButton() {
        mButtonRenderMode = (ImageButton) findViewById(R.id.liveplayer_btn_render_mode_fill);
        mButtonRenderMode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                int renderMode = mLivePlayer.getRenderMode();
                if (mLivePlayer.getRenderMode() == TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN) {
                    mButtonRenderMode.setBackgroundResource(R.drawable.liveplayer_render_mode_fill);
                    renderMode = TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION;
                } else if (mLivePlayer.getRenderMode() == TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION) {
                    mButtonRenderMode.setBackgroundResource(R.drawable.liveplayer_adjust_mode_btn);
                    renderMode = TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN;
                }
                mLivePlayer.setRenderMode(renderMode);
            }
        });
    }

    private void initCacheStrategyButton() {
        mLayoutCacheStrategy = (RadioSelectView) findViewById(R.id.liveplayer_rsv_cache_strategy);
        mImageCacheStrategyShadow = (ImageView) findViewById(R.id.liveplayer_btn_cache_strategy_shadow);
        mButtonCacheStrategy = (ImageButton) findViewById(R.id.liveplayer_btn_cache_strategy);
        mButtonCacheStrategy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutCacheStrategy.setVisibility(mLayoutCacheStrategy.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
            }
        });
        mLayoutCacheStrategy.setTitle(R.string.liveplayer_cache_strategy);
        String[] stringArray = getResources().getStringArray(R.array.liveplayer_cache_strategy);
        mLayoutCacheStrategy.setData(stringArray, Constants.CACHE_STRATEGY_AUTO);
        mLayoutCacheStrategy.setRadioSelectListener(new RadioSelectView.RadioSelectListener() {
            @Override
            public void onClose() {
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }

            @Override
            public void onChecked(int prePosition, RadioButton preRadioButton, int curPosition, RadioButton curRadioButton) {
                if (curPosition == Constants.CACHE_STRATEGY_FAST) {
                    mLogInfoWindow.setCacheTime(Constants.CACHE_TIME_FAST);
                } else {
                    mLogInfoWindow.setCacheTime(Constants.CACHE_TIME_SMOOTH);
                }
                mLivePlayer.setCacheStrategy(curPosition);
                mLayoutCacheStrategy.setVisibility(View.GONE);
            }
        });
        mLivePlayer.setCacheStrategy(Constants.CACHE_STRATEGY_AUTO);
        mLogInfoWindow.setCacheTime(Constants.CACHE_TIME_SMOOTH);
    }

    private void initAccButton() {
        mButtonAcc = (ImageButton) findViewById(R.id.liveplayer_btn_acc);
        mButtonAcc.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLivePlayer.isAcc()) {
                    mButtonCacheStrategy.setClickable(true);
                    mImageCacheStrategyShadow.setVisibility(View.GONE);
                    mButtonAcc.setBackgroundResource(R.drawable.liveplayer_acc);
                } else {
                    mImageCacheStrategyShadow.setVisibility(View.VISIBLE);
                    mButtonCacheStrategy.setClickable(false);
                }
                mLivePlayer.toggleAcc();
            }
        });

    }

    private void initNavigationBack() {
        findViewById(R.id.liveplayer_ibtn_left).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mLivePlayer.destroy();
                finish();
            }
        });
    }

    private void initLogInfo() {
        mImageLogInfo = (ImageButton) findViewById(R.id.liveplayer_ibtn_right);
        mImageLogInfo.setImageResource(R.drawable.liveplayer_log_info_btn_show);
        mImageLogInfo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLogInfoWindow.isShowing()) {
                    mLogInfoWindow.dismiss();
                }
                int count = mLogClickCount % 3;
                if (count == 0) {
                    mLogInfoWindow.show(v);
                    mLivePlayer.showVideoLog(false);
                } else if (count == 1) {
                    mLivePlayer.showVideoLog(true);
                } else if (count == 2) {
                    mLivePlayer.showVideoLog(false);
                }
                mLogClickCount++;
            }
        });
        mLogInfoWindow = new LogInfoWindow(mContext);
    }

    @Override
    public void onPlayEvent(int event, Bundle param) {
        Log.d(TAG, "receive event: " + event + ", " + param.getString(TXLiveConstants.EVT_DESCRIPTION));
        mLogInfoWindow.setLogText(null, param, event);
        switch (event) {
            case TXLiveConstants.PLAY_EVT_PLAY_BEGIN:
            case TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME:
                stopLoadingAnimation();
                break;
            case TXLiveConstants.PLAY_EVT_PLAY_LOADING:
                startLoadingAnimation();
                break;
            case TXLiveConstants.PLAY_EVT_CHANGE_RESOLUTION:
                Log.d(TAG, "size " + param.getInt(TXLiveConstants.EVT_PARAM1) + "x" + param.getInt(TXLiveConstants.EVT_PARAM2));
                break;
            case TXLiveConstants.PLAY_EVT_GET_MESSAGE:
                byte[] data = param.getByteArray(TXLiveConstants.EVT_GET_MSG);
                String seiMessage = "";
                if (data != null && data.length > 0) {
                    try {
                        seiMessage = new String(data, "UTF-8");
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                Toast.makeText(getApplicationContext(), seiMessage, Toast.LENGTH_SHORT).show();
                break;
            case TXLiveConstants.PLAY_EVT_CHANGE_ROTATION:
            case TXLiveConstants.PLAY_ERR_NET_DISCONNECT:
            case TXLiveConstants.PLAY_EVT_PLAY_END:
                break;
        }
        if (event < 0) {
            Toast.makeText(mContext, param.getString(TXLiveConstants.EVT_DESCRIPTION), Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onNetStatus(Bundle bundle) {
        mLogInfoWindow.setLogText(bundle, null, 0);
    }

    @Override
    public void onFetchURLStart() {
        startLoadingAnimation();
    }

    @Override
    public void onFetchURLFailure() {
        stopLoadingAnimation();
        Toast.makeText(mContext, R.string.liveplayer_error_get_test_res, Toast.LENGTH_LONG).show();
    }

    @Override
    public void onFetchURLSuccess(String url) {
        stopLoadingAnimation();
        Toast.makeText(mContext, R.string.liveplayer_toast_fetch_test_res, Toast.LENGTH_LONG).show();
    }

    @Override
    public void onBackPressed() {
        mLivePlayer.stopPlay();
        super.onBackPressed();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mLivePlayer.destroy();
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

    @Override
    public void onPlayStart(int code) {
        switch (code) {
            case Constants.PLAY_STATUS_SUCCESS:
                startLoadingAnimation();
                break;
            case Constants.PLAY_STATUS_EMPTY_URL:
                Toast.makeText(mContext, R.string.liveplayer_warning_res_url_empty, Toast.LENGTH_SHORT).show();
                break;
            case Constants.PLAY_STATUS_INVALID_URL:
                Toast.makeText(mContext, R.string.liveplayer_warning_res_url_invalid, Toast.LENGTH_SHORT).show();
                break;
            case Constants.PLAY_STATUS_INVALID_PLAY_TYPE:
                break;
            case Constants.PLAY_STATUS_INVALID_RTMP_URL:
                Toast.makeText(mContext, R.string.liveplayer_warning_low_latency_format, Toast.LENGTH_SHORT).show();
                break;
            case Constants.PLAY_STATUS_INVALID_SECRET_RTMP_URL:
                new AlertDialog.Builder(mContext)
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
                break;
        }
        if (code != Constants.PLAY_STATUS_SUCCESS) {
            mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_start_btn);
            mLayoutRoot.setBackgroundResource(R.drawable.liveplayer_content_bg);
            mImageRoot.setVisibility(View.VISIBLE);
            Bundle params = new Bundle();
            params.putString(TXLiveConstants.EVT_DESCRIPTION, mContext.getResources().getString(R.string.liveplayer_warning_checkout_res_url));
            mLogInfoWindow.setLogText(null, params, LogInfoWindow.CHECK_RTMP_URL_FAIL);
        } else {
            mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_pause_btn);
            mLayoutRoot.setBackgroundColor(getResources().getColor(R.color.liveplayer_black));
            mImageRoot.setVisibility(View.GONE);
            Bundle params = new Bundle();
            params.putString(TXLiveConstants.EVT_DESCRIPTION, mContext.getResources().getString(R.string.liveplayer_warning_checkout_res_url));
            mLogInfoWindow.setLogText(null, params, LogInfoWindow.CHECK_RTMP_URL_OK);
        }
    }

    @Override
    public void onPlayStop() {
        mButtonPlay.setBackgroundResource(R.drawable.liveplayer_play_start_btn);
        mLayoutRoot.setBackgroundResource(R.drawable.liveplayer_content_bg);
        mImageRoot.setVisibility(View.VISIBLE);
        mLogInfoWindow.clear();
        stopLoadingAnimation();
    }
}