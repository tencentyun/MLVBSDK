package com.tencent.qcloud.xiaozhibo.common.widget.beauty.download;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.text.TextUtils;

import java.io.File;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * Module:   DownloadTask
 *
 * Function: 文件下载任务
 *
 */
public class DownloadTask {
    public static final String DOWNLOAD_FILE_POSTFIX = ".olm";
    public static final String ONLINE_MATERIAL_FOLDER = "olm";
    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
    private static final int CORE_POOL_SIZE = CPU_COUNT + 1;
    private boolean mProcessing;

    private String mUrl;
    private Downloadlistener mListener;
    private DownloadThreadPool sDownloadThreadPool;
    private String mMaterialId;

    public DownloadTask(String materialId, String url){
        this.mMaterialId = materialId;
        this.mUrl = url;
        mProcessing = false;
    }
    public void start(Context context, Downloadlistener listener) {
        if(listener == null || TextUtils.isEmpty(mUrl) || mProcessing){
            return;
        }
        this.mListener = listener;
        mProcessing = true;
        mListener.onDownloadProgress(0);
        DownloadListener fileListener = new DownloadListener() {
            @Override
            public void onSaveSuccess(File file) {

                //删除该素材目录下的旧文件
                File path = new File(file.toString().substring(0, file.toString().indexOf(DOWNLOAD_FILE_POSTFIX)));
                if (path.exists() && path.isDirectory()) {
                    File[] oldFiles = path.listFiles();
                    if (oldFiles != null) {
                        for (File f : oldFiles) {
                            f.delete();
                        }
                    }
                }

                String dataDir = VideoFileUtils.unZip(file.getPath(), file.getParentFile().getPath());
                if (TextUtils.isEmpty(dataDir)) {
                    mListener.onDownloadFail("素材解压失败");
                    stop();
                    return;
                }
                file.delete();
                mListener.onDownloadSuccess(dataDir);
                stop();
            }

            @Override
            public void onSaveFailed(File file, Exception e) {
                mListener.onDownloadFail("下载失败");
                stop();
            }

            @Override
            public void onProgressUpdate(int progress) {
                mListener.onDownloadProgress(progress);
            }

            @Override
            public void onProcessEnd() {
                mProcessing = false;
            }

        };
        File onlineMaterialDir = VideoDeviceUtils.getExternalFilesDir(context, ONLINE_MATERIAL_FOLDER);
        if (onlineMaterialDir == null || onlineMaterialDir.getName().startsWith("null")) {
            mListener.onDownloadFail("存储空间不足");
            stop();
            return;
        }
        if (!onlineMaterialDir.exists()) {
            onlineMaterialDir.mkdirs();
        }

        ThreadPoolExecutor threadPool = getThreadExecutor();
        threadPool.execute(new DownloadRunnable(context, mUrl, onlineMaterialDir.getPath(), mMaterialId + DOWNLOAD_FILE_POSTFIX, fileListener, true));
    }

    public void stop() {
        mListener = null;
    }

    public synchronized ThreadPoolExecutor getThreadExecutor() {
        if (sDownloadThreadPool == null || sDownloadThreadPool.isShutdown()) {
            sDownloadThreadPool = new DownloadThreadPool(CORE_POOL_SIZE);
        }
        return sDownloadThreadPool;
    }

    public static class DownloadThreadPool extends ThreadPoolExecutor {

        @TargetApi(Build.VERSION_CODES.GINGERBREAD)
        public DownloadThreadPool(int poolSize) {
            super(poolSize, poolSize, 0L, TimeUnit.MILLISECONDS,
                    new LinkedBlockingDeque<Runnable>(),
//                    Utils.hasGingerbread() ? new LinkedBlockingDeque<Runnable>() : new LinkedBlockingQueue<Runnable>(),
                    Executors.defaultThreadFactory(), new ThreadPoolExecutor.DiscardOldestPolicy());
        }
    }

    public interface Downloadlistener{
        void onDownloadFail(String errorMsg);
        void onDownloadProgress(final int progress);
        void onDownloadSuccess(String filePath);
    }
}
