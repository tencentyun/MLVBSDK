const CONSTANT = {
  IM: {
    LOGIN_EVENT: 'login_event', // 登录事件
    JOIN_GROUP_EVENT: 'join_group_event', // 创建|加入群组事件
    CONNECTION_EVENT: 'connection_event', // 连接状态事件
    BIG_GROUP_MSG_NOTIFY: 'big_group_msg_notify', // 大群消息通知
    MSG_NOTIFY: 'msg_notify', // 普通群消息
    GROUP_SYSTEM_NOTIFYS: 'group_system_notifys', // 监听（多终端同步）群系统消息事件，必填
    GROUP_INFO_CHANGE_NOTIFY: 'group_info_change_notify', // 监听群资料变化事件，选填
    KICKED: 'kicked' // 被踢下线
  },

  ROOM: {
    ERROR_OPEN_CAMERA: -4, //打开摄像头失败
    ERROR_OPEN_MIC: -5, //打开麦克风失败
    ERROR_PUSH_DISCONNECT: -6, //推流连接断开
    ERROR_CAMERA_MIC_PERMISSION: -7, //获取不到摄像头或者麦克风权限
    ERROR_EXCEEDS_THE_MAX_MEMBER: -8, // 超过最大成员数
    ERROR_REQUEST_ROOM_SIG: -9, // 获取房间SIG错误
    ERROR_JOIN_ROOM: -10, // 进房失败
    ERROR_CHECK_WHITELIST: -11, // 检测白名单失败


    SUCC_PUSH: 10, // 成功推流
    SUCC_JOIN_ROOM: 11, // 进房成功
    SUCC_MEMBERS_LIST: 12, // 成员列表更新

    NETWORK_CHANGE: 13, //网络变化
    PUSHER_LOADING: 14, // 推流端画面loading中
    PUSHER_PLAY: 15, // 推流端画面开始播放

    PLAYER_LOADING: 16, // 对端画面loading
    PLAYER_PLAY: 17, // 对端画面开始播放
    PLAYER_DISCONNECT: 18, // 对端断开

    // 正常退房
    EXIT_ROOM: 19
  }
}

module.exports = CONSTANT;