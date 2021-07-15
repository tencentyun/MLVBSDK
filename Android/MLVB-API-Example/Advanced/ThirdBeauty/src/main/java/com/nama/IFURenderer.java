package com.nama;

import android.hardware.Camera;

import com.faceunity.wrapper.faceunity;

/**
 * 渲染和事件接口
 *
 * @author Richie on 2020.07.08
 */
public interface IFURenderer {
    /**
     * 输入的 texture 类型，OES 或 2D
     */
    int INPUT_TEXTURE_EXTERNAL_OES = faceunity.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE;
    int INPUT_TEXTURE_2D = 0;

    /**
     * 输入的 buffer 格式，NV21、I420 或 RGBA
     */
    int INPUT_FORMAT_NV21_BUFFER = faceunity.FU_FORMAT_NV21_BUFFER;
    int INPUT_FORMAT_I420_BUFFER = faceunity.FU_FORMAT_I420_BUFFER;
    int INPUT_FORMAT_RGBA_BUFFER = faceunity.FU_FORMAT_RGBA_BUFFER;

    /**
     * 算法检测类型，人脸、人体或手势
     */
    int TRACK_TYPE_FACE = faceunity.FUAITYPE_FACEPROCESSOR;
    int TRACK_TYPE_HUMAN = faceunity.FUAITYPE_HUMAN_PROCESSOR;
    int TRACK_TYPE_GESTURE = faceunity.FUAITYPE_HANDGESTURE;

    /**
     * 人脸检测模式，图像或视频
     */
    int FACE_PROCESSOR_DETECT_MODE_IMAGE = 0;
    int FACE_PROCESSOR_DETECT_MODE_VIDEO = 1;

    /**
     * 相机朝向，前置或后置
     */
    int CAMERA_FACING_FRONT = Camera.CameraInfo.CAMERA_FACING_FRONT;
    int CAMERA_FACING_BACK = Camera.CameraInfo.CAMERA_FACING_BACK;

    /**
     * 初始化 SDK，必须在具有 GL 环境的线程调用。
     * 如果没有 GL 环境，请使用 fuCreateEGLContext 创建 EGL Context。
     */
    void onSurfaceCreated();

    /**
     * 销毁 SDK，必须在具有 GL 环境的线程调用。
     * 如果已经调用 fuCreateEGLContext，请使用 fuReleaseEGLContext 释放 EGL Context。
     */
    void onSurfaceDestroyed();

    /**
     * 双输入接口，输入 buffer 和 texture，必须在具有 GL 环境的线程调用
     * 由于省去数据拷贝，性能相对最优，优先推荐使用。
     * 缺点是无法保证 buffer 和纹理对齐，可能出现点位和效果对不上的情况。
     *
     * @param img NV21 buffer
     * @param tex 纹理 ID
     * @param w   宽
     * @param h   高
     * @return
     */
    int onDrawFrameDualInput(byte[] img, int tex, int w, int h);

    /**
     * 双输入接口，输入 buffer 和 texture，支持数据回写到 buffer，必须在具有 GL 环境的线程调用
     *
     * @param img         NV21 buffer
     * @param tex         纹理 ID
     * @param w           宽
     * @param h           高
     * @param readBackImg 数据回写到的 buffer
     * @param readBackW   回写的宽
     * @param readBackH   回写的高
     * @return
     */
    int onDrawFrameDualInput(byte[] img, int tex, int w, int h, byte[] readBackImg, int readBackW, int readBackH);

    /**
     * 单 buffer 输入接口，必须在具有 GL 环境的线程调用
     *
     * @param img    图像 buffer
     * @param w      宽
     * @param h      高
     * @param format buffer 格式: nv21, i420, rgba
     * @return
     */
    int onDrawFrameSingleInput(byte[] img, int w, int h, int format);

    /**
     * 单 buffer 输入接口，支持数据回写，必须在具有 GL 环境的线程调用
     *
     * @param img         图像 buffer
     * @param w           宽
     * @param h           高
     * @param format      buffer 格式: nv21, i420, rgba
     * @param readBackImg 数据回写到的 buffer，长度要和格式对应。比如 nv21 和 i420 长度是 宽*高*3/2，rgba 长度是 宽*高*4
     * @param readBackW   回写的宽
     * @param readBackH   回写的高
     * @return
     */
    int onDrawFrameSingleInput(byte[] img, int w, int h, int format, byte[] readBackImg, int readBackW, int readBackH);

    /**
     * 单 texture 输入接口，必须在具有 GL 环境的线程调用
     *
     * @param tex 纹理 ID
     * @param w   宽
     * @param h   高
     * @return
     */
    int onDrawFrameSingleInput(int tex, int w, int h);

    /**
     * 相机切换时调用
     *
     * @param cameraFacing        相机 ID
     * @param cameraOrientation 相机方向
     */
    void onCameraChanged(int cameraFacing, int cameraOrientation);

    /**
     * 设备方向变化时调用
     *
     * @param deviceOrientation 设备方向
     */
    void onDeviceOrientationChanged(int deviceOrientation);

    /**
     * 类似 GLSurfaceView 的 queueEvent 机制，把任务抛到 GL 线程执行。
     *
     * @param r
     */
    void queueEvent(Runnable r);
}