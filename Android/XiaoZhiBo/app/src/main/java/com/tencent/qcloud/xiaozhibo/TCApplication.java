package com.tencent.qcloud.xiaozhibo;

import android.content.Context;
import android.support.multidex.MultiDexApplication;

import com.tencent.bugly.crashreport.CrashReport;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoomImpl;
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.rtmp.TXLiveBase;

/**
 * Module:   TCApplication
 *
 * Function: 初始化 App 所需要的组件
 *
 * 1. 【重要】初始化直播需要的 Licence : {@link TXLiveBase#setLicence(Context, String, String)}
 *
 * 2. 初始化 App 用户逻辑管理类。
 *
 * 3. 初始化 bugly 组件上报 crash。
 *
 * 4. 初始化友盟分享组件，分享内容到 QQ 或 微信。
 *
 * 5. 初始化小直播ELK上报数据系统，此系统用于 Demo 收集使用数据；您可以不关注相关代码。
 */
public class TCApplication extends MultiDexApplication {
    private static final String TAG = "TCApplication";

    // 如何获取License? 请参考官网指引 https://cloud.tencent.com/document/product/454/34750
    private static final String LICENCE_URL = "http://ugc-licence-test-1252463788.coscd.myqcloud.com/XiaoZhiBo_Android.license";
    private static final String LICENCE_KEY = "9bc74ac7bfd07ea392e8fdff2ba5678a";

    @Override
    public void onCreate() {
        super.onCreate();

        // 必须：初始化 LiteAVSDK Licence。 用于直播推流鉴权。
        TXLiveBase.getInstance().setLicence(this, LICENCE_URL, LICENCE_KEY);

        // 必须：初始化 MLVB 组件
        MLVBLiveRoomImpl.sharedInstance(this);

        // 必须：初始化全局的 用户信息管理类，记录个人信息。
        TCUserMgr.getInstance().initContext(getApplicationContext());

        // 可选：初始化 bugly crash上报系统。
        initBuglyCrashReportSDK();

        // 可选：初始化小直播上报组件
        initXZBAppELKReport();
    }


    /**
     * 初始化 bugly crash 组件：用于上报小直播的 crash。
     */
    private void initBuglyCrashReportSDK() {
        CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(getApplicationContext());
        strategy.setAppVersion(TXLiveBase.getSDKVersionStr());
        // 若您需要使用的话，请将 TCConstants.BUGLY_APPID 替换为您的 appid，否则会出现无法上报的问题。
        CrashReport.initCrashReport(getApplicationContext(), TCGlobalConfig.BUGLY_APPID, true, strategy);
    }

    /**
     *
     * 初始化 ELK 数据上报：仅仅适用于数据收集上报，您可以不关注；或者将相关代码删除。
     */
    private void initXZBAppELKReport() {
        TCELKReportMgr.getInstance().init(this);
        TCELKReportMgr.getInstance().registerActivityCallback(this);
        TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_START_UP, TCUserMgr.getInstance().getUserId(), 0, "启动成功", null);
    }

}
