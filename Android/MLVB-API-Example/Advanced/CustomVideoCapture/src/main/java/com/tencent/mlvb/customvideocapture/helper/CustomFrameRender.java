package com.tencent.mlvb.customvideocapture.helper;

import android.annotation.SuppressLint;
import android.graphics.SurfaceTexture;
import android.media.AudioTrack;
import android.opengl.GLES20;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.util.Pair;
import android.view.Surface;
import android.view.TextureView;
import android.widget.ImageView.ScaleType;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.mlvb.customvideocapture.helper.basic.Size;
import com.tencent.mlvb.customvideocapture.helper.render.EglCore;
import com.tencent.mlvb.customvideocapture.helper.render.opengl.GPUImageFilter;
import com.tencent.mlvb.customvideocapture.helper.render.opengl.GpuImageI420Filter;
import com.tencent.mlvb.customvideocapture.helper.render.opengl.OpenGlUtils;
import com.tencent.mlvb.customvideocapture.helper.render.opengl.Rotation;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.concurrent.CountDownLatch;

/**
 * 本地媒体文件直播分享的自定义渲染辅助类，可以帮助开发者快速实现TRTC 自定义渲染的相关功能
 * 主要包含：
 * - 本地预览视频帧/远端用户视频帧的自定义渲染；
 * - 本地音频/远端音频混音后的播放；
 *
 */
public class CustomFrameRender extends V2TXLivePusherObserver implements Handler.Callback {
    public static final String TAG = "CustomFrameRender";

    private static final int MSG_RENDER              = 2;
    private static final int MSG_DESTROY             = 3;
    private static final int RENDER_TYPE_TEXTURE     = 0;
    private static final int RENDER_TYPE_I420        = 1;

    private       int                mRenderType     = RENDER_TYPE_TEXTURE;
    private       Size               mSurfaceSize    = new Size();
    private       Size               mLastInputSize  = new Size();
    private       Size               mLastOutputSize = new Size();
    private final HandlerThread      mGLThread;
    private final GLHandler          mGLHandler;
    private final FloatBuffer        mGLCubeBuffer;
    private final FloatBuffer        mGLTextureBuffer;
    private       EglCore            mEglCore;
    private       SurfaceTexture     mSurfaceTexture;
    private       TextureView        mRenderView;
    private       GPUImageFilter     mNormalFilter;
    private       GpuImageI420Filter mYUVFilter;
    private       AudioTrack         mAudioTrack;

    @Override
    public void onCaptureFirstVideoFrame() {
        Log.d(TAG, "onCaptureFirstVideoFrame");
    }

    @Override
    public int onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame srcFrame, V2TXLiveDef.V2TXLiveVideoFrame dstFrame) {

        if (srcFrame.texture != null) {
            GLES20.glFinish();
        }
        dstFrame.pixelFormat = srcFrame.pixelFormat;
        dstFrame.bufferType = srcFrame.bufferType;
        dstFrame.texture = srcFrame.texture;
        dstFrame.data = srcFrame.data;
        dstFrame.buffer = srcFrame.buffer;
        dstFrame.width = srcFrame.width;
        dstFrame.height = srcFrame.height;
        dstFrame.rotation = srcFrame.rotation;

        mGLHandler.obtainMessage(MSG_RENDER, srcFrame).sendToTarget();
        return 0;
    }

    public CustomFrameRender() {
        mGLCubeBuffer = ByteBuffer.allocateDirect(OpenGlUtils.CUBE.length * 4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLCubeBuffer.put(OpenGlUtils.CUBE).position(0);

        mGLTextureBuffer = ByteBuffer.allocateDirect(OpenGlUtils.TEXTURE.length * 4)
                .order(ByteOrder.nativeOrder()).asFloatBuffer();
        mGLTextureBuffer.put(OpenGlUtils.TEXTURE).position(0);

        mGLThread = new HandlerThread(TAG);
        mGLThread.start();
        mGLHandler = new GLHandler(mGLThread.getLooper(), this);
        Log.i(TAG, "TestRenderVideoFrame");
    }

    public void start(TextureView videoView) {
        if (videoView == null) {
            Log.w(TAG, "start error when render view is null");
            return;
        }
        Log.i(TAG, "start render");

        // 设置TextureView的SurfaceTexture生命周期回调，用于管理GLThread的创建和销毁
        mRenderView = videoView;
        mSurfaceTexture = mRenderView.getSurfaceTexture();

        mRenderView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                // 保存surfaceTexture，用于创建OpenGL线程
                mSurfaceTexture = surface;
                mSurfaceSize = new Size(width, height);
                Log.i(TAG, String.format("onSurfaceTextureAvailable width: %d, height: %d", width, height));
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
                mSurfaceSize = new Size(width, height);
                Log.i(TAG, String.format("onSurfaceTextureSizeChanged width: %d, height: %d", width, height));
            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                // surface释放了，需要停止渲染
                mSurfaceTexture = null;
                // 等待Runnable执行完，再返回，否则GL线程会使用一个无效的SurfaceTexture
                mGLHandler.runAndWaitDone(new Runnable() {
                    @Override
                    public void run() {
                        uninitGlComponent();
                    }
                });
                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            }
        });
    }

    public void stop() {
        if (mRenderView != null) {
            mRenderView.setSurfaceTextureListener(null);
        }
        if (mAudioTrack != null) {
            mAudioTrack.stop();
            mAudioTrack.release();
            mAudioTrack = null;
        }
        mGLHandler.obtainMessage(MSG_DESTROY).sendToTarget();
    }

    @SuppressLint("NewApi")
    private void initGlComponent(Object eglContext) {
        if (mSurfaceTexture == null) {
            return;
        }

        try {
            if (eglContext instanceof javax.microedition.khronos.egl.EGLContext) {
                mEglCore = new EglCore((javax.microedition.khronos.egl.EGLContext) eglContext, new Surface(mSurfaceTexture));
            } else {
                mEglCore = new EglCore((android.opengl.EGLContext) eglContext, new Surface(mSurfaceTexture));
            }
        } catch (Exception e) {
            Log.e(TAG, "create EglCore failed.", e);
            return;
        }

        mEglCore.makeCurrent();
        if (mRenderType == RENDER_TYPE_TEXTURE) {
            mNormalFilter = new GPUImageFilter();
            mNormalFilter.init();
        } else if (mRenderType == RENDER_TYPE_I420) {
            mYUVFilter = new GpuImageI420Filter();
            mYUVFilter.init();
        }
    }

    private void renderInternal(V2TXLiveDef.V2TXLiveVideoFrame frame) {
        mRenderType = RENDER_TYPE_I420;
        if (frame.bufferType == V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeTexture) {
            mRenderType = RENDER_TYPE_TEXTURE;
        } else if (frame.pixelFormat == V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatI420
                && frame.bufferType == V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeByteArray) {
            mRenderType = RENDER_TYPE_I420;
        } else {
            Log.w(TAG, "error video frame type");
            return;
        }

        if (mEglCore == null && mSurfaceTexture != null) {
            Object eglContext = null;
            if (frame.texture != null) {
                eglContext = frame.texture.eglContext10 != null ? frame.texture.eglContext10 : frame.texture.eglContext14;
            }
            initGlComponent(eglContext);
        }

        if (mEglCore == null) {
            return;
        }

        if (mLastInputSize.width != frame.width || mLastInputSize.height != frame.height
                || mLastOutputSize.width != mSurfaceSize.width || mLastOutputSize.height != mSurfaceSize.height) {
            Pair<float[], float[]> cubeAndTextureBuffer = OpenGlUtils.calcCubeAndTextureBuffer(ScaleType.CENTER,
                    Rotation.ROTATION_180, true, frame.width, frame.height, mSurfaceSize.width, mSurfaceSize.height);
            mGLCubeBuffer.clear();
            mGLCubeBuffer.put(cubeAndTextureBuffer.first);
            mGLTextureBuffer.clear();
            mGLTextureBuffer.put(cubeAndTextureBuffer.second);

            mLastInputSize = new Size(frame.width, frame.height);
            mLastOutputSize = new Size(mSurfaceSize.width, mSurfaceSize.height);
        }

        mEglCore.makeCurrent();
        GLES20.glViewport(0, 0, mSurfaceSize.width, mSurfaceSize.height);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);

        GLES20.glClearColor(0, 0, 0, 1.0f);
        GLES20.glClear(GLES20.GL_DEPTH_BUFFER_BIT | GLES20.GL_COLOR_BUFFER_BIT);
        if (mRenderType == RENDER_TYPE_TEXTURE) {
            mNormalFilter.onDraw(frame.texture.textureId, mGLCubeBuffer, mGLTextureBuffer);
        } else {
            mYUVFilter.loadYuvDataToTexture(frame.data, frame.width, frame.height);
            mYUVFilter.onDraw(OpenGlUtils.NO_TEXTURE, mGLCubeBuffer, mGLTextureBuffer);
        }
        mEglCore.swapBuffer();
    }

    private void uninitGlComponent() {
        if (mNormalFilter != null) {
            mNormalFilter.destroy();
            mNormalFilter = null;
        }
        if (mYUVFilter != null) {
            mYUVFilter.destroy();
            mYUVFilter = null;
        }
        if (mEglCore != null) {
            mEglCore.unmakeCurrent();
            mEglCore.destroy();
            mEglCore = null;
        }
    }

    private void destroyInternal() {
        uninitGlComponent();

        if (Build.VERSION.SDK_INT >= 18) {
            mGLHandler.getLooper().quitSafely();
        } else {
            mGLHandler.getLooper().quit();
        }
    }

    @Override
    public boolean handleMessage(Message msg) {
        switch (msg.what) {
            case MSG_RENDER:
                renderInternal((V2TXLiveDef.V2TXLiveVideoFrame) msg.obj);
                break;
            case MSG_DESTROY:
                destroyInternal();
                break;
        }
        return false;
    }


    public static class GLHandler extends Handler {
        public GLHandler(Looper looper, Callback callback) {
            super(looper, callback);
        }

        public void runAndWaitDone(final Runnable runnable) {
            final CountDownLatch countDownLatch = new CountDownLatch(1);
            post(new Runnable() {
                @Override
                public void run() {
                    runnable.run();
                    countDownLatch.countDown();
                }
            });

            try {
                countDownLatch.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
