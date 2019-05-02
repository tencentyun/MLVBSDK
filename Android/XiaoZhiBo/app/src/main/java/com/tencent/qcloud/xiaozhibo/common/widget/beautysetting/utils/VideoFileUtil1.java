package com.tencent.qcloud.xiaozhibo.common.widget.beautysetting.utils;


import android.content.Context;
import android.content.res.AssetManager;
import android.text.TextUtils;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class VideoFileUtil1 {
    private static final String TAG = VideoFileUtil1.class.getSimpleName();
    private static final String PIC_POSTFIX_JPEG = ".jpg";
    private static final String PIC_POSTFIX_PNG = ".png";
    private static final String PIC_POSTFIX_WEBP = ".webp";

    public VideoFileUtil1() {
    }

    public static boolean exists(String path) {
        return TextUtils.isEmpty(path)?false:path.contains("assets") || (new File(path)).exists();
    }

    public static String load(File file) {
        FileInputStream stream = null;

        try {
            stream = new FileInputStream(file);
            byte[] e = new byte[(int)file.length()];
            stream.read(e);
            String var3 = new String(e, "UTF-8");
            return var3;
        } catch (FileNotFoundException var8) {
            ;
        } catch (Exception var9) {
            Log.e(TAG, var9.toString());
        } finally {
            IOUtils.closeQuietly(stream);
        }

        return null;
    }

//    public static String load(String dirPath, String filename) {
//        return !TextUtils.isEmpty(dirPath) && !TextUtils.isEmpty(filename)?(dirPath.startsWith("assets://")?loadAssetsString(VideoGlobalContext.getContext(), VideoUtil.getRealPath(dirPath) + File.separator + filename):load(new File(dirPath + File.separator + filename))):"";
//    }

    public static String loadAssetsString(Context context, String path) {
        StringBuilder buf = new StringBuilder();

        try {
            InputStream e = context.getAssets().open(path);
            BufferedReader in = new BufferedReader(new InputStreamReader(e, "UTF-8"));

            String line;
            while((line = in.readLine()) != null) {
                buf.append(line);
                buf.append("\n");
            }

            in.close();
        } catch (IOException var9) {
            var9.printStackTrace();
        } finally {
            return buf.toString();
        }
    }

    public static String loadResourceString(String path) {
        StringBuilder buf = new StringBuilder();

        try {
            InputStream e = VideoFileUtil1.class.getResourceAsStream(path);
            BufferedReader in = new BufferedReader(new InputStreamReader(e, "UTF-8"));

            String line;
            while((line = in.readLine()) != null) {
                buf.append(line);
                buf.append("\n");
            }

            in.close();
        } catch (IOException var8) {
            var8.printStackTrace();
        } finally {
            return buf.toString();
        }
    }

    public static String checkAssetsPhoto(Context context, String path) {
        if(TextUtils.isEmpty(path)) {
            return null;
        } else {
            AssetManager assets = context.getAssets();
            InputStream stream = null;

            String jpg;
            try {
                stream = assets.open(path);
                jpg = path;
                return jpg;
            } catch (IOException var68) {
                ;
            } finally {
                IOUtils.closeQuietly(stream);
            }

            String webp;
            if(path.lastIndexOf(".") != -1) {
                jpg = path.substring(0, path.lastIndexOf(46) + 1) + "webp";

                try {
                    stream = assets.open(jpg);
                    webp = jpg;
                    return webp;
                } catch (IOException var66) {
                    ;
                } finally {
                    IOUtils.closeQuietly(stream);
                }

                return null;
            } else {
                jpg = path + ".jpg";

                try {
                    stream = assets.open(jpg);
                    webp = jpg;
                    return webp;
                } catch (IOException var64) {
                    ;
                } finally {
                    IOUtils.closeQuietly(stream);
                }

                webp = path + ".webp";

                String png;
                try {
                    stream = assets.open(webp);
                    png = webp;
                    return png;
                } catch (IOException var62) {
                    ;
                } finally {
                    IOUtils.closeQuietly(stream);
                }

                png = path + ".png";

                try {
                    stream = assets.open(png);
                    String var7 = png;
                    return var7;
                } catch (IOException var60) {
                    ;
                } finally {
                    IOUtils.closeQuietly(stream);
                }

                return null;
            }
        }
    }

    public static String checkPhoto(String path) {
        if(TextUtils.isEmpty(path)) {
            return null;
        } else if((new File(path)).exists()) {
            return path;
        } else {
            int slashIndex = path.lastIndexOf("/");
            String lastStr = path.substring(slashIndex);
            int dotIndex = lastStr.lastIndexOf(".");
            if(dotIndex == -1) {
                String jpeg = path + ".jpg";
                if((new File(jpeg)).exists()) {
                    return jpeg;
                }

                String png = path + ".png";
                if((new File(png)).exists()) {
                    return png;
                }
            }

            return path;
        }
    }


    public static void deleteFiles(String dirPath, final String suffix) {
        if(!TextUtils.isEmpty(dirPath)) {
            File[] files = (new File(dirPath)).listFiles(new FilenameFilter() {
                public boolean accept(File file, String s) {
                    return TextUtils.isEmpty(suffix)?true:s.endsWith(suffix);
                }
            });
            if(files != null) {
                File[] var3 = files;
                int var4 = files.length;

                for(int var5 = 0; var5 < var4; ++var5) {
                    File file = var3[var5];
                    file.delete();
                }
            }

        }
    }
}
