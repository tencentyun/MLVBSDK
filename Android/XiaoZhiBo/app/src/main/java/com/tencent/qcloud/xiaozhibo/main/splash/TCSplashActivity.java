package com.tencent.qcloud.xiaozhibo.main.splash;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.WindowManager;

import com.tencent.qcloud.xiaozhibo.TCGlobalConfig;
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.login.TCLoginActivity;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;

/**
 *  Module:   TCSplashActivity
 *
 *  Function: 闪屏页面，只是显示一张图
 *
 *  Note：需要注意配置小直播后台的 server 地址；配置教程，详见：https://cloud.tencent.com/document/product/454/15187
 */
public class TCSplashActivity extends Activity {
    private static final String SP_NAME = "xiaozhibo_info";
    private static final String KEY_FIRST_RUN = "is_first_run";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!isTaskRoot()
                && getIntent().hasCategory(Intent.CATEGORY_LAUNCHER)
                && getIntent().getAction() != null
                && getIntent().getAction().equals(Intent.ACTION_MAIN)) {

            finish();
            return;
        }

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        boolean isFirstRun = isFirstRun(this);
        if (isFirstRun) {
            saveFirstRun(this);
            TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_INSTALL, TCUserMgr.getInstance().getUserId(), 0, "首次安装成功", null);
        }


        Handler handler = new Handler(Looper.getMainLooper());
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                jumpToLoginActivity();
            }
        }, 1000);
    }

    /**
     * 判定是否第一次运行
     *
     * @param context
     * @return
     */
    public boolean isFirstRun(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        return sharedPreferences.getBoolean(KEY_FIRST_RUN, true);
    }

    /**
     *  本地保存 sharepreferences 变量，表明已经运行过。
     * @param context
     */
    private void saveFirstRun(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        sharedPreferences.edit().putBoolean(KEY_FIRST_RUN, false).commit();
    }

    /**
     *  跳转到登录界面
     */
    private void jumpToLoginActivity() {
        Intent intent = new Intent(this, TCLoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        finish();
    }

}
