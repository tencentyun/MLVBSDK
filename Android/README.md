## 目录结构说明

本目录包含 Android 版 移动直播 SDK 的Demo 源代码，主要演示接口如何调用以及最基本的功能。

```
├─ Demo // 移动直播 Demo，包括直播推流，直播播放，互动直播（IM）
|  ├─ app                   // 程序入口界面
|  ├─ audioeffectsettingkit // 音效面板，包含BGM播放，变声，混响，变调等效果
|  ├─ beautysettingkit      // 美颜面板，包含美颜，滤镜，动效等效果
|  ├─ debug                 // 包含 GenerateTestUserSig，用于本地生成测试用的 UserSig
|  ├─ login                 // 一个演示性质的简单登录界面
|  ├─ liveplayerdemo        // 直播播放，可以扫码播放地址进行播放
|  ├─ livepusherdemo        // 直播推流，包含推流时，设置美颜，音效，等基础操作
|  ├─ mlvbliveroomdemo      // 互动直播，包含连麦、聊天、点赞等特性
|  
├─ SDK 
│  ├─ LiteAVSDK_Smart_x.y.zzzz.aar        // 如果您下载的是 Smart 专用 zip 包，解压后将出现此文件夹，其中 x.y.zzzz 表示 SDK 版本号 
|  ├─ LiteAVSDK_Professional_x.y.zzzz.aar // 如果您下载的是专业版 zip 包，解压后将出现此文件夹，其中 x.y.zzzz 表示 SDK 版本号 
|  ├─ LiteAVSDK_Enterprise_x.y.zzzz.aar   // 如果您下载的是企业版 zip 包，解压后将出现此文件夹，其中 x.y.zzzz 表示 SDK 版本号 
```

## SDK 分类和下载

腾讯云 移动直播 SDK 基于 LiteAVSDK 统一框架设计和实现，该框架包含直播、点播、短视频、RTC、AI美颜在内的多项功能：

- 如果您追求最小化体积增量，可以下载 Smart 版：[TXLiteAVSDK_Smart.zip](https://cloud.tencent.com/document/product/454/7873)
- 如果您需要使用多个功能而不希望打包多个 SDK，可以下载专业版：[TXLiteAVSDK_Professional.zip](https://cloud.tencent.com/document/product/647/32689#Professional)
- 如果您已经通过腾讯云商务购买了 AI 美颜 License，可以下载企业版：[TXLiteAVSDK_Enterprise.zip](https://cloud.tencent.com/document/product/647/32689#Enterprise)

## 相关文档链接

- [SDK 的版本更新历史](https://cloud.tencent.com/document/product/454/7878)
- [SDK 的 API 文档](https://cloud.tencent.com/document/product/454/34766)
- [SDK 的官方体验 App](https://cloud.tencent.com/document/product/454/6555)
- [全功能小直播 App（Demo）源代码](https://cloud.tencent.com/document/product/454/38625)
