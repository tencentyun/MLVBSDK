// pages/push/push.js
const app = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    frontCamera: true,
    cameraContext: {},
    pushUrl: "",
    mode: "SD",
    muted: false,
    enableCamera: true,
    orientation: "vertical",
    beauty: 6.3,
    whiteness: 3.0,
    backgroundMute: false,
    debug: false,
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
  },
  onSwitchCameraClick: function () {
    this.data.frontCamera = !this.data.frontCamera;
    this.setData({
      frontCamera: this.data.frontCamera
    })
    this.data.cameraContext.switchCamera();
  },
  onBeautyClick: function () {
    if (this.data.beauty != 0) {
      this.data.beauty = 0;
      this.data.whiteness = 0;
    } else {
      this.data.beauty = 6.3;
      this.data.whiteness = 3.0;
    }

    this.setData({
      beauty: this.data.beauty,
      whiteness: this.data.whiteness
    })
  },
  onLogClick: function () {
    this.setData({
      debug: !this.data.debug
    })
  },
  onMuteClick: function () {
    this.setData({
      muted: !this.data.muted
    })
  },
  onPushEvent: function (e) {
    console.log(e.detail.code);

    if (e.detail.code == -1307) {
      this.stop();
      wx.showToast({
        title: '推流多次失败',
      })
    }
  },

  stop: function () {
    this.setData({
      playing: false,
      pushUrl: "",
      mode: "SD",
      muted: false,
      enableCamera: true,
      orientation: "vertical",
      beauty: 6.3,
      whiteness: 3.0,
      backgroundMute: false,
      debug: false
    })
    this.data.cameraContext.stop();
  },

  createContext: function () {
    var self = this;
    this.setData({
      cameraContext: wx.createLivePusherContext('camera-push'),
    } , () => {
      self.data.cameraContext.start();
    })
  },
  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    console.log("onLoad");
    this.setData({
      mode: options.mode,
      orientation: options.orientation,
      enableCamera: options.enableCamera === "false" ? false : true,
      pushUrl: decodeURIComponent(options.pushUrl),
    });
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function () {
    console.log("onLoad onReady");
    this.createContext();

    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {
    console.log("onLoad onShow");
    // 保持屏幕常亮
    wx.setKeepScreenOn({
      keepScreenOn: true
    })
  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function () {
    console.log("onLoad onHide");

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {
    console.log("onLoad onUnload");
    this.stop();

    wx.setKeepScreenOn({
      keepScreenOn: false,
    })
  },


  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function () {
    console.log("onLoad onShareAppMessage");
    return {
      // title: 'RTMP推流',
      // path: '/pages/push/push',
      path: '/pages/home-page/main',
      imageUrl: 'https://mc.qcloudimg.com/static/img/dacf9205fe088ec2fef6f0b781c92510/share.png'
    }
  },
  onBack: function () {
    wx.navigateBack({
      delta: 1
    });
  }
})