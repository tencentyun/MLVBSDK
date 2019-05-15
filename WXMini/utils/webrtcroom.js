var config = require('../config.js');

var webrtcroom = {
  serverDomain: config.webrtcServerUrl,
  requestNum: 0,
  heart: '', // 判断心跳变量
  heartBeatReq: null,
  requestSeq: 0, // 请求id
  requestTask: [], // 请求task

  /**
   * [request 封装request请求]
   * @param {options}
   *   url: 请求接口url
   *   data: 请求参数
   *   success: 成功回调
   *   fail: 失败回调
   *   complete: 完成回调
   */
  request: function (options) {
    var self = this;
    self.requestNum++;
    var req = wx.request({
      url: self.serverDomain + options.url,
      data: options.data || {},
      method: 'POST',
      header: {
        'content-type': 'application/json' // 默认值
      },
      // dataType: 'json',
      success: function (res) {
        if (res.data.code) {
          console.error('服务器请求失败' + ', url=' + options.url + ', params = ' + (options.data ? JSON.stringify(options.data) : '') + ', 错误信息=' + JSON.stringify(res));
          options.fail && options.fail({
            errCode: res.data.code,
            errMsg: res.data.message
          })
          return;
        }
        options.success && options.success(res);
      },
      fail: function (res) {
        console.error('请求失败' + ', url=' + options.url + ', 错误信息=' + JSON.stringify(res));
        options.fail && options.fail(res);
      },
      complete: options.complete || function () {
        self.requestNum--;
        // console.log('complete requestNum: ',requestNum);
      }
    });
    self.requestTask[self.requestSeq++] = req;
    return req;
  },

  /**
   * [clearRequest 中断请求]
   * @param {options}
   */
  clearRequest: function () {
    var self = this;
    for (var i = 0; i < self.requestSeq; i++) {
      self.requestTask[i].abort();
    }
    self.requestTask = [];
    self.requestSeq = 0;
  },


  getLoginInfo: function (userID, success, fail) {
    var self = this;
    var data = {};
    if (userID) {
      data.userID = userID;
    }
    self.request({
      url: '/get_login_info',
      data: data,
      success: success,
      fail: fail
    })
  },

  getRoomList: function (index, count, success, fail) {
    var self = this;
    self.request({
      url: '/get_room_list',
      data: {
        index: index,
        count: count,
        roomType: 'trtc'
      },
      success: success,
      fail: fail
    })
  },

  createRoom: function (userID, roomInfo, success, fail) {
    var self = this;
    self.request({
      url: '/create_room',
      data: {
        userID: userID,
        roomInfo: roomInfo,
        roomType: 'trtc'
      },
      
      success: function (res) {
        success && success(res);
      },

      fail: fail
    });
  },

  enterRoom: function (userID, roomID, success, fail) {
    var self = this;
    self.request({
      url: '/enter_room',
      data: {
        userID: userID,
        roomID: roomID
      },
      success: function (res) {
        success && success(res);
      },
      fail: fail
    })
  },

  quitRoom: function (userID, roomID, success, fail) {
    var self = this;
    self.request({
      url: '/quit_room',
      data: {
        userID: userID,
        roomID: roomID
      },
      success: success,
      fail: fail
    });
    self.stopHeartBeat();
  },

  startHeartBeat: function (userID, roomID, success, fail) {
    var self = this;
    self.heart = '1';
    self.heartBeat(userID, roomID, success, fail);
  },

  stopHeartBeat: function () {
    var self = this;
    self.heart = '';
    if (self.heartBeatReq) {
      self.heartBeatReq.abort();
      self.heartBeatReq = null;
    }
  },

  heartBeat: function (userID, roomID, success, fail) {
    var self = this;
    if (!self.heart) {
      self.clearRequest();
      return;
    }
    self.heartBeatReq = self.request({
      url: '/heartbeat',
      data: {
        userID: userID,
        roomID: roomID
      },
      success: function (res) {
        if (self.heart) {
          console.log('心跳成功');
          success && success(res);
          setTimeout(() => {
            self.heartBeat(userID, roomID, success, fail);
          }, 7000);
        }
      },
      fail: function (res) {
        fail && fail(res);
        if (self.heart) {
          setTimeout(() => {
            self.heartBeat(userID, roomID, success, fail);
          }, 7000);
        }
      }
    })
  }
}

module.exports = webrtcroom