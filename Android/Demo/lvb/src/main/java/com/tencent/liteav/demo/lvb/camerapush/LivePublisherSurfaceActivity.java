package com.tencent.liteav.demo.lvb.camerapush;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.app.Service;
import android.content.ClipboardManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.database.ContentObserver;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.net.Uri;
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
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.demo.beauty.BeautyPanel;
import com.tencent.liteav.demo.lvb.R;
import com.tencent.liteav.demo.lvb.common.activity.QRCodeScanActivity;
import com.tencent.liteav.renderer.TXCFocusIndicatorView;
import com.tencent.rtmp.ITXLivePushListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePushConfig;
import com.tencent.rtmp.TXLivePusher;

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
 * 使用Surface模式进行推流的Activity
 */
public class LivePublisherSurfaceActivity extends Activity implements View.OnClickListener , ITXLivePushListener/*, ImageReader.OnImageAvailableListener*/{
    private static final String TAG = LivePublisherSurfaceActivity.class.getSimpleName();
    private TXLivePushConfig mLivePushConfig;
    private TXLivePusher     mLivePusher;
    private TextureView      mTextureView;
    private Surface          mSurface;
    private LinearLayout     mBitrateLayout;
    private BeautyPanel      mBeautyPannelView;
    private RadioGroup       mRadioGroupBitrate;
    private Button           mBtnBitrate;
    private Button           mBtnPlay;
    private Button           mBtnFaceBeauty;
    private Button           mBtnTouchFocus;
    private Button           mBtnHWEncode;
    private Button           mBtnOrientation;
    protected EditText       mRtmpUrlView;
    private boolean          mPortrait = true;         //手动切换，横竖屏推流
    private boolean          mFrontCamera = true;

    private boolean          mVideoPublish;

    private int              mVideoSrc = VIDEO_SRC_CAMERA;
    private boolean          mHWVideoEncode = true;
    private boolean          mTouchFocus  = true;
    private int              mBeautyLevel = 5;
    private int              mWhiteningLevel = 3;
    private int              mRuddyLevel = 2;
    private int              mBeautyStyle = TXLiveConstants.BEAUTY_STYLE_SMOOTH;


    private static final int VIDEO_SRC_CAMERA = 0;
    private static final int VIDEO_SRC_SCREEN = 1;
    private int              mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;

    private int mNetBusyCount = 0;
    private Handler mMainHandler;
    private TextView mNetBusyTips;
    LinearLayout mBottomLinear = null;

    private int         mVideoQuality = TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION;
    private boolean     mAutoBitrate = false;
    private boolean     mAutoResolution = false;
    private Button      mBtnAutoResolution = null;
    private Button      mBtnAutoBitrate = null;
    private boolean     mIsRealTime = false;

    //获取推流地址
    private OkHttpClient mOkHttpClient = null;
    private boolean mFetching = false;
    private ProgressDialog mFetchProgressDialog;

    // 关注系统设置项“自动旋转”的状态切换
    private RotationObserver mRotationObserver = null;
    private boolean mIsLogShow = false;
    private CheckBox mCbSurface;
    private TXCFocusIndicatorView mFocusView;
    private FrameLayout mFlTouchRoot;

    // Surface模式下，手动对焦相关
    private int mFocusAreaSize = 0;
    private final static int  FOCUS_AREA_SIZE_DP     = 70;
    // Surface模式下，缩放Zoom相关
    private float mScaleFactor;
    private float mLastScaleFactor;
    private boolean mEnableZoom = true; // 是否开启缩放
    // Test 当前是否全屏
    private boolean isFullScreen = true;
    private Bitmap mBitmap;

    private Bitmap decodeResource(Resources resources, int id) {
        TypedValue value = new TypedValue();
        resources.openRawResource(id, value);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        opts.inTargetDensity = value.density;
        return BitmapFactory.decodeResource(resources, id, opts);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(R.style.BeautyTheme);
        mLivePusher     = new TXLivePusher(this);
        mLivePushConfig = new TXLivePushConfig();
        mLivePushConfig.setVideoEncodeGop(5);
        mLivePushConfig.setBeautyFilter(mBeautyLevel, mWhiteningLevel, mRuddyLevel);
        mLivePusher.setConfig(mLivePushConfig);

        mBitmap         = decodeResource(getResources(),R.drawable.watermark);

        mRotationObserver = new RotationObserver(new Handler());
        mRotationObserver.startObserver();

        mMainHandler = new Handler(Looper.getMainLooper());

        setContentView();

        LinearLayout backLL = (LinearLayout)findViewById(R.id.back_ll);
        backLL.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mVideoPublish) {
                    stopPublishRtmp();
                }
                finish();
            }
        });
        TextView titleTV = (TextView) findViewById(R.id.title_tv);
        titleTV.setText(getIntent().getStringExtra("TITLE"));

        mBottomLinear = (LinearLayout)findViewById(R.id.btns_tests);

        checkPublishPermission();

        getWindow().addFlags(WindowManager.LayoutParams.
                FLAG_KEEP_SCREEN_ON);

        mPhoneListener = new TXPhoneStateListener(mLivePusher);
        TelephonyManager tm = (TelephonyManager) getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_CALL_STATE);


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

    protected void initView() {
        mRtmpUrlView   = (EditText) findViewById(R.id.roomid);

        Button scanBtn = (Button)findViewById(R.id.btnScan);
        scanBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LivePublisherSurfaceActivity.this, QRCodeScanActivity.class);
                startActivityForResult(intent, 100);
            }
        });
        scanBtn.setEnabled(true);
        RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)scanBtn.getLayoutParams();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            params.removeRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        }
        scanBtn.setLayoutParams(params);
    }

    public void setContentView() {
        super.setContentView(R.layout.activity_publish_surface);

        initView();

        mTextureView = (TextureView) findViewById(R.id.video_view);
        mFocusView = (TXCFocusIndicatorView) findViewById(R.id.publisher_focus_view);
        mFlTouchRoot = (FrameLayout) findViewById(R.id.publisher_fl_root);
        initTouchGesture();
        mCbSurface = (CheckBox) findViewById(R.id.video_cb_surface);
        mCbSurface.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked && mSurface == null)  {
                    if (mTextureView.getSurfaceTexture() != null)
                        mSurface = new Surface(mTextureView.getSurfaceTexture());
                    if (mLivePusher.isPushing()) //处于推流中才显示
                        mTextureView.setVisibility(View.VISIBLE);
                } else {
                    mTextureView.setVisibility(View.GONE);
                    if (mSurface != null) {
                        mSurface.release();
                    }
                    mSurface = null;
                }
                mLivePusher.setSurface(mSurface);
                mLivePusher.setSurfaceSize(mTextureView.getWidth(), mTextureView.getHeight());
            }
        });

        mTextureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                if (mCbSurface.isChecked())
                    mSurface = new Surface(mTextureView.getSurfaceTexture());
                if (mLivePusher.isPushing()) {
                    mLivePusher.setSurface(mSurface);
                    mLivePusher.setSurfaceSize(width, height);
                }
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
                 mLivePusher.setSurfaceSize(width, height);
            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                if (mSurface!=null)
                    mSurface.release();
                mSurface = null;
                if (mCbSurface.isChecked()) {
                    if (mLivePusher.isPushing()) {
                        mLivePusher.setSurface(mSurface);
                    }
                }

                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surface) {

            }
        });

        mNetBusyTips = (TextView) findViewById(R.id.netbusy_tv);
        mVideoPublish = false;

        mRtmpUrlView.setHint(" 请输入或扫二维码获取推流地址");
        mRtmpUrlView.setText("");

        Button btnNew = (Button)findViewById(R.id.btnNew);
        btnNew.setVisibility(View.VISIBLE);
        btnNew.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                fetchPushUrl();
            }
        });

        //美颜p图部分
        mBeautyPannelView = (BeautyPanel) findViewById(R.id.layoutFaceBeauty);
        PusherBeautyKit manager = new PusherBeautyKit(mLivePusher);
        mBeautyPannelView.setProxy(manager);


        mBtnFaceBeauty = (Button)findViewById(R.id.btnFaceBeauty);
        mBtnFaceBeauty.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mBeautyPannelView.setVisibility(mBeautyPannelView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                mBottomLinear.setVisibility(mBeautyPannelView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
            }
        });

        //播放部分
        mBtnPlay = (Button) findViewById(R.id.btnPlay);
        mBtnPlay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (mVideoPublish) {
                    stopPublishRtmp();
                } else {
                    if(mVideoSrc == VIDEO_SRC_CAMERA){
                        FixOrAdjustBitrate();  //根据设置确定是“固定”还是“自动”码率
                    }
                    else{
                        //录屏横竖屏采用两种分辨率，和摄像头推流逻辑不一样
                    }
                    mVideoPublish = startPublishRtmp();
                }
            }
        });


        //log部分
        final Button btnLog = (Button) findViewById(R.id.btnLog);
        btnLog.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsLogShow) {
                    mIsLogShow = false;
                    btnLog.setBackgroundResource(R.drawable.log_show);
                   // mCaptureView.showLog(false);
                } else {
                    mIsLogShow = true;
                    btnLog.setBackgroundResource(R.drawable.log_hidden);
                   // mCaptureView.showLog(true);
                }
            }
        });

        //切换前置后置摄像头
        final Button btnChangeCam = (Button) findViewById(R.id.btnCameraChange);
        btnChangeCam.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFrontCamera = !mFrontCamera;

                if (mLivePusher.isPushing()) {
                    mLivePusher.switchCamera();
                }
                mLivePushConfig.setFrontCamera(mFrontCamera);
                btnChangeCam.setBackgroundResource(mFrontCamera ? R.drawable.lvb_camera_change : R.drawable.lvb_camera_change2);
            }
        });


        //开启硬件加速
        mBtnHWEncode = (Button) findViewById(R.id.btnHWEncode);
        mBtnHWEncode.getBackground().setAlpha(mHWVideoEncode ? 255 : 100);
        mBtnHWEncode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean HWVideoEncode = mHWVideoEncode;
                mHWVideoEncode = !mHWVideoEncode;
                mBtnHWEncode.getBackground().setAlpha(mHWVideoEncode ? 255 : 100);

                if (mHWVideoEncode){
                    if (mLivePushConfig != null) {
                        if(Build.VERSION.SDK_INT < 18){
                            Toast.makeText(getApplicationContext(), "硬件加速失败，当前手机API级别过低（最低18）", Toast.LENGTH_SHORT).show();
                            mHWVideoEncode = false;
                        }
                        }
                    }
                if(HWVideoEncode != mHWVideoEncode){
                    mLivePushConfig.setHardwareAcceleration(mHWVideoEncode ? TXLiveConstants.ENCODE_VIDEO_HARDWARE : TXLiveConstants.ENCODE_VIDEO_SOFTWARE);
                    if(mHWVideoEncode == false){
                        Toast.makeText(getApplicationContext(), "取消硬件加速", Toast.LENGTH_SHORT).show();
                    }
                    else{
                        Toast.makeText(getApplicationContext(), "开启硬件加速", Toast.LENGTH_SHORT).show();
                    }
                }
                if (mLivePusher != null) {
                    mLivePusher.setConfig(mLivePushConfig);
                }
            }
        });

        //码率自适应部分
        mBtnBitrate = (Button)findViewById(R.id.btnBitrate);
        mBitrateLayout = (LinearLayout)findViewById(R.id.layoutBitrate);
        mBtnBitrate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mBitrateLayout.setVisibility(mBitrateLayout.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                refreshBitrateBtn();
                refreshResolutiontn();
            }
        });

        mRadioGroupBitrate = (RadioGroup)findViewById(R.id.resolutionRadioGroup);
        mRadioGroupBitrate.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                boolean oldMode = mIsRealTime;
                FixOrAdjustBitrate();
//                if (oldMode != mIsRealTime && mLivePusher != null && mLivePusher.isPushing()) {
//                    stopPublishRtmp();
//                    startPublishRtmp();
//                }
            }
        });

        mBtnAutoBitrate = (Button)findViewById(R.id.btn_auto_bitrate);
        mBtnAutoBitrate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mAutoBitrate = !mAutoBitrate;
                refreshBitrateBtn();
                mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                if(mVideoQuality == TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION ||
                        mVideoQuality == TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION ||
                        mVideoQuality == TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION) {
                    mLivePushConfig.setVideoEncodeGop(5);
                }
            }
        });

        mBtnAutoResolution = (Button)findViewById(R.id.btn_auto_resolution);
        mBtnAutoResolution.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mAutoResolution = !mAutoResolution;
                refreshResolutiontn();
                mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                if(mVideoQuality == TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION ||
                        mVideoQuality == TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION ||
                        mVideoQuality == TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION) {
                    mLivePushConfig.setVideoEncodeGop(5);
                }
            }
        });
        //手动对焦/自动对焦
        mBtnTouchFocus = (Button) findViewById(R.id.btnTouchFoucs);
        mBtnTouchFocus.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTouchFocus = !mTouchFocus;
                mLivePushConfig.setTouchFocus(mTouchFocus);
                v.setBackgroundResource(mTouchFocus ? R.drawable.automatic : R.drawable.manual);

                if (mLivePusher.isPushing()) {
                    mLivePusher.stopCameraPreview(false);
                    mLivePusher.startCameraPreview(null);
                    mLivePusher.setSurface(mSurface);
                    mLivePusher.setSurfaceSize(mTextureView.getWidth(), mTextureView.getHeight());
                }

                Toast.makeText(LivePublisherSurfaceActivity.this, mTouchFocus ? "已开启手动对焦" : "已开启自动对焦", Toast.LENGTH_SHORT).show();
            }
        });

        //锁定Activity不旋转的情况下，才能进行横屏|竖屏推流切换
        mBtnOrientation = (Button) findViewById(R.id.btnPushOrientation);
        if (isActivityCanRotation()) {
            mBtnOrientation.setVisibility(View.GONE);
        }
        mBtnOrientation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mPortrait = ! mPortrait;
                int renderRotation = 0;
                int orientation = 0;
                boolean screenCaptureLandscape = false;
                if (mPortrait) {
                    mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
                    mBtnOrientation.setBackgroundResource(R.drawable.landscape);
                    orientation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
                    renderRotation = 0;
                } else {
                    mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT);
                    mBtnOrientation.setBackgroundResource(R.drawable.portrait);
                    screenCaptureLandscape = true;
                    orientation = TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT;
                    renderRotation = 90;
                }
                if(VIDEO_SRC_SCREEN == mVideoSrc){
                    //录屏横竖屏推流的判断条件是，视频分辨率取360*640还是640*360
                    switch (mCurrentVideoResolution){
                        case TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640:
                            if(screenCaptureLandscape)
                                mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_640_360);
                            else mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640);
                            break;
                        case TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960:
                            if(screenCaptureLandscape)
                                mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_960_540);
                            else mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960);
                            break;
                        case TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280:
                            if(screenCaptureLandscape)
                                mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_1280_720);
                            else mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280);
                            break;
                    }

                }
                if (mLivePusher.isPushing()) {
                    if(VIDEO_SRC_CAMERA == mVideoSrc){
                        mLivePusher.setConfig(mLivePushConfig);
                    } else if(VIDEO_SRC_SCREEN == mVideoSrc){
                        mLivePusher.setConfig(mLivePushConfig);
                        mLivePusher.stopScreenCapture();
                        mLivePusher.startScreenCapture();
                    }
                }
                else mLivePusher.setConfig(mLivePushConfig);
                mLivePusher.setRenderRotation(renderRotation);
            }
        });

        View view = findViewById(android.R.id.content);
        view.setOnClickListener(this);


        findViewById(R.id.webrtc_link_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/454/7885"));
                startActivity(intent);
            }
        });


    }





    private void initTouchGesture() {
        // 单击手势识别
        final GestureDetector gestureListener = new GestureDetector(this, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (mBeautyPannelView != null && mBeautyPannelView.getVisibility() == View.VISIBLE) {
                    mBeautyPannelView.setVisibility(View.GONE);
                    mBottomLinear.setVisibility(View.VISIBLE);
                    return true;
                }
                if (mBitrateLayout != null && mBitrateLayout.getVisibility() == View.VISIBLE) {
                    mBitrateLayout.setVisibility(View.GONE);
                    return true;
                }
                if (mTouchFocus && mCbSurface.isChecked()) {
                    onTouchFocus((int)e.getX(), (int)e.getY());
                    mLivePusher.setFocusPosition(e.getX() / mTextureView.getWidth(), e.getY() / mTextureView.getHeight());
                }
                return true;
            }

            @Override
            public boolean onDown(MotionEvent e) {
                return true;
            }
        });
        // 缩放手势识别
        final ScaleGestureDetector scaleGestureDetector = new ScaleGestureDetector(this, new ScaleGestureDetector.OnScaleGestureListener() {
            @Override
            public boolean onScale(ScaleGestureDetector detector) {
                if (mEnableZoom) {
                    int maxZoom = mLivePusher.getMaxZoom();
                    if (maxZoom == 0) {
                        TXCLog.i(TAG, "camera not support zoom");
                        return false;
                    }

                    float factorOffset = detector.getScaleFactor() - mLastScaleFactor;

                    mScaleFactor += factorOffset;
                    mLastScaleFactor = detector.getScaleFactor();
                    if (mScaleFactor < 0) {
                        mScaleFactor = 0;
                    }
                    if (mScaleFactor > 1) {
                        mScaleFactor = 1;
                    }

                    int zoomValue = Math.round(mScaleFactor * maxZoom);
                    mLivePusher.setZoom(zoomValue);
                }
                return false;
            }

            @Override
            public boolean onScaleBegin(ScaleGestureDetector detector) {
                mLastScaleFactor = detector.getScaleFactor();
                return true;
            }

            @Override
            public void onScaleEnd(ScaleGestureDetector detector) {

            }
        });
        mFlTouchRoot.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getPointerCount() == 1) {
                    return gestureListener.onTouchEvent(event);
                } else if(event.getPointerCount() >=2 ) {
                    return scaleGestureDetector.onTouchEvent(event);
                }
                return false;
            }
        });
    }

    public void onTouchFocus(int x, int y) {
        if (mFlTouchRoot == null) {
            return;
        }
        if (x < 0 || y < 0) {
            if (mFocusView != null) {
                mFocusView.setVisibility(View.GONE);
            }
            return;
        }
        final Rect focusRect    = getTouchRect(x, y, mFlTouchRoot.getWidth(), mFlTouchRoot.getHeight(), 1f);
        mFocusView.show(focusRect.left, focusRect.top, focusRect.right - focusRect.left);
    }

    private Rect getTouchRect(int x, int y, int width, int height, float coefficient) {
        if (mFocusAreaSize == 0 && mFlTouchRoot != null) {
            mFocusAreaSize = (int) (FOCUS_AREA_SIZE_DP * mFlTouchRoot.getResources().getDisplayMetrics().density + 0.5f);
        }
        int areaSize = Float.valueOf(mFocusAreaSize * coefficient).intValue();

        int touchX = clamp((x - areaSize / 2), 0, width - areaSize);
        int touchY = clamp((y - areaSize / 2), 0, height - areaSize);

        return new Rect(touchX, touchY, touchX + areaSize, touchY + areaSize);
    }

    private int clamp(int x, int min, int max) {
        if (x > max) {
            return max;
        }
        if (x < min) {
            return min;
        }
        return x;
    }


    protected void HWListConfirmDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(LivePublisherSurfaceActivity.this);
        builder.setMessage("警告：当前机型不在白名单中,是否继续尝试硬编码？");
        builder.setPositiveButton("确认", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                throw new RuntimeException();
            }
        });
        builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                throw new RuntimeException();
            }
        });
        builder.setCancelable(false);
        builder.create().show();
        try {
            Looper.loop();
        }catch (Exception e) {}
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            default:
                mBottomLinear.setVisibility(View.VISIBLE);
                mBeautyPannelView.setVisibility(View.GONE);
                mBitrateLayout.setVisibility(View.GONE);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onResume() {
        super.onResume();


        if (mVideoPublish && mLivePusher != null && mVideoSrc == VIDEO_SRC_CAMERA) {
            mLivePusher.resumePusher();
            mLivePusher.resumeBGM();
        }
    }

    @Override
    public void onStop(){
        super.onStop();

        if (mVideoPublish && mLivePusher != null && mVideoSrc == VIDEO_SRC_CAMERA) {
            mLivePusher.pausePusher();
            mLivePusher.pauseBGM();
        }

    }

	@Override
	public void onDestroy() {
		super.onDestroy();
        stopPublishRtmp();

        mRotationObserver.stopObserver();

        TelephonyManager tm = (TelephonyManager) getApplicationContext().getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneListener, PhoneStateListener.LISTEN_NONE);

    }

    // 重载android标准实现函数
    protected void enableQRCodeBtn(boolean bEnable) {
        //disable qrcode
        Button btnScan = (Button) findViewById(R.id.btnScan);
        if (btnScan != null) {
            btnScan.setEnabled(bEnable);
        }
    }

    //公用打印辅助函数
    protected String getNetStatusString(Bundle status) {
        String str = String.format("%-14s %-14s %-12s\n%-8s %-8s %-8s %-8s\n%-14s %-14s %-12s\n%-14s %-14s",
                "CPU:"+status.getString(TXLiveConstants.NET_STATUS_CPU_USAGE),
                "RES:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH)+"*"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT),
                "SPD:"+status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED)+"Kbps",
                "JIT:"+status.getInt(TXLiveConstants.NET_STATUS_NET_JITTER),
                "FPS:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS),
                "GOP:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP)+"s",
                "ARA:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE)+"Kbps",
                "QUE:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE)+"|"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE),
                "DRP:"+status.getInt(TXLiveConstants.NET_STATUS_AUDIO_DROP)+"|"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_DROP),
                "VRA:"+status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE)+"Kbps",
                "SVR:"+status.getString(TXLiveConstants.NET_STATUS_SERVER_IP),
                "AUDIO:"+status.getString(TXLiveConstants.NET_STATUS_AUDIO_INFO));
        return str;
    }

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

    private  boolean startPublishRtmp() {
        String rtmpUrl = "";
        String inputUrl = mRtmpUrlView.getText().toString();
        if (!TextUtils.isEmpty(inputUrl)) {
            String url[] = inputUrl.split("###");
            if (url.length > 0) {
                rtmpUrl = url[0];
            }
        }

        if (TextUtils.isEmpty(rtmpUrl) || (!rtmpUrl.trim().toLowerCase().startsWith("rtmp://"))) {
            Toast.makeText(getApplicationContext(), "推流地址不合法，目前支持rtmp推流!", Toast.LENGTH_SHORT).show();
            return false;
        }

        // demo默认不加水印
        //mLivePushConfig.setWatermark(mBitmap, 0.02f, 0.05f, 0.2f);

        int customModeType = 0;

        //【示例代码1】设置自定义视频采集逻辑 （自定义视频采集逻辑不要调用startPreview）
//        customModeType |= TXLiveConstants.CUSTOM_MODE_VIDEO_CAPTURE;
//        mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_640_360);
//        mLivePushConfig.setAutoAdjustBitrate(false);
//        mLivePushConfig.setVideoBitrate(1300);
//        mLivePushConfig.setVideoEncodeGop(3);
//        new Thread() {  //视频采集线程
//            @Override
//            public void run() {
//                while (true) {
//                    try {
//                        FileInputStream in = new FileInputStream("/sdcard/dump_1280_720.yuv");
//                        int len = 1280 * 720 * 3 / 2;
//                        byte buffer[] = new byte[len];
//                        int count;
//                        while ((count = in.read(buffer)) != -1) {
//                            if (len == count) {
//                                mLivePusher.sendCustomVideoData(buffer, TXLivePusher.YUV_420SP);
//                            } else {
//                                break;
//                            }
//                            sleep(50, 0);
//                        }
//                        in.close();
//                    } catch (Exception e) {
//                        // TODO Auto-generated catch block
//                        e.printStackTrace();
//                    }
//                }
//            }
//        }.start();

        //【示例代码2】设置自定义音频采集逻辑（音频采样位宽必须是16）
//        customModeType |= TXLiveConstants.CUSTOM_MODE_AUDIO_CAPTURE;
//        final int samplerate = 48000;
//        final int channels = 1;
//        final int samplesPerAAC = 1024; //一帧aac包含的采样点数
//        final int bytesPerSample = 2; //一个采样点包含的字节数
//        mLivePushConfig.setAudioSampleRate(samplerate);
//        mLivePushConfig.setAudioChannels(channels);
//        new Thread() {  //音频采集线程
//            @Override
//            public void run() {
//                while (true) {
//                    try {
//                        FileInputStream in = new FileInputStream("/sdcard/test.pcm");
//                        int len = samplesPerAAC * bytesPerSample;
//                        byte buffer[] = new byte[len];
//                        int count;
//                        while ((count = in.read(buffer)) != -1) {
//                            if (len == count) {
//                                mLivePusher.sendCustomPCMData(buffer);
//                            } else {
//                                break;
//                            }
//                            int sendInterval = samplesPerAAC * 1000 / samplerate;//发送间隔要按照采样率和一帧aac大小计算出来
//                            sleep(sendInterval, 0);
//                        }
//                        in.close();
//                    } catch (Exception e) {
//                        // TODO Auto-generated catch block
//                        e.printStackTrace();
//                    }
//                }
//            }
//        }.start();

        //【示例代码3】设置自定义视频预处理逻辑
//        customModeType |= TXLiveConstants.CUSTOM_MODE_VIDEO_PREPROCESS;
//        String path = this.getActivity().getApplicationInfo().dataDir + "/lib";
//        mLivePushConfig.setCustomVideoPreProcessLibrary(path +"/libvideo.so", "tx_video_process");

        //【示例代码4】设置自定义音频预处理逻辑
//        customModeType |= TXLiveConstants.CUSTOM_MODE_AUDIO_PREPROCESS;
//        String path = this.getActivity().getApplicationInfo().dataDir + "/lib";
//        mLivePushConfig.setCustomAudioPreProcessLibrary(path +"/libvideo.so", "tx_audio_process");

//        mLivePushConfig.setAutoAdjustBitrate(true);
//        mLivePushConfig.setMaxVideoBitrate(1200);
//        mLivePushConfig.setMinVideoBitrate(500);
//        mLivePushConfig.setVideoBitrate(600);
//        mLivePushConfig.enablePureAudioPush(true);
        //mLivePushConfig.enableHighResolutionCaptureMode(false);
        if (isActivityCanRotation()) {
            onActivityRotation();
        }
        mLivePushConfig.setEnableZoom(mEnableZoom);
        mLivePushConfig.setCustomModeType(customModeType);
        mLivePusher.setPushListener(this);
        mLivePushConfig.setPauseImg(300,5);
        Bitmap bitmap = decodeResource(getResources(),R.drawable.pause_publish);
        mLivePushConfig.setPauseImg(bitmap);
        mLivePushConfig.setPauseFlag(TXLiveConstants.PAUSE_FLAG_PAUSE_VIDEO | TXLiveConstants.PAUSE_FLAG_PAUSE_AUDIO);
        if(mVideoSrc != VIDEO_SRC_SCREEN){
            mLivePushConfig.setFrontCamera(mFrontCamera);
            mLivePushConfig.setBeautyFilter(mBeautyLevel, mWhiteningLevel, mRuddyLevel);
            mLivePusher.setConfig(mLivePushConfig);
            mLivePusher.startCameraPreview(null);
            if (mCbSurface.isChecked()) {
                mTextureView.setVisibility(View.VISIBLE);
                mLivePusher.setSurface(mSurface);
                mLivePusher.setSurfaceSize(mTextureView.getWidth(), mTextureView.getHeight());
            } else {
                mLivePusher.setSurface(null);
            }
        }
        else{
            mLivePusher.setConfig(mLivePushConfig);
            mLivePusher.startScreenCapture();
        }

        int ret = mLivePusher.startPusher(rtmpUrl.trim());
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
                    stopPublishRtmp();
                }
            });
            dialogBuidler.show();
            return false;
        }

        enableQRCodeBtn(false);

        mBtnPlay.setBackgroundResource(R.drawable.play_pause);

        return true;
    }

    private void stopPublishRtmp() {
        mTextureView.setVisibility(View.GONE);
        mVideoPublish = false;
        mLivePusher.stopBGM();
        mLivePusher.stopCameraPreview(true);
        mLivePusher.stopScreenCapture();
        mLivePusher.setPushListener(null);
        mLivePusher.stopPusher();

        if(mBtnHWEncode != null) {
            //mHWVideoEncode = true;
            mLivePushConfig.setHardwareAcceleration(mHWVideoEncode ? TXLiveConstants.ENCODE_VIDEO_HARDWARE : TXLiveConstants.ENCODE_VIDEO_SOFTWARE);
            mBtnHWEncode.setBackgroundResource(R.drawable.quick);
            mBtnHWEncode.getBackground().setAlpha(mHWVideoEncode ? 255 : 100);
        }

        enableQRCodeBtn(true);
        mBtnPlay.setBackgroundResource(R.drawable.play_start);

        if(mLivePushConfig != null) {
            mLivePushConfig.setPauseImg(null);
        }
    }

    public void FixOrAdjustBitrate() {
        if (mRadioGroupBitrate == null || mLivePushConfig == null || mLivePusher == null) {
            return;
        }
        RadioButton rb = (RadioButton) findViewById(mRadioGroupBitrate.getCheckedRadioButtonId());
        if (rb == null) {
            return;
        }
        int mode = Integer.parseInt((String) rb.getTag());
        mIsRealTime = false;
        mLivePushConfig.setVideoEncodeGop(5);
        switch (mode) {
            case 1: /*360p*/
                if (mLivePusher != null) {
                    mVideoQuality = TXLiveConstants.VIDEO_QUALITY_STANDARD_DEFINITION;
                    mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                    mLivePushConfig.setVideoEncodeGop(5);
                    //标清默认开启了码率自适应，需要关闭码率自适应
                    mLivePushConfig.setAutoAdjustBitrate(false);
                    mLivePushConfig.setVideoBitrate(700);
                    mLivePusher.setConfig(mLivePushConfig);
                    //标清默认关闭硬件加速
                    mHWVideoEncode = false;
                    mBtnHWEncode.getBackground().setAlpha(100);
                }
                break;
            case 2: /*540p*/
                if (mLivePusher != null) {
                    mVideoQuality = TXLiveConstants.VIDEO_QUALITY_HIGH_DEFINITION;
                    mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960;
                    mHWVideoEncode = false;
                    mLivePushConfig.setVideoEncodeGop(5);
                    mBtnHWEncode.getBackground().setAlpha(100);
                }
                break;
            case 3: /*720p*/
                if (mLivePusher != null) {
                    mVideoQuality = TXLiveConstants.VIDEO_QUALITY_SUPER_DEFINITION;
                    mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280;
                    mLivePushConfig.setVideoEncodeGop(5);
                    //超清默认开启硬件加速
                    if (Build.VERSION.SDK_INT >= 18) {
                        mHWVideoEncode = true;
                    }
                    mBtnHWEncode.getBackground().setAlpha(255);
                }
                break;
            case 4: /*连麦大主播*/
                if (mLivePusher != null) {
                    mVideoQuality = TXLiveConstants.VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER;
                    mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                    mHWVideoEncode = true;
                    mBtnHWEncode.getBackground().setAlpha(255);
                }
                break;
            case 5: /*连麦小主播*/
                if (mLivePusher != null) {
                    mVideoQuality = TXLiveConstants.VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER;
                    mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_320_480;
                    mHWVideoEncode = true;
                    mBtnHWEncode.getBackground().setAlpha(255);
                }
                break;
            case 6: /*实时*/
                if (mLivePusher != null) {
                    mVideoQuality = TXLiveConstants.VIDEO_QUALITY_REALTIEM_VIDEOCHAT;
                    mLivePusher.setVideoQuality(mVideoQuality, mAutoBitrate, mAutoResolution);
                    mCurrentVideoResolution = TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640;
                    //超清默认开启硬件加速
                    if (Build.VERSION.SDK_INT >= 18) {
                        mHWVideoEncode = true;
                        mBtnHWEncode.getBackground().setAlpha(255);
                    }
                    mIsRealTime = true;
                }
                break;
            default:
                break;
        }
    }

    private void showNetBusyTips() {
        if (mNetBusyTips.isShown()) {
            return;
        }
        mNetBusyTips.setVisibility(View.VISIBLE);
        mMainHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
               mNetBusyTips.setVisibility(View.GONE);
            }
        }, 5000);
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

        String reqUrl = "https://lvb.qcloud.com/weapp/utils/get_test_pushurl";
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

    @Override
    public void onPushEvent(int event, Bundle param) {
//        Log.e("NotifyCode","LivePublisherActivity :" + event);
        String msg = param.getString(TXLiveConstants.EVT_DESCRIPTION);
        String pushEventLog = "receive event: " + event + ", " + msg;
        Log.d(TAG, pushEventLog);
//        if (mLivePusher != null) {
//            mLivePusher.onLogRecord("[event:" + event + "]" + msg + "\n");
//        }
        //错误还是要明确的报一下
        if (event < 0) {
            Toast.makeText(getApplicationContext(), param.getString(TXLiveConstants.EVT_DESCRIPTION), Toast.LENGTH_SHORT).show();
            if(event == TXLiveConstants.PUSH_ERR_OPEN_CAMERA_FAIL || event == TXLiveConstants.PUSH_ERR_OPEN_MIC_FAIL){
                stopPublishRtmp();
            }
        }

        if (event == TXLiveConstants.PUSH_ERR_NET_DISCONNECT || event == TXLiveConstants.PUSH_ERR_INVALID_ADDRESS) {
            stopPublishRtmp();
        }
        else if (event == TXLiveConstants.PUSH_WARNING_HW_ACCELERATION_FAIL) {
            Toast.makeText(getApplicationContext(), param.getString(TXLiveConstants.EVT_DESCRIPTION), Toast.LENGTH_SHORT).show();
            mLivePushConfig.setHardwareAcceleration(TXLiveConstants.ENCODE_VIDEO_SOFTWARE);
            mBtnHWEncode.setBackgroundResource(R.drawable.quick2);
            mLivePusher.setConfig(mLivePushConfig);
            mHWVideoEncode = false;
        }
        else if (event == TXLiveConstants.PUSH_ERR_SCREEN_CAPTURE_UNSURPORT) {
            stopPublishRtmp();
        }
        else if (event == TXLiveConstants.PUSH_ERR_SCREEN_CAPTURE_START_FAILED) {
            stopPublishRtmp();
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_RESOLUTION) {
            Log.d(TAG, "change resolution to " + param.getInt(TXLiveConstants.EVT_PARAM2) + ", bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_EVT_CHANGE_BITRATE) {
            Log.d(TAG, "change bitrate to" + param.getInt(TXLiveConstants.EVT_PARAM1));
        } else if (event == TXLiveConstants.PUSH_WARNING_NET_BUSY) {
            ++mNetBusyCount;
            Log.d(TAG, "net busy. count=" + mNetBusyCount);
            showNetBusyTips();
        } else if (event == TXLiveConstants.PUSH_EVT_START_VIDEO_ENCODER) {
            int encType = param.getInt(TXLiveConstants.EVT_PARAM1);
            mHWVideoEncode = (encType == 1);
            mBtnHWEncode.getBackground().setAlpha(mHWVideoEncode ? 255 : 100);
        }
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
//        if (mLivePusher != null){
//            mLivePusher.onLogRecord("[net state]:\n"+str+"\n");
//        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        onActivityRotation();
        super.onConfigurationChanged(newConfig);
    }

    protected void onActivityRotation()
    {
        // 自动旋转打开，Activity随手机方向旋转之后，需要改变推流方向
        int mobileRotation = this.getWindowManager().getDefaultDisplay().getRotation();
        int pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
        boolean screenCaptureLandscape = false;
        switch (mobileRotation) {
            case Surface.ROTATION_0:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_DOWN;
                break;
            case Surface.ROTATION_180:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_UP;
                break;
            case Surface.ROTATION_90:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_RIGHT;
                screenCaptureLandscape = true;
                break;
            case Surface.ROTATION_270:
                pushRotation = TXLiveConstants.VIDEO_ANGLE_HOME_LEFT;
                screenCaptureLandscape = true;
                break;
            default:
                break;
        }
        mLivePusher.setRenderRotation(0); //因为activity也旋转了，本地渲染相对正方向的角度为0。
        mLivePushConfig.setHomeOrientation(pushRotation);
        if (mLivePusher.isPushing()) {
            if(VIDEO_SRC_CAMERA == mVideoSrc){
                mLivePusher.setConfig(mLivePushConfig);
                mLivePusher.stopCameraPreview(true);
                mLivePusher.startCameraPreview(null);
                mLivePusher.setSurface(mSurface);
                mLivePusher.setSurfaceSize(mTextureView.getWidth(), mTextureView.getHeight());
            }
            else if(VIDEO_SRC_SCREEN == mVideoSrc){
                //录屏横竖屏推流的判断条件是，视频分辨率取360*640还是640*360
                switch (mCurrentVideoResolution){
                    case TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640:
                        if(screenCaptureLandscape)
                            mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_640_360);
                        else mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_360_640);
                        break;
                    case TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960:
                        if(screenCaptureLandscape)
                            mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_960_540);
                        else mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_540_960);
                        break;
                    case TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280:
                        if(screenCaptureLandscape)
                            mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_1280_720);
                        else mLivePushConfig.setVideoResolution(TXLiveConstants.VIDEO_RESOLUTION_TYPE_720_1280);
                        break;
                }
                mLivePusher.setConfig(mLivePushConfig);
                mLivePusher.stopScreenCapture();
                mLivePusher.startScreenCapture();
            }
        }
    }

    /**
     * 判断Activity是否可旋转。只有在满足以下条件的时候，Activity才是可根据重力感应自动旋转的。
     * 系统“自动旋转”设置项打开；
     * @return false---Activity可根据重力感应自动旋转
     */
    protected boolean isActivityCanRotation()
    {
        // 判断自动旋转是否打开
        int flag = Settings.System.getInt(this.getContentResolver(),Settings.System.ACCELEROMETER_ROTATION, 0);
        if (flag == 0) {
            return false;
        }
        return true;
    }

    //观察屏幕旋转设置变化，类似于注册动态广播监听变化机制
    private class RotationObserver extends ContentObserver
    {
        ContentResolver mResolver;

        public RotationObserver(Handler handler)
        {
            super(handler);
            mResolver = LivePublisherSurfaceActivity.this.getContentResolver();
        }

        //屏幕旋转设置改变时调用
        @Override
        public void onChange(boolean selfChange)
        {
            super.onChange(selfChange);
            //更新按钮状态
            if (isActivityCanRotation()) {
                mBtnOrientation.setVisibility(View.GONE);
                onActivityRotation();
            } else {
                mBtnOrientation.setVisibility(View.VISIBLE);
                mPortrait = true;
                mLivePushConfig.setHomeOrientation(TXLiveConstants.VIDEO_ANGLE_HOME_DOWN);
                mBtnOrientation.setBackgroundResource(R.drawable.landscape);
                mLivePusher.setRenderRotation(0);
                mLivePusher.setConfig(mLivePushConfig);
            }

        }

        public void startObserver()
        {
            mResolver.registerContentObserver(Settings.System.getUriFor(Settings.System.ACCELEROMETER_ROTATION), false, this);
        }

        public void stopObserver()
        {
            mResolver.unregisterContentObserver(this);
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

    static class TXFechPushUrlCall implements Callback {
        WeakReference<LivePublisherSurfaceActivity> mPusher;
        public TXFechPushUrlCall(LivePublisherSurfaceActivity pusher) {
            mPusher = new WeakReference<LivePublisherSurfaceActivity>(pusher);
        }

        @Override
        public void onFailure(Call call, IOException e) {
            final LivePublisherSurfaceActivity pusher = mPusher.get();
            if (pusher != null) {
                pusher.mFetching = false;
                pusher.mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        pusher.mFetchProgressDialog.dismiss();
                        Toast.makeText(pusher, "获取推流地址失败", Toast.LENGTH_SHORT).show();
                    }
                });
            }
            Log.e(TAG, "fetch push url failed ");
        }

        @Override
        public void onResponse(Call call, Response response) throws IOException {
            if (response.isSuccessful()) {
                String rspString = response.body().string();
                final LivePublisherSurfaceActivity pusher = mPusher.get();
                if (pusher != null) {
                        try {
                            JSONObject jsonRsp = new JSONObject(rspString);
                            final String pushUrl = jsonRsp.optString("url_push");
                            final String rtmpPlayUrl = jsonRsp.optString("url_play_rtmp");
                            final String flvPlayUrl = jsonRsp.optString("url_play_flv");
                            final String hlsPlayUrl = jsonRsp.optString("url_play_hls");
                            final String realtimePlayUrl = jsonRsp.optString("url_play_acc");
                            pusher.mMainHandler.post(new Runnable() {
                                @Override
                                public void run() {
                                    pusher.mRtmpUrlView.setText(pushUrl);
                                    pusher.mFetchProgressDialog.dismiss();
                                    if (TextUtils.isEmpty(pushUrl)) {
                                        Toast.makeText(pusher, "获取推流地址失败", Toast.LENGTH_SHORT).show();
                                    } else {
                                        Toast.makeText(pusher, "获取推流地址成功，对应播放地址已复制到剪贴板", Toast.LENGTH_LONG).show();

                                        String playUrl = String.format("rtmp 协议：%s\n", rtmpPlayUrl)
                                                + String.format("flv 协议：%s\n", flvPlayUrl)
                                                + String.format("hls 协议：%s\n", hlsPlayUrl)
                                                + String.format("低时延播放：%s", realtimePlayUrl);
                                        Log.d(TAG, "fetch play url : " + playUrl);
                                        try {
                                            ClipboardManager cmb = (ClipboardManager) pusher.getSystemService(Context.CLIPBOARD_SERVICE);
                                            cmb.setText(playUrl);
                                        } catch (Exception e) {

                                        }
                                    }
                                }
                            });

                        Log.d(TAG, "fetch push url : " + pushUrl);

                    } catch(Exception e){
                        Log.e(TAG, "fetch push url error ");
                        Log.e(TAG, e.toString());
                    }
                    pusher.mFetching = false;
                }
            }
        }
    };
    private TXFechPushUrlCall mFechCallback = null;

    private void refreshBitrateBtn() {
        if (mBtnAutoBitrate == null) return;
        if (mAutoBitrate) {
            mBtnAutoBitrate.setBackgroundResource(R.drawable.black_bkg);
            mBtnAutoBitrate.setBackgroundColor(Color.BLACK);
            mBtnAutoBitrate.setTextColor(Color.WHITE);
        } else {
            mBtnAutoBitrate.setBackgroundResource(R.drawable.white_bkg);
            mBtnAutoBitrate.setTextColor(Color.BLACK);
        }
    }

    private void refreshResolutiontn() {
        if (mBtnAutoResolution == null) return;
        if (mAutoResolution) {
            mBtnAutoResolution.setBackgroundResource(R.drawable.black_bkg);
            mBtnAutoResolution.setTextColor(Color.WHITE);
        } else {
            mBtnAutoResolution.setBackgroundResource(R.drawable.white_bkg);
            mBtnAutoResolution.setTextColor(Color.BLACK);
        }
    }

    static class TXPhoneStateListener extends PhoneStateListener {
        WeakReference<TXLivePusher> mPusher;
        public TXPhoneStateListener(TXLivePusher pusher) {
            mPusher = new WeakReference<TXLivePusher>(pusher);
        }
        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            TXLivePusher pusher = mPusher.get();
            switch(state){
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
    };
    private PhoneStateListener mPhoneListener = null;

}
