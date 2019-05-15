const CONSTANT = {
  IM: {
    LOGIN_EVENT: 'login_event', // 登录事件
    JOIN_GROUP_EVENT: 'join_group_event', // 创建|加入群组事件
    CONNECTION_EVENT: 'connection_event', // 连接状态事件
    BIG_GROUP_MSG_NOTIFY: 'big_group_msg_notify', // 大群消息通知
    MSG_NOTIFY: 'msg_notify', // 普通群消息
    GROUP_SYSTEM_NOTIFYS: 'group_system_notifys', // 监听（多终端同步）群系统消息事件，必填
    GROUP_INFO_CHANGE_NOTIFY: 'group_info_change_notify', // 监听群资料变化事件，选填
  },

  ROOM: {
    ERROR_OPEN_CAMERA: -4, //打开摄像头失败
    ERROR_OPEN_MIC: -5, //打开麦克风失败
    ERROR_PUSH_DISCONNECT: -6, //推流连接断开
    ERROR_CAMERA_MIC_PERMISSION: -7, //获取不到摄像头或者麦克风权限
    ERROR_EXCEEDS_THE_MAX_MEMBER: -8, // 超过最大成员数
    ERROR_REQUEST_ROOM_SIG: -9, // 获取房间SIG错误
    ERROR_JOIN_ROOM: -10, // 进房失败
    ERROR_CHECK_WHITELIST: -11,


    SUCC_PUSH: 10,
    SUCC_JOIN_ROOM: 11,
    SUCC_MEMBERS_LIST: 12,

    NETWORK_CHANGE: 13,
    PUSH_PLAY_LOADING: 14,
    PUSH_PLAY_PLAY: 15
  }
}

module.exports = CONSTANT;