package com.tencent.qcloud.xiaozhibo.common.interrupt;

import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;

import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;

import java.lang.ref.WeakReference;


public class TXPhoneStateListener extends PhoneStateListener {
    WeakReference<MLVBLiveRoom> mPusher;
    public TXPhoneStateListener(MLVBLiveRoom pusher) {
        mPusher = new WeakReference<MLVBLiveRoom>(pusher);
    }
    @Override
    public void onCallStateChanged(int state, String incomingNumber) {
        super.onCallStateChanged(state, incomingNumber);
        MLVBLiveRoom pusher = mPusher.get();
        switch(state){
            //电话等待接听
            case TelephonyManager.CALL_STATE_RINGING:
//                if (pusher != null) pusher.switchToBackground();
                break;
            //电话接听
            case TelephonyManager.CALL_STATE_OFFHOOK:
//                if (pusher != null) pusher.switchToBackground();
                break;
            //电话挂机
            case TelephonyManager.CALL_STATE_IDLE:
//                if (pusher != null) pusher.switchToForeground();
                break;
        }
    }
};