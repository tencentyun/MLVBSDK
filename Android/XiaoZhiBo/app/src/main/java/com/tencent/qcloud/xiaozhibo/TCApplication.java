package com.tencent.qcloud.xiaozhibo;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.os.Bundle;
import android.support.multidex.MultiDexApplication;
import android.util.Log;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCLog;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.rtmp.TXLiveBase;
import com.umeng.socialize.PlatformConfig;

//import com.squareup.leakcanary.LeakCanary;
//import com.squareup.leakcanary.RefWatcher;

/**
 * 小直播应用类，用于全局的操作，如
 * sdk初始化,全局提示框
 */
public class TCApplication extends MultiDexApplication {
    private static final String TAG = "TCApplication";
//    private RefWatcher mRefWatcher;

    private static TCApplication instance;

    // 如何获取License? 请参考官网指引 https://cloud.tencent.com/document/product/454/34750
    String licenceUrl = "";
    String licenseKey = "";

    @Override
    public void onCreate() {
        super.onCreate();

        instance = this;

        initSDK();

        //配置分享第三方平台的appkey
        PlatformConfig.setWeixin(TCConstants.WEIXIN_SHARE_ID, TCConstants.WEIXIN_SHARE_SECRECT);
        PlatformConfig.setSinaWeibo(TCConstants.SINA_WEIBO_SHARE_ID, TCConstants.SINA_WEIBO_SHARE_SECRECT, TCConstants.SINA_WEIBO_SHARE_REDIRECT_URL);
        PlatformConfig.setQQZone(TCConstants.QQZONE_SHARE_ID, TCConstants.QQZONE_SHARE_SECRECT);

        Fresco.initialize(this);
//        mRefWatcher =
//        LeakCanary.install(this);

        // 上报启动次数
        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_START_UP, TCUserMgr.getInstance().getUserId(), 0, "启动成功", null);
        TCUserMgr.getInstance().setAppName(getELKAPPName());
        TCUserMgr.getInstance().setPackageName(getELKPackageName());
        registerActivityLifecycleCallbacks(new MyActivityLifecycleCallbacks(this));

        TXLiveBase.getInstance().setLicence(instance, licenceUrl, licenseKey);
    }

    public String getELKAPPName() {
        ApplicationInfo applicationInfo = this.getApplicationInfo();
        int stringId = applicationInfo.labelRes;
        return stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : getString(stringId);
    }

    public String getELKPackageName() {
        PackageInfo info;
        String packagename = "";
        if (this != null) {
            try {
                info = this.getPackageManager().getPackageInfo(this.getPackageName(), 0);

                // 当前版本的包名
                packagename = info.packageName;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return packagename;
    }

    public static TCApplication getApplication() {
        return instance;
    }

//    public static RefWatcher getRefWatcher(Context context) {
//        TCApplication application = (TCApplication) context.getApplicationContext();
//        return application.mRefWatcher;
//    }

    /**
     * 初始化SDK，包括Bugly，IMSDK，RTMPSDK等
     */
    public void initSDK() {
        Log.w("App","xzb_process: app init sdk");
        //启动bugly组件，bugly组件为腾讯提供的用于crash上报和分析的开放组件，如果您不需要该组件，可以自行移除
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
        strategy.setAppVersion(TXLiveBase.getSDKVersionStr());
        CrashReport.initCrashReport(getApplicationContext(), TCConstants.BUGLY_APPID, true, strategy);

        //设置rtmpsdk log回调，将log保存到文件
        TXLiveBase.setListener(new TCLog(getApplicationContext()));

        //初始化httpengine
//        TCHttpEngine.getInstance().initContext(getApplicationContext());

        TCUserMgr.getInstance().initContext(getApplicationContext());
    }


    private class MyActivityLifecycleCallbacks implements ActivityLifecycleCallbacks {

        private int foregroundActivities;
        private boolean isChangingConfiguration;
        private long time;

        public MyActivityLifecycleCallbacks(TCApplication tcApplication) {

        }

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

        }

        @Override
        public void onActivityStarted(Activity activity) {
            foregroundActivities++;
            if (foregroundActivities == 1 && !isChangingConfiguration) {
                // 应用进入前台
                time = System.currentTimeMillis();
            }
            isChangingConfiguration = false;
        }

        @Override
        public void onActivityResumed(Activity activity) {

        }

        @Override
        public void onActivityPaused(Activity activity) {

        }

        @Override
        public void onActivityStopped(Activity activity) {
            foregroundActivities--;
            if (foregroundActivities == 0) {
                // 应用切入后台
                long bgTime = System.currentTimeMillis();
                long diff = (bgTime - time) / 1000 ;
                uploadStayTime(diff);
            }
            isChangingConfiguration = activity.isChangingConfigurations();
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {

        }
    }

    private void uploadStayTime(long diff) {
        TCUserMgr.getInstance().uploadLogs(TCConstants.ELK_ACTION_STAY_TIME, TCUserMgr.getInstance().getUserId(), diff, "App体验时长", null);
    }
}
