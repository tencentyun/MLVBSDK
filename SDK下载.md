## 精简版 SDK 下载地址

精简版体积最小，适合仅集成 MLVB 直播连麦功能的客户。

| 所属平台 | SDK 下载 | Demo运行说明 | SDK集成指引 | 64位支持 | 安装包增量 |
|:---------:| :--------:| :--------:| :--------:| :--------:|:--------:|
| iOS | [Framework](https://github.com/tencentyun/MLVBSDK/tree/master/iOS/SDK)|[DOC](https://github.com/tencentyun/MLVBSDK/blob/master/iOS/README.md)|[DOC](https://cloud.tencent.com/document/product/454/7876)|支持|1.90M（arm64）|
| Android | [AAR + ZIP](https://github.com/tencentyun/MLVBSDK/tree/master/Android/SDK)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/Android/README.md)|[DOC](https://cloud.tencent.com/document/product/454/7877)|支持| jar：1.7M；<br> so(armeabi)：8.8 M；<br> so(armeabi-v7a)：7.7M；<br>so(arm64-v8a)：11.4M |


> 阅读文档 [如何缩减安装包体积](https://cloud.tencent.com/document/product/647/34400) 了解如何减少 SDK 带来的安装包体积增量。

## 专业版 SDK 下载地址

TRTC SDK 是隶属于腾讯视频云 LiteAV 框架下的一款终端产品，我们基于 LiteAV 框架还研发了[超级播放器 SDK](https://cloud.tencent.com/product/player)、[移动直播 SDK](https://cloud.tencent.com/product/mlvb) 和 [短视频 SDK](https://cloud.tencent.com/product/ugsv) 等其他终端产品。

如果您的项目中同时集成了两款以上的 LiteAV 体系的 SDK，就会出现符号冲突（symbol duplicate）的问题，这是由于 LiteAV 体系的 SDK 都使用了相同的基础模块。

要避免符号冲突问题，正确的做法是不要同时集成两个 SDK，而是集成一个具备完整功能的专业版 SDK：

| 所属平台 | 下载地址 | 64位支持 | 安装包增量 |
|:---------:| :--------:| :--------:|:--------:|
| iOS | [ZIP](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.6/TXLiteAVSDK_Professional_iOS_6.6.7459.zip) | 支持 | 4.08M（arm64）|  [DOC](https://cloud.tencent.com/document/product/647/34400) |
| Android | [AAR](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.6/LiteAVSDK_Professional_6.6.7458.aar) or [ZIP](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.6/LiteAVSDK_Professional_6.6.7458.zip)| 支持 | jar：1.5M；<br> so(armeabi)：6.5M；<br> so(armeabi-v7a)：6.1M；<br>so(arm64-v8a)：7.3M| [DOC](https://cloud.tencent.com/document/product/647/34400) |

> Windows 和 Mac 版本的 SDK 暂时只有一个版本，没有做精简版、专业版和企业版的区分。


## 企业版 SDK 下载地址
LiteAVSDK 的企业版，除了包含专业版的所有功能以外，还集成了一套 AI 特效组件，支持大眼，瘦脸、美颜和动效贴纸挂件等能力，下载后需要解压密码和授权 license 才能运行，解码密码和授权 license 请联系腾讯云商务获取。

| 所属平台 | 下载地址 | 64位支持 | 安装包增量 | 安装包瘦身|
|:---------:| :--------:| :--------:|:--------:|:--------:|
| iOS | [ZIP](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.6/TXLiteAVSDK_Enterprise_iOS_6.6.7459.zip) |支持|4.08M（arm64）|  [DOC](https://cloud.tencent.com/document/product/454/34927) |
| Android | [ZIP](http://liteavsdk-1252463788.cosgz.myqcloud.com/6.6/LiteAVSDK_Enterprise_6.6.7458.zip)|支持|  jar：2.3M；so(armeabi)：20.4M |[DOC](https://cloud.tencent.com/document/product/454/34927) |

> Windows 和 Mac 版的 SDK 暂无 AI 特效组件，没有做精简版、专业版和企业版的区分。

## 各版本差异对照表

![](https://main.qcloudimg.com/raw/76d9d6f854ba4cc8cf3b3c18ed230a35.png)

<table>
<tr>
<th width="100px" style="text-align:center">功能模块</th>
<th width="100px" style="text-align:center">功能项</th>
<th width="100px" style="text-align:center">直播精简版<br>LiteAV_Smart</th>
<th width="100px" style="text-align:center">短视频版<br>LiteAV_UGC</th>
<th width="100px" style="text-align:center">TRTC版<br>LiteAV_TRTC</th>
<th width="100px" style="text-align:center">播放器版<br>LiteAV_Player</th>
<th width="100px" style="text-align:center">专业版<br>Professional</th>
<th width="100px" style="text-align:center">企业版<br>Enterprise</th>
</tr>
<tr>
<td rowspan='2' style="text-align:center">直播推流</td>
<td style="text-align:center">摄像头推流</td>
<td style="text-align:center">✔</td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">录屏推流</td>
<td style="text-align:center">✔</td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td rowspan='3' style="text-align:center">直播播放</td>
<td style="text-align:center">RTMP协议</td>
<td style="text-align:center">✔</td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">HTTP-FLV</td>
<td style="text-align:center">✔</td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">HLS(m3u8)</td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td rowspan='3' style="text-align:center">点播播放</td>
<td style="text-align:center">MP4格式</td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">HLS(m3u8)</td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">DRM加密</td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td rowspan='2' style="text-align:center">美颜滤镜</td>
<td style="text-align:center">基础美颜</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">基础滤镜</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td rowspan='2' style="text-align:center">直播连麦</td>
<td style="text-align:center">连麦互动</td>
<td style="text-align:center">✔</td>
<td></td>
<td style="text-align:center">✔</td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">跨房PK</td>
<td style="text-align:center">✔</td>
<td></td>
<td style="text-align:center">✔</td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td rowspan='2' style="text-align:center">视频通话</td>
<td style="text-align:center">双人通话</td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center"></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">视频会议</td>
<td style="text-align:center"></td>
<td style="text-align:center"></td>
<td style="text-align:center">✔</td>
<td style="text-align:center"></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td rowspan='4' style="text-align:center">短视频</td>
<td style="text-align:center">录制和拍摄</td>
<td></td>
<td style="text-align:center">✔</td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">裁剪拼接</td>
<td></td>
<td style="text-align:center">✔</td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">“抖音”特效</td>
<td></td>
<td style="text-align:center">✔</td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">视频上传</td>
<td></td>
<td style="text-align:center">✔</td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td rowspan='4' style="text-align:center">AI 特效</td>
<td style="text-align:center">大眼瘦脸</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">V脸隆鼻</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">动效贴纸</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
</tr>
<tr>
<td style="text-align:center">绿幕抠图</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td style="text-align:center">✔</td>
</tr>
</table>

> 小故事：LiteAV 最初只研发了直播功能，所以直播精简版被命名为 LiteAV_Smart，而不是另一个更合理的名字 LiteAV_LIVE。





