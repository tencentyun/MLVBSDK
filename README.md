# 腾讯云移动直播终端组件 MLVB SDK
- [移动直播 SDK](https://cloud.tencent.com/product/mlvb)：基于腾讯云 LiteAV 音视频框架实现的一套推拉流和连麦组件，帮您快速上线手机直播功能。
- [云直播](https://cloud.tencent.com/product/lvb)：移动直播 SDK 所依赖的的云端服务，主要提供 RTMP 推流接入点、直播 CDN、实时转码等云端能力。

## 分流下载
腾讯云分流下载地址，适用于访问 Github 较慢的客户 ：[DOWNLOAD](https://github-1252463788.cos.ap-shanghai.myqcloud.com/mlvbsdk/MLVBSDK-6.5.7272.zip)

## 最新版本 6.5.7272 @ 2019.06.13
1. 优化 TXLivePlayer 在极速播放模式下的延迟控制算法，在拉取多条 CDN 直播流时可以做到精准同步。
2. 修复若干稳定性 bug，包括 6.4 版本引入的 TXLivePusher 录制功能失效的问题。
3. 6.4 版本开始，TXLivePusher 组件加入 License 校验功能，您可以通过购买购买[移动直播套餐](https://cloud.tencent.com/document/product/454/34750)免费获得一年的 License 使用权限。

## API 文档指引

| 所属平台 | Github 地址 | Demo运行说明 | SDK集成指引 | API 列表 |
|:---------:| :--------:|:--------:| :--------:|:--------:|
| iOS | [GitHub](https://github.com/tencentyun/MLVBSDK/tree/master/iOS)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/iOS/README.md)| [DOC](https://cloud.tencent.com/document/product/454/7876) | [API](https://cloud.tencent.com/document/product/454/34753) |
| Android | [GitHub](https://github.com/tencentyun/MLVBSDK/tree/master/Android)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/Android/README.md)| [DOC](https://cloud.tencent.com/document/product/454/7877) | [API](https://cloud.tencent.com/document/product/454/34766) |
| 小程序 | [GitHub](https://github.com/tencentyun/MLVBSDK/blob/master/WXMini)| [DOC](https://github.com/tencentyun/MLVBSDK/blob/master/WXMini/README.md)| [DOC](https://cloud.tencent.com/document/product/454/34925) | [API](https://cloud.tencent.com/document/product/454/15368) |

## SDK 下载地址

> [**SDK 各版本下载地址（精简版、专业版、企业版）**](https://github.com/tencentyun/MLVBSDK/blob/master/SDK%E4%B8%8B%E8%BD%BD.md)

## MLVB Demo

![](https://main.qcloudimg.com/raw/ddf1ce540e29f5a43091d9274672e5f1.jpg)

## 小直播 Demo

![](https://main.qcloudimg.com/raw/354d61632bd71d6aec7a833b3afb69bc.jpg)


## 小程序 Demo

![](https://main.qcloudimg.com/raw/913bc2c34495e04dcd3d97eff069df53.jpg)
