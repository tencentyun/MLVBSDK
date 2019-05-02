package com.tencent.qcloud.xiaozhibo.videoupload.impl;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.common.Region;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlProgressListener;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.object.InitMultipartUploadRequest;
import com.tencent.cos.xml.model.object.InitMultipartUploadResult;
import com.tencent.cos.xml.model.object.PutObjectRequest;
import com.tencent.cos.xml.transfer.UploadService;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.InetAddress;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Response;

/**
 * 视频上传客户端
 */
public class TVCClient {
    private final static String TAG = "TVC-Client";
    private Context context;
    private Handler mainHandler;
    private boolean busyFlag = false;

    private TVCUploadInfo uploadInfo;

    private UGCClient ugcClient;
    private TVCUploadListener tvcListener;

    private int cosAppId;   //点播上传用到的COS appid
    private int userAppId;  //客户自己的appid，数据上报需要
    private String uploadRegion = "";
    private String cosBucket;
    private String cosTmpSecretId = "";
    private String cosTmpSecretKey = "";
    private String cosToken = "";
    private long cosExpiredTime;
    private long localTimeAdvance = 0;        //本地时间相对unix时间戳提前间隔

    private String cosVideoPath;
    private String videoFileId;
    private String cosCoverPath;

    private String domain;
    private String cosIP = "";
    private String vodSessionKey = null;

    private long reqTime = 0;            //各阶段开始请求时间
    private long initReqTime = 0;        //上传请求时间，用于拼接reqKey。串联请求
    private String customKey = "";       //用于数据上报

    private CosXmlService cosService;
    private UploadService cosUploadHelper;

    // 断点重传session本地缓存
    // 以文件路径作为key值得，存储的内容是<session, uploadId, fileLastModify, expiredTime>
    private static final String LOCALFILENAME = "TVCSession";
    private SharedPreferences mSharedPreferences;
    private SharedPreferences.Editor mShareEditor;

    private String uploadId = null;
    private long fileLastModTime = 0;     //视频文件最后修改时间
    private boolean enableResume = true;
    private boolean enableHttps = false;
    private UGCReport.ReportInfo reportInfo;

    /**
     * 初始化上传实例
     *
     * @param signature 签名
     * @param iTimeOut  超时时间
     */
    public TVCClient(Context context, String customKey, String signature, boolean enableResume, boolean enableHttps, int iTimeOut) {
        this.context = context.getApplicationContext();
        ugcClient = new UGCClient(context, signature, iTimeOut);
        mainHandler = new Handler(context.getMainLooper());
        mSharedPreferences = context.getSharedPreferences(LOCALFILENAME, Activity.MODE_PRIVATE);
        mShareEditor = mSharedPreferences.edit();
        this.enableResume = enableResume;
        this.enableHttps = enableHttps;
        this.customKey = customKey;
        reportInfo = new UGCReport.ReportInfo();
        clearLocalCache();
    }

    /**
     * 初始化上传实例
     *
     * @param ugcSignature 签名
     */
    public TVCClient(Context context, String customKey, String ugcSignature, boolean resumeUpload, boolean enableHttps) {
        this(context, customKey, ugcSignature, resumeUpload, enableHttps, 8);
    }

    // 清理一下本地缓存，过期的删掉
    private void clearLocalCache() {
        if (mSharedPreferences != null) {
            try {
                Map<String, ?> allContent = mSharedPreferences.getAll();
                //注意遍历map的方法
                for(Map.Entry<String, ?>  entry : allContent.entrySet()){
                    JSONObject json = new JSONObject((String) entry.getValue());
                    long expiredTime = json.optLong("expiredTime", 0);
                    // 过期了清空key
                    if (expiredTime < System.currentTimeMillis() / 1000) {
                        mShareEditor.remove(entry.getKey());
                        mShareEditor.commit();
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // 通知上层上传成功
    private void notifyUploadSuccess(final String fileId, final String playUrl, final String coverUrl) {
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                tvcListener.onSucess(fileId, playUrl, coverUrl);
            }
        });
    }

    // 通知上层上传失败
    private void notifyUploadFailed(final int errCode, final String errMsg) {
        mainHandler.post(new Runnable() {
                @Override
                public void run() {
                    tvcListener.onFailed(errCode, errMsg);
                }
            });
    }

    // 通知上层上传进度
    private void notifyUploadProgress(final long currentSize, final long totalSize) {
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                tvcListener.onProgress(currentSize, totalSize);
            }
        });
    }

    private boolean isVideoFileExist(String path) {
        File file = new File(path);
        try {
            if (file.exists()) {
                return true;
            }
        } catch (Exception e) {
            Log.e("getFileSize", "getFileSize: " + e);
            return false;
        }
        return false;
    }

    /**
     * 上传视频文件
     *
     * @param info     视频文件信息
     * @param listener 上传回调
     * @return
     */
    public int uploadVideo(TVCUploadInfo info, TVCUploadListener listener) {
        if (busyFlag) {     // 避免一个对象传输多个文件
            return TVCConstants.ERR_CLIENT_BUSY;
        }
        busyFlag = true;
        this.uploadInfo = info;
        this.tvcListener = listener;

        if (!isVideoFileExist(info.getFilePath())) { //视频文件不存在 直接返回
            tvcListener.onFailed(TVCConstants.ERR_UGC_REQUEST_FAILED, "file could not find");

            txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_FILE_NOEXIT, "file could not find", System.currentTimeMillis(), 0, 0, "", "");

            return -1;

        }

        String fileName = info.getFileName();
        Log.d(TAG, "fileName = " + fileName);
        if (fileName != null && fileName.getBytes().length > 200) { //视频文件名太长 直接返回
            tvcListener.onFailed(TVCConstants.ERR_UGC_FILE_NAME, "file name too long");
            txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_UGC_FILE_NAME, "file name too long", System.currentTimeMillis(), 0, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

            return TVCConstants.ERR_UGC_FILE_NAME;
        }

        if (info.isContainSpecialCharacters(fileName)) {//视频文件名包含特殊字符 直接返回
            tvcListener.onFailed(TVCConstants.ERR_UGC_FILE_NAME, "file name contains special character / : * ? \" < >");

            txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_UGC_FILE_NAME, "file name contains special character / : * ? \" < >", System.currentTimeMillis(), 0, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

            return TVCConstants.ERR_UGC_FILE_NAME;
        }

        // // 判断是不是要走直接上传，先直接用文件大小区分。小于5M走直接上传
        // if (info.getFileSize() < 5 * 1024 * 1024) {
        //     uploadToVOD();
        //     return TVCConstants.NO_ERROR;
        // }

        if (enableResume)
            getResumeData(info.getFilePath());
        getCosUploadInfo(info, vodSessionKey);
        return TVCConstants.NO_ERROR;
    }

    // 直接上传到VOD，一个http请求
    private void uploadToVOD() {
        reqTime = System.currentTimeMillis();
        initReqTime = reqTime;
        ugcClient.postFile(uploadInfo, customKey, new ProgressRequestBody.ProgressListener() {
            @Override
            public void onProgress(long currentBytes, long contentLength) {
                Log.i(TAG, "onProgress [ " + currentBytes + " / " + contentLength + "]");
                notifyUploadProgress(currentBytes, contentLength);
            }
        }, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                notifyUploadFailed(TVCConstants.ERR_UPLOAD_VOD, e.toString());
                txReport(TVCConstants.UPLOAD_EVENT_ID_VOD_UPLOAD, TVCConstants.ERR_UPLOAD_VOD, e.toString(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
                Log.i(TAG, "onFailure " + e.toString());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (!response.isSuccessful()) {
                    txReport(TVCConstants.UPLOAD_EVENT_ID_VOD_UPLOAD, TVCConstants.ERR_UPLOAD_VOD, "HTTP Code:" + response.code(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
                    notifyUploadFailed(TVCConstants.ERR_UPLOAD_VOD, "HTTP Code:" + response.code());
                } else {
                    parseVodRsp(response.body().string());
                }
            }
        });
    }

    private void parseVodRsp(String rspString) {
        Log.i(TAG, "parseVodRsp: " + rspString);
        if (TextUtils.isEmpty(rspString)) {
            Log.e(TAG, "parseVodRsp->response is empty!");
            notifyUploadFailed(TVCConstants.ERR_UPLOAD_VOD, "vodupload response is empty");

            txReport(TVCConstants.UPLOAD_EVENT_ID_VOD_UPLOAD, TVCConstants.ERR_UPLOAD_VOD, "vodupload response is empty", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

            return;
        }

        try {
            JSONObject jsonRsp = new JSONObject(rspString);
            int code = jsonRsp.optInt("code", -1);

            String message = "";
            try {
                message = new String(jsonRsp.optString("message", "").getBytes("UTF-8"),"utf-8");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            if (0 != code) {
                notifyUploadFailed(TVCConstants.ERR_UPLOAD_VOD, code + "|" + message);
                txReport(TVCConstants.UPLOAD_EVENT_ID_VOD_UPLOAD, TVCConstants.ERR_UPLOAD_VOD, code + "|" + message, reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
                return;
            }

            JSONObject dataRsp = jsonRsp.getJSONObject("data");
            String coverUrl = "";
            if (uploadInfo.isNeedCover()) {
                JSONObject coverObj = dataRsp.getJSONObject("cover");
                coverUrl = coverObj.getString("url");
            }
            JSONObject videoObj = dataRsp.getJSONObject("video");
            String playUrl = videoObj.getString("url");
            videoFileId = dataRsp.getString("fileId");
            notifyUploadSuccess(videoFileId, playUrl, coverUrl);

            txReport(TVCConstants.UPLOAD_EVENT_ID_VOD_UPLOAD, 0, "", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName(), videoFileId);

            Log.d(TAG, "playUrl:" + playUrl);
            Log.d(TAG, "coverUrl: " + coverUrl);
            Log.d(TAG, "videoFileId: " + videoFileId);

        } catch (JSONException e) {
            Log.e(TAG, e.toString());
            txReport(TVCConstants.UPLOAD_EVENT_ID_VOD_UPLOAD, TVCConstants.ERR_UPLOAD_VOD, e.toString(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
            notifyUploadFailed(TVCConstants.ERR_UPLOAD_VOD, e.toString());
            return;
        }

    }

    /**
     * 取消（中断）上传。中断之后恢复上传再用相同的参数调用uploadVideo即可。
     * @return 成功或者失败
     */
    public void cancleUpload() {
        if (cosUploadHelper != null) {
            cosUploadHelper.pause();
            busyFlag = false;
        }
    }

    private void getCosUploadInfo(TVCUploadInfo info, String vodSessionKey) {
        // 第一步 向UGC请求上传(获取COS认证信息)

        reqTime = System.currentTimeMillis();
        initReqTime = reqTime;
        ugcClient.initUploadUGC(info, customKey, vodSessionKey, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e(TAG, "initUploadUGC->onFailure: " + e.toString());
                notifyUploadFailed(TVCConstants.ERR_UGC_REQUEST_FAILED, e.toString());

                txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_UGC_REQUEST_FAILED, e.toString(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (!response.isSuccessful()) {
                    notifyUploadFailed(TVCConstants.ERR_UGC_REQUEST_FAILED, "HTTP Code:" + response.code());

                    txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_UGC_REQUEST_FAILED, "HTTP Code:" + response.code(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

                    setResumeData(uploadInfo.getFilePath(), "", "");

                    Log.e(TAG, "initUploadUGC->http code: " + response.code());
                    throw new IOException("" + response);
                } else {
                    parseInitRsp(response.body().string());
                }
            }
        });
    }

    // 解析上传请求返回信息
    private void parseInitRsp(String rspString) {
        Log.i(TAG, "parseInitRsp: " + rspString);
        if (TextUtils.isEmpty(rspString)) {
            Log.e(TAG, "parseInitRsp->response is empty!");
            notifyUploadFailed(TVCConstants.ERR_UGC_PARSE_FAILED, "init response is empty");

            txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_UGC_REQUEST_FAILED, "init response is empty", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

            setResumeData(uploadInfo.getFilePath(), "", "");

            return;
        }

        try {
            JSONObject jsonRsp = new JSONObject(rspString);
            int code = jsonRsp.optInt("code", -1);
            Log.i(TAG, "parseInitRsp: " + code);

            String message = "";
            try {
                message = new String(jsonRsp.optString("message", "").getBytes("UTF-8"),"utf-8");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            if (0 != code) {
                notifyUploadFailed(TVCConstants.ERR_UGC_PARSE_FAILED, code + "|" + message);

                txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_UGC_REQUEST_FAILED, code + "|" + message, reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

                vodSessionKey = null;
                setResumeData(uploadInfo.getFilePath(), "", "");

                return;
            }

            JSONObject dataObj = jsonRsp.getJSONObject("data");
            JSONObject videoObj = dataObj.getJSONObject("video");
            cosVideoPath = videoObj.getString("storagePath");

            // cos上传临时证书
            JSONObject tempCertificate = dataObj.getJSONObject("tempCertificate");
            cosTmpSecretId = tempCertificate.optString("secretId");
            cosTmpSecretKey = tempCertificate.optString("secretKey");
            cosToken = tempCertificate.optString("token");
            cosExpiredTime = tempCertificate.optLong("expiredTime");

            long serverTS = dataObj.optLong("timestamp", 0);

            Log.d(TAG, "isNeedCover:" + uploadInfo.isNeedCover());
            if (uploadInfo.isNeedCover()) {
                JSONObject coverObj = dataObj.getJSONObject("cover");
                cosCoverPath = coverObj.getString("storagePath");
            }
            cosAppId = dataObj.getInt("storageAppId");
            cosBucket = dataObj.getString("storageBucket");
            uploadRegion = dataObj.getString("storageRegionV5");
            domain = dataObj.getString("domain");
            vodSessionKey = dataObj.getString("vodSessionKey");
            userAppId = dataObj.getInt("appId");

            Log.d(TAG, "cosVideoPath=" + cosVideoPath);
            Log.d(TAG, "cosCoverPath=" + cosCoverPath);
            Log.d(TAG, "cosAppId=" + cosAppId);
            Log.d(TAG, "cosBucket=" + cosBucket);
            Log.d(TAG, "uploadRegion=" + uploadRegion);
            Log.d(TAG, "domain=" + domain);
            Log.d(TAG, "vodSessionKey=" + vodSessionKey);

            getCosIP(uploadRegion);

            CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                    .setAppidAndRegion(String.valueOf(cosAppId), uploadRegion)
                    .setDebuggable(true)
                    .isHttps(enableHttps)
                    .builder();

            long localTS = System.currentTimeMillis() / 1000L;
            if (serverTS > 0 && (localTS - serverTS > 5 * 60 || serverTS - localTS > 5 * 60)) {
                localTimeAdvance = localTS - serverTS;
            }
            cosService = new CosXmlService(context, cosXmlServiceConfig,
                        new TVCDirectCredentialProvider(cosTmpSecretId, cosTmpSecretKey, cosToken, localTS - localTimeAdvance, cosExpiredTime));

            // 第二步 通过COS上传视频
            uploadCosVideo();
        } catch (JSONException e) {
            Log.e(TAG, e.toString());
            txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, TVCConstants.ERR_UGC_PARSE_FAILED, e.toString(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
            notifyUploadFailed(TVCConstants.ERR_UGC_PARSE_FAILED, e.toString());
            return;
        }

        txReport(TVCConstants.UPLOAD_EVENT_ID_REQUEST_UPLOAD, 0, "", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
    }

    private void getCosIP(String uploadRegion) {
        PutObjectRequest putObjectRequest = new PutObjectRequest(cosBucket, cosCoverPath, uploadInfo.getCoverPath());
        cosIP = putObjectRequest.getHost(String.valueOf(cosAppId), uploadRegion);

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    InetAddress address = InetAddress.getByName(cosIP);
                    cosIP = address.getHostAddress();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    // 通过COS上传封面
    private void uploadCosCover() {
        reqTime = System.currentTimeMillis();
        PutObjectRequest putObjectRequest = new PutObjectRequest(cosBucket, cosCoverPath, uploadInfo.getCoverPath());
        putObjectRequest.setProgressListener(new CosXmlProgressListener() {
            @Override
            public void onProgress(long progress, long max) {
                Log.d(TAG, "uploadCosCover->progress: " + progress + "/" + max);
                // 上传封面无进度
                //tvcListener.onProgress(currentSize, totalSize);
            }
        });

        putObjectRequest.setSign(reqTime/1000L - localTimeAdvance, cosExpiredTime);
        cosService.putObjectAsync(putObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult cosXmlResult) {
                txReport(TVCConstants.UPLOAD_EVENT_ID_COS_UPLOAD, 0, "", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getCoverFileSize(), uploadInfo.getCoverImgType(), uploadInfo.getCoverName());
                startFinishUploadUGC(cosXmlResult);
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest, CosXmlClientException qcloudException, CosXmlServiceException qcloudServiceException) {
                StringBuilder stringBuilder = new StringBuilder();
                if(qcloudException != null){
                    stringBuilder.append(qcloudException.getMessage());
                }else {
                    stringBuilder.append(qcloudServiceException.toString());
                }

                notifyUploadFailed(TVCConstants.ERR_UPLOAD_COVER_FAILED, "cos upload error:" + stringBuilder.toString());

                txReport(TVCConstants.UPLOAD_EVENT_ID_COS_UPLOAD, TVCConstants.ERR_UPLOAD_COVER_FAILED, stringBuilder.toString(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getCoverFileSize(), uploadInfo.getCoverImgType(), uploadInfo.getCoverName());
            }
        });
    }


    // 解析cos上传视频返回信息
    private void startUploadCoverFile(CosXmlResult result) {
        // 第三步 通过COS上传封面
        if (uploadInfo.isNeedCover()) {
            uploadCosCover();
        } else {
            startFinishUploadUGC(result);
        }
    }


    // 通过COS上传视频
    private void uploadCosVideo() {
        new Thread() {
            @Override
            public void run() {
                reqTime = System.currentTimeMillis();

                Log.i(TAG, "uploadCosVideo begin :  cosBucket " + cosBucket + " cosVideoPath: " + cosVideoPath + "  path " + uploadInfo.getFilePath());

                try {
                    CosXmlResult result;
                    UploadService.ResumeData resumeData = new UploadService.ResumeData();
                    resumeData.bucket = cosBucket;
                    resumeData.cosPath = cosVideoPath;
                    resumeData.srcPath = uploadInfo.getFilePath();
                    resumeData.sliceSize = 1024 * 1024;
                    if (isResumeUploadVideo()) {
                        resumeData.uploadId = uploadId;
                    } else {
                        InitMultipartUploadRequest initMultipartUploadRequest = new InitMultipartUploadRequest(cosBucket, cosVideoPath);
                        initMultipartUploadRequest.setSign(reqTime/1000L - localTimeAdvance, cosExpiredTime);
                        InitMultipartUploadResult initMultipartUploadResult = cosService.initMultipartUpload(initMultipartUploadRequest);
                        uploadId = initMultipartUploadResult.initMultipartUpload.uploadId;
                        setResumeData(uploadInfo.getFilePath(), vodSessionKey, uploadId);
                        resumeData.uploadId = uploadId;
                    }

                    cosUploadHelper = new UploadService(cosService, resumeData);
                    cosUploadHelper.setProgressListener(new CosXmlProgressListener() {
                        @Override
                        public void onProgress(long progress, long max) {
                            notifyUploadProgress(progress, max);
                        }
                    });
                    cosUploadHelper.setSign(reqTime/1000L - localTimeAdvance, cosExpiredTime);
                    result = cosUploadHelper.resume(resumeData);
                    //分片上传完成之后清空本地缓存的断点续传信息
                    setResumeData(uploadInfo.getFilePath(), "", "");
                    txReport(TVCConstants.UPLOAD_EVENT_ID_COS_UPLOAD, 0, "", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

                    Log.w(TAG,result.accessUrl);
                    Log.i(TAG, "uploadCosVideo finish:  cosBucket " + cosBucket + " cosVideoPath: " + cosVideoPath + "  path: " + uploadInfo.getFilePath() + "  size: " + uploadInfo.getFileSize());

                    startUploadCoverFile(result);
                } catch (CosXmlClientException e) {
                    Log.w(TAG, "CosXmlClientException =" + e.getMessage());
                    txReport(TVCConstants.UPLOAD_EVENT_ID_COS_UPLOAD, TVCConstants.ERR_UPLOAD_VIDEO_FAILED, "CosXmlClientException:" + e.getMessage(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
                	//网络中断导致的
                    if (!TVCUtils.isNetworkAvailable(context)) {
                        notifyUploadFailed(TVCConstants.ERR_UPLOAD_VIDEO_FAILED, "cos upload video error: network unreachable");
                    } else if (busyFlag) { //其他错误，非主动取消
                        notifyUploadFailed(TVCConstants.ERR_UPLOAD_VIDEO_FAILED, "cos upload video error:" + e.getMessage());
                        setResumeData(uploadInfo.getFilePath(), "", "");
                    }
                } catch (CosXmlServiceException e) {
                    Log.w(TAG, "CosXmlServiceException =" + e.toString());
                    txReport(TVCConstants.UPLOAD_EVENT_ID_COS_UPLOAD, TVCConstants.ERR_UPLOAD_VIDEO_FAILED, "CosXmlServiceException: " + e.getMessage(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
                    // 临时密钥过期，重新申请一次临时密钥，不中断上传
                    if (e.getErrorCode().equalsIgnoreCase("RequestTimeTooSkewed")) {
                        getCosUploadInfo(uploadInfo, vodSessionKey);
                    } else {
                        notifyUploadFailed(TVCConstants.ERR_UPLOAD_VIDEO_FAILED, "cos upload video error:" + e.getMessage());
                        setResumeData(uploadInfo.getFilePath(), "", "");
                    }
                } catch (Exception e) {
                    Log.w(TAG,"Exception =" + e.toString());
                    txReport(TVCConstants.UPLOAD_EVENT_ID_COS_UPLOAD, TVCConstants.ERR_UPLOAD_VIDEO_FAILED, "HTTP Code:" + e.getMessage(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
                    notifyUploadFailed(TVCConstants.ERR_UPLOAD_VIDEO_FAILED, "cos upload video error:" + e.getMessage());
                    setResumeData(uploadInfo.getFilePath(), "", "");
                }
            }
        }.start();
    }

    // 解析cos上传视频返回信息
    private void startFinishUploadUGC(CosXmlResult result) {
        String strAccessUrl = result.accessUrl;
        Log.i(TAG, "startFinishUploadUGC: " + strAccessUrl);

        reqTime = System.currentTimeMillis();

        // 第三步 上传结束
        ugcClient.finishUploadUGC(domain, customKey, vodSessionKey, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.i(TAG, "FinishUploadUGC: fail" + e.toString());
                notifyUploadFailed(TVCConstants.ERR_UGC_FINISH_REQUEST_FAILED, e.toString());

                txReport(TVCConstants.UPLOAD_EVENT_ID_UPLOAD_RESULT, TVCConstants.ERR_UGC_FINISH_REQUEST_FAILED, e.toString(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (!response.isSuccessful()) {
                    notifyUploadFailed(TVCConstants.ERR_UGC_FINISH_REQUEST_FAILED, "HTTP Code:" + response.code());
                    Log.e(TAG, "FinishUploadUGC->http code: " + response.code());

                    txReport(TVCConstants.UPLOAD_EVENT_ID_UPLOAD_RESULT, TVCConstants.ERR_UGC_FINISH_REQUEST_FAILED, "HTTP Code:" + response.code(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

                    throw new IOException("" + response);
                } else {
                    Log.i(TAG, "FinishUploadUGC Suc onResponse body : " + response.body().toString());
                    parseFinishRsp(response.body().string());
                }
            }
        });
    }


    // 解析结束上传返回信息.
    private void parseFinishRsp(String rspString) {
        Log.i(TAG, "parseFinishRsp: " + rspString);
        if (TextUtils.isEmpty(rspString)) {
            Log.e(TAG, "parseFinishRsp->response is empty!");
            notifyUploadFailed(TVCConstants.ERR_UGC_FINISH_RESPONSE_FAILED, "finish response is empty");

            txReport(TVCConstants.UPLOAD_EVENT_ID_UPLOAD_RESULT, TVCConstants.ERR_UGC_FINISH_RESPONSE_FAILED, "finish response is empty", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

            return;
        }
        try {
            JSONObject jsonRsp = new JSONObject(rspString);
            int code = jsonRsp.optInt("code", -1);
            String message = jsonRsp.optString("message", "");
            if (0 != code) {
                notifyUploadFailed(TVCConstants.ERR_UGC_FINISH_RESPONSE_FAILED, code + "|" + message);

                txReport(TVCConstants.UPLOAD_EVENT_ID_UPLOAD_RESULT, TVCConstants.ERR_UGC_FINISH_RESPONSE_FAILED, code + "|" + message, reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());

                return;
            }
            JSONObject dataRsp = jsonRsp.getJSONObject("data");
            String coverUrl = "";
            if (uploadInfo.isNeedCover()) {
                JSONObject coverObj = dataRsp.getJSONObject("cover");
                coverUrl = coverObj.getString("url");
                if (enableHttps) {
                    coverUrl = coverUrl.replace("http", "https");
                }
            }
            JSONObject videoObj = dataRsp.getJSONObject("video");
            String playUrl = videoObj.getString("url");
            if (enableHttps) {
                playUrl = playUrl.replace("http", "https");
            }
            videoFileId = dataRsp.getString("fileId");
            notifyUploadSuccess(videoFileId, playUrl, coverUrl);

            txReport(TVCConstants.UPLOAD_EVENT_ID_UPLOAD_RESULT, 0, "", reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName(), videoFileId);

            Log.d(TAG, "playUrl:" + playUrl);
            Log.d(TAG, "coverUrl: " + coverUrl);
            Log.d(TAG, "videoFileId: " + videoFileId);
        } catch (JSONException e) {
            notifyUploadFailed(TVCConstants.ERR_UGC_FINISH_RESPONSE_FAILED, e.toString());

            txReport(TVCConstants.UPLOAD_EVENT_ID_UPLOAD_RESULT, TVCConstants.ERR_UGC_FINISH_RESPONSE_FAILED, e.toString(), reqTime, System.currentTimeMillis() - reqTime, uploadInfo.getFileSize(), uploadInfo.getFileType(), uploadInfo.getFileName());
        }
    }

    void txReport(int reqType, int errCode, String errMsg, long reqTime, long reqTimeCost, long fileSize, String fileType, String fileName) {
        txReport(reqType, errCode, errMsg, reqTime, reqTimeCost, fileSize, fileType, fileName, "");
    }

    /**
     * 数据上报
     * @param reqType：请求类型，标识是在那个步骤
     * @param errCode：错误码
     * @param errMsg：错误详细信息，COS的错误把requestId拼在错误信息里带回
     * @param reqTime：请求时间
     * @param reqTimeCost：耗时，单位ms
     * @param fileSize :文件大小
     * @param fileType :文件类型
     * @param fileId :上传完成后点播返回的fileid
     */
    void txReport(int reqType, int errCode, String errMsg, long reqTime, long reqTimeCost, long fileSize, String fileType, String fileName, String fileId) {
        reportInfo.reqType = reqType;
        reportInfo.errCode = errCode;
        reportInfo.errMsg = errMsg;
        reportInfo.reqTime = reqTime;
        reportInfo.reqTimeCost = reqTimeCost;
        reportInfo.fileSize = fileSize;
        reportInfo.fileType = fileType;
        reportInfo.fileName = fileName;
        reportInfo.fileId = fileId;
        reportInfo.appId = userAppId;
        if (reqType == 20001) {
            reportInfo.reqServerIp = cosIP;
        } else {
            reportInfo.reqServerIp = ugcClient.getServerIP();
        }
        reportInfo.reportId = customKey;
        reportInfo.reqKey = String.valueOf(uploadInfo.getFileLastModifyTime()) + ";" + String.valueOf(initReqTime);
        reportInfo.vodSessionKey = vodSessionKey;
        UGCReport.getInstance(context).addReportInfo(reportInfo);
    }

    // 断点续传
    // 本地保存 filePath --> <session, uploadId, expireTime> 的映射集合，格式为json
    // session的过期时间是1天
    private void getResumeData(String filePath) {
        vodSessionKey = null;
        uploadId = null;
        fileLastModTime = 0;
        if (TextUtils.isEmpty(filePath) || enableResume == false) {
            return;
        }

        if (mSharedPreferences != null && mSharedPreferences.contains(filePath)) {
            try {
                JSONObject json = new JSONObject(mSharedPreferences.getString(filePath, ""));
                long expiredTime = json.optLong("expiredTime", 0);
                if (expiredTime > System.currentTimeMillis() / 1000) {
                    vodSessionKey = json.optString("session", "");
                    uploadId = json.optString("uploadId", "");
                    fileLastModTime = json.optLong("fileLastModTime", 0);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return;
    }

    private void setResumeData(String filePath, String vodSessionKey, String uploadId) {
        if (filePath == null || filePath.isEmpty()) {
            return;
        }
        if (mSharedPreferences != null) {
            try {
                // vodSessionKey、uploadId为空就表示删掉该记录
                String itemPath = filePath;
                if ( TextUtils.isEmpty(vodSessionKey) || TextUtils.isEmpty(uploadId)) {
                    mShareEditor.remove(itemPath);
                    mShareEditor.commit();
                } else {
                    String comment = "";
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("session", vodSessionKey);
                    jsonObject.put("uploadId", uploadId);
                    jsonObject.put("expiredTime", System.currentTimeMillis() / 1000 + 24 * 60 * 60);
                    jsonObject.put("fileLastModTime", uploadInfo.getFileLastModifyTime());
                    comment = jsonObject.toString();
                    mShareEditor.putString(itemPath, comment);
                    mShareEditor.commit();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // 视频是否走断点续传
    public boolean isResumeUploadVideo() {
        if (enableResume
                && !TextUtils.isEmpty(uploadId)
                && uploadInfo != null && fileLastModTime != 0 && fileLastModTime == uploadInfo.getFileLastModifyTime()) {
            return true;
        }
        return false;
    }

    public void updateSignature(String signature) {
        if (ugcClient != null) {
            ugcClient.updateSignature(signature);
        }
    }

    public Intent getStatusInfo() {
        Intent intent = new Intent();
        intent.putExtra("reqType",String.valueOf(reportInfo.reqType));
        intent.putExtra("errCode",String.valueOf(reportInfo.errCode));
        intent.putExtra("errMsg",reportInfo.errMsg);
        intent.putExtra("reqTime",String.valueOf(reportInfo.reqTime));
        intent.putExtra("reqTimeCost",String.valueOf(reportInfo.reqTimeCost));
        intent.putExtra("fileSize",String.valueOf(reportInfo.fileSize));
        intent.putExtra("fileType",reportInfo.fileType);
        intent.putExtra("fileName",reportInfo.fileName);
        intent.putExtra("fileId",reportInfo.fileId);
        intent.putExtra("appId",String.valueOf(reportInfo.appId));
        intent.putExtra("reqServerIp",reportInfo.reqServerIp);
        intent.putExtra("reportId",reportInfo.reportId);
        intent.putExtra("reqKey",reportInfo.reqKey);
        intent.putExtra("vodSessionKey",reportInfo.vodSessionKey);

        return intent;
    }

}
