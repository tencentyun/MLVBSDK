## 如何跑通 Demo 与 小直播 App
> 小直播需要您搭建一个业务后台用来进行帐号和回看列表的管理，请参考：[快速搭建“小直播”](https://cloud.tencent.com/document/product/454/15187) 。

本文将一步一步教您如何跑通 Github 提供的 Demo 以及 小直播 App

- 步骤一：申请 Licence。
- 步骤二：将 Licence 内容填写到 App 的相关位置。
- 步骤三：将 Bundle Identifier 修改为申请 License 时填写的Bundle Id。

## 步骤一：申请 Licence

您可以申请测试的28天免费的 Licence 进行调试，也可以直接申请正式版 Licence。

### 方式一：申请测试 Licence

您可以免费申请测试 License（基础版，有效期28天）体验测试，具体步骤如下:
- 登录腾讯云官网，进入 [移动直播 License](https://console.cloud.tencent.com/live/license)，并填写相应的信息：在 Package Name 中填写 Android 的包名，Bundle Id 中填写 iOS 的 bundleId。

![](https://main.qcloudimg.com/raw/edd99f145276ad5250f0ca5d0f5d4980.png)

- 创建成功后页面会显示生成的 License 信息，这里需要记下 Key 和 LicenseUrl，在 SDK 的初始化时需要传入这两个参数。

![](https://main.qcloudimg.com/raw/ce722e4038a86b85d96b2cb9f5a058e8.png)

### 方式二：购买正式 Licence

当您的测试 License 过期了，可以点击 [购买移动直播套餐](https://buy.cloud.tencent.com/mobilelive) ，可以免费获得一年有效的 License 使用权限。
![](https://main.qcloudimg.com/raw/52004efac93e7e6c8f446e53830816a3.png)

> 购买“移动直播 SDK 套餐包”后，在 [移动直播 License](https://console.cloud.tencent.com/live/license) 页面下部会有 “一键切换普通版” 按钮。当点击切换的时候，会再次确认 Bundle ID 和 Package Name，如与提交到商店的不一致请进行修改，一旦切换成功，License信息不能再做修改

## 步骤二：填写 Licence 信息到 App 中

iOS 中填写 Licence 的接口为：

```
[TXLiveBase setLicenceURL:@"您的 Licence URL" key:@"您的 Licence Key");
```

- **填写到 Demo 中**

Demo 中填写 Licence 的位置在 `Demo/TXLiteAVDemo/App/AppDelegate.m` 和 `Deom/ReplaykitUpload/SampleHandler.m` （用于录屏推流）中：

```
[TXLiveBase setLicenceURL:@"<#Licence URL#>" key:@"<#Licence Key#>"];
```

- **填写到小直播 App 中**

小直播 App 中填写 Licence 的位置在 ` XiaoZhiBo/XiaoZhiBoApp/Classes/App/AppDelegate.m`中

```
[TXLiveBase setLicenceURL:@"<#Licence URL#>" key:@"<#Licence Key#>"];
```

## 步骤三：将 Bundle Identifier 修改为申请 License 时填写的Bundle Id。

### 如下图所示，分两步修改 Demo 的 Bundle Identifier

- **步骤一：修改 Target: TXLiteAVDemo_Smart 的 Budle Identifier**

![](https://main.qcloudimg.com/raw/6231af8c59df8de803cf856b1c50ea6e.png)

- **步骤二：修改 Target: TXReplaykitUpload_Smart 的 Budle Identifier**

![](https://main.qcloudimg.com/raw/64da88974e8f62d6e0f28208e766169a.png)

### 如下图所示，修改小直播 App 的 Bundle Identifier

![](https://main.qcloudimg.com/raw/3c2d09095d6ec0c3bb559f099d039d70.png)


## 关于 Licence 

关于 Licence 的更多信息，您可以查阅[腾讯云 - Licence 使用指南](<https://cloud.tencent.com/document/product/454/34750>)。
