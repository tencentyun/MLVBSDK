# MLVB API-Example 
中文 | [English](README.en.md)

## 前言
这个开源示例Demo主要演示了 [移动直播 SDK](https://cloud.tencent.com/document/product/454) 部分API的使用示例，帮助开发者可以更好的理解 移动直播 SDK 的API，从而快速实现一些移动直播场景的基本功能。 

## 结构说明
在这个示例项目中包含了以下场景:（带上对应的跳转目录，方便用户快速浏览感兴趣的功能）

- 基础功能
  - [摄像头推流](./Basic/LivePushCamera)
  - [录屏推流](./Basic/LivePushScreen)
  - [直播拉流](./Basic/LivePlay)
  - [连麦互动](./Basic/LiveLink)
  - [连麦PK](./Basic/LinkPK)
- 进阶功能
  - [自定义视频采集](./Advanced/CustomVideoCapture)
  - [第三方美颜](./Advanced/ThirdBeauty)
  - [RTC连麦+超低延时播放](./Advanced/RTCPushAndPlay)

## 环境准备
- Xcode 11.0及以上版本
- 请确保您的项目已设置有效的开发者签名


## 运行示例

### 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

### 申请SDKAPPID 和 SECRETKEY
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入您的应用名称，例如`TestTRTC`，单击【创建应用】。

![ #900px](https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png)
3. 创建应用完成后，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

### 开通移动直播服务
1. [开通直播服务并绑定域名](https://console.cloud.tencent.com/live/livestat) 如果还没开通，点击申请开通，之后在域名管理中配置推流域名和拉流域名
2. [获取SDK的测试License](https://console.cloud.tencent.com/live/license) 

### 配置 Demo 工程文件

1. 打开 Debug 目录下的 [GenerateTestUserSig.h](debug/GenerateTestUserSig.h) 文件。
2. 配置`GenerateTestUserSig.h`文件中的参数：

  - SDKAPPID：替换该变量值为上一步骤中在页面上看到的 SDKAppID。
  - SECRETKEY：替换该变量值为上一步骤中在页面上看到的密钥。
  - LICENSEURL：默认为 PLACEHOLDER ，请设置为实际的License Url信息；
  - LICENSEURLKEY：默认为 PLACEHOLDER ，请设置为实际的License Key信息；
  - URLKEY: 如果开通鉴权配置的鉴权Key

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 编译运行

使用 XCode（11.0及以上的版本）打开源码目录下的 MLVB-API-Example-OC.xcodeproj

> 上述流程并没有解答您的疑问，你可以[点击此处](https://wj.qq.com/s2/8393513/f442/)反馈，我们的**工程师妹子**会尽快处理！

# 联系我们
- [常见问题](https://cloud.tencent.com/document/product/454/7937)
- [官网文档](https://cloud.tencent.com/document/product/454)
- [API文档](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__V2TXLivePusher__ios.html#afc848d88fe99790b8c0988b8525dd4d9)

