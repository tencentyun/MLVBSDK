# MLVB API-Example 
[中文](README.md) | English

## Background
This open-source demo shows how to use some APIs of the [MLVB SDK](https://cloud.tencent.com/document/product/454) to help you better understand the APIs and use them to implement some basic MLVB features. 

## Contents
This demo covers the following features (click to view the details of a feature):

- Basic Features
  - [Publishing from Camera](./Basic/LivePushCamera)
  - [Publishing from Screen](./Basic/LivePushScreen)
  - [Playback](./Basic/LivePlay)
  - [Co-anchoring](./Basic/LiveLink)
  - [Competition](./Basic/LinkPK)
- Advanced Features
  - [Custom Video Capturing](./Advanced/CustomVideoCapture)
  - [Third-Party Beauty Filters](./Advanced/ThirdBeauty)
  - [RTC Co-anchoring + Ultra-low-latency Playback](./Advanced/RTCPushAndPlay)

## Environment Requirements
- Xcode 11.0 or above
- A valid developer signature for your project


## Demo Run Example

### Prerequisites
You have [signed up for a Tencent Cloud account](https://intl.cloud.tencent.com/document/product/378/17985) and completed [identity verification](https://intl.cloud.tencent.com/document/product/378/3629).

### Obtaining `SDKAppID` and secret key
1. In the TRTC console, select **Development Assistance** > **[Demo Quick Run](https://console.cloud.tencent.com/trtc/quickstart)**.
2. Enter an application name such as `TestTRTC`, and click **Create**.

![ #900px](https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png)
3. Click **Next** to view your `SDKAppID` and key.

### Activating MLVB
1. [Activate CSS and add domain names](https://console.cloud.tencent.com/live/livestat). If you haven’t activated CSS, click **Apply for Activation**, and add publishing and playback domain names in **Domain Management**.
2. [Obtain a trial license to use the SDK](https://console.cloud.tencent.com/live/license). 

### Configuring demo project files

1. Open the [GenerateTestUserSig.h](debug/GenerateTestUserSig.h) file in the `Debug` directory.
2. Set parameters in `GenerateTestUserSig.h` as follows:

  - `SDKAPPID`: set it to the `SDKAppID` obtained in the previous step.
  - `SECRETKEY`: set it to the secret key obtained in the previous step.
  - `LICENSEURL`: a placeholder by default. Set it to the actual license URL.
  - `LICENSEURLKEY`: a placeholder by default. Set it to the actual license key.
  - `URLKEY`: set it to the authentication key (if authentication configuration is enabled).

>!The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is suitable only for the local execution and debugging of the demo**.
>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://cloud.tencent.com/document/product/647/17275#Server).

### Compiling and running the project

Open `MLVB-API-Example-OC.xcodeproj` in the source code directory with Xcode (11.0 or above).

> If the above does not solve your problem, [report](https://wj.qq.com/s2/8393513/f442/) it to our **engineer**.

# Contact Us
- [FAQs](https://cloud.tencent.com/document/product/454/7937)
- [Documentation](https://cloud.tencent.com/document/product/454)
- [API documentation](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__V2TXLivePusher__ios.html#afc848d88fe99790b8c0988b8525dd4d9)

