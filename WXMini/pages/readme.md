# 目录结构

├── Resources								//资源目录

├── main									//首页

├── components								//组件

│   ├── mlvb-live-room							//直播组件

│   └── webrtc-room							//多人音视频通话组件，使用实时音视频方案

├── play								      //播放页面

├── rtplay							      //低延时播放页面

├── push								      //推流页面

│   └── push-config						//推流设置页面

├── mlvb-live-room-demo							//使用live-room的demo示例

│   ├── room								//房间页面

│   ├── roomlist							//房间列表页面

│   └── roomname							//新建房间页面

├── readme.md								//文档

└── webrtc-room-demo						//使用webrtc-room的demo示例

​    ├── room								//房间页面

​    └── join-room-by-id					//进房间页面



# 组件使用说明
## mlvb-live-room组件

### 属性

| 属性 | 类型 | 默认值 | 说明 |
|:--------:|:---------:|---------|:-----: |
| role | String | 'audience' | 必要，角色，是主播anchor还是观众audience |
| roomid | String | '' | 必要，房间id |
| roomname | String | '' | 必要，房间名 |
| debug | Boolean | false | 可选，是否打开log |
| template | String | 'float' | 必要，模版名，mlvb-live-room只有float这种类型 |
| beauty | Number | 5 | 可选，美颜，取值范围 0-9 ，0 表示关闭 |
| muted | Boolean | false | 可选，是否静音，指推流 |
| pureaudio | Boolean | false | 可选，是否纯音频推流 |


### 接口

| 函数名                                          | 说明         |
|-------------------------------------------------|--------------|
| start()                                         | 启动     |
| pause()                                       | 暂停     |
| resume()                                     | 恢复    |
| stop()                                          | 停止     |
| requestJoinAnchor()                                              | 请求连麦，适用于audience  |
| respondJoinAnchor(agree:Boolean, audience:Object) | 同意连麦，适用于anchor  |
| switchCamera()                           | 切换摄像头   |

### 叠加图标的实现

mlvb-live-room组件提供两个<slot> 节点，用于承载组件引用时提供的子节点。slot名分别为caster（主播），audience（观众）。

```js
<view class='container-box'>
  <mlvb-live-room id="id_liveroom" wx:if="{{showLiveRoom}}" roomid="{{roomID}}" role="{{role}}" roomname="{{roomName}}" pureaudio="{{pureAudio}}" debug="{{debug}}" muted="{{muted}}" beauty="{{beauty}}" template="float" bindRoomEvent="onRoomEvent">
    <!-- 主播推流界面上叠加的操作按钮 -->
    <cover-view slot="caster" style='height:100%;width:100%'>
      <cover-view class="operate">
        <cover-view class='img-box'>
          <cover-image class='img-view' src='/pages/Resources/camera.png' bindtap="changeCamera"></cover-image>
        </cover-view>
        <cover-view class='img-box'>
          <cover-image class='img-view' src='/pages/Resources/{{beauty > 0? "beauty" : "beauty-dis"}}.png' bindtap="setBeauty"></cover-image>
        </cover-view>
        <cover-view class='img-box'>
          <cover-image class='img-view' src='/pages/Resources/{{debug? "log" : "log2"}}.png' bindtap="showLog"></cover-image>
        </cover-view>
      </cover-view>
      <cover-image class='close' style="top:{{(headerHeight + statusBarHeight) - 26}}rpx" src="/pages/Resources/back.png" bindtap="onBack"></cover-image>
    </cover-view>

    <!-- 观众播放界面上叠加的操作按钮 -->
    <cover-view slot="audience" style='height:100%;width:100%'>
      <cover-view class="operate">
        <cover-view wx:if="{{linked}}" class='img-box'>
          <cover-image class='img-view' src='/pages/Resources/camera.png' bindtap="changeCamera"></cover-image>
        </cover-view>
        <cover-view wx:if="{{linked}}" class='img-box'>
          <cover-image class='img-view' src='/pages/Resources/{{beauty > 0? "beauty" : "beauty-dis"}}.png' bindtap="setBeauty"></cover-image>
        </cover-view>
        <cover-view wx:if="{{!linked}}" class='img-box'>
          <cover-image class='img-view' src='/pages/Resources/video-call.png' bindtap="onLinkClick"></cover-image>
        </cover-view>
        <cover-view class='img-box'>
          <cover-image class='img-view' src='/pages/Resources/{{debug? "log" : "log2"}}.png' bindtap="showLog"></cover-image>
        </cover-view>
      </cover-view>
      <cover-image wx:if="{{phoneNum}}" class='center' src="/pages/Resources/{{phoneNum}}.png"></cover-image>
      <cover-image class='close' style="top:{{(headerHeight + statusBarHeight) - 26}}rpx" src="/pages/Resources/back.png" bindtap="onBack"></cover-image>
    </cover-view>
  </mlvb-live-room>
</view>
```


## webrtc-room组件
### 属性

| 属性      | 类型    | 默认值           | 说明       |
|:---------:|:---------:|:---------:|--------------|
| template  | String  | '' | 必要，标识组件使用的界面模版，可选值有'float', 'grid', '1u3d' |
| sdkAppID    | String  | '' | 必要，开通IM服务所获取到的AppID       |
| userID     | String  | ''  |必要，用户ID |
| userSig    | String  | '' | 必要，身份签名，相当于登录密码的作用    |
| roomID    | Number  | '' | 必要，房间号                           |
| privateMapKey    | String  | '' | 必要，房间权限key，相当于进入指定房间roomID的钥匙      |
| beauty    | Number  | 5 | 美颜，取值范围 0-9 ，0 表示关闭  |
| muted     | Boolean | false | 可选，是否静音    |
| debug     | Boolean | false | 可选，是否打开log   |
| enableIM     | Boolean | false | 可选，是否启用IM   |

### 接口

| 函数名                                          | 说明         |
|-------------------------------------------------|--------------|
| start()                                         | 启动     |
| pause()                                       | 暂停     |
| resume()                                     | 恢复    |
| stop()                                          | 停止     |
| switchCamera()                           | 切换摄像头   |

### 叠加图标的实现

webrtc-room组件提供两个<slot> 节点，用于承载组件引用时提供的子节点。slot名分别为grid（四宫格布局），float（嵌套布局）。
设置两个slot的原因是为了解决选择布局跟默认布局float不一致，导致子节点失效的问题。
```js
<view class="container-box">
  <view class="camera-box">
    <webrtc-room id="webrtcroom" template="{{template}}" autoplay="{{autoplay}}" enableCamera="{{enableCamera}}" roomID="{{roomID}}" roomName="{{roomName}}" userID="{{userID}}" roomCreator="{{roomCreator}}" userSig="{{userSig}}" sdkAppID="{{sdkAppID}}" accountType="{{accountType}}"
      privateMapKey="{{privateMapKey}}" beauty="{{beauty}}" muted="{{muted}}" debug="{{debug}}" bindRoomEvent="onRoomEvent" bindIMEvent="onIMEvent" enableIM="true">
      <cover-view wx:if="{{template == 'grid'}}" slot="grid" style='height:100%;width:100%;position: absolute;'>
        <cover-view class="operate">
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/camera{{frontCamera?"":"-gray"}}.png' bindtap="changeCamera"></cover-image>
          </cover-view>
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/{{beauty > 0? "beauty" : "beauty-dis"}}.png' bindtap="setBeauty"></cover-image>
          </cover-view>
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/{{muted ? "mic-dis" : "mic"}}.png' bindtap="changeMute"></cover-image>
          </cover-view>
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/{{debug? "log" : "log2"}}.png' bindtap="showLog"></cover-image>
          </cover-view>
        </cover-view>
        <cover-image class='close' style="top:{{(headerHeight + statusBarHeight) - 26}}rpx" src="/pages/Resources/back.png" bindtap="onBack"></cover-image>
      </cover-view>
      <cover-view wx:elif="{{template == 'float'}}" slot="float" style='height:100%;width:100%;position: absolute;'>
        <cover-view class="operate">
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/camera{{frontCamera?"":"-gray"}}.png' bindtap="changeCamera"></cover-image>
          </cover-view>
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/{{beauty > 0? "beauty" : "beauty-dis"}}.png' bindtap="setBeauty"></cover-image>
          </cover-view>
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/{{muted ? "mic-dis" : "mic"}}.png' bindtap="changeMute"></cover-image>
          </cover-view>
          <cover-view class='img-box'>
            <cover-image class='img-view' src='/pages/Resources/{{debug? "log" : "log2"}}.png' bindtap="showLog"></cover-image>
          </cover-view>
        </cover-view>
        <cover-image class='close' style="top:{{(headerHeight + statusBarHeight) - 26}}rpx" src="/pages/Resources/back.png" bindtap="onBack"></cover-image>
      </cover-view>
    </webrtc-room>
  </view>
</view>
```

> 注意：
> - demo设置了全屏，在一些页面上有设置margin-top为标题栏高度。如果您不需要全屏，去掉`app.json`中的`"navigationStyle": "custom"`，然后在`app.js`中注释掉下面代码；同时修改每个页面的标题，去掉返回按钮。
    ```js
    this.globalData.headerHeight = headHeight;
    this.globalData.statusBarHeight = statusBarHeight;
    ```
