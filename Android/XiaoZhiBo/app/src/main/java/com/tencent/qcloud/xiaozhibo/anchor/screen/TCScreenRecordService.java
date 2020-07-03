package com.tencent.qcloud.xiaozhibo.anchor.screen;

import android.annotation.TargetApi;
import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.IBinder;
import android.support.v4.content.LocalBroadcastManager;

import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.rtmp.TXLog;

/**
 * 前台进程
 * 添加广播消息监听下线通知，若被挤下线则强制拉起陆平页面显示错误信息
 */
@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class TCScreenRecordService extends Service {

    private static final String TAG = TCScreenRecordService.class.getSimpleName();

    //被踢下线广播监听
    private LocalBroadcastManager mLocalBroadcatManager;
    private BroadcastReceiver mExitBroadcastReceiver;

    public TCScreenRecordService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        Notification.Builder builder = new Notification.Builder(this);
        Intent intent = new Intent(this, TCScreenAnchorActivity.class);
        final PendingIntent contentIntent = PendingIntent.getActivity(getApplicationContext(), 0, intent, 0);
        builder.setContentIntent(contentIntent);
        builder.setTicker("Foreground Service Start");
        builder.setContentTitle("正在进行录制");
        Notification notification = builder.build();
        //把该service创建为前台service
        startForeground(1, notification);

        mLocalBroadcatManager = LocalBroadcastManager.getInstance(this);
        mExitBroadcastReceiver = new ExitBroadcastRecevier();
        mLocalBroadcatManager.registerReceiver(mExitBroadcastReceiver, new IntentFilter(TCConstants.EXIT_APP));

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mLocalBroadcatManager.unregisterReceiver(mExitBroadcastReceiver);
    }

    public class ExitBroadcastRecevier extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(TCConstants.EXIT_APP)) {
                TXLog.d(TAG, "service broadcastReceiver receive exit app msg");
                //唤醒activity提示推流结束
                Intent restartIntent = new Intent(getApplicationContext(), TCScreenAnchorActivity.class);
                restartIntent.setAction(TCConstants.EXIT_APP);
                restartIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(restartIntent);
            }
        }
    }
}
