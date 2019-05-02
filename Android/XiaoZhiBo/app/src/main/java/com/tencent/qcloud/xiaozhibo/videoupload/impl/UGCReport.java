package com.tencent.qcloud.xiaozhibo.videoupload.impl;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


public class UGCReport {

    public static class ReportInfo {
        public int reqType = 0;
        public int errCode = 0;
        public String errMsg = "";
        public long reqTime = 0;
        public long reqTimeCost = 0;
        public long fileSize = 0;
        public String fileType = "";
        public String fileName = "";
        public String fileId = "";
        public int appId = 0;
        public String reqServerIp = "";
        public String reportId = "";
        public String reqKey = "";
        public String vodSessionKey = "";
        public int retryCount = 0;
        public boolean reporting = false;   // 正在上报


        public ReportInfo() {
        }

        public ReportInfo(ReportInfo info) {
            this.reqType = info.reqType;
            this.errCode = info.errCode;
            this.errMsg = info.errMsg;
            this.reqTime = info.reqTime;
            this.reqTimeCost = info.reqTimeCost;
            this.fileSize = info.fileSize;
            this.fileType = info.fileType;
            this.fileName = info.fileName;
            this.fileId = info.fileId;
            this.appId = info.appId;
            this.reqServerIp = info.reqServerIp;
            this.reportId = info.reportId;
            this.reqKey = info.reqKey;
            this.vodSessionKey = info.vodSessionKey;
            this.retryCount = 0;
            this.reporting = false;
        }
    };

    private static final String TAG = UGCReport.class.getSimpleName();
    private static final int MAX_CACHES = 100;//最多缓存的上报记录条数

    private static UGCReport ourInstance;

    private Context context;
    private OkHttpClient okHttpClient;
    private List<ReportInfo> reportCaches = new ArrayList<ReportInfo>();

    private TimerTask reportTask = null;
    private Timer mTimer;


    public static UGCReport getInstance(Context context) {
        if (ourInstance == null) {
            synchronized (UGCReport.class) {
                if (ourInstance == null) {
                    ourInstance = new UGCReport(context);
                }
            }
        }

        return ourInstance;
    }


    private UGCReport(Context context) {
        this.context = context;
        okHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(10, TimeUnit.SECONDS)    // 设置超时时间
                .readTimeout(10, TimeUnit.SECONDS)       // 设置读取超时时间
                .writeTimeout(10, TimeUnit.SECONDS)      // 设置写入超时时间
                .build();
        reportTask = new TimerTask() {
            @Override
            public void run() {
                reportAll();
            }
        };
    }

    private synchronized void reportAll() {
        if (!TVCUtils.isNetworkAvailable(context)) {
            return;
        }

        synchronized (reportCaches) {
            Iterator iter = reportCaches.iterator();
            while (iter.hasNext()) {
                ReportInfo info = (ReportInfo) iter.next();
                if (info.retryCount < 4) {
                    if (!info.reporting)
                        report(info);
                } else {
                    iter.remove();
                }
            }
        }
    }

    public void addReportInfo(ReportInfo info) {
        if (mTimer == null) {
            mTimer = new Timer(true);
            mTimer.schedule(reportTask, 10 * 000, 10 * 1000);
        }

        ReportInfo newInfo = new ReportInfo(info);

        synchronized (reportCaches) {
            if (reportCaches.size() > MAX_CACHES) {
                reportCaches.remove(0);
            }
            reportCaches.add(newInfo);
        }
        reportAll();
    }

    public void report(final ReportInfo info) {
        try {
            String body = "";
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("version", TVCConstants.TVCVERSION);
            jsonObject.put("reqType", info.reqType);
            jsonObject.put("errCode", info.errCode);
            jsonObject.put("errMsg", info.errMsg);
            jsonObject.put("reqTimeCost", info.reqTimeCost);
            jsonObject.put("reqServerIp", info.reqServerIp);
            jsonObject.put("platform", 2000); // 1000 - iOS, 2000 - Android
            jsonObject.put("device", Build.MANUFACTURER + Build.MODEL);
            jsonObject.put("osType", String.valueOf(Build.VERSION.SDK_INT));
            jsonObject.put("netType", TVCUtils.getNetWorkType(context));
            jsonObject.put("reqTime", info.reqTime);
            jsonObject.put("reportId", info.reportId);
            jsonObject.put("uuid", TVCUtils.getDevUUID(context));
            jsonObject.put("reqKey", info.reqKey);
            jsonObject.put("appId", info.appId);
            jsonObject.put("fileSize", info.fileSize);
            jsonObject.put("fileType", info.fileType);
            jsonObject.put("fileName", info.fileName);
            jsonObject.put("vodSessionKey", info.vodSessionKey);
            jsonObject.put("fileId", info.fileId);
            ++info.retryCount;
            info.reporting = true;
            body = jsonObject.toString();
            String reqUrl = "https://vodreport.qcloud.com/ugcupload";
            Log.i(TAG, "reportUGCEvent->request url:" + reqUrl + " body:" + body);
            RequestBody requestBody = RequestBody.create(MediaType.parse("application/json"), body);
            Request request = new Request.Builder()
                    .url(reqUrl)
                    .post(requestBody)
                    .build();

            okHttpClient.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    info.reporting = false;
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    if (response != null && response.isSuccessful()) {
                        synchronized (reportCaches) {
                            reportCaches.remove(info);
                        }
                    } else {
                        info.reporting = false;
                    }
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
        }

    }
}