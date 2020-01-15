package com.tencent.liteav.demo.lvb.liveroom.roomutil.misc;

import android.Manifest;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by jac on 2017/11/16.
 * Copyright © 2013-2017 Tencent Cloud. All Rights Reserved.
 */

public abstract class CommonAppCompatActivity extends AppCompatActivity {

    private static final String TAG = CommonAppCompatActivity.class.getSimpleName();

    private static final int PERMISSIONS_REQUEST_CODE = 1;
    private AndroidPermissions mPermissions;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mPermissions = new AndroidPermissions(this,
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
                );

        doChecking();
    }

    private void doChecking() {
        if (mPermissions.checkPermissions()) {
            onPermissionGranted();
        } else {
            mPermissions.requestPermissions(PERMISSIONS_REQUEST_CODE);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        Log.i(TAG, "onRequestPermissionsResult");

        if (mPermissions.areAllRequiredPermissionsGranted(permissions, grantResults)) {
            onPermissionDisable();
        } else {
            onPermissionGranted();
        }
    }

    public abstract void onPermissionDisable() ;
    public abstract void onPermissionGranted();

}
