package com.tencent.liteav.demo.livepusher.camerapush.ui;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.livepusher.R;
import com.tencent.liteav.demo.livepusher.camerapush.ui.view.LoadingFragment;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * 摄像头推流入口页面，主要用于生成推流地址
 */
public class CameraPushEntranceActivity extends Activity {

    private static final int ACTIVITY_SCAN_REQUEST_CODE = 1;
    private static final int REQUEST_CODE = 100;

    private Context mContext;

    private EditText mEditInputURL;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        setContentView(R.layout.livepusher_activity_live_pusher_entrance);
        initViews();
        checkPublishPermission();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == ACTIVITY_SCAN_REQUEST_CODE && resultCode == RESULT_OK) {
            String scanURL = data.getStringExtra(Constants.INTENT_SCAN_RESULT);
            mEditInputURL.setText(scanURL);
            startLivePusher(scanURL);
        }
    }

    private void initViews() {
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
        findViewById(R.id.livepusher_ibtn_left).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        findViewById(R.id.livepusher_ibtn_right).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startQuestionLink();
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
            startLivePusher(url);
        }
    }

    private void fetchPusherURL() {
        final LoadingFragment fragment = new LoadingFragment();
        fragment.show(getFragmentManager(), "LOADING");
        OkHttpClient okHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(10, TimeUnit.SECONDS)
                .readTimeout(10, TimeUnit.SECONDS)
                .writeTimeout(10, TimeUnit.SECONDS)
                .build();
        Request request = new Request.Builder()
                .url(Constants.URL_FETCH_PUSH_URL)
                .addHeader("Content-Type", "application/json; charset=utf-8")
                .build();
        okHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                fragment.dismissAllowingStateLoss();
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.isSuccessful()) {
                    try {
                        JSONObject jsonRsp = new JSONObject(response.body().string());
                        String pusherURLDefault = jsonRsp.optString(Constants.URL_PUSH);
                        String rtmpPlayURL = jsonRsp.optString(Constants.URL_PLAY_RTMP);
                        String flvPlayURL = jsonRsp.optString(Constants.URL_PLAY_FLV);
                        String hlsPlayURL = jsonRsp.optString(Constants.URL_PLAY_HLS);
                        String realtimePlayURL = jsonRsp.optString(Constants.URL_PLAY_ACC);
                        fragment.dismissAllowingStateLoss();
                        startLivePusher(pusherURLDefault, rtmpPlayURL, flvPlayURL, hlsPlayURL, realtimePlayURL);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }

    private boolean checkPublishPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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
                ActivityCompat.requestPermissions(this, permissions.toArray(new String[0]), REQUEST_CODE);
                return false;
            }
        }
        return true;
    }

    private void startLivePusher(String pushURL) {
        if (TextUtils.isEmpty(pushURL)) {
            Toast.makeText(mContext, getString(R.string.livepusher_input_push_url), Toast.LENGTH_LONG).show();
        } else {
            startLivePusher(pushURL, "", "", "", "");
        }
    }

    private void startLivePusher(String pushURL, String rtmpPlayURL, String flvPlayURL, String hlsPlayURL, String realtimePlayURL) {
        Intent intent = new Intent(mContext, CameraPushMainActivity.class);
        intent.putExtra(Constants.INTENT_URL_PUSH, pushURL);
        intent.putExtra(Constants.INTENT_URL_PLAY_RTMP, rtmpPlayURL);
        intent.putExtra(Constants.INTENT_URL_PLAY_FLV, flvPlayURL);
        intent.putExtra(Constants.INTENT_URL_PLAY_HLS, hlsPlayURL);
        intent.putExtra(Constants.INTENT_URL_PLAY_ACC, realtimePlayURL);
        startActivity(intent);
    }

    private void startQuestionLink() {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse(Constants.URL_PRODUCT_DOCUMENT));
        startActivity(intent);
    }
}