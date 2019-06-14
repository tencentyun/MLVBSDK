package com.tencent.qcloud.xiaozhibo.common.report;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Module:   TCELKReportMgr
 *
 * Function: 小直播 APP 用于做数据上报统计使用的。 您的 APP 可以直接移除此模块，或者保持不动；不会影响 APP 的正常功能。
 *
 */
public class TCELKReportMgr {
    // 小直播做统计用的，您可以不用关心
    private static final String DEFAULT_ELK_HOST = "";
    private static final String TAG = "TCELKReportMgr";
    private Context mContext;
    private String mAppName;
    private String mPackageName;
    /**
     * 用于保证单例
     */
    private static final class TCELKReportMgrHolder {
        public static final TCELKReportMgr INSTANCE = new TCELKReportMgr();
    }

    public static final TCELKReportMgr getInstance() {
        return TCELKReportMgrHolder.INSTANCE;
    }

    private TCELKReportMgr() {

    }

    /**
     * 初始化
     *
     * @param context
     */
    public void init(Context context) {
        if (context == null) return;
        mContext = context.getApplicationContext();
        mAppName = getAPPName();
        mPackageName = getPackageName();
    }

    /**
     * 监听 Activity 的声明周期
     *
     * @param application
     */
    public void registerActivityCallback(Application application) {
        application.registerActivityLifecycleCallbacks(new ELKActivityLifecycleCallbacks());
    }


    /**
     * 小直播APP 数据上报使用的，用于 Demo 数据收集，您可以不用关心。
     *
     * @param action
     * @param userName
     * @param code
     * @param errorMsg
     * @param callback
     */
    public void reportELK(String action, String userName, long code, String errorMsg, TCHTTPMgr.Callback callback) {
        if (TextUtils.isEmpty(DEFAULT_ELK_HOST)) {
            // 对外的发布的源码版本会将 ELK 的上报拿掉。
            return;
        }
        Log.i(TAG, "reportELK: action = " + action + " userName = " + userName + " code = " + code);
        String reqUrl = DEFAULT_ELK_HOST;
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("action", action);
            jsonObject.put("action_result_code", code);
            jsonObject.put("action_result_msg", errorMsg);
            jsonObject.put("type", "xiaozhibo");
            jsonObject.put("bussiness", "xiaozhibo");
            jsonObject.put("userName", userName);
            jsonObject.put("platform", "android");
            if (mAppName != null) {
                jsonObject.put("appname", mAppName);
            }
            if (mPackageName != null) {
                jsonObject.put("appidentifier", mPackageName);
            }
            TCHTTPMgr.getInstance().request(reqUrl, jsonObject, null);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    /**
     * 获取当前 APP 的名字
     *
     * @return
     */
    private String getAPPName() {
        ApplicationInfo applicationInfo = mContext.getApplicationInfo();
        int stringId = applicationInfo.labelRes;
        return stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : mContext.getString(stringId);
    }

    /**
     * 获取当前 APP 的包名
     *
     * @return
     */
    private String getPackageName() {
        PackageInfo info;
        String packagename = "";
        if (this != null) {
            try {
                info = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
                // 当前版本的包名
                packagename = info.packageName;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return packagename;
    }


    /**
     * ELK 数据上报用于监听 Activity 生命周期的回调
     *
     * 主要是用于统计 APP 的使用体验时长。
     */
    private static class ELKActivityLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
        private int foregroundActivities;
        private boolean isChangingConfiguration;
        private long time;

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
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_STAY_TIME, TCUserMgr.getInstance().getUserId(), diff, "App体验时长", null);
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

}
