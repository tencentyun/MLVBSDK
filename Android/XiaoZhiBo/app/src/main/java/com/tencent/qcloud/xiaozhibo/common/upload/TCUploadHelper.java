package com.tencent.qcloud.xiaozhibo.common.upload;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlProgressListener;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.model.object.PutObjectACLRequest;
import com.tencent.cos.xml.model.object.PutObjectRequest;
import com.tencent.qcloud.xiaozhibo.TCGlobalConfig;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;

/**
 *  Module:   TCUploadHelper
 *
 *  Function: 上传图片到 Cos 的工具类
 *
 *  直播开播之前，可以设置自己的封面，所以我们需要将图片保存到 cos 存储，提供给观看端查看。
 *
 *  腾讯云对于 COS 存储服务提供了额外的 SDK，他不属于 LiteAVSDK 的组成部分，该工具仅提供一个简单用法；
 *
 *  COS SDK 相关服务的开通可以参考此篇文章：
 *  https://cloud.tencent.com/document/product/454/15187#2.-.E5.BC.80.E9.80.9A.E5.AF.B9.E8.B1.A1.E5.AD.98.E5.82.A8.E6.9C.8D.E5.8A.A1
 *
 **/
public class TCUploadHelper {
    private static final String TAG = "TCUploadHelper";

    private final static int MESSAGE_CODE_RESULT = 1;
    public final static int UPLOAD_RESULT_SUCCESS = 0;
    public final static int UPLOAD_RESULT_FAIL = -1;

    private OnUploadListener mCallbackListener;
    private Handler mMainHandler;
    private CosXmlService mCosService;

    public TCUploadHelper(final Context context, OnUploadListener listener) {
        mCallbackListener = listener;

        mMainHandler = new Handler(Looper.getMainLooper(), new Handler.Callback() {
            @Override
            public boolean handleMessage(Message msg) {
                switch (msg.what) {
                    case MESSAGE_CODE_RESULT:
                        if (mCallbackListener != null) {
                        }
                        break;
                    default:
                        break;
                }
                return false;
            }
        });

        final TCUserMgr.CosInfo cosInfo = TCUserMgr.getInstance().getCosInfo();
        CosXmlServiceConfig cosXmlServiceConfig = new CosXmlServiceConfig.Builder()
                .setAppidAndRegion(cosInfo.appID, cosInfo.region)
                .setDebuggable(true)
                .builder();
        mCosService = new CosXmlService(context, cosXmlServiceConfig,
                new TCCOSNetworkCredentialProvider(cosInfo.secretID));
    }

    private String createNetUrl() {
        return "/" + TCUserMgr.getInstance().getUserId() + "/" + System.currentTimeMillis();
    }


    public void uploadPic(final String path) {
        Log.d(TAG,"uploadPic do upload path:"+path);

        if (TextUtils.isEmpty(TCGlobalConfig.APP_SVR_URL)) {
            mMainHandler.post(new Runnable() {
                @Override
                public void run() {
                    if (mCallbackListener != null) {
                        mCallbackListener.onUploadResult(UPLOAD_RESULT_FAIL, "没有填写后台地址，此功能暂不支持.");
                    }
                }
            });
            return;
        }

        final String netUrl = createNetUrl();

        final TCUserMgr.CosInfo cosInfo = TCUserMgr.getInstance().getCosInfo();
        PutObjectRequest putObjectRequest = new PutObjectRequest(cosInfo.bucket, netUrl, path);
        putObjectRequest.setProgressListener(new CosXmlProgressListener() {
            @Override
            public void onProgress(long progress, long max) {
            }
        });
        putObjectRequest.setSign(600,null,null);
        mCosService.putObjectAsync(putObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult cosXmlResult) {
                //修改访问权限为公开
                PutObjectACLRequest putObjectACLRequest = new PutObjectACLRequest(cosInfo.bucket, netUrl);
                putObjectACLRequest.setXCOSACL("public-read");
                putObjectACLRequest.setSign(600,null,null);

                try {
                    mCosService.putObjectACL(putObjectACLRequest);
                } catch (CosXmlServiceException e) {
                    e.printStackTrace();
                } catch (CosXmlClientException e) {
                    e.printStackTrace();
                }

                final TCUserMgr.CosInfo cosInfo = TCUserMgr.getInstance().getCosInfo();
                final String accessUrl = "http://" + cosXmlRequest.getHost(cosInfo.appID, cosInfo.region) + cosXmlRequest.getPath();
                Log.d(TAG,"uploadPic do upload sucess, url:" + accessUrl);
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (mCallbackListener != null) {
                            mCallbackListener.onUploadResult(UPLOAD_RESULT_SUCCESS, accessUrl);
                        }
                    }
                });
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest, CosXmlClientException qcloudException, CosXmlServiceException qcloudServiceException) {
                final StringBuilder stringBuilder = new StringBuilder();
                if(qcloudException != null){
                    stringBuilder.append(qcloudException.getMessage());
                }else {
                    stringBuilder.append(qcloudServiceException.toString());
                }

                Log.e(TAG, "uploadPic do upload fail, msg:" + stringBuilder.toString());
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (mCallbackListener != null) {
                            mCallbackListener.onUploadResult(UPLOAD_RESULT_FAIL, stringBuilder.toString());
                        }
                    }
                });
            }
        });
    }

    public interface OnUploadListener {
        void onUploadResult(int code, String url);
    }
}
