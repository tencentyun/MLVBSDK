package com.tencent.liteav.demo.livepusher.cameralivepush;

import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.support.v4.content.FileProvider;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class FileUtils {

    /**
     * 拷贝assets目录下的 指定文件夹 下的所有文件夹及文件到指定文件夹
     *
     * @param context
     * @param assetsPath assets下指定文件夹
     * @param savePath   目标指定文件夹
     */
    public static void copyFilesFromAssets(Context context, String assetsPath, String savePath) {
        InputStream is = null;
        FileOutputStream fos = null;
        try {
            File file = new File(savePath);
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            String fileNames[] = context.getAssets().list(assetsPath);// 获取assets目录下的所有文件及目录名
            if (fileNames.length > 0) {// 如果是目录
                file.mkdirs();// 如果文件夹不存在，则递归
                for (String fileName : fileNames) {
                    copyFilesFromAssets(context, assetsPath + "/" + fileName,
                            savePath + "/" + fileName);
                }
            } else {// 如果是文件
                is = context.getAssets().open(assetsPath);
                fos = new FileOutputStream(new File(savePath));
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                while ((byteCount = is.read(buffer)) != -1) {// 循环从输入流读取
                    // buffer字节
                    fos.write(buffer, 0, byteCount);// 将读取的输入流写入到输出流
                }
                fos.flush();// 刷新缓冲区
                is.close();
                fos.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
                if (fos != null) {
                    fos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static Uri getUri(Context context, String authority, File file) {
        Uri uri;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            //设置7.0以上共享文件，分享路径定义在xml/file_paths.xml
            uri = FileProvider.getUriForFile(context, authority, file);
        } else {
            // 7.0以下,共享文件
            uri = Uri.fromFile(file);
        }
        return uri;
    }
}
