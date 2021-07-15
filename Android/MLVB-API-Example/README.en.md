# MLVB API-Example 
_[中文](README.md) | English_

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
  - [Dynamically Switching Rendering Controls](./Advanced/SwitchRenderView)
  - [Custom Video Capturing](./Advanced/CustomVideoCapture)
  - [Third-Party Beauty Filters](./Advanced/ThirdBeauty)
  - [RTC Co-anchoring + Ultra-low-latency Playback](./Advanced/RTCPushAndPlay)
  
>  Note: for clarity purposes, the naming of folders in the project may differ slightly from a standard Android Studio project in terms of letter case.
 
 
## Environment Requirements
- Android 4.1 (SDK API level 16) or above; Android 5.0 (SDK API level 21) or above is recommended.
- Android Studio 3.5 or above
- Devices with Android 5.0 or above
 

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
1. Open the demo project `MLVB-API-Example` with Android Studio (3.5 or above).
2. Find and open `MLVB-API-Example/Debug/src/main/java/com/tencent/trtc/debug/GenerateTestUserSig.java`.
3. Set parameters in `GenerateTestUserSig.java` as follows:
  - `SDKAPPID`: a placeholder by default. Set it to the actual `SDKAppID`.
  - `SECRETKEY`: left empty by default. Set it to the actual key.
  - `LICENSEURL`: a placeholder by default. Set it to the actual license URL.
  - `LICENSEURLKEY`: a placeholder by default. Set it to the actual license key.
4. Find and open `MLVB-API-Example/Debug/src/main/java/com/tencent/mlvb/debug/AddressUtils.java`.
5. Set parameters in `AddressUtils.java` as follows:
  - `PUSH_DOMAIN`: set it to the configured publishing URL.
  - `PLAY_DOMAIN`: set it to the configured playback URL.
  - `KEY`: set it to the authentication key (if authentication configuration is enabled).

### Integrating the SDK
You can use JCenter for automatic loading or manually download the AAR file and import it to your project. The demo uses the first method by default.

#### Method 1: automatic loading (AAR)
1. Add the SDK dependencies to `dependencies`.
 - Run the following command if you use the 3.x version of com.android.tools.build:gradle.
```
dependencies {
    implementation 'com.tencent.liteav:LiteAVSDK_Professional:latest.release'
}
```
 - Run the following command if you use the 2.x version of com.android.tools.build:gradle.
```
dependencies {
    compile 'com.tencent.liteav:LiteAVSDK_Professional:latest.release'
}
```
2. In `defaultConfig`, specify the CPU architecture to be used by your application.
```
defaultConfig {
    ndk {
        abiFilters "armeabi-v7a", "arm64-v8a"
    }
}
```
3. Click **Sync Now** to automatically download and integrate the SDK into your project.

#### Method 2: manual download (AAR)
If you have difficulty accessing JCenter, you can manually download the SDK and integrate it into your project.

1. Download the latest version of the [MLVB SDK](https://cloud.tencent.com/document/product/454/7873).
2. Copy the downloaded AAR file to the **App/libs** directory of your project.
3. Add **flatDir** to `build.gradle` under the project’s root directory and specify a local path for the repository.
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
4. Add code in `app/build.gradle` to import the AAR file.
```
dependencies {
    ...
    compile(name: 'LiteAVSDK_Professional_xxx', ext: 'aar') // `xxx` is the version number of the decompressed SDK
    ...
}
```
5. In `defaultConfig` of `app/build.gradle`, specify the CPU architecture to be used by your application.
```
defaultConfig {
    ndk {
        abiFilters "armeabi-v7a", "arm64-v8a"
    }
}
```
6. Click **Sync Now** to complete the integration.

### Compiling and running the project
Open the project with Android Studio, connect to an Android device, and compile and run the project.

# Contact Us
- [FAQs](https://cloud.tencent.com/document/product/454/7937)
- [Documentation](https://cloud.tencent.com/document/product/454)
- [API documentation](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__V2TXLivePusher__android.html#afc848d88fe99790b8c0988b8525dd4d9)