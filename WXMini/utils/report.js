/**
 * 连通上报js
 */
var str_appid = 1252463788,
    str_platform = 'weixin',
    str_appversion = '1.2.477',
    str_sdkversion = '',
    str_common_version = '',
    str_nickname = '',
    str_device = '',
    str_device_type = '',
    reportData = {
      str_roomid: '',
      str_room_creator: '',
      str_userid: '',
      str_play_info: '',
      str_push_info: '',
      int64_ts_enter_room: -99999,
      int64_tc_join_group: -99999,
      int64_tc_get_pushers: -99999,
      int64_tc_play_stream: -99999,
      int64_tc_get_pushurl: -99999,
      int64_tc_push_stream: -99999,
      int64_tc_add_pusher: -99999,
      int64_tc_enter_room: -99999
    },
    streamData = {
      int64_ts_add_pusher: 0,
      int64_ts_play_stream: 0
    }

// 获取用户信息
wx.getUserInfo({
  withCredentials: false,
  success: function (ret) {
    str_nickname = ret.userInfo.nickName;
  }
});
// 获取设备信息
var systemInfo = wx.getSystemInfoSync();
str_sdkversion = systemInfo.version;
str_common_version = systemInfo.SDKVersion;
str_device = systemInfo.model;
str_device_type = systemInfo.system;


/**
 * 设置参数
 */
function setReportData(options) {
  // 第一次进来重置数据
  if (options.int64_ts_enter_room) {
    console.log('第一次进来重置数据');
    clearData();
  }
  for(var item in reportData) {
    if(options[item]) {
      reportData[item] = options[item];
    }
  }
  for (var item in streamData) {
    if (options[item]) {
      streamData[item] = options[item];
    }
  }
  // console.warn('上报数据: ', reportData, streamData);
  // 连通率上报前做负值判断
  for (var item in reportData) {
    if (!isNaN(reportData[item]) && item != 'int64_tc_enter_room' && reportData[item] < 0)
      return;
  } 
  if (streamData.int64_ts_add_pusher && streamData.int64_ts_play_stream) {
    reportData.int64_tc_enter_room = Math.max(streamData.int64_ts_add_pusher, streamData.int64_ts_play_stream) - reportData.int64_ts_enter_room;
    // 上报：只对进房进行上报
    // console.log('走完所有流程上报');
    reportData.str_room_creator && reportData.str_userid && reportData.str_room_creator != reportData.str_userid && report();
  }
}

/**
 * 上报cgi
 */
function report() {
  // 有房间id与用户id才上报
  if (!reportData.str_roomid || !reportData.str_userid) {
    clearData();
    return;
  }
  // 创建房间不加入上报
  if (reportData.str_room_creator == reportData.str_userid) {
    clearData();
    return;
  } 
  var data = reportData;
  data.str_appid = str_appid;
  data.str_platform = str_platform;
  data.str_appversion = str_appversion;
  data.str_sdkversion = str_sdkversion;
  data.str_common_version = str_common_version;
  data.str_nickname = str_nickname;
  data.str_device = str_device;
  data.str_device_type = str_device_type;
  console.log('真正上报数据: ', data);
  wx.request({
    url: 'https://roomtest.qcloud.com/weapp/utils/report',
    data: {
      reportID: 1,
      data: data
    },
    method: 'POST',
    header: {
      'content-type': 'application/json' // 默认值
    },
    success: function (ret) { 
      if(ret.data.code) {
        console.log('上报失败：' + ret.data.code + ret.data.message);
      } else {
        console.log('上报成功');
      }
    },
    fail: function () { console.log('report error') },
    complete: function () {}
  });
  clearData();
}

/**
 * 重置参数
 */
function clearData() {
  reportData = {
    str_roomid: '',
    str_room_creator: '',
    str_userid: '',
    str_play_info: '',
    str_push_info: '',
    int64_ts_enter_room: -99999,
    int64_tc_join_group: -99999,
    int64_tc_get_pushers: -99999,
    int64_tc_play_stream: -99999,
    int64_tc_get_pushurl: -99999,
    int64_tc_push_stream: -99999,
    int64_tc_add_pusher: -99999,
    int64_tc_enter_room: -99999
  };
  streamData = {
    int64_ts_add_pusher: 0,
    int64_ts_play_stream: 0
  };
}

/**
 * 对外暴露函数
 * @type {Object}
 */
module.exports = {
  setReportData: setReportData,
  report: report,
  clearData: clearData
}