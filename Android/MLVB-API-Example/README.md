# MLVB API-Example 
_中文 | [English](README.en.md)_

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
  - [动态切换渲染组件](./Advanced/SwitchRenderView)
  - [自定义视频采集](./Advanced/CustomVideoCapture)
  - [第三方美颜](./Advanced/ThirdBeauty)
  - [RTC连麦+超低延时播放](./Advanced/RTCPushAndPlay)
  
>  说明：目前的工程结构跟标准的Android Studio工程在名称大小写上可能有略微的差异，主要目的是方便大家在网页上看到此工程时，名称意义更加清晰
 
 
## 环境准备
- 最低兼容 Android 4.1（SDK API Level 16），建议使用 Android 5.0 （SDK API Level 21）及以上版本
- Android Studio 3.5及以上版本
- App 要求 Android 5.0及以上设备
 

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
1. 使用 Android Studio（3.5及以上的版本）打开源码工程`MLVB-API-Example`
2. 找到并打开`MLVB-API-Example/Debug/src/main/java/com/tencent/trtc/debug/GenerateTestUserSig.java`文件。
3. 设置`GenerateTestUserSig.java`文件中的相关参数：
  - `SDKAPPID`：默认为 PLACEHOLDER ，请设置为实际的 SDKAppID；
  - `SECRETKEY`：默认为空字符串，请设置为实际的密钥信息；
  - `LICENSEURL`：默认为 PLACEHOLDER ，请设置为实际的License Url信息；
  - `LICENSEURLKEY`：默认为 PLACEHOLDER ，请设置为实际的License Key信息；
4. 找到并打开`MLVB-API-Example/Debug/src/main/java/com/tencent/mlvb/debug/AddressUtils.java`文件。
5. 设置`AddressUtils.java`文件中的相关参数：
  - `PUSH_DOMAIN`：配置的推流地址
  - `PLAY_DOMAIN`：配置的拉流地址
  - `KEY`：如果开通鉴权配置的鉴权Key

### 集成 SDK
您可以选择使用 JCenter 自动加载的方式，或者手动下载 aar 再将其导入到您当前的工程项目中，Demo默认采用方法一配置。

#### 方法一：自动加载（aar）
1. 在 dependencies 中添加 SDK 的依赖。
 - 若使用3.x版本的 com.android.tools.build:gradle 工具，请执行以下命令：
```
dependencies {
    implementation 'com.tencent.liteav:LiteAVSDK_Professional:latest.release'
}
```
 - 若使用2.x版本的 com.android.tools.build:gradle 工具，请执行以下命令：
```
dependencies {
    compile 'com.tencent.liteav:LiteAVSDK_Professional:latest.release'
}
```
2. 在 defaultConfig 中，指定 App 使用的 CPU 架构。
```
defaultConfig {
    ndk {
        abiFilters "armeabi-v7a", "arm64-v8a"
    }
}
```
3.单击【Sync Now】，自动下载 SDK 并集成到工程里。

#### 方法二：手动下载（aar）
如果您的网络连接 JCenter 有问题，您也可以手动下载 SDK 集成到工程里：

1. 下载最新版本 [移动直播 SDK](https://cloud.tencent.com/document/product/454/7873)
2. 将下载到的 aar 文件拷贝到工程的 **App/libs** 目录下。
3. 在工程根目录下的 build.gradle 中，添加 **flatDir**，指定本地仓库路径。
```
...
allprojects {
    repositories {
        flatDir {
            dirs 'libs'
            dirs project(':app').file('libs')
        }
    ...
    }
}
...
```
4. 在 app/build.gradle 中，添加引用 aar 包的代码。
```
dependencies {
    ...
    compile(name: 'LiteAVSDK_Professional_xxx', ext: 'aar') // xxx表示解压出来的SDK版本号
    ...
}
```
5. 在 app/build.gradle的defaultConfig 中，指定 App 使用的 CPU 架构。
```
defaultConfig {
    ndk {
        abiFilters "armeabi-v7a", "arm64-v8a"
    }
}
```
6. 单击【Sync Now】，完成 SDK 的集成工作。 

### 编译运行
用 Android Studio 打开该项目，连上Android设备，编译并运行。

# 联系我们
- [常见问题](https://cloud.tencent.com/document/product/454/7937)
- [官网文档](https://cloud.tencent.com/document/product/454)
- [API文档](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__V2TXLivePusher__android.html#afc848d88fe99790b8c0988b8525dd4d9)