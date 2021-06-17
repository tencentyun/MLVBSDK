package com.tencent.liteav.demo.livepusher.screenpush;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePusher;
import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.live2.impl.V2TXLivePusherImpl;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_OK;
import static com.tencent.live2.V2TXLiveCode.V2TXLIVE_WARNING_SCREEN_CAPTURE_START_FAILED;

public class ScreenPushEntranceActivity extends Activity {

    public static final String URL_FETCH_PUSH_URL = "https://lvb.qcloud.com/weapp/utils/get_test_pushurl";

    /**
     * QRCodeScanActivity完成扫描后，传递过来的结果的KEY
     */
    public static final String INTENT_SCAN_RESULT   = "SCAN_RESULT";

    public static final String URL_PUSH        = "url_push";       // RTMP 推流地址
    public static final String URL_PLAY_FLV    = "url_play_flv";   // FLA  播放地址

    private static final int ACTIVITY_SCAN_REQUEST_CODE = 1;
    private Context mContext;
    private EditText mEditInputURL;
    private boolean mIsFirstPush = false;

    private RadioButton mLandScape;
    private RadioButton mPortrait;
    private RadioButton mVideoSuper;
    private RadioButton mVideoStand;
    private RadioButton mVideoHigh;

    private QRCodeGenerateFragment mPusherPlayQRCodeFragment;
    private static String sQRCodePusherURL;
    private static final String PUSHER_PLAY_QR_CODE_FRAGMENT = "push_play_qr_code_fragment";
    private static V2TXLiveDef.V2TXLiveVideoResolution sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x360;
    private static V2TXLiveDef.V2TXLiveVideoResolutionMode sResolutionMode = V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait;
    private static V2TXLivePusher sLivePusher;
    private static boolean sHasInitPusher = false;
    private static String sPushURL;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livepusherscreen_activity_entrance);
        mContext = this;

        mPortrait = (RadioButton) findViewById(R.id.rb_portrait);
        mLandScape = (RadioButton) findViewById(R.id.rb_landscape);
        mVideoSuper = findViewById(R.id.rb_video_super);
        mVideoStand = findViewById(R.id.rb_video_stand);
        mVideoHigh = findViewById(R.id.rb_video_high);

        mLandScape.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                if (checked) {
                    sResolutionMode = V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModeLandscape;
                    if (sLivePusher != null) {
                        sLivePusher.setVideoQuality(sResolution, sResolutionMode);
                    }
                }
            }
        });
        mPortrait.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                if (checked) {
                    sResolutionMode = V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait;
                    if (sLivePusher != null) {
                        sLivePusher.setVideoQuality(sResolution, sResolutionMode);
                    }
                }
            }
        });
        mVideoStand.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                if (checked) {
                    sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x360;
                    if (sLivePusher != null) {
                        sLivePusher.setVideoQuality(sResolution, sResolutionMode);
                    }
                }
            }
        });
        mVideoHigh.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                if (checked) {
                    sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution960x540;
                    if (sLivePusher != null) {
                        sLivePusher.setVideoQuality(sResolution, sResolutionMode);
                    }

                }
            }
        });
        mVideoSuper.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                if (checked) {
                    sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution1280x720;
                    if (sLivePusher != null) {
                        sLivePusher.setVideoQuality(sResolution, sResolutionMode);
                    }
                }
            }
        });

        setStyle(mPortrait);
        setStyle(mLandScape);
        setStyle(mVideoSuper);
        setStyle(mVideoStand);
        setStyle(mVideoHigh);

        initViews();
        checkPusherStatus();
    }

    private void checkPusherStatus() {
        if (sHasInitPusher) {
            ((Button)findViewById(R.id.livepusher_btn_play)).setText(getString(R.string.livepusher_screen_push_tip));
            ((Button)findViewById(R.id.livepusher_btn_stop)).setVisibility(View.VISIBLE);

            if (!TextUtils.isEmpty(sPushURL)) {
                mEditInputURL.setText(sPushURL);
            }


            if (sResolutionMode == V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait) {
                mPortrait.setChecked(true);
            } else if (sResolutionMode == V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModeLandscape) {
                mLandScape.setChecked(true);
            }

            if (sResolution == V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x360) {
                mVideoStand.setChecked(true);
            } else if (sResolution == V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution960x540) {
                mVideoHigh.setChecked(true);
            } else if (sResolution == V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution1280x720){
                mVideoSuper.setChecked(true);
            }

        }
    }

    private void setStyle(RadioButton rb) {
        Drawable drawable = getResources().getDrawable(R.drawable.livepusher_screen_rb_icon_selector);
        //定义底部标签图片大小和位置
        drawable.setBounds(0, 0, 45, 45);
        //设置图片在文字的哪个方向
        rb.setCompoundDrawables(drawable, null, null, null);
        rb.setCompoundDrawablePadding(20);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == ACTIVITY_SCAN_REQUEST_CODE && resultCode == RESULT_OK) {
            String scanURL = data.getStringExtra(INTENT_SCAN_RESULT);
            mEditInputURL.setText(scanURL);
            startLivePusher(scanURL);
        }
    }

    private void initViews() {
        if (mPusherPlayQRCodeFragment == null) {
            mPusherPlayQRCodeFragment = new QRCodeGenerateFragment();
        }
        mEditInputURL = findViewById(R.id.livepusher_et_input_url);
        mEditInputURL.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_GO || (event != null && event.getAction() == KeyEvent.ACTION_UP)) {
                    String url = mEditInputURL.getText().toString().trim();
                    startLivePusher(url);
                    return true;
                }
                return false;
            }
        });
        findViewById(R.id.livepusher_ibtn_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.livepusher_btn_normal_url) {
            fetchPusherURL();
        } else if (id == R.id.livepusher_btn_qr_code_scan) {
            Intent intent = new Intent(mContext, QRCodeScanActivity.class);
            startActivityForResult(intent, ACTIVITY_SCAN_REQUEST_CODE);
        } else if (id == R.id.livepusher_btn_play) {
            String url = mEditInputURL.getText().toString().trim();
            if (!sHasInitPusher) {
                startLivePusher(url);
            }
        } else if (id == R.id.livepusher_btn_stop) {
            if (sHasInitPusher) {
                stopLivePusher();
            }
        } else if (id == R.id.livepusher_ibtn_qrcode) {
            if (sHasInitPusher) {
                mPusherPlayQRCodeFragment.setQRCodeURL(sQRCodePusherURL);
                mPusherPlayQRCodeFragment.toggle(getFragmentManager(), PUSHER_PLAY_QR_CODE_FRAGMENT);
            } else {
                Toast.makeText(this, getString(R.string.livepusher_screen_toast_please_start_up_push), Toast.LENGTH_LONG).show();
            }
        }
    }

    private void fetchPusherURL() {
        OkHttpClient okHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(10, TimeUnit.SECONDS)
                .readTimeout(10, TimeUnit.SECONDS)
                .writeTimeout(10, TimeUnit.SECONDS)
                .build();
        Request request = new Request.Builder()
                .url(URL_FETCH_PUSH_URL)
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build();
        okHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {

            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.isSuccessful()) {
                    try {
                        JSONObject jsonRsp = new JSONObject(response.body().string());
                        final String pusherURLDefault = jsonRsp.optString(URL_PUSH);
                        String flvPlayURL = jsonRsp.optString(URL_PLAY_FLV);
                        sQRCodePusherURL = flvPlayURL;
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mEditInputURL.setText(pusherURLDefault);
                            }
                        });
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }

    private void startLivePusher(final String pushURL) {
        if (mLandScape.isChecked()) {
            sResolutionMode = V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModeLandscape;
        } else if (mPortrait.isChecked()) {
            sResolutionMode = V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait;
        }

        if (mVideoStand.isChecked()) {
            sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x360;
        } else if (mVideoHigh.isChecked()) {
            sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution960x540;
        } else {
            sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution1280x720;
        }

        if (TextUtils.isEmpty(pushURL)) {
            Toast.makeText(mContext, getString(R.string.livepusher_screen_input_push_url), Toast.LENGTH_LONG).show();
        } else {
            PermissionUtils.permission(PermissionConstants.CAMERA, PermissionConstants.STORAGE, PermissionConstants.MICROPHONE).callback(new PermissionUtils.FullCallback() {
                @Override
                public void onGranted(List<String> permissionsGranted) {
                    mIsFirstPush = true;
                    startPush(pushURL);
                }

                @Override
                public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                    ToastUtils.showShort(R.string.livepusher_screen_camera_storage_mic);
                    finish();
                }
            }).request();

            if (!mIsFirstPush) {
                startPush(pushURL);
            }
        }
    }

    private class MyTXLivePusherObserver extends V2TXLivePusherObserver {

        @Override
        public void onWarning(int code, String msg, Bundle extraInfo) {
            if (code == V2TXLIVE_WARNING_SCREEN_CAPTURE_START_FAILED) {
                sHasInitPusher = false;
                resetConfig();
                Toast.makeText(ScreenPushEntranceActivity.this, getString(R.string.livepusher_screen_cancel), Toast.LENGTH_LONG).show();
                stopLivePusher();
            }
        }
    }

    private void resetConfig() {
        sQRCodePusherURL = "";
        sResolution = V2TXLiveDef.V2TXLiveVideoResolution.V2TXLiveVideoResolution640x360;
        sPushURL = "";
        sResolutionMode = V2TXLiveDef.V2TXLiveVideoResolutionMode.V2TXLiveVideoResolutionModePortrait;
    }

    private void startPush(String pushURL) {
        if (sLivePusher != null) {
            sLivePusher.stopMicrophone();
            sLivePusher.stopScreenCapture();
            sLivePusher.stopPush();
            sLivePusher = null;
        }
        sLivePusher = new V2TXLivePusherImpl(mContext, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTMP);
        sLivePusher.setObserver(new MyTXLivePusherObserver());
        sLivePusher.startMicrophone();
        sLivePusher.startScreenCapture();
        sLivePusher.setVideoQuality(sResolution, sResolutionMode);
        sPushURL = pushURL;
        int result = sLivePusher.startPush(pushURL);
        if (result == V2TXLIVE_OK) {
            sHasInitPusher = true;
            Toast.makeText(ScreenPushEntranceActivity.this, getString(R.string.livepusher_screen_push), Toast.LENGTH_LONG).show();
            ((Button)findViewById(R.id.livepusher_btn_play)).setText(getString(R.string.livepusher_screen_push_tip));
            ((Button)findViewById(R.id.livepusher_btn_stop)).setVisibility(View.VISIBLE);
        } else {
            resetConfig();
            sHasInitPusher = false;
        }
    }

    private void stopLivePusher() {
        if (sLivePusher != null) {
            sLivePusher.stopMicrophone();
            sLivePusher.stopScreenCapture();
            sLivePusher.stopPush();
        }
        sHasInitPusher = false;
        resetConfig();
        mEditInputURL.setText("");
        Toast.makeText(ScreenPushEntranceActivity.this, getString(R.string.livepusher_screen_cancel), Toast.LENGTH_LONG).show();
        ((Button)findViewById(R.id.livepusher_btn_play)).setText(getString(R.string.livepusher_screen_start_screen_push));
        ((Button)findViewById(R.id.livepusher_btn_stop)).setVisibility(View.GONE);
    }
}
