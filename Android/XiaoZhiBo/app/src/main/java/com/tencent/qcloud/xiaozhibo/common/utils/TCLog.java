package com.tencent.qcloud.xiaozhibo.common.utils;

import android.content.Context;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import com.tencent.rtmp.ITXLiveBaseListener;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;

/**
 * 获取RTMP SDK内部log，并保存到文件
 * 1.实现ITXLiveBaseListener回调接口获取RTMPSDK的log
 * 2.开启单独线程将log保存到sdcard路径：tencent/imsdklogs/com/tencent/qcloud/xiaozhibo/rtmpsdk_日期.log
 *   其中日期以天为单位，每天保存一个文件，如rtmpsdk_20160901.log
 * 3.app的log使用TXLog和RTMPSDK的log一起保存
 */
public class TCLog implements ITXLiveBaseListener {
    static private int LOG_MSG = 1001;
    static private String LOG_PATH = "/tencent/imsdklogs/";
    private Handler mLogHandler;
    private HandlerThread mLogThread;
    public TCLog(Context context) {
        mLogThread = new HandlerThread("TCLogThread");
        mLogThread.start();
        mLogHandler = new TCLogHandler(context,mLogThread.getLooper());
    }

    /**
     * RTMP SDK log回调,app自己保存log
     * @param level log级别
     * @param module log模块
     * @param msg 具体log内容
     */
    @Override
    public void OnLog(int level, String module, String msg) {
        Bundle data = new Bundle();
        data.putInt("LEVEL",level);
        data.putString("MODULE",module);
        data.putString("MSG",msg);
        Message logMsg = new Message();
        logMsg.what = LOG_MSG;
        logMsg.setData(data);
        if (mLogHandler != null) {
            mLogHandler.sendMessage(logMsg);
        }
    }

    static class TCLogHandler extends Handler {

        private FileOutputStream mLogFileStream;
        private Context mContext;
        public TCLogHandler(Context context, Looper looper) {
            super(looper);
            mContext = context;
            openLogFile();

        }

        public void handleMessage(Message msg) {
            if (msg.what == LOG_MSG) {
                Bundle data = msg.getData();
                if (data != null) {
                    appendMsg(data.getInt("LEVEL",0), data.getString("MODULE",""),data.getString("MSG",""));
                }
            }
        }

        private void appendMsg(int level, String module, String msg) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
            String date = sdf.format(System.currentTimeMillis());
            if (mLogFileStream != null) {
                String logMsg = date + "|level:" + level + "|module:" + module + "|" + msg + "\n";
                try {
                    mLogFileStream.write(logMsg.getBytes());
//                    Log.d(module, msg);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        /**
         * 打开log文件
         */
        private void openLogFile() {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            String date = sdf.format(System.currentTimeMillis());

            File sdcard = Environment.getExternalStorageDirectory();
            String pkgName = mContext.getPackageName();
            String pkgPath = pkgName.replace(".", "/");
            File dir = new File(sdcard.getAbsolutePath() + LOG_PATH + pkgPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            String fileName = "rtmpsdk_"+date+".log";
            File logFile = new File(dir, fileName);
            try {
                mLogFileStream = new FileOutputStream(logFile);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                mLogFileStream = null;
            }
        }
    }
}
