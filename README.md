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

### Version 8.6 @ 2021.05.06
- iOS&Android：移动直播 V2 新增 RTC 协议混流接口。
- iOS&Android：移动直播 V2 新增预处理接口。
- iOS&Android：移动直播 V2 修复观众端偶现拉流失败的问题。
- iOS&Android：移动直播 V2 修复开启自定义采集再关闭后，导致的推流失败问题。
- iOS&Android：移动直播 V2 优化若干体验问题。
- iOS&Android：修复移动直播若干稳定性问题。
- iOS：优化 Swift 编译警告问题。

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
