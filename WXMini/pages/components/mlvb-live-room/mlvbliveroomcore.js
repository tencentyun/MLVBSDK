import TYPES from "./utils/types";
import {isJSON} from "./utils/common";

/**
 * @file liveroom.js 直播模式房间管理sdk
 * @author binniexu
 */
var TIM = require('tim_wx.js');
var timHandler = require('tim_handler.js');


//移动直播（<mlvb-live-room>）使用此地址实现房间服务和连麦功能
var RoomServiceUrl = "https://liveroom.qcloud.com/weapp/live_room/",

	heart = '',				// 判断心跳变量
	requestSeq = 0,			// 请求id
	requestTask = [],		// 请求task
	// 用户信息
	tim = null,
	accountInfo = {
		userID: '',			// 用户ID
		userName: '',		// 用户昵称
		userAvatar: '',		// 用户头像URL
		userSig: '',		// IM登录凭证
		sdkAppID: '',		// IM应用ID
		accountType: '',	// 账号集成类型
		accountMode: 0,		//帐号模式，0-表示独立模式，1-表示托管模式
		token: ''			//登录RoomService后使用的票据
	},
	// 房间信息
	roomInfo = {
		roomID: '',			// 视频位房间ID
		roomInfo: '',		// 房间名称
		mixedPlayURL: '', 	// 混流地址
		isCreator: false,	// 是否为创建者
		pushers: [],		// 当前用户信息
		isLoginIM: false,	// 是否登录IM
		isJoinGroup: false,	// 是否加入群
		isDestory: false,	// 是否已解散
		hasJoinAnchor: false,
		roomStatusCode: 0
	},
	// 事件
	event = {
    		onAnchorEnter: function () {},			// 进房通知
    		onAnchorExit: function () {},			// 退房通知
    		onRoomDestroy: function() {},			// 群解散通知
		    onRecvRoomTextMsg: function() {},		// 消息通知
    		onRequestJoinAnchor: function() {}, //大主播收到小主播连麦请求通知
    		onKickoutJoinAnchor: function() {}, //小主播被踢通知
        onRecvRoomCustomMsg: function() {}, //自定义消息通知
	};
// 随机昵称
var userName = ['林静晓', '陆杨', '江辰', '付小司', '陈小希', '吴柏松', '肖奈', '芦苇微微', '一笑奈何', '立夏'];
// 请求数
var requestNum = 0;
var requestJoinCallback = null;
var bigAnchorStreamID = '';
var bigAnchorWidth = 360;
var bigAnchorHeight = 640;
var gTimeoutID = null;
var mTimeDiff = 0;

/**
 * [request 封装request请求]
 * @param {options}
 *   url: 请求接口url
 *   data: 请求参数
 *   success: 成功回调
 *   fail: 失败回调
 *   complete: 完成回调
 */
function request(options) {
	requestNum++;
	console.log('requestNum: ', requestNum);
	requestTask[requestSeq++] = wx.request({
    url: RoomServiceUrl + options.url + (options.params?('?' + formatParams(options.params) + '&'):'?') + 'userID=' + accountInfo.userID + (accountInfo.token?'&token=' + accountInfo.token:""),
		data: options.data || {},
		method: 'POST',
		header: {
			'content-type': 'application/json' // 默认值
		},
		// dataType: 'json',
		success: options.success || function() {},
		fail: options.fail || function() {},
		complete: options.complete || function() {
			requestNum--;
			// console.log('complete requestNum: ',requestNum);
		}
	});
}

//url encode编码
function formatParams(data) {
	var arr = [];
	for (var name in data) {
		arr.push(encodeURIComponent(name) + "=" + encodeURIComponent(data[name]));
	}
	return arr.join("&");
}

/**
 * [login 初始化登录信息]
 * @param {options}
 *   data: {
 *    userID: 用户ID
 *    userSig: 用户sig
 *    sdkAppID: IM应用ID
 *    userName: 用户昵称
 *    userAvatar: 用户头像地址
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 *
 * @return success
 *   userName: 用户昵称
 */
function login(options) {
  if (!options || !options.data.sdkAppID || !options.data.userID || !options.data.userSig) {
		console.log('init参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'init参数错误'
		});
		return;
	}
	accountInfo.userID = options.data.userID;
	accountInfo.userSig = options.data.userSig;
	accountInfo.sdkAppID = options.data.sdkAppID;
  accountInfo.userName = options.data.userName || userName[Math.floor(Math.random()*10)] || accountInfo.userID;
	accountInfo.userAvatar = options.data.userAvatar || '123';

	request({
		url: 'login',
		params: {
			accountType: '0',
			sdkAppID: accountInfo.sdkAppID,
			userSig: accountInfo.userSig,
			platform: "WeChat"
		},
		data: {},
		success: function(ret) {
			if (ret.data.code) {
				console.error("登录到RoomService后台失败:", JSON.stringify(ret));
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message
				});
				return;
			}
			accountInfo.token = ret.data.token;
			accountInfo.userID = ret.data.userID;
      mTimeDiff = Math.round(Date.now()) - ret.data.timestamp;
			// 登录IM
	        loginIM({
	        	success: function(ret) {
					options.success && options.success({
						userID: accountInfo.userID,
						userName: accountInfo.userName
					});
				},
	        	fail: function(ret) {
					console.error("IM登录失败:", JSON.stringify(ret));
					options.fail && options.fail({
						errCode: -999,
						errMsg: "IM登录失败"
					});
				}
	        });
		},
		fail: function(ret) {
			console.error("登录到RoomService后台失败:", JSON.stringify(ret));
			options.fail && options.fail(ret);
		}
	});
}

/**
 * [logout 结束初始化信息]
 */
function logout() {
	request({
		url: "logout",
		success: function(ret){},
		fail: function(ret){}
	});
	accountInfo.userID = '';
	accountInfo.userSig = '';
	accountInfo.sdkAppID = '';
	accountInfo.userName = '';
	accountInfo.userAvatar = '';
	accountInfo.token = '';
	// 退出IM登录
	timHandler.logout();
}

/**
 * [loginIM 登录IM]
 * @param {options}
 *   data: {
 *   	roomID: 房间ID
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 */

//im 事件监听
function initListener() {
	unbind()
	bind()
}

function bind() {
	tim.on(TIM.EVENT.SDK_READY, onReadyStateUpdate)
	// SDK NOT READT
	tim.on(TIM.EVENT.SDK_NOT_READY, onReadyStateUpdate)
	//收到新消息
	tim.on(TIM.EVENT.MESSAGE_RECEIVED, onReceiveMessage)
	// 网络监测
	tim.on(TIM.EVENT.NET_STATE_CHANGE, onNetStateChange)
	// SDK内部出错
	tim.on(TIM.EVENT.ERROR, onError)

}

function unbind() {
	tim.off(TIM.EVENT.SDK_READY, onReadyStateUpdate)
	// SDK NOT READT
	tim.off(TIM.EVENT.SDK_NOT_READY, onReadyStateUpdate)
	//收到新消息
	tim.off(TIM.EVENT.MESSAGE_RECEIVED, onReceiveMessage)
	// 网络监测
	tim.off(TIM.EVENT.NET_STATE_CHANGE, onNetStateChange)
	// SDK内部出错
	tim.off(TIM.EVENT.ERROR, onError)
}
function onError(event) {
	// event.data.code - 错误码
	// event.data.message - 错误信息
}

function onReadyStateUpdate() {

}

function onNetStateChange(event) {
	switch (event.data.state) {
		case TIM.TYPES.NET_STATE_CONNECTED:
			return console.log('已接入网络')
		case TIM.TYPES.NET_STATE_CONNECTING:
			return console.log('当前网络不稳定')
		case TIM.TYPES.NET_STATE_DISCONNECTED:
			return console.log('当前网络不可用')
		default:
			return ''
	}
}

function onReceiveMessage ({ data: messageList }) {
	for (let i = 0; i < messageList.length; i++) {
		let item = messageList[i]
		if (item.type === TIM.TYPES.MSG_TEXT) {
			event.onRecvRoomTextMsg({msg:item});
		}
		// C2C 自定义消息
		if (item.type === TYPES.MSG_CUSTOM) {
			recvC2CMsg(item)
		}
		if (item.type === TIM.TYPES.MSG_GRP_SYS_NOTICE) {
			// 系统消息
			if (item.payload.operationType === TIM.TYPES.GRP_TIP_MBR_CANCELED_ADMIN) {
				console.log(item.payload,'群被解散')
				roomInfo.isDestory = true;
				event.onRoomDestroy()
			}
		}
	}
	// 提示消息
}

function loginIM(options) {
	// 初始化设置参数
	tim = TIM.create({
		SDKAppID: accountInfo.sdkAppID
	})
	timHandler.init({
		accountMode: accountInfo.accountMode,
		accountType: '0',
		sdkAppID: accountInfo.sdkAppID,
		avChatRoomId: options.roomID || 0,
		selType: TIM.TYPES.CONV_GROUP,
		selToID: options.roomID || 0,
		selSess: null,//当前聊天会话
		tim:tim
	});

	//当前用户身份
	var loginInfo = {
		'sdkAppID': accountInfo.sdkAppID, //用户所属应用id,必填
		'appIDAt3rd': accountInfo.sdkAppID, //用户所属应用id，必填
		'accountType': "0", //用户所属应用帐号类型，填0
		'identifier': accountInfo.userID, //当前用户ID,必须是否字符串类型，选填
		'identifierNick': accountInfo.userID, //当前用户昵称，选填
		'userSig': accountInfo.userSig, //当前用户身份凭证，必须是字符串类型，选填
	};

	//监听事件
	initListener()
	if (accountInfo.accountMode == 1) { //托管模式
		timHandler.sdkLogin(loginInfo, 0, afterLoginIM, options);
	} else { //独立模式
		//sdk登录
		timHandler.sdkLogin(loginInfo,  0, afterLoginIM, options);
	}
}
function afterLoginIM(options) {
	if (options.errCode) {
		// tim登录失败
		console.log('tim登录失败:', options);
		options.callback.fail && options.callback.fail({
			errCode: -2,
			errMsg: 'IM登录失败，如果你是在配置线上环境，请将IM域名[https://webim.tim.qq.com]配置到小程序request合法域名'
		});
		return;
	}
	// tim登录成功
	console.log('tim登录成功');
	roomInfo.isLoginIM = true;
	options.callback.success && options.callback.success({
		userName: accountInfo.userName
	});
}
function afterJoinBigGroup(options) {
	if (options.errCode && options.errCode != 10025) {
		console.log('tim进群失败: ', options);
		options.callback.fail && options.callback.fail({
			errCode: -2,
			errMsg: 'IM进群失败'
		});
		return;
	}
	roomInfo.isJoinGroup = true;
	console.log('进入IM房间成功: ', roomInfo.roomID);
  options.callback.success && options.callback.success({});
}

function onSketchpadData(data){
    event.onSketchpadData(data);
}


function recvC2CMsg(msg) {
	console.log("收到C2C消息:", msg);
	if (isJSON(msg.payload.data)) {
		var contentObj = JSON.parse(msg.payload.data)
	}
	console.log(contentObj)
	if (contentObj) {
		if (contentObj.cmd == 'linkmic') {
			if (contentObj.data.type && contentObj.data.type == 'request') {
				console.log('发起连麦请求')
				event.onRequestJoinAnchor({
					userID: msg.from,
					userName: contentObj.data.userName,
					userAvatar: contentObj.data.userAvatar
				})
			} else if (contentObj.data.type && contentObj.data.type == 'response') {
				if (contentObj.data.result == 'accept') {
					console.log('接收了连麦')
					requestJoinCallback && requestJoinCallback({
						errCode: 0,
						errMsg: ''
					});
				} else if (contentObj.data.result == 'reject') {
					requestJoinCallback && requestJoinCallback({
						errCode: -999,
						errMsg: '主播拒绝了你的请求'
					});
				}
			} else if (contentObj.data.type && contentObj.data.type == 'kickout') {
				event.onKickoutJoinAnchor && event.onKickoutJoinAnchor({
					roomID: contentObj.data.roomID
				});
			}
		}
	}
}



function mergeAnchors() {
	if (!roomInfo.hasJoinAnchor) {
		return;
	}
  getAnchors({
        data: {
            roomID: roomInfo.roomID
        },
		success: function(ret) {
			ret = ret.data;

			innerMergerAnchors(ret)
		},
		fail: function(ret) {
			// event.onRoomDestroy && event.onRoomDestroy({
			// 	errCode: ret.errCode,
			// 	errMsg: ret.errMsg
			// });
		}
	});
};

function innerMergerAnchors(data) {
  /**
   * enterPushers：新进推流人员信息
   * leavePushers：退出推流人员信息
   * ishave：用于判断去重操作
   */
  var enterPushers = [],leavePushers = [],ishave = 0;
  data.pushers && data.pushers.forEach(function(val1){
    ishave = 0;
    roomInfo.pushers && roomInfo.pushers.forEach(function(val2) {
      if(val1.userID == val2.userID) {
        ishave = 1;
      }
    });
    if(!ishave && val1.userID != accountInfo.userID)
      enterPushers.push(val1);
    ishave = 0;
  });
  roomInfo.pushers && roomInfo.pushers.forEach(function(val1) {
    ishave = 0;
    data.pushers && data.pushers.forEach(function(val2) {
      if(val1.userID == val2.userID) {
        ishave = 1;
      }
    });
    if(!ishave)
      leavePushers.push(val1);
    ishave = 0;
  });
  if (data.roomStatusCode) {
    roomInfo.roomStatusCode = data.roomStatusCode
	}
  // 重置roomInfo.pushers
  roomInfo.pushers = data.pushers;
  // 通知有人进入房间
  if(enterPushers.length) {
    console.log('进房:', JSON.stringify(enterPushers));
    event.onAnchorEnter && event.onAnchorEnter({
      pushers: enterPushers
    });
    //混流
    mergeStream(1);
  }
  // 通知有人退出房间
  if(leavePushers.length) {
    console.log('退房:', JSON.stringify(leavePushers));
    event.onAnchorExit && event.onAnchorExit({
      pushers: leavePushers
    });
    //混流
    mergeStream(1);
  }
}


function getAnchors(object) {
	var data = {};
	if (object.data && object.data.roomID) {
		data.roomID = object.data.roomID;
	} else if (roomInfo.roomID) {
		data.roomID = roomInfo.roomID;
	} else {
		object.fail && object.fail({
			errCode: -999,
			errMsg: '无roomID'
		})
		return;
	}
    //获取房间信息
    request({
        url: 'get_anchors',
        data: data,
        success: function (ret) {
            if (ret.data.code) {
                console.log('请求CGI:get_anchors失败', ret);
                object.fail && object.fail({errCode: ret.data.code, errMsg: '请求CGI:get_anchors失败:' + ret.data.message +  + '[' + ret.data.code + ']'});
                return;
            }
            console.log("房间信息：", JSON.stringify(ret));
            object.success && object.success(ret);
        },
        fail: object.fail
    });
}


/**
 * [pusherHeartBeat 推流者心跳]
 * @param {options}
 */
function pusherHeartBeat(options) {
	if (options) {
		setTimeout(function () {
			proto_pusherHeartBeat();
		}, 3000);
	}
	if (heart) {
		setTimeout(function () {
			proto_pusherHeartBeat();
			pusherHeartBeat();
		}, 7000);
	}
}
function proto_pusherHeartBeat() {
	console.log('心跳请求');
	request({
		url: 'anchor_heartbeat',
		data: {
			roomID: roomInfo.roomID,
			userID: accountInfo.userID,
			roomStatusCode: roomInfo.roomStatusCode
		},
		success: function (ret) {
			if (ret.data.code) {
				console.log('心跳失败：', ret);
				return;
			}
			if (ret.data.pushers) {
        innerMergerAnchors(ret.data);
			}
			console.log('心跳成功', ret);
		},
		fail: function (ret) {
			console.log('心跳失败：', ret);
		}
	});
}

/**
 * [stopPusherHeartBeat 停止推流者心跳]
 * @param {options}
 */
function stopPusherHeartBeat() {
	heart = false;
}

/**
 * [getRoomList 获取房间列表]
 * @param {options}
 *   data: {
 *   	index: 获取的房间开始索引，从0开始计算
 *   	cnt: 获取的房间个数
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 *
 * @return success
 *   rooms: 房间列表信息
 */
function getRoomList(options) {
	if (!options) {
		console.log('getRoomList参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'getRoomList参数错误'
		});
		return;
	}
	request({
		url: 'get_room_list',
		data: {
			index: options.data.index || 0,
			cnt: options.data.cnt || 20
		},
		success: function (ret) {
			if (ret.data.code) {
				console.error('获取房间列表失败: ', ret);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});
				return;
			}
			console.log("房间列表信息:", ret);
			options.success && options.success({
				rooms: ret.data.rooms
			});
		},
		fail: function (ret) {
			console.log('获取房间列表失败: ', ret);
			if(ret.errMsg == 'request:fail timeout') {
				var errCode = -1;
				var errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({
				errCode: errCode || -1,
				errMsg: errMsg || '获取房间列表失败'
			});
		}
	});
}


/**
 * [getPushURL 获取推流地址]
 * @param {options}
 *   success: 成功回调
 *   fail: 失败回调
 *
 * @return success
 *   pushURL: 推流地址
 */
function getPushURL(options) {
	if (!options) {
		console.log('getPushURL参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'getPushURL参数错误'
		});
		return;
	}
	request({
		url: 'get_anchor_url',
		data: {
			userID: accountInfo.userID
		},
		success: function (ret) {
			if (ret.data.code) {
				console.log('获取推流地址失败: ', ret);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});
				return;
			}
			console.log('获取推流地址成功：', ret.data.pushURL);
			options.success && options.success({
				pushURL: ret.data.pushURL
			});
		},
		fail: function (ret) {
			if(ret.errMsg == 'request:fail timeout') {
				var errCode = -1;
				var errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({
				errCode: errCode || -1,
				errMsg: errMsg || '获取推流地址失败'
			});
		}
	});
};

/**
 * [sendRoomTextMsg 发送文本消息]
 * @param {options}
 *   data: {
 *   	msg: 文本消息
 *   }
 */
function sendRoomTextMsg(options) {
	if (!options || !options.data.msg || !options.data.msg.replace(/^\s*|\s*$/g, '')) {
		console.log('sendRoomTextMsg参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'sendRoomTextMsg参数错误'
		});
		return;
	}
	timHandler.sendTextMessage({
		text: options.data.msg,
		to: options.data.roomID
	},function() {
		options.success && options.success();
	});
}

/**
 * [setListener 设置监听事件]
 * @param {options}
 *   onRoomDestroy: 群解散通知
 *   onRecvRoomTextMsg: 消息通知
 */
function setListener(options) {
	if (!options) { console.log('setListener参数错误',options); return; }
        event.onAnchorEnter = options.onAnchorEnter || function () {};
        event.onAnchorExit = options.onAnchorExit || function () {};
        event.onRoomDestroy = options.onRoomDestroy || function () {};
	      event.onRecvRoomTextMsg = options.onRecvRoomTextMsg || function () {};
	      event.onRequestJoinAnchor = options.onRequestJoinAnchor || function () {};
        event.onKickoutJoinAnchor = options.onKickoutJoinAnchor || function () {};
        event.onRecvRoomCustomMsg = options.onRecvRoomCustomMsg || function () {};
}

/**
 * [createRoom 创建房间]
 * @param {options}
 *   data: {
 *   	roomInfo: 房间名称
 *    	pushURL: 推流地址
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 */
function createRoom(options) {
	roomInfo.isCreator = true;
	roomInfo.isDestory = false;
	roomInfo.isJoinGroup = false;
	if (!options || !options.data.roomInfo || !options.data.pushURL) {
		console.log('createRoom参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'createRoom参数错误'
		});
		return;
	}
	roomInfo.roomInfo = options.data.roomInfo;
	proto_createRoom(options);
}
function proto_createRoom(options) {
  var createRoomInfo = {
    userID: accountInfo.userID,
    roomInfo: roomInfo.roomInfo
  };
  if (options.data.roomID && options.data.roomID.length > 0) {
    createRoomInfo.roomID = options.data.roomID;
  }
	request({
		url: 'create_room',
    data: createRoomInfo,
		success: function (ret) {
			if (ret.data.code) {
				console.log('创建房间失败:', ret);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});
				return;
			}
			console.log('--->创建房间成功:', ret);
			roomInfo.roomID = ret.data.roomID;
			roomInfo.roomCreator = accountInfo.userID;
			if (roomInfo.isDestory) {
				roomInfo.isDestory = false;
				destoryRoom({});
				return;
			}
			options.data.roomID = ret.data.roomID;
			// 创建IM群
			var createIMGroupInfo = {
				roomID: options.data.roomID,
				userID: accountInfo.userID,
        roomName: options.data.roomID
			}
      timHandler.createBigGroup(createIMGroupInfo, afterJoinBigGroup, {
        success: function() {
          joinAnchor(options);
        },
        fail: options.fail
      });
		},
		fail: function (ret) {
			console.log('创建后台房间失败:', ret);
			if(ret.errMsg == 'request:fail timeout') {
				var errCode = -1;
				var errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({
				errCode: errCode || -3,
				errMsg: errMsg || '创建房间失败'
			});
		}
	});
}

/**
 * [joinAnchor 加入推流]
 * @param {options}
 *   data: {
 *   	roomID: 房间ID
 *   	pushURL: 推流地址
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 */
function joinAnchor(options) {
	if(!options || !options.data.roomID || !options.data.pushURL) {
		console.log('joinAnchor参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'joinAnchor参数错误'
		});
		return;
	}
	roomInfo.roomID = options.data.roomID;
  	roomInfo.isDestory = false;
	proto_joinAnchor(options);
}
function proto_joinAnchor(options) {
	request({
		url: 'add_anchor',
		data: {
			roomID: roomInfo.roomID,
			userID: accountInfo.userID,
			userName: accountInfo.userName,
			userAvatar: accountInfo.userAvatar,
			pushURL: options.data.pushURL
		},
		success: function(ret) {
			if(ret.data.code) {
				console.log('进入房间失败:',ret);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});
				return;
			}
			roomInfo.hasJoinAnchor = true;
      mergeAnchors();
			console.log('加入推流成功');
			// 开始心跳
			heart = true;
			pusherHeartBeat(1);
      //通知房间内其他主播
      //notifyPusherChange();
  		options.success && options.success({roomID: roomInfo.roomID});
		},
		fail: function(ret) {
			console.log('进入房间失败:',ret);
			if(ret.errMsg == 'request:fail timeout') {
				var errCode = -1;
				var errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({
				errCode: errCode || -4,
				errMsg: errMsg || '进入房间失败'
			});
		}
	});
}

/**
 * [enterRoom 进入房间]
 * @param {options}
 *   data: {
 *   	roomID: 房间ID
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 */
function enterRoom(options) {
	roomInfo.isCreator = false;
	roomInfo.isJoinGroup = false;
	if (!options || !options.data.roomID) {
		console.log('enterRoom参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'enterRoom参数错误'
		});
		return;
	}
	roomInfo.roomID = options.data.roomID;
	proto_enterRoom({
		success: function(ret) {
			options.success && options.success(ret);
			var userInfo = {
				userName: accountInfo.userName,
				userAvatar: accountInfo.userAvatar
			}
			addAudience({
				data: {
					roomID: options.data.roomID,
					userID: accountInfo.userID,
					userInfo: JSON.stringify(userInfo)
				}
			})
		},
		fail: options.fail
	});
}
function proto_enterRoom(options) {
	console.log('开始IM: ', roomInfo.roomID);
	timHandler.applyJoinBigGroup(roomInfo.roomID, afterJoinBigGroup, {
		success: function(ret) {
      getAnchors({
				data: {
					roomID: roomInfo.roomID
				},
				success: function(ret) {
					console.log(ret,'进入房间成功')
					roomInfo.roomID = ret.data.roomID;
          roomInfo.roomInfo = ret.data.roomInfo;
          roomInfo.roomCreator = ret.data.roomCreator;
					roomInfo.mixedPlayURL = ret.data.mixedPlayURL;
					options.success && options.success({
						roomID: roomInfo.roomID,
						roomCreator: roomInfo.roomCreator,
						mixedPlayURL: roomInfo.mixedPlayURL,
            			pushers: ret.data.pushers
					});
				},
				fail: function(ret) {
					options.fail && options.fail({
						errCode: ret.errCode,
						errMsg: ret.errMsg || '拉取主播信息失败'
					});
				}
			});
		},
		fail: options.fail
	});
}

/**
 * [exitRoom 退出房间]
 * @param {options}
 */
function exitRoom(options) {
	if (roomInfo.isCreator) {
		destoryRoom(options);
	} else {
		leaveRoom(options);
	}
	roomInfo.isDestory = true;
	roomInfo.roomID = '';
	roomInfo.pushers = [];
	roomInfo.mixedPlayURL = "";
	roomInfo.roomInfo = "";
	accountInfo.pushURL = "";
	accountInfo.isCreator = false;
}

/**
 * [leaveRoom 退出房间]
 */
function leaveRoom(options) {
	// 停止心跳
	stopPusherHeartBeat();
	roomInfo.isJoinGroup && timHandler.quitBigGroup();
	request({
		url: 'delete_anchor',
		data: {
			roomID: roomInfo.roomID,
			userID: accountInfo.userID
		},
		success: function(ret) {
			if(ret.data.code) {
				console.log('退出推流失败:',ret);
				console.error('退房信息: roomID:' + roomInfo.roomID + ", userID:" + accountInfo.userID);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});
				return;
			}
			console.log('退出推流成功');
			options.success && options.success({});
		},
		fail: function(ret) {
			console.log('退出推流失败:',ret);
			var errCode = ret.errCode || -1;
			var errMsg = ret.errMsg || '退出房间失败'
			if(ret.errMsg == 'request:fail timeout') {
				errCode = -1;
				errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({
				errCode: errCode,
				errMsg: errMsg
			});
		}
	});

	delAudience({
		data: {
			userID: accountInfo.userID,
			roomID: roomInfo.roomID
		}
	})
}

/**
 * [destoryRoom 销毁房间]
 */
function destoryRoom(options) {
	// 停止心跳
	stopPusherHeartBeat();
	roomInfo.isJoinGroup && timHandler.destroyGroup();
	if(roomInfo.isDestory) return;
	request({
		url: 'destroy_room',
		data: {
			roomID: roomInfo.roomID,
			userID: accountInfo.userID
		},
		success: function(ret) {
			if(ret.data.code) {
				console.log('关闭房间失败:',ret);
				console.error('关闭房间失败: roomID:' + roomInfo.roomID + ", userID:" + accountInfo.userID);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});
				return;
			}
			console.log('关闭房间成功');
			options.success && options.success({});
		},
		fail: function(ret) {
			console.log('关闭房间失败:',ret);
			var errCode = ret.errCode || -1;
			var errMsg = ret.errMsg || '关闭房间失败'
			if(ret.errMsg == 'request:fail timeout') {
				errCode = -1;
				errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({
				errCode: errCode,
				errMsg: errMsg
			});
		}
	});
}

function quitJoinAnchor(options) {
	stopPusherHeartBeat();
	request({
		url: 'delete_anchor',
		data: {
			roomID: roomInfo.roomID,
			userID: accountInfo.userID
		},
		success: function(ret) {
			if(ret.data.code) {
				console.log('退出推流失败:',ret);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});
				return;
			}
			console.log('退出推流成功');
			roomInfo.pushers = [];
      //通知房间内其他主播
      //notifyPusherChange();
			options.success && options.success({});
		},
		fail: function(ret) {
			console.log('退出推流失败:',ret);
			if(ret.errMsg == 'request:fail timeout') {
				var errCode = -1;
				var errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({
				errCode: errCode || -1,
				errMsg: errMsg || '退出房间失败'
			});
		}
	});
	roomInfo.hasJoinAnchor = false;
}

function requestJoinAnchor (object) {
	var body = {
		cmd: 'linkmic',
		data: {
			type: 'request',
			roomID: roomInfo.roomID,
			userID: accountInfo.userID,
			userName: accountInfo.userName,
			userAvatar: accountInfo.userAvatar,
      timestamp: Math.round(Date.now()) - mTimeDiff
		}
	}

	requestJoinCallback = function(ret) {
		if (gTimeoutID) {
			clearTimeout(gTimeoutID);
			gTimeoutID = null;
		}
		if (ret.errCode) {
			object.fail && object.fail(ret);
		} else {
			object.success && object.success(ret);
		}
	}

	var isTimeout = false;
	gTimeoutID = setTimeout(function () {
		gTimeoutID = null;
		console.error('申请连麦超时:', JSON.stringify(object.data));
		isTimeout = true;
		requestJoinCallback && requestJoinCallback({
			errCode: -999,
			errMsg: '申请加入连麦超时'
		});
	}, (object.data && object.data.timeout)? object.data.timeout : 30000);

	var msg = {
		data: JSON.stringify(body)
	}
	timHandler.sendC2CCustomMsg(roomInfo.roomCreator, msg, function (ret) {
		if (isTimeout) {
			return;
		}
		if (ret && ret.errCode) {
			console.log('请求连麦失败:', JSON.stringify(ret));
			requestJoinCallback && requestJoinCallback(ret);
			return;
		}
	});
}

function acceptJoinAnchor (object) {
	var body = {
		cmd: 'linkmic',
		data: {
			type: 'response',
			result: 'accept',
			reason: '',
      roomID: roomInfo.roomID,
      timestamp: Math.round(Date.now()) - mTimeDiff
		}
	}

	var msg = {
		data: JSON.stringify(body)
	}
	timHandler.sendC2CCustomMsg(object.data.userID, msg, function (ret) {});
}

function rejectJoinAnchor (object) {
	var body = {
		cmd: 'linkmic',
		data: {
			type: 'response',
			result: 'reject',
      reason: object.data.reason || '主播拒绝了您的连麦请求',
      roomID: roomInfo.roomID,
      timestamp: Math.round(Date.now()) - mTimeDiff
		}
	}

	var msg = {
		data: JSON.stringify(body)
	}
	timHandler.sendC2CCustomMsg(object.data.userID, msg, function (ret) {});
}

function kickoutJoinAnchor (object) {
	var body = {
		cmd: 'linkmic',
		data: {
			type: 'kickout',
      roomID: roomInfo.roomID,
      timestamp: Math.round(Date.now()) - mTimeDiff
		}
	}

	var msg = {
		data: JSON.stringify(body)
	}
	timHandler.sendC2CCustomMsg(object.data.userID, msg, function (ret) {
		if (ret && ret.errCode==0) {
			object.success && object.success(ret);
		} else {
			object.fail && object.fail(ret);
		}
	});
}

function getAccountInfo() {
	return accountInfo;
}

/**
 *
 * @param {Int} retryCount
 */
function mergeStream(retryCount) {
    if (accountInfo.userID != roomInfo.roomCreator) {
        //大主播才能混流
        return;
    }
    var mergeStreams = [];
	if (roomInfo.pushers && roomInfo.pushers.length > 0) {
		roomInfo.pushers.forEach(function (val) {
			if (val.userID != roomInfo.roomCreator) {
				//获取流id
                var streamID = getStreamIDByStreamUrl(val.accelerateURL);
                if (streamID) {
                    mergeStreams.push({
                        userID: val.userID,
                        streamID: streamID,
                        width: val.width,
                        height: val.height
                    });
                }
			} else {
				bigAnchorStreamID = getStreamIDByStreamUrl(val.accelerateURL);
			}
		});
	}
	console.log("混流信息:", JSON.stringify(mergeStreams));

    sendStreamMergeRequest(retryCount, mergeStreams);
}

function getStreamIDByStreamUrl(streamUrl) {
    if (!streamUrl) {
        return null;
    }
    //推流地址格式: rtmp://8888.livepush.myqcloud.com/path/8888_test_12345?txSecret=aaa&txTime=bbb
    //拉流地址格式: rtmp://8888.livepush.myqcloud.com/path/8888_test_12345
    //             http://8888.livepush.myqcloud.com/path/8888_test_12345.flv
    //             http://8888.livepush.myqcloud.com/path/8888_test_12345.m3u8

    var subStr = streamUrl;
    var index = subStr.indexOf('?');
    if (index >= 0) {
        subStr = subStr.substring(0, index);
    }
    if (!subStr) {
        return null;
    }
    index = subStr.lastIndexOf('/');
    if (index >= 0) {
        subStr = subStr.substring(index + 1);
    }
    if (!subStr) {
        return null;
    }
    index = subStr.indexOf('.');
    if (index >= 0) {
        subStr = subStr.substring(0, index);
    }
    if (!subStr) {
        return null;
    }
    return subStr;
}

function sendStreamMergeRequest(retryCount, mergeStreams) {
    if (retryCount < 0) {
        return;
    }

    var mergeInfo = createMergeInfo(mergeStreams);
    console.log('混流信息:', JSON.stringify(mergeInfo));

    doMergeRequest(mergeInfo, function (ret) {
        if (ret) {
            console.log('混流成功');
        } else {
            console.log('混流失败');
            setTimeout(() => {
                retryCount--;
                sendStreamMergeRequest(retryCount, mergeStreams);
            }, 2000);
        }
    });
}

function doMergeRequest(mergeInfo, callback) {
    request({
        url: 'merge_stream',
        data: {
            userID: accountInfo.userID,
            roomID: roomInfo.roomID,
            mergeParams: JSON.stringify(mergeInfo)
        },
        success: function (ret) {
            if (ret.data.code || ret.data.merge_code) {
                console.error('混流失败:', JSON.stringify(ret));
                callback(false);
                return;
            }
            callback(true);
        },
        fail: function (ret) {
            callback(false);
        }
    })
}

function createMergeInfo(mergeStreams) {
    console.log("混流原始信息:", JSON.stringify(mergeStreams));

    var smallAnchorWidth = 160;
	var smallAnchorHeight = 240;
	var offsetHeight = 90;
	if (bigAnchorWidth < 540 || bigAnchorHeight < 960) {
		smallAnchorWidth = 120;
		smallAnchorHeight = 180;
		offsetHeight = 60;
	}

    //组装混流JSON结构体
    var streamInfoArray = [];
    if (mergeStreams && mergeStreams.length > 0) {

        //大主播
        var bigAnchorInfo = {
            input_stream_id: bigAnchorStreamID || '',
            layout_params: {
                image_layer: 1
            }
        }
        streamInfoArray.push(bigAnchorInfo);

        //小主播
        var subLocationX = bigAnchorWidth - smallAnchorWidth;
        var subLocationY = bigAnchorHeight - smallAnchorHeight - offsetHeight;
        if (mergeStreams && mergeStreams.length > 0) {
            var layerIndex = 0
            mergeStreams.forEach(function (val) {
				//组装JSON
				var smallAchorInfo = {
					input_stream_id: val.streamID,
					layout_params: {
						image_layer: layerIndex + 2,
						image_width: smallAnchorWidth,
						image_height: smallAnchorHeight,
						location_x: subLocationX,
						location_y: subLocationY - layerIndex * smallAnchorHeight
					}
				}
				streamInfoArray.push(smallAchorInfo);
				layerIndex++;
            });
        }
    } else {
        var bigAnchorInfo = {
            input_stream_id: bigAnchorStreamID || '',
            layout_params: {
                image_layer: 1
            }
        }
        streamInfoArray.push(bigAnchorInfo);
    }

    var para = {
        app_id: accountInfo.sdkAppID.toString(),
        interface: 'mix_streamv2.start_mix_stream_advanced',
        mix_stream_session_id: bigAnchorStreamID,
        output_stream_id: bigAnchorStreamID,
        input_stream_list: streamInfoArray
    }

    var interfaceObj = {
        interfaceName: 'Mix_StreamV2',
        para: para
    }

    var reqParam = {
        timestamp: Math.round((Date.now() / 1000)),
        eventId: Math.round((Date.now() / 1000)),
        interface: interfaceObj
    }

    return reqParam;
}

function setVideoRatio(ratio) {
	if (ratio == 1) {
		//9:16
		bigAnchorWidth = 360;
		bigAnchorHeight = 640;
	} else {
		//3:4
		bigAnchorWidth = 480;
		bigAnchorHeight = 640;
	}
}

function sendC2CCustomMsg(object) {
	var body = {
		cmd: object.cmd,
		data: {
			userID: accountInfo.userID,
			userName: accountInfo.userName,
			userAvatar: accountInfo.userAvatar,
			msg: object.msg || ''
		}
	}
	var msg = {
		data: JSON.stringify(body)
	}
	timHandler.sendC2CCustomMsg(object.toUserID?object.toUserID:roomInfo.roomCreator, msg, function (ret) {
		if (ret && ret.errCode) {
			console.log('请求连麦失败:', JSON.stringify(ret));
			object.fail && object.fail(ret);
			return;
		}
		object.success && object.success({});
	});
}

//观众进房时，向后台发送进房通知
function addAudience(object) {
	request({
		url: 'add_audience',
		data: {
			userID: accountInfo.userID,
			roomID: object.data.roomID,
			userInfo: object.data.userInfo
		},
		success: function (ret) {
			if (ret.data.code) {
				console.log('增加观众请求失败', ret);
				object.fail && object.fail({errCode: ret.data.code, errMsg: '增加观众请求失败:' + ret.data.message +  + '[' + ret.data.code + ']'});
				return;
			}
			object.success && object.success(ret);
		},
		fail: object.fail
	});
 }

 //观众退房时，向后台发送退房通知
 function delAudience(object) {
	request({
		url: 'delete_audience',
		data: {
			userID: object.data.userID,
			roomID: object.data.roomID
		},
		success: function (ret) {
			if (ret.data.code) {
				console.log('减少观众请求失败', ret);
				object.fail && object.fail({errCode: ret.data.code, errMsg: '减少观众请求失败:' + ret.data.message +  + '[' + ret.data.code + ']'});
				return;
			}
			object.success && object.success(ret);
		},
		fail: object.fail
	});
 }

/**
 * 对外暴露函数
 * @type {Object}
 */
module.exports = {
	login: login,							// 初始化
	logout: logout,						// 结束初始化
	getRoomList: getRoomList,			// 拉取房间列表
	getPushURL: getPushURL,				// 拉取推流地址
	createRoom: createRoom,				// 创建房间
	enterRoom: enterRoom,				// 加入房间
	exitRoom: exitRoom,					// 退出房间
	sendRoomTextMsg: sendRoomTextMsg,	// 发送文本消息
	setListener: setListener,			// 设置监听事件
	joinAnchor: joinAnchor,			//加入连麦
  quitJoinAnchor: quitJoinAnchor, //退出连麦
	requestJoinAnchor: requestJoinAnchor,
	acceptJoinAnchor: acceptJoinAnchor,
	rejectJoinAnchor: rejectJoinAnchor,
  kickoutJoinAnchor: kickoutJoinAnchor,
	getAccountInfo: getAccountInfo,
	setVideoRatio: setVideoRatio,
	sendC2CCustomMsg: sendC2CCustomMsg,
	getAnchors: getAnchors
	// addRemoteView: addRemoteView,
	// deleteRemoteView: deleteRemoteView
}
