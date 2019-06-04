package com.tencent.qcloud.xiaozhibo.common.widget.beauty.download;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.PointF;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.xiaozhibo.TCApplication;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Module:   VideoFileUtils
 *
 * Function: 文件操作的工具类
 *
 */
public class VideoFileUtils {
    private static final String TAG = VideoFileUtils.class.getSimpleName();
    public static final String THREAD_NAME_MEM = "mMemThread";
    public static final String RES_PREFIX_ASSETS = "assets://";
    public static final String RES_PREFIX_STORAGE = "/";
    public static final String RES_PREFIX_HTTP = "http://";
    public static final String RES_PREFIX_HTTPS = "https://";
    public static final String[] GPU_GL_ONE_THREAD = new String[]{"PowerVR SGX 544MP", "Adreno (TM) 306"};

    public VideoFileUtils() {
    }

    public static boolean hasHoneycomb() {
        return Build.VERSION.SDK_INT >= 11;
    }

    public static boolean hasKitKat() {
        return Build.VERSION.SDK_INT >= 19;
    }

    public static boolean isEmpty(Collection object) {
        return null == object || object.isEmpty();
    }

    private static boolean isEmpty(int[] points) {
        return null == points || points.length == 0;
    }

    private static boolean isEmpty(float[] points) {
        return null == points || points.length == 0;
    }

    public static String getRealPath(String path) {
        return TextUtils.isEmpty(path)?path:(path.startsWith("assets://")?path.substring("assets://".length()):path);
    }

    public static boolean indexOutOfBounds(Collection c, int index) {
        return c == null || index < 0 || index >= c.size();
    }

    public static float getFaceAngle(List<PointF> facePoints) {
        if(isEmpty((Collection)facePoints)) {
            return 0.0F;
        } else {
            PointF p0 = (PointF)facePoints.get(0);
            PointF p18 = (PointF)facePoints.get(18);
            float v1x = p18.x - p0.x;
            float v1y = 0.0F;
            float v2x = p18.x - p0.x;
            float v2y = p18.y - p0.y;
            float productValue = v1x * v2x + v1y * v2y;
            float t1 = (float)Math.sqrt((double)(v1x * v1x + v1y * v1y));
            float t2 = (float)Math.sqrt((double)(v2x * v2x + v2y * v2y));
            float cosValue = productValue / (t1 * t2);
            if(cosValue < -1.0F && cosValue > -2.0F) {
                cosValue = -1.0F;
            } else if(cosValue > 1.0F && cosValue < 2.0F) {
                cosValue = 1.0F;
            }

            float radian = (float)Math.acos((double)cosValue);
            if(p0.y < p18.y) {
                radian = -radian;
            }

            return radian;
        }
    }

    public static boolean hasJellyBeanMR1() {
        return Build.VERSION.SDK_INT >= 17;
    }

    public static List<Integer> arrayToList(int[] points) {
        ArrayList list = new ArrayList();
        if(isEmpty(points)) {
            return list;
        } else {
            int[] var2 = points;
            int var3 = points.length;

            for(int var4 = 0; var4 < var3; ++var4) {
                int point = var2[var4];
                list.add(Integer.valueOf(point));
            }

            return list;
        }
    }

    public static List<Float> arrayToList(float[] points) {
        ArrayList list = new ArrayList();
        if(isEmpty(points)) {
            return list;
        } else {
            float[] var2 = points;
            int var3 = points.length;

            for(int var4 = 0; var4 < var3; ++var4) {
                float point = var2[var4];
                list.add(Float.valueOf(point));
            }

            return list;
        }
    }

    public static synchronized String unZip(String zipFile, String targetDir) {
        if(TextUtils.isEmpty(zipFile)) {
            return null;
        } else {
            File file = new File(zipFile);
            if(!file.exists()) {
                return null;
            } else {
                File targetFolder = new File(targetDir);
                if(!targetFolder.exists()) {
                    targetFolder.mkdirs();
                }

                String dataDir = null;
                short BUFFER = 4096;
                FileInputStream fis = null;
                ZipInputStream zis = null;
                FileOutputStream fos = null;
                BufferedOutputStream dest = null;

                try {
                    fis = new FileInputStream(file);
                    zis = new ZipInputStream(new BufferedInputStream(fis));

                    while(true) {
                        while(true) {
                            String strEntry;
                            ZipEntry entry;
                            do {
                                if((entry = zis.getNextEntry()) == null) {
                                    return dataDir;
                                }

                                strEntry = entry.getName();
                            } while(strEntry.contains("../"));

                            if(entry.isDirectory()) {
                                String count1 = targetDir + File.separator + strEntry;
                                File data1 = new File(count1);
                                if(!data1.exists()) {
                                    data1.mkdirs();
                                }

                                if(TextUtils.isEmpty(dataDir)) {
                                    dataDir = data1.getPath();
                                }
                            } else {
                                byte[] data = new byte[BUFFER];
                                String targetFileDir = targetDir + File.separator + strEntry;
                                File targetFile = new File(targetFileDir);

                                try {
                                    fos = new FileOutputStream(targetFile);
                                    dest = new BufferedOutputStream(fos, BUFFER);

                                    int count;
                                    while((count = zis.read(data)) != -1) {
                                        dest.write(data, 0, count);
                                    }

                                    dest.flush();
                                } catch (IOException var41) {
                                    ;
                                } finally {
                                    try {
                                        if(dest != null) {
                                            dest.close();
                                        }

                                        if(fos != null) {
                                            fos.close();
                                        }
                                    } catch (IOException var40) {
                                        ;
                                    }

                                }
                            }
                        }
                    }
                } catch (IOException var43) {
                    ;
                } finally {
                    try {
                        if(zis != null) {
                            zis.close();
                        }

                        if(fis != null) {
                            fis.close();
                        }
                    } catch (IOException var39) {
                        ;
                    }

                }

                return dataDir;
            }
        }
    }

    public static boolean hasJellyBeanMR2() {
        return Build.VERSION.SDK_INT >= 18;
    }

    public static void copyAssets(Context context, String assetFilePath, String destFilePath) {
        AssetManager assetManager = context.getAssets();

        try {
            InputStream in = assetManager.open(assetFilePath);
            File e = new File(destFilePath);
            FileOutputStream out = new FileOutputStream(e);
            copyFile(in, out);
            in.close();
            out.flush();
            out.close();
        } catch (IOException var7) {
            Log.e("Utils", "Failed to copy asset file: " + assetFilePath + " into " + destFilePath);
        }

    }

    private static void copyFile(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[16384];

        int read;
        while((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }

    }

    public static boolean isInOneGLThreadBlackList() {
        String[] gpuInfo = VideoDeviceUtils.getGPUInfo().split(";");
        if(gpuInfo.length > 0 && !TextUtils.isEmpty(gpuInfo[0])) {
            String gpu = gpuInfo[0].trim().toLowerCase();
            String[] var2 = GPU_GL_ONE_THREAD;
            int var3 = var2.length;

            for(int var4 = 0; var4 < var3; ++var4) {
                String blackgpu = var2[var4];
                if(gpu.equals(blackgpu.toLowerCase())) {
                    return true;
                }
            }
        }

        return false;
    }
}
