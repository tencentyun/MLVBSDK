package com.tencent.mlvb.thirdbeauty;

//import static com.tencent.live2.V2TXLiveDef.V2TXLiveBufferType.V2TXLiveBufferTypeTexture;
//import static com.tencent.live2.V2TXLiveDef.V2TXLivePixelFormat.V2TXLivePixelFormatTexture2D;

import androidx.annotation.Nullable;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.live2.V2TXLiveDef;
import com.tencent.live2.V2TXLivePusher;
//import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.live2.V2TXLivePusherObserver;
import com.tencent.live2.impl.V2TXLivePusherImpl;
import com.tencent.mlvb.common.MLVBBaseActivity;
import com.tencent.mlvb.common.URLUtils;
import com.tencent.rtmp.ui.TXCloudVideoView;
//import com.tencent.xmagic.XmagicApi;
//import com.tencent.xmagic.XmagicConstant;
//import com.tencent.xmagic.XmagicProperty;
//import com.tencent.xmagic.telicense.TELicenseCheck;

import java.util.Random;

/**
 * MLVB 第三方美颜页面
 * <p>
 * 接入步骤：
 * 第一步：集成腾讯特效SDK并拷贝资源（可参考腾讯特效提供的接入文档：https://cloud.tencent.com/document/product/616/65888）
 * 第二步：腾讯特效SDK的鉴权与初始化,详见{@link ThirdBeautyTencentEffectActivity#authXmagic()},License获取请参考 {https://cloud.tencent.com/document/product/616/65878}
 * 第三步：在MLVB中使用腾讯特效美颜，详见{@link ThirdBeautyTencentEffectActivity#startPush()} 中的注释说明
 * - 首先在推流之前调用{@link V2TXLivePusher#enableCustomVideoProcess(boolean,
 * V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)},设置开启自定义渲染
 * - 然后掉用{@link V2TXLivePusher#setObserver(V2TXLivePusherObserver)} 监听SDK的视频数据
 * - 当收到数据时，在{@link V2TXLivePusherObserver#onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame,
 * V2TXLiveDef.V2TXLiveVideoFrame)}中适应第三方的美颜组件去处理。
 * <p>
 * 注意：腾讯特效提供的 License 与 applicationId 一一对应的，测试过程中需要修改 applicationId 为 License对应的applicationId
 *
 * <p>
 * MLVB Third-Party Beauty Filter View
 * <p>
 * <p>
 * Access steps：
 * First step：
 * Integrate Tencent Effect SDK and copy resources（You can refer to the access document provided by Tencent Effects：https://cloud.tencent.com/document/product/616/65888）
 * Second step：Authentication and initialization of Tencent Effect SDK,
 * see details{@link ThirdBeautyTencentEffectActivity#authXmagic()},to obtain the license, please refer to {https://cloud.tencent.com/document/product/616/65878}
 * Third step：Using Tencent Effect in MLVB，see details{@link ThirdBeautyTencentEffectActivity#startPush()}
 * You must call {@link V2TXLivePusher#enableCustomVideoProcess(boolean,
 * V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)}
 * to enable custom video processing before you can receive this callback.
 * - Before stream publishing, call {@link V2TXLivePusher#enableCustomVideoProcess(boolean,
 * V2TXLiveDef.V2TXLivePixelFormat, V2TXLiveDef.V2TXLiveBufferType)} to enable custom rendering.
 * - Call {@link V2TXLivePusher#setObserver(V2TXLivePusherObserver)} to listen for video data from the SDK.
 * - After data is received, use third-party beauty filters to process the data
 * in {@link V2TXLivePusherObserver#onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame,
 * V2TXLiveDef.V2TXLiveVideoFrame)}.
 * <p>
 * Note：The applicationId and License provided by Tencent Effects are in one-to-one correspondence.
 * During the test process, the applicationId needs to be modified to the applicationId corresponding to the License.
 **/
public class ThirdBeautyTencentEffectActivity extends MLVBBaseActivity implements View.OnClickListener {
    private static final String TAG = "ThirdBeautyFaceUnityActivity";

    private TXCloudVideoView mPushRenderView;
    private V2TXLivePusher   mLivePusher;
    private SeekBar          mSeekBlurLevel;
    private TextView         mTextBlurLevel;
    private EditText         mEditStreamId;
    private Button           mButtonPush;
    private TextView         mTextTitle;

//    private XmagicApi mXmagicApi;
//
//    private XmagicProperty<XmagicProperty.XmagicPropertyValues> mProperty;
//
//    private final String XMAGIC_LICENSE_URL = "";
//    private final String XMAGIC_LICENSE_KEY = "";
//    private final String XMAGIC_RES_PATH = "";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_third_beauty_tencent_effect);
        getSupportActionBar().hide();

        if (checkPermission()) {
            initView();
        }
//        authXmagic();
    }

//    private void authXmagic() {
//        TELicenseCheck.getInstance().setTELicense(this,
//                XMAGIC_LICENSE_URL,
//                XMAGIC_LICENSE_KEY,
//                new TELicenseCheck.TELicenseCheckListener() {
//                    @Override
//                    public void onLicenseCheckFinish(int errorCode, String msg) {
//                        //注意：此回调不一定在调用线程
//                        if (errorCode == TELicenseCheck.ERROR_OK) {
//                            initXmagicApi();
//                        }
//                    }
//                });
//    }

//    private void initXmagicApi() {
//        mXmagicApi = new XmagicApi(this, XMAGIC_RES_PATH, new XmagicApi.OnXmagicPropertyErrorListener() {
//            @Override
//            public void onXmagicPropertyError(String s, int i) {
//            }
//        });
//        mProperty = new XmagicProperty<>(XmagicProperty.Category.BEAUTY, null, null,
//                XmagicConstant.BeautyConstant.BEAUTY_SMOOTH,
//                new XmagicProperty.XmagicPropertyValues(0, 100, 50, 0, 1));
//    }

    @Override
    protected void onPermissionGranted() {
        initView();
    }

    private void initView() {
        mPushRenderView = findViewById(R.id.pusher_tx_cloud_view);
        mSeekBlurLevel = findViewById(R.id.sb_blur_level);
        mTextBlurLevel = findViewById(R.id.tv_blur_level);
        mButtonPush = findViewById(R.id.btn_push);
        mEditStreamId = findViewById(R.id.et_stream_id);
        mTextTitle = findViewById(R.id.tv_title);

        mEditStreamId.setText(generateStreamId());
        findViewById(R.id.iv_back).setOnClickListener(this);

        mSeekBlurLevel.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
//                if (mLivePusher != null && mLivePusher.isPushing() == 1
//                        && fromUser && mProperty != null && mXmagicApi != null) {
//                    mProperty.effValue.setCurrentDisplayValue(progress * 10);
//                    mXmagicApi.updateProperty(mProperty);
//                }
                mTextBlurLevel.setText(String.valueOf(progress));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        mButtonPush.setOnClickListener(this);
        if (!TextUtils.isEmpty(mEditStreamId.getText().toString())) {
            mTextTitle.setText(mEditStreamId.getText().toString());
        }
    }

    private void startPush() {
        String streamId = mEditStreamId.getText().toString();
        if (TextUtils.isEmpty(streamId)) {
            Toast.makeText(ThirdBeautyTencentEffectActivity.this, getString(R.string.thirdbeauty_please_input_streamd),
                    Toast.LENGTH_SHORT).show();
            return;
        }
        mTextTitle.setText(streamId);
        mLivePusher = new V2TXLivePusherImpl(this, V2TXLiveDef.V2TXLiveMode.TXLiveMode_RTC);

//        mLivePusher.enableCustomVideoProcess(true, V2TXLivePixelFormatTexture2D, V2TXLiveBufferTypeTexture);
//        mLivePusher.setObserver(new V2TXLivePusherObserver() {
//            @Override
//            public void onGLContextCreated() {
//
//            }
//
//            @Override
//            public int onProcessVideoFrame(V2TXLiveDef.V2TXLiveVideoFrame srcFrame,
//                                           V2TXLiveDef.V2TXLiveVideoFrame dstFrame) {
//                dstFrame.texture.textureId = mXmagicApi.process(srcFrame.texture.textureId,
//                        srcFrame.width, srcFrame.height);
//                return 0;
//            }
//
//            @Override
//            public void onGLContextDestroyed() {
//                mXmagicApi.onDestroy();
//            }
//        });
        mLivePusher.setRenderView(mPushRenderView);
        mLivePusher.startCamera(true);
        String userId = String.valueOf(new Random().nextInt(10000));
        String pushUrl = URLUtils.generatePushUrl(streamId, userId, 0);
        int ret = mLivePusher.startPush(pushUrl);
        Log.i(TAG, "startPush return: " + ret);
        mLivePusher.startMicrophone();
        mButtonPush.setText(R.string.thirdbeauty_stop_push);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mLivePusher != null) {
            mLivePusher.stopCamera();
            mLivePusher.stopMicrophone();
            if (mLivePusher.isPushing() == 1) {
                mLivePusher.stopPush();
            }
            mLivePusher = null;
        }
    }

    @Override
    public void onBackPressed() {
        finish();
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if (id == R.id.btn_push) {
            push();
        } else if (id == R.id.iv_back) {
            finish();
        }
    }

    private void push() {
        if (mLivePusher != null && mLivePusher.isPushing() == 1) {
            stopPush();
        } else {
            startPush();
        }
    }

    private void stopPush() {
        if (mLivePusher != null) {
            mLivePusher.stopCamera();
            mLivePusher.stopMicrophone();
            if (mLivePusher.isPushing() == 1) {
                mLivePusher.stopPush();
            }
            mLivePusher = null;
        }
        mButtonPush.setText(R.string.thirdbeauty_start_push);
    }
}