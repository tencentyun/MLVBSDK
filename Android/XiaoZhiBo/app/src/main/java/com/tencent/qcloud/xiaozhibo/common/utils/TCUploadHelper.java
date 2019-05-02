package com.tencent.qcloud.xiaozhibo.common.utils;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
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
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.videoupload.impl.TVCNetworkCredentialProvider;
import com.tencent.qcloud.xiaozhibo.videoupload.impl.TVCConstants;

/**
 * Cos人图片上传类
 */
public class TCUploadHelper {
    private static final String TAG = "TCUploadHelper";

    private final static int MAIN_CALL_BACK = 1;
    private final static int MAIN_PROCESS = 2;
    private final static int UPLOAD_AGAIN = 3;

    private Context mContext;
    private OnUploadListener mListerner;
    private Handler mMainHandler;
    private CosXmlService cosService;

    public TCUploadHelper(final Context context, OnUploadListener listener) {
        mContext = context;
        mListerner = listener;

        mMainHandler = new Handler(Looper.getMainLooper(), new Handler.Callback() {
            @Override
            public boolean handleMessage(Message msg) {
                switch (msg.what) {
                    case MAIN_CALL_BACK:
                        if (mListerner != null) {
                            mListerner.onUploadResult(msg.arg1, (String) msg.obj);
                        }
                        break;
                    case UPLOAD_AGAIN:
                        Bundle taskBundle = (Bundle) msg.obj;
                        uploadCover(taskBundle.getString("path",""));
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
        cosService = new CosXmlService(context, cosXmlServiceConfig,
                new TVCNetworkCredentialProvider(cosInfo.secretID));
    }

    private String createNetUrl() {
        return "/" + TCUserMgr.getInstance().getUserId() + "/" + System.currentTimeMillis();
    }


    public void uploadCover(final String path) {
        Log.d(TAG,"uploadCover do upload path:"+path);
        final String netUrl = createNetUrl();

        final TCUserMgr.CosInfo cosInfo = TCUserMgr.getInstance().getCosInfo();
        PutObjectRequest putObjectRequest = new PutObjectRequest(cosInfo.bucket, netUrl, path);
        putObjectRequest.setProgressListener(new CosXmlProgressListener() {
            @Override
            public void onProgress(long progress, long max) {
            }
        });
        putObjectRequest.setSign(600,null,null);
        cosService.putObjectAsync(putObjectRequest, new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest cosXmlRequest, CosXmlResult cosXmlResult) {
                //修改访问权限为公开
                PutObjectACLRequest putObjectACLRequest = new PutObjectACLRequest(cosInfo.bucket, netUrl);
                putObjectACLRequest.setXCOSACL("public-read");
                putObjectACLRequest.setSign(600,null,null);

                try {
                    cosService.putObjectACL(putObjectACLRequest);
                } catch (CosXmlServiceException e) {
                    e.printStackTrace();
                } catch (CosXmlClientException e) {
                    e.printStackTrace();
                }

                final TCUserMgr.CosInfo cosInfo = TCUserMgr.getInstance().getCosInfo();
                String accessUrl = "http://" + cosXmlRequest.getHost(cosInfo.appID, cosInfo.region) + cosXmlRequest.getPath();
                Log.d(TAG,"uploadCover do upload sucess, url:" + accessUrl);
                Message msg = new Message();
                msg.what = MAIN_CALL_BACK;
                msg.arg1 = 0;
                msg.obj = accessUrl;

                mMainHandler.sendMessage(msg);
            }

            @Override
            public void onFail(CosXmlRequest cosXmlRequest, CosXmlClientException qcloudException, CosXmlServiceException qcloudServiceException) {
                StringBuilder stringBuilder = new StringBuilder();
                if(qcloudException != null){
                    stringBuilder.append(qcloudException.getMessage());
                }else {
                    stringBuilder.append(qcloudServiceException.toString());
                }

                Log.w(TAG, "uploadCover do upload fail, msg:" + stringBuilder.toString());
                Message msg = new Message();
                msg.what = MAIN_CALL_BACK;
                msg.arg1 = TVCConstants.ERR_UPLOAD_COVER_FAILED;
                msg.obj = stringBuilder.toString();

                mMainHandler.sendMessage(msg);
            }
        });
    }

    public interface OnUploadListener {
        public void onUploadResult(int code, String url);
    }
}
