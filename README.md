# 腾讯云移动直播终端组件 MLVB SDK
- [移动直播 SDK](https://cloud.tencent.com/product/mlvb)：基于腾讯云 LiteAV 音视频框架实现的一套推拉流和连麦组件，帮您快速上线手机直播功能。
- [云直播](https://cloud.tencent.com/product/lvb)：移动直播 SDK 所依赖的的云端服务，主要提供 RTMP 推流接入点、直播 CDN、实时转码等云端能力。

## SDK 下载
您可以在腾讯云官网下载页面 [DOWNLOAD](https://cloud.tencent.com/document/product/454/7873) 获取精简版、专业版和商用版的 SDK 下载链接，如下为精简版下载链接：

| 所属平台 | Zip下载 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_Smart_iOS_latest.zip)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/iOS/README.md)| [DOC](https://cloud.tencent.com/document/product/454/7876) | [API](https://cloud.tencent.com/document/product/454/34753) |
| Android | [下载](https://liteav.sdk.qcloud.com/download/latest/TXLiteAVSDK_Smart_Android_latest.zip)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/Android/README.md)| [DOC](https://cloud.tencent.com/document/product/454/7877) | [API](https://cloud.tencent.com/document/product/454/34766) |
| 小程序 | [下载](https://liteavsdk-1252463788.cosgz.myqcloud.com/MLVB_WXMini_latest.zip)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/WXMini/README.md)| [DOC](https://cloud.tencent.com/document/product/454/34925) | [API](https://cloud.tencent.com/document/product/454/15368) |

### 移动直播 SDK V1 升级到 V2 API 接口对比说明
移动直播 SDK 从 8.4 版本开始，提供了新的 V2 接口:
- 同时支持 RTMP 协议和 RTC 协议
- 支持更加强大灵活的连麦/PK 能力
  
对于使用 V1 的客户，我们提供了 V1 升级到 V2 的[接口升级指引对照表](https://docs.qq.com/sheet/DRkJUckpGdkNTUmt2)

### Version 9.2 @ 2021.09.26
- iOS：修复 V2 Player onWarning 方法不回的问题；
- iOS：修复快直播播放拉流端停止拉流，再重新拉流观看音画不同步的问题；
- Android：修复特定情况下出现崩溃的问题；
- Android：修复 V2 RTMP 推流存在的内存泄漏问题；
- Android&iOS：修复快直播 H265 流播放失败的问题；

## MLVB Demo

<table style="text-align:center;vertical-align:middle;">
<tr>
<th>平台</th><th>Demo体验</th>
</tr>
<tr>
<td>iOS</td>
<td><a onclick="window.open('https://itunes.apple.com/cn/app/id1152295397?mt=8')"><div style="width:130px;height: 130px;background-image:url(https://liteav.sdk.qcloud.com/doc/res/mlvb/picture/video_cloud_tools_app_qr_code_ios.png);background-size: cover;margin:auto">
</div></a></td>
</tr>
<tr>
<td>Android</td>
<td><a onclick="window.open('https://dldir1.qq.com/hudongzhibo/liteav/rtmpdemo.apk')"><div style="width:130px;height: 130px;background-image:url(https://liteav.sdk.qcloud.com/doc/res/mlvb/picture/video_cloud_tools_app_qr_code_android.png);background-size: cover;margin:auto">
</div></a></td>
</tr>
</tr>
</table>
 
**MLVB Demo 展示**
 
<img width="900" src="https://main.qcloudimg.com/raw/7f5440164eb5835b1fb2b67c3752fe2a.png"/>

## 小直播 Demo

<table>
<tr>
<th>平台</th><th>Demo体验</th>
</tr>
<tr>
<td>iOS</td>
<td><a onclick="window.open('https://itunes.apple.com/cn/app/id1132521667?mt=8')"><div style="width:130px;height: 130px;background-image:url(https://liteav.sdk.qcloud.com/doc/res/mlvb/picture/xiaozhibo_app_qr_code_ios.png);background-size: cover;margin:auto">
</div></a></td>
</tr>
<tr>
<td>Android</td>
<td><a onclick="window.open('https://dldir1.qq.com/hudongzhibo/liteav/xiaozhibo.apk')"><div style="width:130px;height: 130px;background-image:url(https://liteav.sdk.qcloud.com/doc/res/mlvb/picture/xiaozhibo_app_qr_code_android.png);background-size: cover;margin:auto">
</div></a></td>
</tr>
</tr>
</table>
 
**小直播 Demo 展示**
 
<img width="900" src="https://main.qcloudimg.com/raw/732c851eb9c25dd426e02e764a4c0bc1.png"/>


## 小程序 Demo

![](https://main.qcloudimg.com/raw/913bc2c34495e04dcd3d97eff069df53.jpg)
