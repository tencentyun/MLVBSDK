package com.tencent.mlvb.liveplay;

import android.content.Intent;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.tencent.mlvb.common.MLVBBaseActivity;

/**
 * MLVB 直播拉流的入口页面
 *
 * 其中包含三种拉流方式，RTC拉流，RTMP拉流，WebRTC拉流，推荐使用WebRtc拉流
 *
 * - 拉流详情页见{@link LivePlayActivity}
 *
 *
 * Playback Entrance View
 *
 * You can play streams over RTC, RTMP, or WebRTC (recommended).
 *
 * - For the playback view, see {@link LivePlayActivity}.
 */
public class LivePlayEnterActivity extends MLVBBaseActivity {

    private EditText    mEditStreamId;
    private TextView    mTextDesc;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.liveplay_activity_live_play_enter);
        initView();
    }

    private void initView(){
        mEditStreamId       = findViewById(R.id.et_stream_id);

        mEditStreamId.setText(generateStreamId());
        findViewById(R.id.btn_play_rtc).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startPlay(0);
            }
        });

        findViewById(R.id.btn_play_rtmp).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startPlay(1);
            }
        });

        findViewById(R.id.btn_play_webrtc).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startPlay(2);
            }
        });

        mTextDesc = findViewById(R.id.tv_desc);

        String text = mTextDesc.getText().toString();

        SpannableString str = new SpannableString(text);
        str.setSpan(new URLSpan("https://cloud.tencent.com/document/product/454/56598"),text.indexOf("https://"),text.indexOf("56598") + 5, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTextDesc.setMovementMethod(LinkMovementMethod.getInstance());
        mTextDesc.setText(str);
    }

    private void startPlay(int type) {
        String streamId = mEditStreamId.getText().toString();
        if(TextUtils.isEmpty(streamId)){
            Toast.makeText(LivePlayEnterActivity.this,getString(R.string.liveplay_please_input_streamid), Toast.LENGTH_SHORT).show();
        }else{
            Intent intent = new Intent(LivePlayEnterActivity.this, LivePlayActivity.class);
            intent.putExtra("STREAM_ID", streamId);
            intent.putExtra("STREAM_TYPE", type);
            startActivity(intent);
        }
    }

    @Override
    protected void onPermissionGranted() {

    }
}
