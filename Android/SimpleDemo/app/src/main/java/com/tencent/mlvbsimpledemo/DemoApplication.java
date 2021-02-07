package com.tencent.mlvbsimpledemo;

import android.app.Application;
import com.tencent.rtmp.TXLiveBase;

public class DemoApplication extends Application {

    private static DemoApplication instance;

    // 如何获取License? 请参考官网指引 https://cloud.tencent.com/document/product/454/34750
    String licenceUrl = "http://download-1252463788.cossh.myqcloud.com/xiaoshipin/licence_android/RDM_Enterprise.license";
    String licenseKey = "9bc74ac7bfd07ea392e8fdff2ba5678a";

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        TXLiveBase.setConsoleEnabled(true);
        TXLiveBase.getInstance().setLicence(instance, licenceUrl, licenseKey);
    }

}
