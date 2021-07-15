package com.nama.utils;

import android.hardware.Camera;

/**
 * 相机工具类
 *
 * @author Richie on 2020.07.07
 */
public final class CameraUtils {

    private CameraUtils() {
    }

    /**
     * 获取相机方向
     *
     * @param cameraFacing
     * @return
     */
    public static int getCameraOrientation(int cameraFacing) {
        Camera.CameraInfo info = new Camera.CameraInfo();
        int cameraId = -1;
        int numCameras = Camera.getNumberOfCameras();
        for (int i = 0; i < numCameras; i++) {
            Camera.getCameraInfo(i, info);
            if (info.facing == cameraFacing) {
                cameraId = i;
                break;
            }
        }
        if (cameraId < 0) {
            // no front camera, regard it as back camera
            return 90;
        } else {
            return info.orientation;
        }
    }

}
