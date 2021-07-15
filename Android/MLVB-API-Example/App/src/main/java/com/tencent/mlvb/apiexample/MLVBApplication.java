package com.tencent.mlvb.apiexample;

import android.app.Application;

import androidx.multidex.MultiDex;

import com.tencent.mlvb.debug.GenerateTestUserSig;
import com.tencent.rtmp.TXLiveBase;

public class MLVBApplication extends Application {

    private static MLVBApplication instance;

    @Override
    public void onCreate() {
        super.onCreate();
        MultiDex.install(this);
        instance = this;
        TXLiveBase.setConsoleEnabled(true);
        TXLiveBase.getInstance().setLicence(instance, GenerateTestUserSig.LICENSEURL, GenerateTestUserSig.LICENSEURLKEY);
    }

}
