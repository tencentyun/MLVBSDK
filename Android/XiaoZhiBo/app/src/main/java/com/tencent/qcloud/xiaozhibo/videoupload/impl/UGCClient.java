package com.tencent.qcloud.xiaozhibo.videoupload.impl;

import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.net.InetAddress;
import java.util.concurrent.TimeUnit;

import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;


/**
 * UGC Client
 */
public class UGCClient {
    private final static String TAG = "TVC-UGCClient";
    private Context context;
    private String signature;
    private OkHttpClient okHttpClient;
    private Handler mainHandler;
    public static String SERVER = "https://vod2.qcloud.com/v3/index.php?Action=";
    private String serverIP = "";


    public UGCClient(Context context, String signature, int iTimeOut) {
        this.context = context;
        this.signature = signature;

        okHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(iTimeOut, TimeUnit.SECONDS)    // 设置超时时间
                .readTimeout(iTimeOut, TimeUnit.SECONDS)       // 设置读取超时时间
                .writeTimeout(iTimeOut, TimeUnit.SECONDS)      // 设置写入超时时间
                .build();

        mainHandler = new Handler(context.getMainLooper());
    }

//    private String getCommonReqPath(String interfaceName) {
//        return SERVER + interfaceName
//                + "&Region=gz"
//                + "&Timestamp=" + String.valueOf(System.currentTimeMillis() / 1000)
//                + "&Nonce=" + String.valueOf((int) Math.random() * 65535 + 1)
//                + "&SecretId=" + URLEncoder.encode(scretId)
//                + "&Signature=" + URLEncoder.encode(UGCSignature);
//    }

    /**
     * 申请上传（UGC接口）
     *
     * @param info     文件信息
     * @param customKey
     *@param callback 回调  @return
     */
    public int initUploadUGC(TVCUploadInfo info, String customKey, String vodSessionKey, Callback callback) {
        String reqUrl = SERVER + "ApplyUploadUGC";
        Log.d(TAG, "initUploadUGC->request url:" + reqUrl);

        String body = "";
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("signature", signature);
            jsonObject.put("videoName", info.getFileName());
            jsonObject.put("videoType", info.getFileType());
            // 判断是否需要上传封面
            if (info.isNeedCover()) {
                jsonObject.put("coverName",info.getCoverName());
                jsonObject.put("coverType",info.getCoverImgType());
            }
            jsonObject.put("clientReportId", customKey);
            jsonObject.put("clientVersion", TVCConstants.TVCVERSION);
            if (!TextUtils.isEmpty(vodSessionKey)) {
                jsonObject.put("vodSessionKey", vodSessionKey);
            }
            body = jsonObject.toString();
            Log.d(TAG, body);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        RequestBody requestBody = RequestBody.create(MediaType.parse("application/json"), body);
        Request request = new Request.Builder()
                .url(reqUrl)
                .post(requestBody)
                .build();

        final String host = request.url().host();
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    InetAddress address = InetAddress.getByName(host);
                    serverIP = address.getHostAddress();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();

        okHttpClient.newCall(request).enqueue(callback);

        return TVCConstants.NO_ERROR;
    }

    /**
     * 上传结束(UGC接口)
     *
     * @param domain        视频上传的域名
     * @param vodSessionKey 视频上传的会话key
     * @param callback 回调
     * @return
     */
    public int finishUploadUGC(String domain, String customKey, String vodSessionKey, final Callback callback) {
        String reqUrl = "https://" + domain + "/v3/index.php?Action=CommitUploadUGC";
        Log.d(TAG, "finishUploadUGC->request url:" + reqUrl);
        String body = "";
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("signature", signature);
            jsonObject.put("clientReportId", customKey);
            jsonObject.put("clientVersion", TVCConstants.TVCVERSION);
            jsonObject.put("vodSessionKey", vodSessionKey);
            body = jsonObject.toString();
            Log.d(TAG, body);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        RequestBody requestBody = RequestBody.create(MediaType.parse("application/json"), body);
        Request request = new Request.Builder()
                .url(reqUrl)
                .post(requestBody)
                .build();

        final String host = request.url().host();
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    InetAddress address = InetAddress.getByName(host);
                    serverIP = address.getHostAddress();
                } catch (Exception e) {
                    serverIP = host;
                    e.printStackTrace();
                }
            }
        }).start();

        okHttpClient.newCall(request).enqueue(callback);

        return TVCConstants.NO_ERROR;
    }

    public String getServerIP() {
        return serverIP;
    }

    public void updateSignature(String signature) {
        this.signature = signature;
    }

    public void postFile(TVCUploadInfo info, String customKey, final ProgressRequestBody.ProgressListener listener, Callback callback){
        File videoFile = new File(info.getFilePath());
        MultipartBody.Builder builder = new MultipartBody.Builder();
        builder.setType(MultipartBody.FORM);
        String body = "";
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("signature", signature);
            jsonObject.put("videoName", info.getFileName());
            jsonObject.put("videoType", info.getFileType());
            jsonObject.put("videoSize", info.getFileSize());
            // 判断是否需要上传封面
            if (info.isNeedCover()) {
                jsonObject.put("coverName",info.getCoverName());
                jsonObject.put("coverType",info.getCoverImgType());
                jsonObject.put("coverSize", info.getCoverFileSize());
            }
            jsonObject.put("clientReportId", customKey);
            jsonObject.put("clientVersion", TVCConstants.TVCVERSION);
            body = jsonObject.toString();
            Log.d(TAG, body);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        builder.addFormDataPart("para", null, RequestBody.create(MediaType.parse("application/json"), body));
        builder.addFormDataPart("video_content",videoFile.getName(), RequestBody.create(MediaType.parse("application/octet-stream"),videoFile));
        if (info.isNeedCover()) {
            builder.addFormDataPart("cover_content", info.getCoverName(), RequestBody.create(MediaType.parse("application/octet-stream"),new File(info.getCoverPath())));
        }

        MultipartBody multipartBody = builder.build();

        Request request  = new Request.Builder().url(SERVER + "UploadFile").post(new ProgressRequestBody(multipartBody,listener)).build();

        final String host = request.url().host();
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    InetAddress address = InetAddress.getByName(host);
                    serverIP = address.getHostAddress();
                } catch (Exception e) {
                    serverIP = host;
                    e.printStackTrace();
                }
            }
        }).start();

        okHttpClient.newCall(request).enqueue(callback);
    }
}
