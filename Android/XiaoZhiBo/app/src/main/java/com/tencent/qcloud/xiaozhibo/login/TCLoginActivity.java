package com.tencent.qcloud.xiaozhibo.login;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.view.View;
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
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.main.TCMainActivity;

import org.json.JSONObject;

/**
 *  Module:   TCLoginActivity
 *
 *  Function: 用于登录小直播的页面
 *
 *  1. 未登陆过，输入账号密码登录
 *
 *  2. 已经登陆过，小直播获取读取缓存，并且自动登录。 详见{@link TCUserMgr}
 */
public class TCLoginActivity extends Activity {

    private static final String TAG = TCLoginActivity.class.getSimpleName();

    private RelativeLayout rootRelativeLayout;

    private ProgressBar progressBar;

    private EditText etPassword;

    private AutoCompleteTextView etLogin;

    private Button btnLogin;

    private TextInputLayout tilLogin, tilPassword;

    private TextView tvRegister;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        rootRelativeLayout = (RelativeLayout) findViewById(R.id.rl_login_root);

        if (null != rootRelativeLayout) {
            ViewTarget<RelativeLayout, GlideDrawable> viewTarget = new ViewTarget<RelativeLayout, GlideDrawable>(rootRelativeLayout) {
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

        etLogin = (AutoCompleteTextView) findViewById(R.id.et_login);

        etPassword = (EditText) findViewById(R.id.et_password);

        tvRegister = (TextView) findViewById(R.id.btn_register);

        btnLogin = (Button) findViewById(R.id.btn_login);

        progressBar = (ProgressBar) findViewById(R.id.progressbar);

        tilLogin = (TextInputLayout) findViewById(R.id.til_login);

        tilPassword = (TextInputLayout) findViewById(R.id.til_password);

        userNameLoginViewInit();

        //检测是否存在缓存
        checkLogin();
    }

    /**
     * 用户名密码登录界面init
     */
    public void userNameLoginViewInit() {

        etLogin.setInputType(EditorInfo.TYPE_CLASS_TEXT);

        etLogin.setText("");
        etLogin.setError(null, null);

        etPassword.setText("");
        etPassword.setError(null, null);

        tilLogin.setHint(getString(R.string.activity_login_username));

        tilPassword.setHint(getString(R.string.activity_login_password));

        tvRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //注册界面 phoneView 与 normalView跳转逻辑一致
                Intent intent = new Intent();
                intent.setClass(getApplicationContext(), TCRegisterActivity.class);
                startActivity(intent);
            }
        });

        btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //调用normal登录逻辑
                showOnLoading(true);

                attemptNormalLogin(etLogin.getText().toString(), etPassword.getText().toString());
            }
        });
    }

    /**
     * trigger loading模式
     *
     * @param active
     */
    private void showOnLoading(boolean active) {
        if (active) {
            progressBar.setVisibility(View.VISIBLE);
            btnLogin.setVisibility(View.INVISIBLE);
            etLogin.setEnabled(false);
            etPassword.setEnabled(false);
            tvRegister.setClickable(false);
        } else {
            progressBar.setVisibility(View.GONE);
            btnLogin.setVisibility(View.VISIBLE);
            etLogin.setEnabled(true);
            etPassword.setEnabled(true);
            tvRegister.setClickable(true);
            tvRegister.setTextColor(getResources().getColor(R.color.colorTransparentGray));
        }

    }

    private void showToast(final String msg) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(getApplicationContext(), msg, Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void showOnLoadingInUIThread(final boolean active) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showOnLoading(active);
            }
        });
    }

    private void showLoginError(String errorString) {
        etLogin.setError(errorString);
        showOnLoading(false);
    }

    private void showPasswordError(String errorString) {
        etPassword.setError(errorString);
        showOnLoading(false);
    }

    /**
     * 登录成功后被调用，跳转至TCMainActivity
     */
    private void jumpToHomeActivity() {
        Intent intent = new Intent(this, TCMainActivity.class);
        startActivity(intent);
        finish();
    }

    private void login(String username, String password) {
        final TCUserMgr tcLoginMgr = TCUserMgr.getInstance();
        tcLoginMgr.login(username, password, new TCHTTPMgr.Callback() {
            @Override
            public void onSuccess(JSONObject data) {
                showToast("登录成功");
                jumpToHomeActivity();
            }

            @Override
            public void onFailure(int code, final String msg) {
                showToast(msg);
                showOnLoadingInUIThread(false);
            }
        });
    }

    private void checkLogin() {
        if (TCUtils.isNetworkAvailable(this)) {
            //返回true表示存在本地缓存，进行登录操作，显示loadingFragment
            if (TCUserMgr.getInstance().hasUser()) {
                showOnLoadingInUIThread(true);
                TCUserMgr.getInstance().autoLogin(new TCHTTPMgr.Callback() {
                    @Override
                    public void onSuccess(JSONObject data) {
                        jumpToHomeActivity();
                    }

                    @Override
                    public void onFailure(int code, String msg) {
                        showToast("自动登录失败");
                        showOnLoadingInUIThread(false);
                    }
                });
            }
        }
    }
    /**
     * 用户名密码登录
     *
     * @param username 用户名
     * @param password 密码
     */
    public void attemptNormalLogin(String username, String password) {
        if (TCUtils.isUsernameVaild(username)) {
            if (TCUtils.isPasswordValid(password)) {
                if (TCUtils.isNetworkAvailable(this)) {
                    login(username, password);
                } else {
                    Toast.makeText(getApplicationContext(), "当前无网络连接", Toast.LENGTH_SHORT).show();
                }
            } else {
                showPasswordError("密码长度应为8-16位");
            }
        } else {
            showLoginError("用户名不符合规范");
        }
    }

}
