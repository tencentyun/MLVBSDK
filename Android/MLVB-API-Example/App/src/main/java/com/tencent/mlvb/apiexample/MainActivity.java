package com.tencent.mlvb.apiexample;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.mlvb.customvideocapture.CustomVideoCaptureActivity;
import com.tencent.mlvb.demo.R;
import com.tencent.mlvb.linkpk.LivePKEnterActivity;
import com.tencent.mlvb.livelink.LiveLinkEnterActivity;
import com.tencent.mlvb.liveplay.LivePlayEnterActivity;
import com.tencent.mlvb.livepushcamera.LivePushCameraEnterActivity;
import com.tencent.mlvb.livepushscreen.LivePushScreenEnterActivity;
import com.tencent.mlvb.rtcpushandplay.RTCPushAndPlayEnterActivity;
import com.tencent.mlvb.switchrenderview.SwitchRenderViewActivity;
import com.tencent.mlvb.thirdbeauty.ThirdBeautyActivity;


/**
 * MLVB API-Example 主页面
 *
 * 其中包含
 * 基础功能模块如下：
 * - 摄像头推流模块{@link LivePushCameraEnterActivity}
 * - 录屏推流模块{@link LivePushScreenEnterActivity}
 * - 直播拉流模块{@link LivePlayEnterActivity}
 * - 连麦互动模块{@link LiveLinkEnterActivity}
 * - 连麦PK模块{@link LivePKEnterActivity}
 *
 * 进阶功能模块如下：
 * - 动态切换渲染控件{@link SwitchRenderViewActivity}
 * - 自定义视频采集{@link CustomVideoCaptureActivity}
 * - 第三方美颜{@link ThirdBeautyActivity}
 * - RTC连麦+超低延时播放{@link RTCPushAndPlayEnterActivity}
 *
 * MLVB API-Example Main View
 *
 * Features
 * Basic features:
 * - Publishing from camera {@link LivePushCameraEnterActivity}
 * - Publishing from screen {@link LivePushScreenEnterActivity}
 * - Playback {@link LivePlayEnterActivity}
 * - Co-anchoring {@link LiveLinkEnterActivity}
 * - Competition {@link LivePKEnterActivity}
 *
 * Advanced features:
 * - Dynamically switching rendering controls {@link SwitchRenderViewActivity}
 * - Custom video capturing {@link CustomVideoCaptureActivity}
 * - Third-party beauty filters {@link ThirdBeautyActivity}
 * - RTC co-anchoring + ultra-low-latency playback {@link RTCPushAndPlayEnterActivity}
 *
 */
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        getSupportActionBar().hide();

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                findViewById(R.id.launch_view).setVisibility(View.GONE);
            }
        }, 1000);

        findViewById(R.id.ll_push_camera).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LivePushCameraEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_push_screen).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LivePushScreenEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_play).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LivePlayEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_link).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LiveLinkEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_pk).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LivePKEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_switch_render_view).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SwitchRenderViewActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_custom_camera).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, CustomVideoCaptureActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_third_beauty).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, ThirdBeautyActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_cloud_transcoding).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, RTCPushAndPlayEnterActivity.class);
                startActivity(intent);
            }
        });
    }

}
