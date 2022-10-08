# MLVB API-Example 
[中文](README.md) | English

## Background
This open-source demo shows how to use some APIs of the [MLVB SDK](https://www.tencentcloud.com/document/product/1071) to help you better understand the APIs and use them to implement some basic MLVB features. 

## Contents
This demo covers the following features (click to view the details of a feature):

- Basic Features
  - [Publishing from Camera](./Basic/LivePushCamera)
  - [Publishing from Screen](./Basic/LivePushScreen)
  - [Playback](./Basic/LivePlay)
  - [Leb Playback](./Basic/LebPlay)
  - [Co-anchoring](./Basic/LiveLink)
  - [Competition](./Basic/LinkPK)
- Advanced Features
  - [Custom Video Capturing](./Advanced/CustomVideoCapture)
  - [Third-Party Beauty Filters](./Advanced/ThirdBeauty)
  - [RTC Co-anchoring + Ultra-low-latency Playback](./Advanced/RTCPushAndPlay)
  - [Webrtc Auto Bitrate](./Advanced/LebAutoBitrate)

## Environment Requirements
- Xcode 11.0 or above
- A valid developer signature for your project


## Demo Run Example

### Prerequisites
You have [signed up for a Tencent Cloud account](https://intl.cloud.tencent.com/document/product/378/17985) and completed [identity verification](https://intl.cloud.tencent.com/document/product/378/3629).

### Obtaining `SDKAppID` and secret key
1. In the TRTC console, select **Application Management** > **[Create application](https://console.tencentcloud.com/trtc/app/create)**.
2. Enter an application name such as `TestTRTC`, and click **Next**.

![ #900px](https://qcloudimg.tencent-cloud.cn/raw/51c73a617e69a76ed26e6f74b0071ec9.png)
3. Click **Next** to view your `SDKAppID` and key.

### Activating MLVB
1. [Activate CSS and add domain names](https://console.intl.cloud.tencent.com/live/common/apply?code=0). If you haven’t activated CSS, click **Apply for Activation**, and add publishing and playback domain names in **Domain Management**.
2. [Obtain a trial license to use the SDK](https://console.intl.cloud.tencent.com/live/license). 

### Configuring demo project files

1. Open the [GenerateTestUserSig.h](debug/GenerateTestUserSig.h) file in the `Debug` directory.
2. Set parameters in `GenerateTestUserSig.h` as follows:

  - `SDKAPPID`: set it to the `SDKAppID` obtained in the previous step.
  - `SECRETKEY`: set it to the secret key obtained in the previous step.
  - `LICENSEURL`: a placeholder by default. Set it to the actual license URL.
  - `LICENSEURLKEY`: a placeholder by default. Set it to the actual license key.
  - `PUSH_DOMAIN`: set it to the configured publishing URL.
  - `PLAY_DOMAIN`: set it to the configured playback URL.
  - `LIVE_URL_KEY`: set it to the authentication key (if authentication configuration is enabled).

>!The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is suitable only for the local execution and debugging of the demo**.
>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://www.tencentcloud.com/document/product/1071/39471).

## Compiling and running the project

Open `MLVB-API-Example-OC.xcodeproj` in the source code directory with Xcode (11.0 or above).

## Contact Us
- If you have questions, see [FAQs](https://www.tencentcloud.com/document/product/1071/39477).

- To learn about how the MLVB SDK can be used in different scenarios, see [Sample Code](https://www.tencentcloud.com/document/product/1071).

- For complete API documentation, see [SDK API Documentation](https://liteav.sdk.qcloud.com/doc/api/en/group__V2TXLivePusher__ios.html).

- Communication & Feedback   
Welcome to join our Telegram Group to communicate with our professional engineers! We are more than happy to hear from you~
Click to join: [https://t.me/+EPk6TMZEZMM5OGY1](https://t.me/+EPk6TMZEZMM5OGY1)   
Or scan the QR code   
  <img src="https://qcloudimg.tencent-cloud.cn/raw/79cbfd13877704ff6e17f30de09002dd.jpg" width="300px">
