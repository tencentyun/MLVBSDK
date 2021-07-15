package com.tencent.mlvb.rtcpushandplay;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.tencent.mlvb.common.MLVBBaseActivity;

/**
 * MLVB RTC连麦+超低延时播放的入口页面
 *
 * - 以主播角色该场景{@link RTCPushAndPlayAnchorActivity}
 * - 以观众角色该场景{@link RTCPushAndPlayAudienceActivity}
 *
 *
 * Entrance View for RTC Co-anchoring + Ultra-low-latency Playback
 *
 * - Enter as an anchor {@link RTCPushAndPlayAnchorActivity}
 * - Enter as audience {@link RTCPushAndPlayAudienceActivity}
 */
public class RTCPushAndPlayEnterActivity extends MLVBBaseActivity {

    private EditText        mEditStreamId;
    private Button          mButtonCommit;
    private RadioGroup      mRadioRole;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.rtcpushandplay_activity_rtc_push_and_play_enter);
        initView();
    }

    private void initView(){
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mRadioRole      = findViewById(R.id.rg_role);
        mButtonCommit   = findViewById(R.id.btn_commit);

        mEditStreamId.setText(generateStreamId());
        mRadioRole.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup radioGroup, int i) {
                if(i == R.id.rb_anchor){
                    mButtonCommit.setText(R.string.rtcpushandplay_rtc_push);
                }else if(i == R.id.rb_audience){
                    mButtonCommit.setText(R.string.rtcpushandplay_rtc_play);
                }
            }
        });
        mRadioRole.check(R.id.rb_anchor);

        findViewById(R.id.btn_commit).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String streamId = mEditStreamId.getText().toString();

                if(TextUtils.isEmpty(streamId)){
                    Toast.makeText(RTCPushAndPlayEnterActivity.this, getString(R.string.rtcpushandplay_please_input_streamid), Toast.LENGTH_SHORT).show();
                    return;
                }

                Intent intent = null;
                if(mRadioRole.getCheckedRadioButtonId() == R.id.rb_anchor){
                    intent = new Intent(RTCPushAndPlayEnterActivity.this, RTCPushAndPlayAnchorActivity.class);
                }else if(mRadioRole.getCheckedRadioButtonId() == R.id.rb_audience){
                    intent = new Intent(RTCPushAndPlayEnterActivity.this, RTCPushAndPlayAudienceActivity.class);
                }
                intent.putExtra("STREAM_ID", streamId);
                startActivity(intent);
            }
        });
    }

    @Override
    protected void onPermissionGranted() {

    }
}
