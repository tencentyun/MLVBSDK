/**
 * 小程序配置文件
 */
var config = {
  //客户业务后台请求域名
  serverUrl: 'https://room.qcloud.com',
  //腾讯云RoomService后台请求域名，视频通话（RTCRoom）使用此地址
  roomServiceUrl: 'https://room.qcloud.com',
  //腾讯云新RoomService后台请求域名，移动直播（MLVBLiveRoom）使用此地址
  newRoomServiceUrl: "https://liveroom.qcloud.com",
  webrtcServerUrl: 'https://xzb.qcloud.com/webrtc/weapp/webrtc_room'
}

module.exports = config;