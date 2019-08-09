package com.tencent.liteav.demo.lvb.camerapush;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.app.Service;
import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.database.ContentObserver;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.util.TypedValue;
import android.view.Surface;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.common.activity.QRCodeScanActivity;
import com.tencent.liteav.demo.common.view.BeautySettingPannel;
import com.tencent.liteav.demo.common.view.TXPushVisibleLogView;
import com.tencent.rtmp.ITXLivePushListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePushConfig;
import com.tencent.rtmp.TXLivePusher;
import com.tencent.rtmp.ui.TXCloudVideoView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * 腾讯云 {@link TXLivePusher} 推流器使用参考 Demo
 *
 * 有以下功能参考 ：
 *
 * 1. 基本功能参考： 启动推流 {@link #startRTMPPush()} 与 结束推流 {@link #stopRTMPPush()}
 *
 * 2. 场景化配置参考：{@link PusherSettingFragment} 与 {@link #setPushScene(int, boolean)} 您可以根据您的 App 使用设定不同的推流场景，SDK 内部会自动选择相关配置，让您可以快速搭建
 *    注：一般客户建议直接使用场景化配置；若您是专业级客户，推荐您参考 {@link TXLivePushConfig} 进行个性化配置
 *
 * 3. 美颜功能使用参考: {@link BeautySettingPannel} 与 {@link #onBeautyParamsChange(BeautySettingPannel.BeautyParams, int)}
 *
 * 4. 性能数据查看参考： {@link #onNetStatus(Bundle)}
 *
 * 5. 处理 SDK 回调事件参考： {@link #onPushEvent(int, Bundle)}
 *
 * 6. 混响、变声、码率自适应、硬件加速，使用参考： {@link PusherSettingFragment} 与 {@link PusherSettingFragment.OnSettingChangeListener}
 *
 * 7. 横竖屏推流、静音、静画、观众端镜像、闪光灯、调试信息、水印、对焦、缩放功能，使用参考： {@link PusherMoreFragment} 与 {@link PusherMoreFragment.OnMoreChangeListener}
 *
 * 8. 横屏推流使用参考：该功能较为复杂，需要区分Activity是否可以旋转。
 *      A. 不可旋转情况下开启横屏推流：直接参考 {@link #onOrientationChange(boolean)} 即可
 *      B. 可旋转情况下开启横屏推流，参考： {@link ActivityRotationObserver} 与 {@link #setRotationForActivity()}
 *
 * 9. mute功能：muteLocalVideo、muteLocalAudio
 *
 * 10. BGM功能: {@link PusherBGMFragment}
 */
public class CameraPusherActivity extends Activity implements ITXLivePushListener, BeautySettingPannel.IOnBeautyParamsChangeListener,
        PusherSettingFragment.OnSettingChangeListener, PusherMoreFragment.OnMoreChangeListener, PusherBGMFragment.OnBGMControllCallback, TXLivePusher.OnBGMNotify {
    private static final String TAG = CameraPusherActivity.class.getSimpleName();
    /**
     * SDK 提供的类
     */
    private TXLivePushConfig                mLivePushConfig;                // SDK 推流 config
    private TXLivePusher                    mLivePusher;                    // SDK 推流类
    private TXCloudVideoView                mPusherView;                    // SDK 推流本地预览类

    /**
     * 控件
     */
    private TextView                        mTvNetBusyTips;                 // 网络繁忙Tips
    private BeautySettingPannel             mBeautyPannelView;              // 美颜模块pannel
    private EditText                        mEtRTMPURL;                     // RTMP URL链接的View
    private Button                          mBtnStartPush;                  // 开启推流的按钮
    private PusherMoreFragment              mPushMoreFragment;              // 更多Fragment
    private PusherSettingFragment           mPushSettingFragment;           // 设置Fragment
    private PusherBGMFragment               mPushBGMFragment;               // BGM Fragment
    private PusherTroubleshootingFragment   mPusherTroublieshootingFragment;// 问题排查Fragment
    private Button                          mBtnShowQRCode;                 // 显示播放二维码的按钮
    private LinearLayout                    mLlQrCode;                      // 二维码的布局
    private ImageView mIvRTMP, mIvFlv, mIvHls, mIvAccRTMP;                  // RTMP、FLV、HLS、ACCRTMP 二维码地址控件

    /**
     * 默认美颜参数
     */
    private int                             mBeautyLevel    = 5;            // 美颜等级
    private int                             mBeautyStyle    = TXLiveConstants.BEAUTY_STYLE_SMOOTH; // 美颜样式
    private int                             mWhiteningLevel = 3;            // 美白等级
    private int                             mRuddyLevel     = 2;            // 红润等级

    /**
     * 其他参数
     */
    private int                             mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;   // 当前分辨率
    private boolean                         mIsPushing;                     // 当前是否正在推流
    private Bitmap                          mWaterMarkBitmap;               // 水印

    /**
     * 网络相关
     */
    private OkHttpClient                     mOkHttpClient = null;
    private boolean                          mIsGettingRTMPURL = false;     // 当前是否正在获取 RTMP 链接
    private ProgressDialog                   mFetchProgressDialog;          // 获取 RTMP 链接时候的 loading 框

    /**
     * BGM 相关
     */
    private int                              mBGMLoopTimes;                 // 当前BGM循环次数
    private boolean                          mBGMIsOnline;                  // BGM是否在线链接
    private String                           mBGMURL;                       // BGM URL（本地 、 在线）


    private PhoneStateListener               mPhoneListener = null;         // 当前电话监听Listener
    private ActivityRotationObserver         mActivityRotationObserver;     // 监听Activity旋转

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_camera_pusher);
        checkPublishPermission();  // 检查权限
        initPusher();              // 初始化 SDK 推流器
        initTitleBar();            // 初始化 Title Bar
        initToolBar();             // 初始化顶部工具栏
        initListener();            // 初始化电话监听
        initMainView();            // 初始化一些核心的 View
        initToolBottom();          // 初始化底部工具栏
        initFragment();            // 初始化底部工具栏的两个Fragment
    }


    /**
     *  初始化 SDK 推流器
     */
    private void initPusher() {
        mLivePusher = new TXLivePusher(this);
        mLivePushConfig = new TXLivePushConfig();
        mLivePushConfig.setVideoEncodeGop(5);
        mLivePusher.setConfig(mLivePushConfig);
        mWaterMarkBitmap = decodeResource(getResources(), R.drawable.watermark);
    }


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      View初始化相关
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 初始化两个配置的 Fragment
     */
    private void initFragment() {
        if (mPushSettingFragment == null) {
            mPushSettingFragment = new PusherSettingFragment();
            mPushSettingFragment.loadConfig(this);
            mPushSettingFragment.setOnSettingChangeListener(CameraPusherActivity.this);
        }
        if (mPushMoreFragment == null) {
            mPushMoreFragment = new PusherMoreFragment();
            mPushMoreFragment.loadConfig(this);
            mPushMoreFragment.setMoreChangeListener(CameraPusherActivity.this);
        }
        if (mPushBGMFragment == null) {
            mPushBGMFragment = new PusherBGMFragment();
            mPushBGMFragment.setBGMControllCallback(this);
        }
        if (mPusherTroublieshootingFragment == null) {
            mPusherTroublieshootingFragment = new PusherTroubleshootingFragment();
        }
    }

    /**
     * 初始化底部工具栏
     */
    private void initToolBottom() {
        mBtnStartPush = (Button) findViewById(R.id.pusher_btn_start);
        mBtnStartPush.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!mIsPushing) {
                    boolean isSuccess = startRTMPPush();
                } else {
                    stopRTMPPush();
                }
            }
        });


        findViewById(R.id.pusher_btn_beauty).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mBeautyPannelView.isShown()) {
                    mBeautyPannelView.setVisibility(View.GONE);
                } else {
                    mBeautyPannelView.setVisibility(View.VISIBLE);
                }
            }
        });
        findViewById(R.id.pusher_btn_show_log).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPusherTroublieshootingFragment.isVisible()) {
                    try {
                        mPusherTroublieshootingFragment.dismissAllowingStateLoss();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    mPusherTroublieshootingFragment.show(getFragmentManager(), "push_trouble_shooting_fragment");
                }
            }
        });
        findViewById(R.id.pusher_btn_setting).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (mPushSettingFragment.isVisible()) {
                    try {
                        mPushSettingFragment.dismissAllowingStateLoss();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    mPushSettingFragment.show(getFragmentManager(), "push_setting_fragment");
                }
            }
        });
        findViewById(R.id.pusher_btn_more).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPushMoreFragment.isVisible()) {
                    try {
                        mPushMoreFragment.dismissAllowingStateLoss();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    mPushMoreFragment.show(getFragmentManager(), "push_more_fragment");
                }
            }
        });
        findViewById(R.id.pusher_btn_bgm).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mPushBGMFragment.isVisible()) {
                    try {
                        mPushBGMFragment.dismissAllowingStateLoss();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    mPushBGMFragment.show(getFragmentManager(), "push_bgm_fragment");
                }
            }
        });
        findViewById(R.id.pusher_btn_switch_camera).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 表明当前是前摄像头
                if (v.getTag() == null || (Boolean) v.getTag()) {
                    v.setTag(false);
                    v.setBackgroundResource(R.mipmap.camera_back);
                } else {
                    v.setTag(true);
                    v.setBackgroundResource(R.mipmap.camera_front);
                }
                mLivePusher.switchCamera();
            }
        });
    }

    /**
     * 初始化 美颜、log、二维码 等 view
     */
    private void initMainView() {
        mPusherView = (TXCloudVideoView) findViewById(R.id.pusher_tx_cloud_view);
        mBeautyPannelView = (BeautySettingPannel) findViewById(R.id.pusher_beauty_pannel);
        mBeautyPannelView.setBeautyParamsChangeListener(this);
        mTvNetBusyTips = (TextView) findViewById(R.id.pusher_tv_net_error_warning);
        mLlQrCode = (LinearLayout) findViewById(R.id.pusher_ll_code_viewer);
        mIvAccRTMP = (ImageView) findViewById(R.id.pusher_iv_rtmp_acc_url);
        mIvRTMP = (ImageView) findViewById(R.id.pusher_iv_rtmp_url);
        mIvFlv = (ImageView) findViewById(R.id.pusher_iv_flv_url);
        mIvHls = (ImageView) findViewById(R.id.pusher_iv_hls_url);

        mLlQrCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLlQrCode.isShown()) {
                    mLlQrCode.setVisibility(View.GONE);
                } else {
                    mLlQrCode.setVisibility(View.VISIBLE);
                }
            }
        });
    }


    /**
     * 初始化顶部工具栏
     */
    private void initToolBar() {
        mEtRTMPURL = (EditText) findViewById(R.id.pusher_et_rtmp_url);
        mEtRTMPURL.setHint("请输入或扫二维码获取推流地址");
        mEtRTMPURL.setText("");
        findViewById(R.id.pusher_btn_new_push_url).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsGettingRTMPURL) {
                    Toast.makeText(v.getContext(), "已发起获取 RTMP URL，请稍后重试。", Toast.LENGTH_SHORT).show();
                } else {
                    getRTMPPusherFromServer();
                }
                mBtnShowQRCode.setVisibility(View.VISIBLE);
            }
        });
        findViewById(R.id.pusher_btn_scanner).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(CameraPusherActivity.this, QRCodeScanActivity.class);
                startActivityForResult(intent, 100);
            }
        });
        mBtnShowQRCode = (Button) findViewById(R.id.pusher_btn_code_viewer);
        mBtnShowQRCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLlQrCode.isShown()) {
                    mLlQrCode.setVisibility(View.GONE);
                } else {
                    mLlQrCode.setVisibility(View.VISIBLE);
                }
            }
        });
    }

    /**
     * 初始化状态栏
     */
    private void initTitleBar() {
        findViewById(R.id.pusher_ll_return).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 如果正在推流，先停止推流，再退出
                if (mIsPushing) {
                    stopRTMPPush();
                }
                finish();
            }
        });

        findViewById(R.id.pusher_ib_link).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/454/7885"));
                startActivity(intent);
            }
        });
    }

    /**
     * 根据播放连接生成二维码，设置到View中
     *
     * @param playURLArr
     */
    private void initPlayURLQRCodes(final String[] playURLArr) {
        AsyncTask.execute(new Runnable() { // 生成二维码，耗时操作，放到AsyncTask中
            @Override
            public void run() {
                if (playURLArr != null && playURLArr.length == 4) {
                    final Bitmap bitmap = createQRCodeBitmap(playURLArr[0], 300, 300);
                    if (bitmap != null) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (!CameraPusherActivity.this.isFinishing()) {
                                    mIvRTMP.setImageBitmap(bitmap);
                                }
                            }
                        });
                    }

                    final Bitmap bitmap1 = createQRCodeBitmap(playURLArr[1], 300, 300);
                    if (bitmap != null) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (!CameraPusherActivity.this.isFinishing()) {
                                    mIvFlv.setImageBitmap(bitmap1);
                                }
                            }
                        });
                    }

                    final Bitmap bitmap2 = createQRCodeBitmap(playURLArr[2], 300, 300);
                    if (bitmap != null) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (!CameraPusherActivity.this.isFinishing()) {
                                    mIvHls.setImageBitmap(bitmap2);
                                }
                            }
                        });
                    }

                    final Bitmap bitmap3 = createQRCodeBitmap(playURLArr[3], 300, 300);
                    if (bitmap != null) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (!CameraPusherActivity.this.isFinishing()) {
                                    mIvAccRTMP.setImageBitmap(bitmap3);
                                }
                            }
                        });
                    }
                }
            }
        });
    }


    /**
     * 显示网络繁忙的提示
     */
    private void showNetBusyTips() {
        if (mTvNetBusyTips.isShown()) {
            return;
        }
        mTvNetBusyTips.setVisibility(View.VISIBLE);
        mTvNetBusyTips.postDelayed(new Runnable() {
            @Override
            public void run() {
                mTvNetBusyTips.setVisibility(View.GONE);
            }
        }, 5000);
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      Activity声明周期相关
    //
    /////////////////////////////////////////////////////////////////////////////////
    @Override
    public void onResume() {
        super.onResume();
        if (mPusherView != null) {
            mPusherView.onResume();
        }

        if (mIsPushing && mLivePusher != null) {
            // 如果当前是隐私模式，那么不resume
            if (!mPushMoreFragment.isPrivateMode()) {
                mLivePusher.resumePusher();
            }
            mLivePusher.resumeBGM();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if (mPusherView != null) {
            mPusherView.onPause();
        }

        if (mIsPushing && mLivePusher != null) {
            // 如果当前已经是隐私模式，那么则不pause
            if (!mPushMoreFragment.isPrivateMode()) {
                mLivePusher.pausePusher();
            }
            mLivePusher.pauseBGM();
        }

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopRTMPPush(); // 停止推流
        if (mPusherView != null) {
            mPusherView.onDestroy(); // 销毁 View
        }
        unInitPhoneListener();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (data == null || data.getExtras() == null || TextUtils.isEmpty(data.getExtras().getString("result"))) {
            return;
        }
        String result = data.getExtras().getString("result");
        if (mEtRTMPURL != null) {
            mEtRTMPURL.setText(result);
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        setRotationForActivity(); // Activity 旋转
    }


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      权限相关回调接口
    //
    /////////////////////////////////////////////////////////////////////////////////
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case 100:
                for (int ret : grantResults) {
                    if (ret != PackageManager.PERMISSION_GRANTED) {
                        return;
                    }
                }
                break;
            default:
                break;
        }
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
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)) {
                permissions.add(Manifest.permission.RECORD_AUDIO);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE)) {
                permissions.add(Manifest.permission.READ_PHONE_STATE);
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
    //                      网络获取RTMP推流地址
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 从业务后台获取 RTMP 推流地址
     */
    private void getRTMPPusherFromServer() {
        if (mIsGettingRTMPURL) return;
        mIsGettingRTMPURL = true;
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
        String reqUrl = "https://lvb.qcloud.com/weapp/utils/get_test_pushurl";
        Request request = new Request.Builder()
                .url(reqUrl)
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build();
        Log.d(TAG, "start fetch push url");
        mOkHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                CameraPusherActivity activity = CameraPusherActivity.this;
                mFetchProgressDialog.dismiss();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mIsGettingRTMPURL = false;
                        Toast.makeText(CameraPusherActivity.this, "获取推流地址失败", Toast.LENGTH_SHORT).show();
                    }
                });
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                CameraPusherActivity activity = CameraPusherActivity.this;
                mFetchProgressDialog.dismiss();
                if (response.isSuccessful()) {
                    JSONObject jsonRsp = null;
                    try {
                        jsonRsp = new JSONObject(response.body().string());
                        final String rtmpPushUrl = jsonRsp.optString("url_push");            // RTMP 推流地址
                        final String rtmpPlayUrl = jsonRsp.optString("url_play_rtmp");   // RTMP 播放地址
                        final String flvPlayUrl = jsonRsp.optString("url_play_flv");     // FLA  播放地址
                        final String hlsPlayUrl = jsonRsp.optString("url_play_hls");     // HLS  播放地址
                        final String realtimePlayUrl = jsonRsp.optString("url_play_acc");// RTMP 加速流地址

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mEtRTMPURL.setText(rtmpPushUrl);
                                Bundle params = new Bundle();
                                params.putString(TXLiveConstants.EVT_DESCRIPTION, "检查地址合法性");
                                mPusherTroublieshootingFragment.setLogText(null, params, TXPushVisibleLogView.CHECK_RTMP_URL_OK);

                                mIsGettingRTMPURL = false;
                                if (TextUtils.isEmpty(rtmpPushUrl)) {
                                    Toast.makeText(CameraPusherActivity.this, "获取推流地址失败", Toast.LENGTH_SHORT).show();
                                } else {
                                    Toast.makeText(CameraPusherActivity.this, "获取推流地址成功，点击左上角二维码查看推流地址。", Toast.LENGTH_LONG).show();
                                }
                            }
                        });
                        String[] arrays = new String[]{rtmpPlayUrl, flvPlayUrl, hlsPlayUrl, realtimePlayUrl};
                        initPlayURLQRCodes(arrays);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      SDK 推流相关
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 开始 RTMP 推流
     *
     * 推荐使用方式：
     * 1. 配置好 {@link TXLivePushConfig} ， 配置推流参数
     * 2. 调用 {@link TXLivePusher#setConfig(TXLivePushConfig)} ，设置推流参数
     * 3. 调用 {@link TXLivePusher#startCameraPreview(TXCloudVideoView)} ， 开始本地预览
     * 4. 调用 {@link TXLivePusher#startPusher(String)} ， 发起推流
     *
     * 注：步骤 3 要放到 2 之后，否则横屏推流、聚焦曝光、画面缩放功能配置不生效
     * @return
     */
    private boolean startRTMPPush() {
        String tRTMPURL = "";
        String inputUrl = mEtRTMPURL.getText().toString();
        if (!TextUtils.isEmpty(inputUrl)) {
            String url[] = inputUrl.split("###");
            if (url.length > 0) {
                tRTMPURL = url[0];
            }
        }

        if (TextUtils.isEmpty(tRTMPURL) || (!tRTMPURL.trim().toLowerCase().startsWith("rtmp://"))) {
            Toast.makeText(getApplicationContext(), "推流地址不合法，目前支持rtmp推流!", Toast.LENGTH_SHORT).show();

            // 输出状态log
            Bundle params = new Bundle();
            params.putString(TXLiveConstants.EVT_DESCRIPTION, "检查地址合法性");
            mPusherTroublieshootingFragment.setLogText(null, params, TXPushVisibleLogView.CHECK_RTMP_URL_FAIL);
            return false;
        }
        // 显示本地预览的View
        mPusherView.setVisibility(View.VISIBLE);

        // 输出状态log
        Bundle params = new Bundle();
        params.putString(TXLiveConstants.EVT_DESCRIPTION, "检查地址合法性");
        mPusherTroublieshootingFragment.setLogText(null, params, TXPushVisibleLogView.CHECK_RTMP_URL_OK);


        // 添加播放回调
        mLivePusher.setPushListener(this);
        mLivePusher.setBGMNofify(this);

        // 添加后台垫片推流参数
        Bitmap bitmap = decodeResource(getResources(), R.drawable.pause_publish);
        mLivePushConfig.setPauseImg(bitmap);
        mLivePushConfig.setPauseImg(300, 5);
        mLivePushConfig.setPauseFlag(TXLiveConstants.PAUSE_FLAG_PAUSE_VIDEO);// 设置暂停时，只停止画面采集，不停止声音采集。

        // 设置推流分辨率
        mLivePushConfig.setVideoResolution(mCurrentVideoResolution);

        // 设置美颜
        mLivePusher.setBeautyFilter(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);

        // 如果当前Activity可以自动旋转的话，那么需要进行设置
        if (mPushMoreFragment.isActivityCanRotation(this)) {
            setRotationForActivity();
        }

        Log.i(TAG, "startRTMPPush: mPushMore = " + mPushMoreFragment.toString());

        // 开启麦克风推流相关
        mLivePusher.setMute(mPushMoreFragment.isMuteAudio());

        // 横竖屏推流相关
        int renderRotation = 0;
        if (mPushMoreFragment.isPortrait()) {
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
            renderRotation = 0;
        } else {
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT);
            renderRotation = 90; // 因为采集旋转了，那么保证本地渲染是正的，则设置渲染角度为90度。
        }
        mLivePusher.setRenderRotation(renderRotation);

        // 是否开启观众端镜像观看
        mLivePusher.setMirror(mPushMoreFragment.isMirrorEnable());

        // 是否打开调试信息
        mPusherView.showLog(mPushMoreFragment.isDebugInfo());

        // 是否添加水印
        if (mPushMoreFragment.isWaterMarkEnable()) {
            mLivePushConfig.setWatermark(mWaterMarkBitmap, 0.02f, 0.05f, 0.2f);
        } else {
            mLivePushConfig.setWatermark(null, 0, 0, 0);
        }

        // 是否打开曝光对焦
        mLivePushConfig.setTouchFocus(mPushMoreFragment.isFocusEnable());

        // 是否打开手势放大预览画面
        mLivePushConfig.setEnableZoom(mPushMoreFragment.isZoomEnable());

        // 设置推流配置
        mLivePusher.setConfig(mLivePushConfig);

        // 设置场景
        setPushScene(mPushSettingFragment.getQualityType(), mPushSettingFragment.isEnableAdjustBitrate());

        // 设置本地预览View
        mLivePusher.startCameraPreview(mPusherView);
        // 发起推流
        int ret = mLivePusher.startPusher(tRTMPURL.trim());
        if (ret == -5) {
            String errInfo = "License 校验失败";
            int start = (errInfo + " 详情请点击[").length();
            int end = (errInfo + " 详情请点击[License 使用指南").length();
            SpannableStringBuilder spannableStrBuidler = new SpannableStringBuilder(errInfo + " 详情请点击[License 使用指南]");
            ClickableSpan clickableSpan = new ClickableSpan() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent();
                    intent.setAction("android.intent.action.VIEW");
                    Uri content_url = Uri.parse("https://cloud.tencent.com/document/product/454/34750");
                    intent.setData(content_url);
                    startActivity(intent);
                }
            };
            spannableStrBuidler.setSpan(new ForegroundColorSpan(Color.BLUE), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            spannableStrBuidler.setSpan(clickableSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            TextView tv = new TextView(this);
            tv.setMovementMethod(LinkMovementMethod.getInstance());
            tv.setText(spannableStrBuidler);
            tv.setPadding(20, 0, 20, 0);
            AlertDialog.Builder dialogBuidler = new AlertDialog.Builder(this);
            dialogBuidler.setTitle("推流失败").setView(tv).setPositiveButton("确定", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    stopRTMPPush();
                }
            });
            dialogBuidler.show();
            return false;
        }

        // 设置混响
        mLivePusher.setReverb(mPushSettingFragment.getReverbIndex());

        // 设置变声
        mLivePusher.setVoiceChangerType(mPushSettingFragment.getVoiceChangerIndex());

        mIsPushing = true;

        mBtnStartPush.setBackgroundResource(R.mipmap.pusher_stop);

        return true;
    }


    /**
     * 停止 RTMP 推流
     */
    private void stopRTMPPush() {
        // 清除log状态
        mPusherTroublieshootingFragment.clear();

        // 停止BGM
        mLivePusher.stopBGM();
        // 停止本地预览
        mLivePusher.stopCameraPreview(true);
        // 移除监听
        mLivePusher.setPushListener(null);
        // 停止推流
        mLivePusher.stopPusher();
        // 隐藏本地预览的View
        mPusherView.setVisibility(View.GONE);
        // 移除垫片图像
        mLivePushConfig.setPauseImg(null);
        // 关闭隐私模式
        if (mPushMoreFragment != null)
            mPushMoreFragment.closePrivateModel();

        mIsPushing = false;

        mBtnStartPush.setBackgroundResource(R.mipmap.pusher_start);
    }

    /**
     * 根据当前 Activity 的旋转方向，配置推流器
     */
    private void setRotationForActivity() {
        // 自动旋转打开，Activity随手机方向旋转之后，需要改变推流方向
        int mobileRotation = this.getWindowManager().getDefaultDisplay().getRotation();
        int pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
        switch (mobileRotation) {
            case Surface.ROTATION_0:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
                break;
            case Surface.ROTATION_180:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_UP;
                break;
            case Surface.ROTATION_90:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT;
                break;
            case Surface.ROTATION_270:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_LEFT;
                break;
            default:
                break;
        }
        mLivePusher.setRenderRotation(0);                                   // 因为activity也旋转了，本地渲染相对正方向的角度为0。
        mLivePushConfig.setHomeOrientation(pushRotation);                   // 根据Activity方向，设置采集角度
        // 当前正在推流，
        if (mLivePusher.isPushing()) {
            mLivePusher.setConfig(mLivePushConfig);
            // 不是隐私模式，则开启摄像头推流。
            if (!mPushMoreFragment.isPrivateMode()) {
                mLivePusher.stopCameraPreview(true);
                mLivePusher.startCameraPreview(mPusherView);
            }
        }
    }


    /**
     * 推流器状态回调
     *
     * @param event 事件id.id类型请参考 {@linkplain TXLiveConstants#PLAY_EVT_CONNECT_SUCC 推流事件列表}.
     * @param param
     */
    @Override
    public void onPushEvent(int event, Bundle param) {
        String msg = param.getString(TXLiveConstants.EVT_DESCRIPTION);
        String pushEventLog = "receive event: " + event + ", " + msg;
        Log.d(TAG, pushEventLog);
        mPusherTroublieshootingFragment.setLogText(null, param, event);

        // 如果开始推流，设置了隐私模式。 需要在回调里面设置，不能直接start之后直接pause
        if (event == TXLiveConstants.PUSH_EVT_PUSH_BEGIN) {
            if (mPushMoreFragment.isPrivateMode()) {
                mLivePusher.pausePusher();
            }
        }
        // Toast错误内容
        if (event < 0) {
            Toast.makeText(getApplicationContext(), param.getString(TXLiveConstants.EVT_DESCRIPTION), Toast.LENGTH_SHORT).show();
        }

        if (event == TXLiveConstants.PUSH_ERR_NET_DISCONNECT
                || event == TXLiveConstants.PUSH_ERR_INVALID_ADDRESS
                || event == TXLiveConstants.PUSH_ERR_OPEN_CAMERA_FAIL
                || event == TXLiveConstants.PUSH_ERR_OPEN_MIC_FAIL) {
            // 遇到以上错误，则停止推流
            stopRTMPPush();
        } else if (event == TXLiveConstants.PUSH_WARNING_HW_ACCELERATION_FAIL) {
            // 开启硬件加速失败
            Toast.makeText(getApplicationContext(), param.getString(TXLiveConstants.EVT_DESCRIPTION), Toast.LENGTH_SHORT).show();
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_SOFTWARE);
            mLivePusher.setConfig(mLivePushConfig);
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_RESOLUTION) {
            Log.d(TAG, "change resolution to " + param.getInt(TXLiveConstants.EVT_PARAM2) + ", bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_BITRATE) {
            Log.d(TAG, "change bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_WARNING_NET_BUSY) {
            showNetBusyTips();
        } else if (event == TXLiveConstants.PUSH_EVT_START_VIDEO_ENCODER) {
//            int encType = param.getInt(TXLiveConstants.EVT_PARAM1);
//            boolean hwAcc = (encType == TXLiveConstants.ENCODE_VIDEO_HARDWARE);
//            Toast.makeText(CameraPusherActivity.this, "是否启动硬编：" + hwAcc, Toast.LENGTH_SHORT).show();
        } else if (event == TXLiveConstants.PUSH_EVT_OPEN_CAMERA_SUCC) {
            // 只有后置摄像头可以打开闪光灯，若默认需要开启闪光灯。 那么在打开摄像头成功后，才可以进行配置。 若果当前是前置，设定无效；若是后置，打开闪光灯。
            mLivePusher.turnOnFlashLight(mPushMoreFragment.isFlashEnable());
        }
    }


    @Override
    public void onNetStatus(Bundle status) {
        String str = getStatus(status);
        Log.d(TAG, "Current status, CPU:" + status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE) +
                ", RES:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT) +
                ", SPD:" + status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps" +
                ", FPS:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS) +
                ", ARA:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps" +
                ", VRA:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps");
        mPusherTroublieshootingFragment.setLogText(status, null, 0);
//        if (mLivePusher != null){
//            mLivePusher.onLogRecord("[net state]:\n"+str+"\n");
//        }
    }


    /**
     * 获取当前推流状态
     *
     * @param status
     * @return
     */
    private String getStatus(Bundle status) {
        String str = String.format("%-14s %-14s %-12s\n%-8s %-8s %-8s %-8s\n%-14s %-14s %-12s\n%-14s %-14s",
                "CPU:" + status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE),
                "RES:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH) + "*" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT),
                "SPD:" + status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED) + "Kbps",
                "JIT:" + status.getInt(TXLiveConstants.NET_STATUS_NET_JITTER),
                "FPS:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS),
                "GOP:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP) + "s",
                "ARA:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE) + "Kbps",
                "QUE:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE) + "|" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE),
                "DRP:" + status.getInt(TXLiveConstants.NET_STATUS_AUDIO_DROP) + "|" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_DROP),
                "VRA:" + status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE) + "Kbps",
                "SVR:" + status.getString(TXLiveConstants.NET_STATUS_SERVER_IP),
                "AUDIO:" + status.getString(TXLiveConstants.NET_STATUS_AUDIO_INFO));
        return str;
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      美颜模块相关
    //
    /////////////////////////////////////////////////////////////////////////////////

    @Override
    public void onBeautyParamsChange(BeautySettingPannel.BeautyParams params, int key) {
        switch (key) {
            case BeautySettingPannel.BEAUTYPARAM_EXPOSURE:
                if (mLivePusher != null) {
                    mLivePusher.setExposureCompensation(params.mExposure);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_BEAUTY:
                mBeautyStyle = params.mBeautyStyle;
                mBeautyLevel = params.mBeautyLevel;
                if (mLivePusher != null) {
                    mLivePusher.setBeautyFilter(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_WHITE:
                mWhiteningLevel = params.mWhiteLevel;
                if (mLivePusher != null) {
                    mLivePusher.setBeautyFilter(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_BIG_EYE:
                if (mLivePusher != null) {
                    mLivePusher.setEyeScaleLevel(params.mBigEyeLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FACE_LIFT:
                if (mLivePusher != null) {
                    mLivePusher.setFaceSlimLevel(params.mFaceSlimLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FILTER:
                if (mLivePusher != null) {
                    mLivePusher.setFilter(params.mFilterBmp);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_GREEN:
                if (mLivePusher != null) {
                    mLivePusher.setGreenScreenFile(params.mGreenFile);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_MOTION_TMPL:
                if (mLivePusher != null) {
                    mLivePusher.setMotionTmpl(params.mMotionTmplPath);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_RUDDY:
                mRuddyLevel = params.mRuddyLevel;
                if (mLivePusher != null) {
                    mLivePusher.setBeautyFilter(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FACEV:
                if (mLivePusher != null) {
                    mLivePusher.setFaceVLevel(params.mFaceVLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FACESHORT:
                if (mLivePusher != null) {
                    mLivePusher.setFaceShortLevel(params.mFaceShortLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_CHINSLIME:
                if (mLivePusher != null) {
                    mLivePusher.setChinLevel(params.mChinSlimLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_NOSESCALE:
                if (mLivePusher != null) {
                    mLivePusher.setNoseSlimLevel(params.mNoseScaleLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FILTER_MIX_LEVEL:
                if (mLivePusher != null) {
                    mLivePusher.setSpecialRatio(params.mFilterMixLevel / 10.f);
                }
                break;
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      MoreFragment功能回调
    //
    /////////////////////////////////////////////////////////////////////////////////
    @Override
    public void onPrivateModeChange(boolean enable) {
        // 隐私模式下，会进入垫片推流
        if (mLivePusher.isPushing()) {
            if (enable) {
                mLivePusher.pausePusher();
            } else {
                mLivePusher.resumePusher();
            }
        }
    }
    @Override
    public void onMuteAudioChange(boolean enable) {
        mLivePusher.setMute(enable);
    }

    /**
     * 横竖屏推流切换
     *
     * @param isPortrait
     */
    @Override
    public void onOrientationChange(boolean isPortrait) {
        int renderRotation = 0;
        if (isPortrait) {
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
            renderRotation = 0;
        } else {
            mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT);
            renderRotation = 90; // 因为采集旋转了，那么保证本地渲染是正的，则设置渲染角度为90度。
        }
        if (mLivePusher.isPushing()) {
            mLivePusher.setConfig(mLivePushConfig);
            mLivePusher.setRenderRotation(renderRotation);
        }
    }

    /**
     * 镜像切换
     *
     * @param enable
     */
    @Override
    public void onMirrorChange(boolean enable) {
        mLivePusher.setMirror(enable);
    }

    /**
     * 闪光灯切换
     *
     * @param enable
     */
    @Override
    public void onFlashLightChange(boolean enable) {
        mLivePusher.turnOnFlashLight(enable);
    }

    @Override
    public void onDebugInfoChange(boolean enable) {
        mPusherView.showLog(enable);
    }

    /**
     * 水印
     *
     * @param enable
     */
    @Override
    public void onWaterMarkChange(boolean enable) {
        if (enable) {
            mLivePushConfig.setWatermark(mWaterMarkBitmap, 0.02f, 0.05f, 0.2f);
        } else {
            mLivePushConfig.setWatermark(null, 0, 0, 0);
        }
        if (mLivePusher.isPushing()) {
            // 水印变更不需要重启推流，直接应用配置项即可
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    /**
     * 使用硬件加速
     *
     * @param enable
     */
    @Override
    public void onHwAccChange(boolean enable) {
        if (enable) {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_HARDWARE); // 启动硬编
        } else {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_SOFTWARE); // 启动软编
        }
        if (mLivePusher.isPushing()) {
            // 硬件加速变更不需要重启推流，直接应用配置项即可
            mLivePusher.setConfig(mLivePushConfig);
        }
    }

    /**
     * 手动对焦
     *
     * @param enable
     */
    @Override
    public void onFocusChange(boolean enable) {
        mLivePushConfig.setTouchFocus(enable);
        if (mLivePusher.isPushing()) {
            Toast.makeText(this, "当前正在推流，启动或关闭对焦需要重新推流", Toast.LENGTH_SHORT).show();
            stopRTMPPush();
            startRTMPPush();
        }
    }

    /**
     * 缩放
     *
     * @param enable
     */
    @Override
    public void onZoomChange(boolean enable) {
        mLivePushConfig.setEnableZoom(enable);
        if (mLivePusher.isPushing()) {
            Toast.makeText(this, "当前正在推流，启动或关闭缩放需要重新推流", Toast.LENGTH_SHORT).show();
            stopRTMPPush();
            startRTMPPush();
        }
    }

    /**
     * 点击截图
     */
    @Override
    public void onClickSnapshot() {
        if (mLivePusher != null) {
            mLivePusher.snapshot(new TXLivePusher.ITXSnapshotListener() {
                @Override
                public void onSnapshot(final Bitmap bmp) {
                    if (mLivePusher.isPushing()) {
                        saveAndSharePic(bmp);
                    } else {
                        Toast.makeText(CameraPusherActivity.this, "截图失败，请先发起推流", Toast.LENGTH_SHORT).show();
                    }
                }
            });
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      SettingFragment功能回调
    //
    /////////////////////////////////////////////////////////////////////////////////


    /**
     * 码率自适应
     *
     * @param enable
     */
    @Override
    public void onAdjustBitrateChange(boolean enable) {
        setPushScene(mPushSettingFragment.getQualityType(), mPushSettingFragment.isEnableAdjustBitrate());
    }

    /**
     * SDK 场景与清晰度设置
     *
     * @param type
     */
    @Override
    public void onQualityChange(int type) {
        setPushScene(type, mPushSettingFragment.isEnableAdjustBitrate());
    }

    /**
     * 混响配置
     *
     * @param type
     */
    @Override
    public void onReverbChange(int type) {
        if (mLivePusher != null) {
            mLivePusher.setReverb(type);
        }
    }

    /**
     * 变音配置
     *
     * @param type
     */
    @Override
    public void onVoiceChange(int type) {
        if (mLivePusher != null) {
            mLivePusher.setVoiceChangerType(type);
        }
    }

    /**
     * 设置推流场景
     * <p>
     * SDK 内部将根据具体场景，进行推流 分辨率、码率、FPS、是否启动硬件加速、是否启动回声消除 等进行配置
     * <p>
     * 适用于一般客户，方便快速进行配置
     * <p>
     * 专业客户，推荐通过 {@link TXLivePushConfig} 进行逐一配置
     */
    public void setPushScene(int type, boolean enableAdjustBitrate) {
        Log.i(TAG, "setPushScene: type = " + type + " enableAdjustBitrate = " + enableAdjustBitrate);
        // 码率、分辨率自适应都关闭
        boolean autoBitrate = enableAdjustBitrate;
        boolean autoResolution = false;
        switch (type) {
            case TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION: /*360p*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION, autoBitrate, autoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION: /*540p*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION, autoBitrate, autoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION: /*720p*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION, autoBitrate, autoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER: /*连麦大主播*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER, autoBitrate, autoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER: /*连麦小主播*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER, autoBitrate, autoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_320_480;
                }
                break;
            case TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT: /*实时*/
                if (mLivePusher != null) {
                    mLivePusher.setVideoQuality(TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT, autoBitrate, autoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                }
                break;
            default:
                break;
        }
        // 设置场景化配置后，SDK 内部会根据场景自动选择相关的配置参数，所以我们这里把内部的config获取出来，赋值到外部。
        mLivePushConfig = mLivePusher.getConfig();

        // 是否开启硬件加速
        if (mPushSettingFragment.isHWAcc()) {
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_HARDWARE);
            mLivePusher.setConfig(mLivePushConfig);
        }
    }


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      BGM
    //
    /////////////////////////////////////////////////////////////////////////////////


    @Override
    public void onStartPlayBGM(final String url, int loopTimes, boolean isOnline) {
        mBGMURL = url;
        mBGMLoopTimes = loopTimes;
        mBGMIsOnline = isOnline;
        if (mLivePusher != null) {
            mLivePusher.stopBGM();
            if (isOnline) {
                // 在线音乐，由于刚开始需要进行网络请求，所以需要抛到子线程调用，否则有ARN风险
                AsyncTask.execute(new Runnable() {
                    @Override
                    public void run() {
                        mLivePusher.playBGM(url);
                    }
                });
            } else {
                mLivePusher.playBGM(url);
            }
        }
    }

    @Override
    public void onResumeBGM() {
        if (mLivePusher != null)
            mLivePusher.resumeBGM();
    }

    @Override
    public void onPauseBGM() {
        if (mLivePusher != null)
            mLivePusher.pauseBGM();
    }

    @Override
    public void onStopBGM() {
        mBGMURL = null;
        mBGMLoopTimes = 0;
        mBGMIsOnline = false;
        if (mLivePusher != null) {
            mLivePusher.stopBGM();
        }
    }

    @Override
    public void onBGMVolumeChange(float volume) {
        if (mLivePusher != null) {
            mLivePusher.setBGMVolume(volume);
        }
    }

    @Override
    public void onMICVolumeChange(float volume) {
        if (mLivePusher != null) {
            mLivePusher.setMicVolume(volume);
        }
    }

    @Override
    public void onBGMPitchChange(float pitch) {
        if (mLivePusher != null) {
            mLivePusher.setBGMPitch(pitch);
        }
    }


    @Override
    public void onBGMStart() {

    }

    @Override
    public void onBGMProgress(long progress, long duration) {

    }

    @Override
    public void onBGMComplete(int err) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mBGMLoopTimes != 0) {
                    mBGMLoopTimes--;
                    if (mBGMIsOnline) {
                        // 在线音乐，由于刚开始需要进行网络请求，所以需要抛到子线程调用，否则有ARN风险
                        AsyncTask.execute(new Runnable() {
                            @Override
                            public void run() {
                                mLivePusher.playBGM(mBGMURL);
                            }
                        });
                    } else {
                        mLivePusher.playBGM(mBGMURL);
                    }
                }
            }
        });
    }


    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      监听相关
    //
    /////////////////////////////////////////////////////////////////////////////////

    /**
     * 初始化电话监听、系统是否打开旋转监听
     */
    private void initListener() {
        mPhoneListener = new TXPhoneStateListener(mLivePusher);
        TelephonyManager tm = (TelephonyManager) getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);

        mActivityRotationObserver = new ActivityRotationObserver(new Handler(Looper.getMainLooper()));
        mActivityRotationObserver.startObserver();
    }


    /**
     * 销毁
     */
    private void unInitPhoneListener() {
        TelephonyManager tm = (TelephonyManager) getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_NONE);
        mActivityRotationObserver.stopObserver();
    }


    /**
     * 电话监听
     */
    private static class TXPhoneStateListener extends PhoneStateListener {
        WeakReference<TXLivePusher> mPusher;

        public TXPhoneStateListener(TXLivePusher pusher) {
            mPusher = new WeakReference<TXLivePusher>(pusher);
        }

        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            TXLivePusher pusher = mPusher.get();
            switch (state) {
                //电话等待接听
                case TelephonyManager.CALL_STATE_RINGING:
                    if (pusher != null) pusher.pausePusher();
                    break;
                //电话接听
                case TelephonyManager.CALL_STATE_OFFHOOK:
                    if (pusher != null) pusher.pausePusher();
                    break;
                //电话挂机
                case TelephonyManager.CALL_STATE_IDLE:
                    if (pusher != null) pusher.resumePusher();
                    break;
            }
        }
    }

    /**
     * 观察屏幕旋转设置变化
     */
    private class ActivityRotationObserver extends ContentObserver {
        ContentResolver mResolver;

        public ActivityRotationObserver(Handler handler) {
            super(handler);
            mResolver = CameraPusherActivity.this.getContentResolver();
        }

        //屏幕旋转设置改变时调用
        @Override
        public void onChange(boolean selfChange) {
            super.onChange(selfChange);
            if (mPushMoreFragment.isActivityCanRotation(CameraPusherActivity.this)) {
                mPushMoreFragment.hideOrientationButton();
                setRotationForActivity();
            } else {
                mPushMoreFragment.showOrientationButton();
                // 恢复到正方向
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
                // 恢复渲染角度
                mLivePusher.setRenderRotation(0);
                if (mLivePusher.isPushing())
                    mLivePusher.setConfig(mLivePushConfig);
            }
        }

        public void startObserver() {
            mResolver.registerContentObserver(Settings.System.getUriFor(Settings.System.ACCELEROMETER_ROTATION), false, this);
        }

        public void stopObserver() {
            mResolver.unregisterContentObserver(this);
        }
    }
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      工具函数
    //
    /////////////////////////////////////////////////////////////////////////////////


    /**
     * 获取资源图片
     *
     * @param resources
     * @param id
     * @return
     */
    private Bitmap decodeResource(Resources resources, int id) {
        TypedValue value = new TypedValue();
        resources.openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(resources, id, opts);
    }


    /**
     * 利用 QRCode 生成 Bitmap的工具函数
     *
     * @param content
     * @param widthPix
     * @param heightPix
     * @return
     */
    public static Bitmap createQRCodeBitmap(String content, int widthPix, int heightPix) {
        try {
            if (content == null || "".equals(content)) {
                return null;
            }
            //配置参数
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
            //容错级别
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);

            // 图像数据转换，使用了矩阵转换
            BitMatrix bitMatrix = new QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, widthPix, heightPix, hints);
            int[] pixels = new int[widthPix * heightPix];
            // 下面这里按照二维码的算法，逐个生成二维码的图片，
            // 两个for循环是图片横列扫描的结果
            for (int y = 0; y < heightPix; y++) {
                for (int x = 0; x < widthPix; x++) {
                    if (bitMatrix.get(x, y)) {
                        pixels[y * widthPix + x] = 0xff000000;
                    } else {
                        pixels[y * widthPix + x] = 0xffffffff;
                    }
                }
            }
            // 生成二维码图片的格式，使用ARGB_8888
            Bitmap bitmap = Bitmap.createBitmap(widthPix, heightPix, Bitmap.Config.ARGB_8888);
            bitmap.setPixels(pixels, 0, widthPix, 0, 0, widthPix, heightPix);
            return bitmap;
        } catch (WriterException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 保存并分享图片
     *
     * @param bmp
     */
    private void saveAndSharePic(final Bitmap bmp) {
        AsyncTask.execute(new Runnable() {
            @Override
            public void run() {
                String bitmapFileName = UUID.randomUUID().toString();//通过UUID生成字符串文件名
                FileOutputStream out = null;
                final File file = new File("/sdcard/test/pusher/" + bitmapFileName + ".png");
                try {
                    file.getParentFile().mkdirs();
                    if (!file.exists()) {
                        file.createNewFile();
                    }
                    out = new FileOutputStream(file);
                    bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (out != null) {
                            out.flush();
                            out.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                if (file.exists() && file.length() > 0) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(CameraPusherActivity.this, "截图成功", Toast.LENGTH_SHORT).show();
                            Intent intent = new Intent();
                            intent.setAction(Intent.ACTION_SEND);//设置分享行为
                            intent.setType("image/*");  //设置分享内容的类型
                            intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(file));
                            intent = Intent.createChooser(intent, "图片分享");
                            startActivity(intent);
                        }
                    });
                } else {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(CameraPusherActivity.this, "截图失败", Toast.LENGTH_SHORT).show();
                        }
                    });
                }
            }
        });
    }


}
