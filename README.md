# 腾讯云移动直播终端组件 MLVB SDK
- [移动直播 SDK](https://cloud.tencent.com/product/mlvb)：基于腾讯云 LiteAV 音视频框架实现的一套推拉流和连麦组件，帮您快速上线手机直播功能。
- [云直播](https://cloud.tencent.com/product/lvb)：移动直播 SDK 所依赖的的云端服务，主要提供 RTMP 推流接入点、直播 CDN、实时转码等云端能力。

## SDK 下载
您可以在腾讯云官网下载页面 [DOWNLOAD](https://cloud.tencent.com/document/product/454/7873) 获取精简版、专业版和商用版的 SDK 下载链接，如下为精简版下载链接：

| 所属平台 | Zip下载 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Smart_iOS_latest.zip)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/iOS/README.md)| [DOC](https://cloud.tencent.com/document/product/454/7876) | [API](https://cloud.tencent.com/document/product/454/34753) |
| Android | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/TXLiteAVSDK_Smart_Android_latest.zip)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/Android/README.md)| [DOC](https://cloud.tencent.com/document/product/454/7877) | [API](https://cloud.tencent.com/document/product/454/34766) |
| 小程序 | [下载](http://liteavsdk-1252463788.cosgz.myqcloud.com/MLVB_WXMini_latest.zip)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/WXMini/README.md)| [DOC](https://cloud.tencent.com/document/product/454/34925) | [API](https://cloud.tencent.com/document/product/454/15368) |

## Version 6.7.7733 @ 2019.09.29
- iOS：iOS13 录屏兼容性问题处理。
- iOS：解决阿拉伯文兼容性问题。
- iOS：解决编辑视频使用高质量保存偶现失败的问题。
- Android：短视频合成偶现杂音问题 fix。
- Android：STL 库统一直接使用系统库，解决因 STL 库冲突引起的偶现 CRASH 问题。
- iOS&Android：精简版极速模式拉流有画面无声音问题 fix。
- iOS&Android：录制增加16：9分辨率支持。
- iOS&Android：重点解决上报的偶现 CRASH 问题。

## MLVB Demo

![](https://main.qcloudimg.com/raw/ddf1ce540e29f5a43091d9274672e5f1.jpg)

## 小直播 Demo

![](https://main.qcloudimg.com/raw/354d61632bd71d6aec7a833b3afb69bc.jpg)


## 小程序 Demo

![](https://main.qcloudimg.com/raw/913bc2c34495e04dcd3d97eff069df53.jpg)
