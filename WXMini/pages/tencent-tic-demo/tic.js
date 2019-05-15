const config = require('./config');

function TICDataUtil() {}

TICDataUtil.prototype.register = function () {
  return this.requestLoading({
    "cmd": "open_account_svc",
    "sub_cmd": "register",
    "id": config.userID,
    "password": config.password
  });
}

TICDataUtil.prototype.login = function () {
  return this.requestLoading({
    "cmd": "open_account_svc",
    "sub_cmd": "verify",
    "id": config.userID,
    "password": config.password
  })
}

TICDataUtil.prototype.getRoomList = function () {
  return this.requestLoading({
    "cmd": "open_conf_svc",
    "sub_cmd": "get_conf_list"
  });
}

/**
 * 加入课堂
 * @param {*} roomId 
 */
TICDataUtil.prototype.joinClassRoom = function (roomId) {
  return this.requestLoading({
    "cmd": "open_conf_svc",
    "sub_cmd": "join_conf",
    "conf_id": roomId * 1,
    "nick": config.nickName
  });
}


/**
 * 上报课堂成功
 * @param {*} roomId 
 */
TICDataUtil.prototype.reportJoinClassRomm = function (roomId) {
  return this.requestLoading({
    "cmd": "open_conf_svc",
    "sub_cmd": "report_join_conf",
    "conf_id": roomId * 1,
    "local_timestamp": this.getTimeStamp()
  });
}

/**
 * 退出课堂
 */
TICDataUtil.prototype.quitClassRoom = function (roomId) {
  return this.request({
    "cmd": "open_conf_svc",
    "sub_cmd": "quit_conf",
    "conf_id": roomId * 1,
    "reason": ""
  });
}

/**
 * 获取课堂成员列表
 * @param {*} roomId 
 */
TICDataUtil.prototype.getClassMember = function (roomId) {
  return this.requestLoading({
    "cmd": "open_conf_svc",
    "sub_cmd": "get_member_list",
    "conf_id": roomId * 1,
    "local_timestamp": this.getTimeStamp()
  });
}


/**
 * 发送心跳包
 */
TICDataUtil.prototype.sendHeartBeat = function (roomId) {
  return this.request({
    "cmd": "open_conf_svc",
    "sub_cmd": "heart_beat",
    "conf_id": roomId * 1
  }, false);
}

// 时间戳
TICDataUtil.prototype.getTimeStamp = function () {
  var time = Date.now();
  return parseInt(time & 0xFFFFFFFF, 10);
}

TICDataUtil.prototype.requestLoading = function (data) {
  return this.request(data);
}

TICDataUtil.prototype.request = function (data, showLoading = true) {
  var url = config.serverUrl;
  wx.hideLoading();
  return new Promise((resolve, reject) => {
    if (showLoading) {
      wx.showLoading({
        title: '加载中',
      });
    }
    wx.request({
      method: 'POST',
      url: url + `?sdkappid=${config.sdkAppID}&user_token=${config.userToken}&identifier=${config.userID}`,
      header: {
        'content-type': 'application/json' // 默认值
      },
      data,
      success(res) {
        wx.hideLoading()
        resolve(res);
      },
      fail(error) {
        wx.hideLoading()
        reject(error);
      }
    })
  });
}

/**
 * 腾讯视频云Demo中的PrivateMapKey获取接口
 * 业务侧需要自己实现
 */
TICDataUtil.prototype.getPrivateMapKey = function (roomId) {
  var privateMapKeyUrl = config.privateMapKeyUrl;
  wx.hideLoading();
  return new Promise((resolve, reject) => {
    wx.showLoading({
      title: '加载中',
    });
    wx.request({
      method: 'POST',
      url: privateMapKeyUrl,
      header: {
        'content-type': 'application/json' // 默认值
      },
      data: {
        "identifier": config.userID,
        "pwd": "123", // 腾讯云DEMO接口鉴权密码
        "appid": config.sdkAppID,
        "accounttype": config.accountType,
        "roomnum": roomId * 1,
        "privMap": 255
      },
      success(res) {
        wx.hideLoading();
        if (res.data.errorCode) {
          reject(res.data);
        } else {
          resolve(res.data);
        }
      },
      fail(error) {
        wx.hideLoading()
        reject(error);
      }
    })
  });
}

module.exports = new TICDataUtil();