var wxTunnel = require('./wxTunnel');

/**
 * 当前打开的socket通道，同一时间只能有一个socket通道打开
 */
var currentSocketTunnel = null;

// 信道状态枚举
var STATUS_CLOSED = SocketTunnel.STATUS_CLOSED = 'CLOSED';
var STATUS_CONNECTING = SocketTunnel.STATUS_CONNECTING = 'CONNECTING';
var STATUS_ACTIVE = SocketTunnel.STATUS_ACTIVE = 'ACTIVE';

// 错误类型枚举
var ERR_CONNECT_SOCKET = SocketTunnel.ERR_CONNECT_SOCKET = 1002;
var ERR_SOCKET_ERROR = SocketTunnel.ERR_SOCKET_ERROR = 3001;

function SocketTunnel(socketUrl) {
  if (currentSocketTunnel && currentSocketTunnel.status !== STATUS_CLOSED) {
    close(false)
  }

  currentSocketTunnel = this;

  // 等确认微信小程序全面支持 ES6 就不用那么麻烦了
  var me = this;

  //=========================================================================
  // 暴露实例状态以及方法
  //=========================================================================
  this.socketUrl = socketUrl;
  this.status = null;

  this.open = openConnect;
  this.on = registerEventHandler;
  this.close = close;

  this.isClosed = isClosed;
  this.isConnecting = isConnecting;
  this.isActive = isActive;
  this.send = sendPacket;


  //=========================================================================
  // socket状态处理，状态说明：
  //   closed       - 已关闭
  //   connecting   - 首次连接
  //   active       - 当前socket已经在工作
  //=========================================================================
  function isClosed() { return me.status === STATUS_CLOSED; }
  function isConnecting() { return me.status === STATUS_CONNECTING; }
  function isActive() { return me.status === STATUS_ACTIVE; }

  function setStatus(status) {
    var lastStatus = me.status;
    if (lastStatus !== status) {
      me.status = status;
    }
  }

  // 初始为关闭状态
  setStatus(STATUS_CLOSED);


  //=========================================================================
  // socket事件处理机制
  // socket事件包括：
  //   connect      - 连接已建立
  //   close        - 连接被关闭（包括主动关闭和被动关闭）
  //   error        - 发生错误
  //   message      - websocket服务器发送过来消息
  //=========================================================================
  var preservedEventTypes = 'connect,close,error,message'.split(',');
  var eventHandlers = [];

  /**
   * 注册消息处理函数
   * @param {string} messageType 支持类型（"connect"|"close"|"error"|"message"）
   */
  function registerEventHandler(eventType, eventHandler) {
    if (typeof eventHandler === 'function') {
      eventHandlers.push([eventType, eventHandler]);
    }
  }

  /**
   * 派发事件，通知所有处理函数进行处理
   */
  function dispatchEvent(eventType, eventPayload) {
    eventHandlers.forEach(function (handler) {
      var handleType = handler[0];
      var handleFn = handler[1];

      if (handleType === eventType) {
        handleFn(eventPayload);
      }
    });
  }

  //=========================================================================
  // 连接控制
  //=========================================================================
  var isOpening = false;

  /**
   * 进行 WebSocket 连接
   */
  function openConnect() {
    if (isOpening) return;
    isOpening = true;
    setStatus(STATUS_CONNECTING);
    openSocket(me.socketUrl);
  }

  /**
   * 打开 WebSocket 连接，打开后，注册微信的 Socket 处理方法
   */
  function openSocket(url) {
    wxTunnel.listen({
      onOpen: handleSocketOpen,
      onMessage: handleSocketMessage,
      onClose: handleSocketClose,
      onError: handleSocketError,
    });

    wx.connectSocket({ url: url });
  }


  //=========================================================================
  // 处理消息
  //=========================================================================

  // 连接还没成功建立的时候，需要发送的包会先存放到队列里
  var queuedPackets = [];

  /**
   * WebSocket 打开之后，更新状态，同时发送所有遗留的数据包
   */
  function handleSocketOpen() {
    /* istanbul ignore else */
    if (isConnecting()) {
      dispatchEvent('connect');

    }

    setStatus(STATUS_ACTIVE);
  }

  /**
   * 收到 WebSocket 数据包，交给处理函数
   */
  function handleSocketMessage(message) {
    dispatchEvent('message', message);
  }

  /**
   * 数据包推送到websocket
   */
  function sendPacket(packet) {
    wx.sendSocketMessage({
      data: packet,
      fail: handleSocketError,
    });
  }

  var isClosing = false;
  /**
   * 收到 WebSocket 断开的消息，处理断开逻辑
   */
  function handleSocketClose(res) {
    dispatchEvent('close', res);

    /* istanbul ignore if */
    if (isClosing) return;

    /* istanbul ignore else */
    if (isActive()) {
      close()
    }
  }

  function close(emitClose) {
    isClosing = true;
    closeSocket(emitClose);
    setStatus(STATUS_CLOSED);
    dispatchEvent('close');
    isClosing = false;
  }

  function closeSocket(emitClose) {
    if (isActive() && emitClose !== false) {
      wx.sendSocketMessage({
        data: JSON.stringify({
          "type": "Close", "data": "", "extra": ""
        }),complete:function(res){
          console.log(res)
        },
      })
    }

    wx.closeSocket({
      complete: function (res) {
        console.log('WebSocket连接关闭！' + res.errMsg)
      }
    })
  }

  //=========================================================================
  // 错误处理
  //=========================================================================

  /**
   * 错误处理
   */
  function handleSocketError(detail) {
    dispatchEvent('error', detail)
  }

}

module.exports = SocketTunnel;