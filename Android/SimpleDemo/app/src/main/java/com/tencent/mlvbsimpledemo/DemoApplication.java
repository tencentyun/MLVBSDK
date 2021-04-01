package com.tencent.mlvbsimpledemo;

import android.app.Application;
import com.tencent.rtmp.TXLiveBase;

public class DemoApplication extends Application {

    private static DemoApplication instance;

    // 如何获取License? 请参考官网指引 https://cloud.tencent.com/document/product/454/34750
    String licenceUrl = "请替换成您的licenseUrl";
    String licenseKey = "请替换成您的licenseKey";

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        TXLiveBase.setConsoleEnabled(true);
        TXLiveBase.getInstance().setLicence(instance, licenceUrl, licenseKey);
    }

}
