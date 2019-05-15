// components/board-component/board-component.js

const BoardSDK = require('./libs/board_mini_prog_sdk.mini.js');
const CONSTANT = require('./libs/Constant.js');

Component({
  /**
   * 组件的属性列表
   */
  properties: {
    identifier: {
      type: String,
      value: ''
    },

    userSig: {
      type: String,
      value: ''
    },

    sdkAppID: {
      type: Number,
      value: null
    },

    accountType: {
      type: Number,
      value: null
    },

    roomID: {
      type: Number,
      value: null
    },

    preStep: {
      type: Number,
      value: 2
    }

    //backgroundpicid:{
    //   type:object,
    //   value:null,
    //   observer:boardupdate
    // }
  },

  /**
   * 组件的初始数据
   */
  data: {
    board: null,
    //backgroundPic:null,//全部的背景图片url?如何及时更新，如何传出
    //currentBoard:0,//当前的白板
    //boardlist:null,
    currentPic: "", //预留图片链接
    imgLoadList: null, //预加载图片链接列表
    bgColor: '#ffffff'
  },

  ready() {

  },

  /**
   * 组件的方法列表
   */
  methods: {
    start(loginData) {
      wx.createSelectorQuery().in(this).select('.tic-board-box .tic_board_canvas').boundingClientRect((rect) => {
        this.init(loginData, rect.width, rect.height);
      }).exec();
    },
    init(loginData, width, height) {
      var canvasComponent = wx.createCanvasContext('tic_board_canvas', this);
      this.board = new BoardSDK({
        debug: false,
        conf_id: loginData.roomID,
        canDraw: false,
        color: '#0f0000',
        preStep: this.data.preStep, //预加载步数
        tlsData: {
          identifier: loginData.identifier,
          userSig: loginData.userSig,
          sdkAppId: loginData.sdkAppId
        },
        width,
        height,
        canvasComponent,
        context: this
      });

      /*监听draw发送的预加载列表和图像链接 */
      this.board.on("preload", (data) => {
        console.log("preload");
        this.setData({
          currentPic: data.currentPic,
          imgLoadList: data.preloadList
        });
        console.log(data.preloadList);
      });
    },

    /**
     * 图片加载完成
     * @param {*} ev 
     */
    imgOnLoad(ev) {
      let src = ev.currentTarget.dataset.src,
        width = ev.detail.width,
        height = ev.detail.height
      console.log('图片加载完成', ev);
    },

    // 图片加载失败
    imgOnLoadError(error) {
      console.log('图片加载失败', error);
    },

    addBoardData(data) {
      this.board.addData(data);
    },

    // 设置当前背景图片
    setCurrentImg(currentPic) {
      this.setData({
        currentPic
      });
    },

    // 设置预加载图片
    setPreLoadImgList(preloadList) {
      console.log(preloadList);
      this.setData({
        preloadList
      });
    },

    // 设置白板背景颜色
    setBoardBgColor(bgColor) {
      this.setData({
        bgColor
      });
    }
  }
})