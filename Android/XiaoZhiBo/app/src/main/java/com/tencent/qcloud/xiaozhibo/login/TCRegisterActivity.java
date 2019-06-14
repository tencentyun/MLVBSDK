package com.tencent.qcloud.xiaozhibo.login;

import android.animation.LayoutTransition;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.inputmethod.EditorInfo;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.resource.drawable.GlideDrawable;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.ViewTarget;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.main.TCMainActivity;

import org.json.JSONObject;


/**
 *  Module:   TCRegisterActivity
 *
 *  Function: 注册小直播账号
 *
 */
public class TCRegisterActivity extends Activity  {

    public static final String TAG = TCRegisterActivity.class.getSimpleName();

    //共用控件
    private RelativeLayout relativeLayout;

    private ProgressBar progressBar;

    private EditText etPassword;

    private EditText etPasswordVerify;

    private AutoCompleteTextView etRegister;

    private TextInputLayout tilRegister, tilPassword, tilPasswordVerify;

    private Button btnRegister;

    private TextView tvBackBtn;

    //动画
    AlphaAnimation fadeInAnimation, fadeOutAnimation;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        relativeLayout = (RelativeLayout) findViewById(R.id.rl_register_root);

        if(null != relativeLayout) {
            ViewTarget<RelativeLayout, GlideDrawable> viewTarget = new ViewTarget<RelativeLayout, GlideDrawable>(relativeLayout) {
                @Override
                public void onResourceReady(GlideDrawable resource, GlideAnimation<? super GlideDrawable> glideAnimation) {
                    this.view.setBackgroundDrawable(resource.getCurrent());
                }
            };

            Glide.with(getApplicationContext()) // safer!
                    .load(R.drawable.bg_dark)
                    .diskCacheStrategy(DiskCacheStrategy.SOURCE)
                    .into(viewTarget);
        }

        etRegister = (AutoCompleteTextView) findViewById(R.id.et_register);

        etPassword = (EditText) findViewById(R.id.et_password);

        etPasswordVerify = (EditText) findViewById(R.id.et_password_verify);

        tilPasswordVerify = (TextInputLayout) findViewById(R.id.til_password_verify);

        btnRegister = (Button) findViewById(R.id.btn_register);

        progressBar = (ProgressBar) findViewById(R.id.progressbar);

        tilRegister = (TextInputLayout) findViewById(R.id.til_register);

        tilPassword = (TextInputLayout) findViewById(R.id.til_password);

        tvBackBtn = (TextView) findViewById(R.id.tv_back);

        fadeInAnimation = new AlphaAnimation(0.0f, 1.0f);
        fadeOutAnimation = new AlphaAnimation(1.0f, 0.0f);
        fadeInAnimation.setDuration(250);
        fadeOutAnimation.setDuration(250);

        LayoutTransition layoutTransition = new LayoutTransition();
        relativeLayout.setLayoutTransition(layoutTransition);

    }

    @Override
    protected void onResume() {
        super.onResume();
        userNameRegisterViewInit();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void showOnLoadingInUIThread(final boolean active) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showOnLoading(active);
            }
        });
    }

    private void showToast(final String msg) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(getApplicationContext(), msg, Toast.LENGTH_SHORT).show();
            }
        });
    }
    private void showOnLoading(boolean active) {
        if (active) {
            progressBar.setVisibility(View.VISIBLE);
            btnRegister.setVisibility(View.INVISIBLE);
            etPassword.setEnabled(false);
            etPasswordVerify.setEnabled(false);
            etRegister.setEnabled(false);
            btnRegister.setEnabled(false);
        } else {
            progressBar.setVisibility(View.GONE);
            btnRegister.setVisibility(View.VISIBLE);
            etPassword.setEnabled(true);
            etPasswordVerify.setEnabled(true);
            etRegister.setEnabled(true);
            btnRegister.setEnabled(true);
        }

    }

    private void userNameRegisterViewInit() {

        etRegister.setText("");
        etRegister.setError(null, null);

        etRegister.setInputType(EditorInfo.TYPE_CLASS_TEXT);

        etPassword.setText("");
        etPassword.setError(null, null);

        etPasswordVerify.setText("");
        etPasswordVerify.setError(null, null);

        tilPasswordVerify.setVisibility(View.VISIBLE);

        tilRegister.setHint(getString(R.string.activity_register_username));

        tilPassword.setHint(getString(R.string.activity_register_password));

        tilPasswordVerify.setHint(getString(R.string.activity_register_password_verify));

        btnRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //调用normal注册逻辑
                attemptNormalRegist(etRegister.getText().toString(),
                        etPassword.getText().toString(), etPasswordVerify.getText().toString());
            }
        });

        tvBackBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
    }

    private void showRegistError(String errorString) {
        etRegister.setError(errorString);
        showOnLoading(false);
    }

    private void showPasswordVerifyError(String errorString) {
        etPassword.setError(errorString);
        showOnLoading(false);
    }
    private void attemptNormalRegist(String username, String password, String passwordVerify) {

        if (!TCUtils.isUsernameVaild(username)) {
            showRegistError("用户名不符合规范");
            return ;
        }
        if (!TCUtils.isPasswordValid(password)) {
            showPasswordVerifyError("密码长度应为8-16位");
            return ;
        }
        if (!password.equals(passwordVerify)) {
            showPasswordVerifyError("两次输入密码不一致");
            return ;
        }
        if (!TCUtils.isNetworkAvailable(this)) {
            Toast.makeText(getApplicationContext(), "当前无网络连接", Toast.LENGTH_SHORT).show();
            return ;
        }

        register(username, password);
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    private void jumpToHomeActivity () {
        Intent intent = new Intent(this, TCMainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    private void jumpToLoginActivity() {
        Intent intent = new Intent(this, TCLoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        finish();
    }

    private void register(final String username, final String password) {
        final TCUserMgr tcLoginMgr = TCUserMgr.getInstance();
        tcLoginMgr.register(username, password, new TCHTTPMgr.Callback() {
            @Override
            public void onSuccess(JSONObject data) {
                showToast("成功注册");

                // 注册成功之后，将自动登录。
                tcLoginMgr.login(username, password, new TCHTTPMgr.Callback() {
                    @Override
                    public void onSuccess(JSONObject data) {
                        showToast("自动登录成功");
                        jumpToHomeActivity(); // 登录成功，跳转到 MainActivity
                    }

                    @Override
                    public void onFailure(int code, final String msg) {
                        showToast("自动登录失败");
                        showOnLoadingInUIThread(false);
                        jumpToLoginActivity(); // 登录失败，登录界面。
                    }
                });
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_REGISTER, username, 0, "注册成功", null);
            }

            @Override
            public void onFailure(int code, final String msg) {
                String errorMsg = msg;
                if (code == 610) {
                    errorMsg = "用户名格式错误";
                    TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_REGISTER, username, -1, errorMsg, null);
                } else if (code == 611){
                    errorMsg = "密码格式错误";
                    TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_REGISTER, username, -2, errorMsg, null);
                } else if (code == 612){
                    errorMsg = "用户已存在";
                    TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_REGISTER, username, -3, errorMsg, null);
                }
                showToast("注册失败 ：" + errorMsg);
                showOnLoadingInUIThread(false);
            }
        });
        showOnLoading(true);
    }
}
