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

    private static final int STEP_INPUT_USERID = 0;
    private static final int STEP_INPUT_ROLE   = 1;
    private static final int STEP_INPUT_STREAM = 2;

    private static final int ROLE_UNKNOWN      = -1;
    private static final int ROLE_ANCHOR       = 0;
    private static final int ROLE_AUDIENCE     = 1;

    private LinearLayout mLayoutStreamId;
    private EditText     mEditStreamId;
    private LinearLayout mLayoutUserId;
    private EditText     mEditUserId;
    private LinearLayout mLayoutSelectRole;
    private Button       mButtonRoleAnchor;
    private Button       mButtonRoleAudience;
    private Button       mButtonNext;

    private String       mUserId;
    private String       mStreamId;
    private int          mStateInput   = STEP_INPUT_USERID;
    private int          mRoleSelected = ROLE_UNKNOWN;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.livepk_activity_live_pk_enter);
        initView();
    }

    private void initView() {
        mLayoutUserId = findViewById(R.id.ll_user_id);
        mEditUserId = findViewById(R.id.et_user_id);
        mLayoutStreamId = findViewById(R.id.ll_stream_id);
        mEditStreamId = findViewById(R.id.et_stream_id);
        initSelectRoleLayout();
        initNextButton();

    }

    private void initSelectRoleLayout() {
        mLayoutSelectRole = findViewById(R.id.ll_role);
        mButtonRoleAnchor = findViewById(R.id.bt_anchor);
        mButtonRoleAudience = findViewById(R.id.bt_audience);

        mButtonRoleAnchor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mRoleSelected = ROLE_ANCHOR;
                mButtonRoleAnchor.setSelected(true);
                mButtonRoleAudience.setSelected(false);
            }
        });

        mButtonRoleAudience.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mRoleSelected = ROLE_AUDIENCE;
                mButtonRoleAnchor.setSelected(false);
                mButtonRoleAudience.setSelected(true);
            }
        });
    }

    private void initNextButton() {
        mButtonNext = findViewById(R.id.btn_next);
        mButtonNext.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mStateInput == STEP_INPUT_USERID) {
                    mUserId = mEditUserId.getText().toString();
                    if (TextUtils.isEmpty(mUserId)) {
                        Toast.makeText(LivePKEnterActivity.this, getString(R.string.livepk_please_input_userid),
                                Toast.LENGTH_SHORT).show();
                        return;
                    }
                    mLayoutUserId.setVisibility(View.GONE);
                    mLayoutSelectRole.setVisibility(View.VISIBLE);
                    mLayoutStreamId.setVisibility(View.GONE);
                    mStateInput = STEP_INPUT_ROLE;
                } else if (mStateInput == STEP_INPUT_ROLE) {
                    if (mRoleSelected == ROLE_UNKNOWN) {
                        Toast.makeText(LivePKEnterActivity.this, getString(R.string.livepk_please_input_userid),
                                Toast.LENGTH_SHORT).show();
                        return;
                    }
                    mLayoutUserId.setVisibility(View.GONE);
                    mLayoutSelectRole.setVisibility(View.GONE);
                    mLayoutStreamId.setVisibility(View.VISIBLE);
                    mButtonNext.setText(mRoleSelected == ROLE_ANCHOR ? R.string.livepk_rtc_push :
                            R.string.livepk_webrtc_play);
                    mStateInput = STEP_INPUT_STREAM;
                } else if (mStateInput == STEP_INPUT_STREAM) {
                    mStreamId = mEditStreamId.getText().toString();
                    if (TextUtils.isEmpty(mStreamId)) {
                        Toast.makeText(LivePKEnterActivity.this, getString(R.string.livepk_please_input_streamid)
                                , Toast.LENGTH_SHORT).show();
                        return;
                    }
                    Class<?> cls = mRoleSelected == ROLE_ANCHOR ? LivePKAnchorActivity.class :
                            LivePKAudienceActivity.class;
                    Intent intent = new Intent(LivePKEnterActivity.this, cls);
                    intent.putExtra("USER_ID", mUserId);
                    intent.putExtra("STREAM_ID", mStreamId);
                    startActivity(intent);
                    finish();
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mUserId = "";
        mRoleSelected = ROLE_UNKNOWN;
        mStreamId = "";
        mStateInput = STEP_INPUT_USERID;
    }

    @Override
    protected void onPermissionGranted() {

    }
}
