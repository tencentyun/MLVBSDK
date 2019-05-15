var imHandler = require('./im_handler.js')
var webim = require('../../../utils/webim_wx')
const tic = require('../tic')
const config = require('../config');
const CONSTANT = require('./Constants');

Page({
  /**
   * 页面的初始数据
   */
  data: {
    webrtcroomComponent: null,
    beauty: 9,
    muted: false,
    debug: false,
    frontCamera: true,
    userID: '',
    userSig: '',
    sdkAppID: '',
    accountType: null,
    roomCreator: '',
    toview: null,

    roomID: '',
    roomName: '',
    teacherId: '',
    enableWebRTCIM: false,
    enableIM: false,
    heartTask: null,
    msgList: [],
    useCloud: true, //  切换为云上

    items: [
      { value: 'ppt', title: 'PPT' },
      { value: 'chat', title: '聊天室' },
    ],
    currentTab: 'ppt',
  },

  radioChange: function (e) {
    this.setData({
      currentTab: e.detail.value
    });
  },

  /**
   * 监听房间事件
   */
  onRoomEvent: function (e) {
    var self = this;
    switch (e.detail.tag) {
      case 'error':
        if (this.data.isErrorModalShow) {
          return;
        }
        if (e.detail.code === -10) { // 进房失败，一般为网络切换的过程中
          this.data.isErrorModalShow = true;
          wx.showModal({
            title: '提示',
            content: e.detail.detail,
            confirmText: '重试',
            cancelText: '退出',
            success: function (res) {
              self.data.isErrorModalShow = false
              if (res.confirm) {
                self.joinRoom();
              } else if (res.cancel) { //
                self.goBack();
              }
            }
          });
        } else {
          // 在房间内部才显示提示
          console.error("error:", e.detail.detail);
          var pages = getCurrentPages();
          console.log(pages, pages.length, pages[pages.length - 1].__route__);
          if (pages.length > 1 && (pages[pages.length - 1].__route__ == 'pages/tencent-tic-demo/classroom/room')) {
            this.data.isErrorModalShow = true;
            wx.showModal({
              title: '提示',
              content: e.detail.detail,
              showCancel: false,
              complete: function () {
                self.data.isErrorModalShow = false
                pages = getCurrentPages();
                if (pages.length > 1 && (pages[pages.length - 1].__route__ == 'pages/tencent-tic-demo/classroom/room')) {
                  wx.showToast({
                    title: `code:${e.detail.code} content:${e.detail.detail}`
                  });
                  wx.navigateBack({
                    delta: 1
                  });
                }
              }
            });
          }
        }
        break;
    }
  },

  /**
   * 返回上一页
   */
  goBack() {
    var pages = getCurrentPages();
    if (pages.length > 1 && (pages[pages.length - 1].__route__ == 'pages/tencent-tic-demo/classroom/room')) {
      wx.navigateBack({
        delta: 1
      });
    }
  },


  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    this.data.webrtcroomComponent = this.selectComponent('#webrtcroom');

    this.data.roomID = options.roomID || '';
    this.data.roomName = options.roomName;
    this.data.teacherId = options.teacherId;

    this.setData({
      roomCreator: options.teacherId
    });

    this.data.sdkAppID = config.sdkAppID;
    this.data.userID = config.userID;
    this.data.userSig = config.userSig;
    this.data.accountType = config.accountType;

    // 初始化IM事件监听
    imHandler.initLoginListeners(this.imLoginListener());
    this.loginIm();
  },

  loginIm() {
    imHandler.loginIm({
      'sdkAppID': config.sdkAppID, //用户所属应用id,必填
      'appIDAt3rd': config.sdkAppID, //用户所属应用id，必填
      'accountType': config.accountType, //用户所属应用帐号类型，必填
      'identifier': config.userID, //当前用户ID,必须是否字符串类型，选填
      'identifierNick': config.nickName || config.userID, //当前用户昵称，选填
      'userSig': config.userSig
    }, () => {
      this.joinClassRoom();
    }, error => {
      this.showErrorToast('IM登录失败', error);
    });
  },

  /**
   * 加入课堂
   */
  joinClassRoom() {
    // 房间号
    tic.joinClassRoom(this.data.roomID).then(res => {
      this.data.chatGroupId = res.data.chat_group_id;
      this.data.boardGroupId = res.data.board_group_id;
      this.data.memberCount = res.data.member_count;

      this.reportJoinClassRomm();
      this.startWebRTC();
      this.initBoard();
    }, error => {
      this.showErrorToast('加入课堂失败', error);
    });
  },

  // 上报进房成功
  reportJoinClassRomm() {
    tic.reportJoinClassRomm(this.data.roomID).then(res => {
      this.data.heartTask = setInterval(() => {
        tic.sendHeartBeat(this.data.roomID);
      }, 5000);
    }, error => {
      this.showErrorToast('上报进入课堂失败', error);
    });
  },

  /**
   * 开始WebRTC
   */
  startWebRTC() {
    // 设置webrtc-room标签中所需参数，并启动webrtc-room标签
    tic.getPrivateMapKey(this.data.roomID).then(res => {
      this.setData({
        userID: this.data.userID,
        userSig: this.data.userSig,
        sdkAppID: this.data.sdkAppID,
        accountType: this.data.accountType,
        roomID: this.data.roomID,
        privateMapKey: res.data.privMapEncrypt
      }, () => {
        this.data.webrtcroomComponent.start();
      });

    }, error => {
      this.showErrorToast('获取privateMapKey错误', error);
    });
  },


  initBoard() {
    var boardComponent = this.selectComponent('#tx_board');
    boardComponent.start({
      identifier: this.data.userID,
      userSig: this.data.userSig,
      sdkAppId: this.data.sdkAppID,
      accountType: this.data.accountType,
      roomID: this.data.roomID
    });
  },

  // IM登录监听
  imLoginListener() {
    var self = this;
    return {
      // 用于监听用户连接状态变化的函数，选填
      onConnNotify(resp) {
        console.log('用户连接状态变化');
      },

      // 监听新消息(直播聊天室)事件，直播场景下必填
      onBigGroupMsgNotify(msgs) {
        console.log('onBigGroupMsgNotify');
      },

      // 监听新消息函数，必填
      onMsgNotify(msgs) {
        // 解析每一个msg对象
        msgs.forEach((msg) => {
          var subType = msg.getSubType();
          var fromAccount = msg.fromAccount || '';
          var fromAccountNick = msg.fromAccountNick || fromAccount;

          if (msg.elems && msg.elems instanceof Array) { // 保证elems是数组
            var elems = msg.elems;
            elems.forEach((elem) => {
              if (elem.type == 'TIMTextElem') {
                self.setData({
                  msgList: self.data.msgList.concat([{
                    type: 'msg',
                    from: fromAccount,
                    content: elem.content.text
                  }])
                });

                self.setData({
                  toview: 'scroll-bottom' // 滚动条置底
                });

              } else if (elem.type == 'TIMCustomElem') {
                var type = elem.content.ext;
                if (type == 'TXWhiteBoardExt') {
                  if (msg.fromAccount == self.data.userID)
                    return;
                  var boardComponent = self.selectComponent('#tx_board');
                  boardComponent && boardComponent.addBoardData(JSON.parse(elem.content.data));
                }
              } else if (elem.type == 'TIMFileElem') {
                axios.get(elem.content.downUrl).then(function (response) {
                  self.paint && self.paint.addData(response.data);
                  boardComponent && boardComponent.addBoardData(response.data);
                })
              }
            });
          }
        });
      },

      // 系统消息
      onGroupSystemNotifys: {
        "255": (res) => {
          var data = JSON.parse(res.UserDefinedField);
          if (data.sub_cmd == 'member_join_notify') {
            var member = data.member;
            self.setData({
              msgList: self.data.msgList.concat({
                type: 'admin',
                from: 'admin',
                content: member.nick + '加入了房间'
              })
            });
            self.setData({
              toview: 'scroll-bottom' // 滚动条置底
            });
          } else if (data.sub_cmd == 'member_quit_notify') {
            var member = data.member;
            self.setData({
              msgList: self.data.msgList.concat({
                type: 'admin',
                from: 'admin',
                content: member.nick + '离开了房间'
              })
            });
            self.setData({
              toview: 'scroll-bottom' // 滚动条置底
            });
          } else if (data.sub_cmd == 'modify_member_info_notify') {
            data.modify_infos.forEach(function (member) {
              if (member.status == 0) {
                self.setData({
                  msgList: self.data.msgList.concat({
                    type: 'admin',
                    from: 'admin',
                    content: member.nick + '离开了房间'
                  })
                });
                self.setData({
                  toview: 'scroll-bottom' // 滚动条置底
                });
              }
            })
          } else if (data.sub_cmd == 'destroy_notify') {
            console.log('课程销毁');
          } else if (data.sub_cmd == 'invite_interact_notify') {
            console.log('收到老师请求');
          } else if (data.sub_cmd == 'apply_permission_notify') {
            console.log('收到学生请求');

          } else if (data.sub_cmd == 'grant_permission_notify') {

          } else if (data.sub_cmd == 'modify_conf_info_notify') {

          }
        } //用户自定义通知(默认全员接收)
      },

      // 被踢下线
      onKickedEventCall() {
        this.showErrorToast('被踢下线');
      }
    }
  },


  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function () {
    // 设置房间标题
    wx.setNavigationBarTitle({
      title: this.data.roomName
    });
  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {
    var self = this;
    // 保持屏幕常亮
    wx.setKeepScreenOn({
      keepScreenOn: true
    })
  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {
    clearInterval(this.data.heartTask);
    imHandler.logout();
    console.log('room.js onUnload');
  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function () {
    return {
      // title: '',
      path: '/pages/main/main',
      imageUrl: 'https://mc.qcloudimg.com/static/img/dacf9205fe088ec2fef6f0b781c92510/share.png'
    }
  },

  // IM输入框的信息
  bindInputMsg: function (e) {
    this.data.inputMsg = e.detail.value;
  },

  // 发送IM消息
  sendComment: function () {
    var msg = this.data.inputMsg || '';
    if (!msg || !msg.trim()) {
      this.showErrorToast('不能发送空消息');
      return;
    }
    imHandler.sendGroupTextMsg(msg, this.data.chatGroupId, () => {
      console.log('消息发送成功');
      // 发送成功
      this.setData({
        inputMsg: ''
      });
    }, (error) => {
      this.showErrorToast('消息发送失败', error);
    });
  },

  showErrorToast(msg, error) {
    wx.showToast({
      icon: 'none',
      title: msg
    });
    console.error('Error msg:', error || msg);
  },

  /**
   * 切换摄像头
   */
  changeCamera: function () {
    this.data.webrtcroomComponent.switchCamera();
    this.setData({
      frontCamera: !this.data.frontCamera
    })
  },

  /**
   * 设置美颜
   */
  setBeauty: function () {
    this.data.beauty = (this.data.beauty == 0 ? 9 : 0);
    this.setData({
      beauty: this.data.beauty
    });
  },

  /**
   * 切换是否静音
   */
  changeMute: function () {
    this.data.muted = !this.data.muted;
    this.setData({
      muted: this.data.muted
    });
  },

  /**
   * 是否显示日志
   */
  showLog: function () {
    this.data.debug = !this.data.debug;
    this.setData({
      debug: this.data.debug
    });
  }
})