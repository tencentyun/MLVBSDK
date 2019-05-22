package com.tencent.qcloud.xiaozhibo.mainui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.text.TextUtils;
import android.view.WindowManager;

import com.tencent.qcloud.xiaozhibo.common.activity.URLGuideDialogFragment;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.login.TCLoginActivity;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;

import java.lang.ref.WeakReference;

/**
 * Created by RTMP on 2016/8/1
 */
public class TCSplashActivity extends FragmentActivity {

    private static final String TAG = TCSplashActivity.class.getSimpleName();
    private static final String SP_NAME = "xiaozhibo_info";
    private static final String KEY_FIRST_RUN = "is_first_run";
    private static final int START_LOGIN = 2873;
    private final MyHandler mHandler = new MyHandler(this);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (TextUtils.isEmpty(TCConstants.APP_SVR_URL)) {
            URLGuideDialogFragment fragment = new URLGuideDialogFragment();
            Bundle bundle = new Bundle();
            bundle.putString(URLGuideDialogFragment.ERROR_TITLE, "未填写后台服务地址");
            bundle.putString(URLGuideDialogFragment.ERROR_MSG, "需要搭建小直播后台，详情请点击[快速搭建小直播]");
            bundle.putString(URLGuideDialogFragment.ERROR_LINK, "https://cloud.tencent.com/document/product/454/15187");
            fragment.setArguments(bundle);
            fragment.show(getSupportFragmentManager(), "url_guide_dialog");
            return;
        }
        if (!isTaskRoot()
                && getIntent().hasCategory(Intent.CATEGORY_LAUNCHER)
                && getIntent().getAction() != null
                && getIntent().getAction().equals(Intent.ACTION_MAIN)) {

            finish();
            return;
        }

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        Message msg = Message.obtain();
        msg.arg1 = START_LOGIN;
        mHandler.sendMessageDelayed(msg, 1000);
        boolean isFirstRun = isFirstRun(this);
        if (isFirstRun) {
            saveFirstRun(this);
            TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_INSTALL, TCUserMgr.getInstance().getUserId(), 0, "首次安装成功", null);
        }
    }


    public boolean isFirstRun(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        return sharedPreferences.getBoolean(KEY_FIRST_RUN, true);
    }

    private void saveFirstRun(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
        sharedPreferences.edit().putBoolean(KEY_FIRST_RUN, false).commit();
    }


    @Override
    protected void onResume() {
        super.onResume();

    }

    @Override
    public void onBackPressed() {
        //splashActivity下不允许back键退出O
        //super.onBackPressed();
    }

    private void jumpToLoginActivity() {
        Intent intent = new Intent(this, TCLoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        finish();
    }

    private static class MyHandler extends Handler {
        private final WeakReference<TCSplashActivity> mActivity;

        public MyHandler(TCSplashActivity activity) {
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            TCSplashActivity activity = mActivity.get();
            if (activity != null) {
                activity.jumpToLoginActivity();
            }
        }
    }

}
