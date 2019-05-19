/**
 * 获取登录信息
 */
var liveroom = require('../../components/mlvb-live-room/mlvbliveroom.js');

//客户业务后台请求域名，用于获取IM信息
var GetTestLoginInfoUrl = "https://room.qcloud.com";

// 获取微信登录信息，用于获取openid
function getLoginInfo(options) {
  wx.login({
    success: function (res) {
      if (res.code) {
        console.log('获取code成功',res.code);
        options.code = res.code;
        proto_getLoginInfo(options);
        // 获取用户信息,该接口微信有调整，如果需要使用，请查看https://developers.weixin.qq.com/miniprogram/dev/api/open.html
        // wx.getUserInfo({
        //   withCredentials: false,
        //   success: function (ret) {
        //     options.userName = ret.userInfo.nickName;
        //   },
        //   fail: function() {
        //     proto_getLoginInfo(options);
        //   }
        // });
      } else {
        console.log('获取用户登录态失败！' + res.errMsg);
        options.fail && options.fail({
          errCode: -1,
          errMsg: '获取用户登录态失败，请退出重试'
        });
      }
    },
    fail: function () {
      console.log('获取用户登录态失败！' + res.errMsg);
      if (ret.errMsg == 'request:fail timeout') {
        var errCode = -1;
        var errMsg = '网络请求超时，请检查网络状态';
      }
      options.fail && options.fail({
        errCode: errCode || -1,
        errMsg: errMsg || '获取用户登录态失败，请退出重试'
      });
    }
  });
}

// 调用后台获取登录信息接口
function proto_getLoginInfo(options) {
  wx.request({
    url: GetTestLoginInfoUrl + '/weapp/utils/get_login_info',
    data: { userIDPrefix: 'weixin', code: options.code },
    method: 'GET',
    header: {
      'content-type': 'application/json' // 默认值
    },
    success: function (ret) {
      if (ret.data.code) {
        console.log('获取登录信息失败，调试期间请点击右上角三个点按钮，选择打开调试');
        options.fail && options.fail({
          errCode: ret.data.code,
          errMsg: ret.data.message + '[' + ret.data.code + ']'
        });
        return;
      }
      console.log('获取IM登录信息成功: ', ret.data);
      ret.data.userName = options.userName;
      liveroom.login({
        data: ret.data,
        success: options.success,
        fail: options.fail
      });
    },
    fail: function (ret) {
      console.log('获取IM登录信息失败: ', ret);
      if (ret.errMsg == 'request:fail timeout') {
        var errCode = -1;
        var errMsg = '网络请求超时，请检查网络状态';
      }
      options.fail && options.fail({
        errCode: errCode || -1,
        errMsg: errMsg || '获取登录信息失败，调试期间请点击右上角三个点按钮，选择打开调试'
      });
    }
  });
}

module.exports = {
  getLoginInfo: getLoginInfo
};