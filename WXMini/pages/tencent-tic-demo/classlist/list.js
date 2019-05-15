// pages/tic/classlist/list.js
const tic = require('../tic');
const config = require('../config');
const app = getApp()

Page({

  /**
   * 页面的初始数据
   */
  data: {
    roomList: [],
    isLogin: false,
    headerHeight: app.globalData.headerHeight, //
    statusBarHeight: app.globalData.statusBarHeight,
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad: function (options) {
    var id = Math.round(Math.random() * 1000);
    var userId = 'mini_' + id;
    var password = '123456';
    var nickName = `昵称${id}`;
    config.setUserID(userId);
    config.setPassword(password);
    config.setNickName(nickName);
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady: function () {
    this.start();
  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function () {

  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide: function () {

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload: function () {

  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh: function () {
    if (this.data.isLogin) {
      this.getClassRoomList();
      wx.stopPullDownRefresh();
    }
  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function () {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage: function () {

  },

  createRoom() {
    wx.showModal({
      title: '提示',
      content: '请先通过PC端Chrome浏览器创建课堂，再小程序接入体验【https://sxb.qcloud.com/web-edu/index.html】',
      showCancel: false
    });
  },

  start() {
    this.register();
  },

  register() {
    tic.register().then(res => {
      this.login();
    }, error => {
      this.showErrorToast('注册失败', error);
    })
  },

  login() {
    tic.login().then(res => {
      config.setUserSig(res.data.user_sig);
      config.setUserToken(res.data.user_token);

      this.data.isLogin = true;

      this.getClassRoomList();
    }, error => {
      this.showErrorToast('登录失败', error);
    });
  },

  // 获取房间列表
  getClassRoomList() {
    this.setData({
      roomList: []
    }, () => {
      tic.getRoomList().then(res => {
        if (res.data.error_code) {
          this.showErrorToast('获取房间列表失败', res.data.error_msg);
        } else {
          this.setData({
            roomList: res.data.items
          });
        }
      }, error => {
        this.showErrorToast('获取房间列表失败', error);
      });
    })
  },

  // 加入课堂
  joinClassRoom(event) {
    var index = event.currentTarget.dataset.index;
    var room = this.data.roomList[index];
    var roomId = room.conf_id;
    wx.navigateTo({
      url: `../classroom/room?roomID=${roomId}&roomName=${room.conf_name}&teacherId=${room.owner}`
    });
  },

  showErrorToast(msg, error) {
    wx.showToast({
      icon: 'none',
      title: msg
    });
    console.error('Error msg:', error);
  },
  onBack: function () {
    wx.navigateBack({
      delta: 1
    });
  },
})