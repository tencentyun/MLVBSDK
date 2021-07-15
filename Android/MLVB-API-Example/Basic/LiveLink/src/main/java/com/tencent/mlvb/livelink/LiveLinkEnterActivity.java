package com.tencent.mlvb.livelink;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.tencent.mlvb.common.MLVBBaseActivity;

/**
 * MLVB 连麦互动的入口页面
 *
 * - 以主播角色进入连麦互动{@link LiveLinkAnchorActivity}
 * - 以观众角色进入连麦互动{@link LiveLinkAudienceActivity}
 *
 *
 * Co-anchoring Entrance View
 *
 * - Enter as an anchor {@link LiveLinkAnchorActivity}
 * - Enter as audience {@link LiveLinkAudienceActivity}
 */
public class LiveLinkEnterActivity extends MLVBBaseActivity {

    private EditText        mEditStreamId;
    private EditText        mEditUserId;
    private Button          mButtonCommit;
    private RadioGroup      mRadioRole;
    private LinearLayout    mLinearUserId;
    private TextView        mTextDesc;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livelink_activity_live_link_enter);
        initView();
    }

    private void initView(){
        mEditStreamId   = findViewById(R.id.et_stream_id);
        mEditUserId     = findViewById(R.id.et_user_id);
        mRadioRole      = findViewById(R.id.rg_role);
        mButtonCommit   = findViewById(R.id.btn_commit);
        mLinearUserId   = findViewById(R.id.ll_user_id);
        mTextDesc       = findViewById(R.id.tv_desc);

        mEditStreamId.setText(generateStreamId());
        String text = mTextDesc.getText().toString();

        SpannableString str = new SpannableString(text);
        str.setSpan(new ForegroundColorSpan(Color.RED),text.indexOf("2.1"),text.indexOf("2.2"), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTextDesc.setMovementMethod(LinkMovementMethod.getInstance());
        mTextDesc.setText(str);

        mRadioRole.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup radioGroup, int i) {
                if(i == R.id.rb_anchor){
                    mButtonCommit.setText(getString(R.string.livelink_rtc_push));
                    mLinearUserId.setVisibility(View.VISIBLE);
                }else if(i == R.id.rb_audience){
                    mButtonCommit.setText(R.string.livelink_webrtc_play);
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
                    Toast.makeText(LiveLinkEnterActivity.this, getString(R.string.livelink_please_input_streamid), Toast.LENGTH_SHORT).show();
                    return;
                }

                Intent intent = null;
                if(mRadioRole.getCheckedRadioButtonId() == R.id.rb_anchor){
                    if(TextUtils.isEmpty(userId)){
                        Toast.makeText(LiveLinkEnterActivity.this, getString(R.string.livelink_please_input_userid), Toast.LENGTH_SHORT).show();
                        return;
                    }
                    intent = new Intent(LiveLinkEnterActivity.this, LiveLinkAnchorActivity.class);
                    intent.putExtra("USER_ID", userId);
                }else if(mRadioRole.getCheckedRadioButtonId() == R.id.rb_audience){
                    intent = new Intent(LiveLinkEnterActivity.this, LiveLinkAudienceActivity.class);
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
