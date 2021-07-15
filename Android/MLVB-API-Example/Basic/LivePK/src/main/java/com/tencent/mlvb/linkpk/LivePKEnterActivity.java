package com.tencent.mlvb.linkpk;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.livepk.R;

/**
 * MLVB 连麦PK的入口页面
 *
 * - 以主播角色进入连麦PK{@link LivePKAnchorActivity}
 * - 以观众角色进入连麦PK{@link LivePKAudienceActivity}
 *
 *
 * Competition Entrance View
 *
 * - Enter as an anchor {@link LivePKAnchorActivity}
 * - Enter as audience {@link LivePKAudienceActivity}
 */
public class LivePKEnterActivity extends MLVBBaseActivity {

    private EditText        mEditStreamId;
    private EditText        mEditUserId;
    private Button          mButtonCommit;
    private RadioGroup      mRadioRole;
    private LinearLayout    mLinearUserId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livepk_activity_live_pk_enter);
        initView();
    }

    private void initView(){
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mEditUserId     = findViewById(R.id.et_user_id);
        mRadioRole      = findViewById(R.id.rg_role);
        mButtonCommit   = findViewById(R.id.btn_commit);
        mLinearUserId   = findViewById(R.id.ll_user_id);

        mEditStreamId.setText(generateStreamId());
        mRadioRole.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup radioGroup, int i) {
                if(i == R.id.rb_anchor){
                    mButtonCommit.setText(getString(R.string.livepk_rtc_push));
                    mLinearUserId.setVisibility(View.VISIBLE);
                }else if(i == R.id.rb_audience){
                    mButtonCommit.setText(R.string.livepk_webrtc_play);
                    mLinearUserId.setVisibility(View.GONE);
                }
            }
        });
        mRadioRole.check(R.id.rb_anchor);

        findViewById(R.id.btn_commit).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String streamId = mEditStreamId.getText().toString();
                String userId = mEditUserId.getText().toString();

                if(TextUtils.isEmpty(streamId)){
                    Toast.makeText(LivePKEnterActivity.this, getString(R.string.livepk_please_input_streamid), Toast.LENGTH_SHORT).show();
                    return;
                }

                Intent intent = null;
                if(mRadioRole.getCheckedRadioButtonId() == R.id.rb_anchor){
                    if(TextUtils.isEmpty(userId)){
                        Toast.makeText(LivePKEnterActivity.this, getString(R.string.livepk_please_input_userid), Toast.LENGTH_SHORT).show();
                        return;
                    }
                    intent = new Intent(LivePKEnterActivity.this, LivePKAnchorActivity.class);
                    intent.putExtra("USER_ID", userId);
                }else if(mRadioRole.getCheckedRadioButtonId() == R.id.rb_audience){
                    intent = new Intent(LivePKEnterActivity.this, LivePKAudienceActivity.class);
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
