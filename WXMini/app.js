//app.js

var qcloud = require('./lib/index');

App({
  onLaunch: function (options) {
    // 展示本地存储能力
    // qcloud.setLoginUrl(config.url + 'getwxinfo');
    // qcloud.setLoginUrl(config.url + 'login');
    const { model, system, statusBarHeight } = wx.getSystemInfoSync();
    var headHeight;
    if (/iphone\s{0,}x/i.test(model)) {
      headHeight = 88;
    } else if (system.indexOf('Android') !== -1) {
      headHeight = 68;
    } else {
      headHeight = 64;
    }
    this.globalData.headerHeight = headHeight;
    this.globalData.statusBarHeight = statusBarHeight;
  },
  globalData: {
    userInfo: null,
    headerHeight : 0,
    statusBarHeight : 0
  }
})