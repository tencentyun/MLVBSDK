package com.tencent.qcloud.xiaozhibo.common.widget.beauty.download;

import android.content.Context;
import android.text.TextUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Module:   DownloadRunnable
 *
 * Function: 下载任务的Runnable
 *
 */
public class DownloadRunnable implements Runnable {
    private static final int TIMEOUT = 30000; // 连接超时时间 30s
    private String mUrl;
    private String mFolder;
    private String mFilename;
    private DownloadListener mListener;
    private long mContentLength;
    private long mDownloadingSize;
    private boolean mNeedProgress;
    private Context mContext;

    public DownloadRunnable(Context context, String url, String folder, String filename, DownloadListener listener, boolean needProgress) {
        mContext = context.getApplicationContext();
        mUrl = url;
        mFolder = folder;
        mFilename = filename;
        mListener = listener;
        mNeedProgress = needProgress;
    }

    @Override
    public void run() {
        if (!VideoDeviceUtils.isNetworkAvailable(mContext) ||
                TextUtils.isEmpty(mUrl) || TextUtils.isEmpty(mFolder) || TextUtils.isEmpty(mFilename) || !mUrl.startsWith("http")) {
            fail(null, 0);
            return;
        }
        File dstFolder = new File(mFolder);
        if (!dstFolder.exists()) {
            dstFolder.mkdirs();
        } else {
            if (dstFolder.isFile()) {
                if (mListener != null) {
                    mListener.onSaveFailed(dstFolder, null);
                    return;
                }
            }
        }
        File dstFile = new File(mFolder + File.separator + mFilename);
        HttpURLConnection client = null;
        InputStream responseIs = null;
        FileOutputStream fos = null;
        int statusCode = -1;
        boolean success = false;
        Exception failException = null;

        try {
            if (dstFile.exists()) {
                dstFile.delete();
            }
            dstFile.createNewFile();
            client = (HttpURLConnection) new URL(mUrl).openConnection();

            // 设置网络超时参数
            client.setConnectTimeout(TIMEOUT);
            client.setReadTimeout(TIMEOUT);
            client.setDoInput(true);
            client.setRequestMethod("GET");

            statusCode = client.getResponseCode();
            success = client.getResponseCode() == HttpURLConnection.HTTP_OK;

            if (success) {
                if (mNeedProgress) {
                    mContentLength = client.getContentLength();
                    if (!VideoDeviceUtils.isExternalStorageSpaceEnough(mContentLength)) {
                        if (mListener != null) {
                            mListener.onSaveFailed(dstFile, null);
                        }
                        return;
                    }
                }
                responseIs = client.getInputStream();
                int length = -1;
                byte[] buffer = new byte[8192];
                fos = new FileOutputStream(dstFile);
                mDownloadingSize = 0;
                while ((length = responseIs.read(buffer)) != -1) {
                    fos.write(buffer, 0, length);
                    if (mNeedProgress) {
                        int pre = (int) (mDownloadingSize * 100 / mContentLength);
                        mDownloadingSize += length;
                        int now = (int) (mDownloadingSize * 100 / mContentLength);
                        if (pre != now && mListener != null) {
                            mListener.onProgressUpdate(now);
                        }
                    }
                }
                fos.flush();
                if (mListener != null) {
                    mListener.onProgressUpdate(100);
                    mListener.onSaveSuccess(dstFile);
                }
            } else {
                failException = new Exception("http status got exception. code = " + statusCode);
            }
        } catch (Exception e) {
            failException = e;
        } finally {
            try {
                if (fos != null) {
                    fos.close();
                }
                if (responseIs != null) {
                    responseIs.close();
                }
                if (client != null) {
                    client.disconnect();
                }
                mListener.onProcessEnd();
            } catch (IOException e) {

            }
        }

        if (!success || null != failException) {
            mListener.onSaveFailed(dstFile, null);
        }
    }

    private void fail(Exception e, int statusCode) {
        if (mListener != null) {
            mListener.onSaveFailed(null, e);
        }
        mListener = null;
    }
}
