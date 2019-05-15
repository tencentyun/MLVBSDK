/**
 * @file rtcroom.js 多人音视频房间管理sdk
 * @author binniexu
 */

var webim = require('webim_wx.js');
var webimhandler = require('webim_handler.js');
var tls = require('tls.js');
var encrypt = require('encrypt.js');
var report = require('report.js')

var serverDomain = '',		// 后台域名
	heart = '',				// 判断心跳变量
	requestSeq = 0,			// 请求id
	requestTask = [],		// 请求task
	// 用户信息
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
		roomCreator: '',	//房间创建者
		roomInfo: '',		// 房间自定义信息（如作为房间名称）
		mixedPlayURL: '', 	// 混流地址
		pushers: [],		// 当前用户信息
		isDestory: false	// 是否已解散
	},
	// 事件
	event = {
		onGetPusherList: function () { },		// 初始化成员列表
		onPusherJoin: function () { },			// 进房通知
		onPusherQuit: function () { },			// 退房通知
		onRoomClose: function() {},				// 群解散通知
		onRecvRoomTextMsg: function() {}		// 消息通知
	},
	gViewKey = {
		pushURL: 'pushURL',
		aspect: 'aspect',
		minBitrate: 'minBitrate',
		maxBitrate: 'maxBitrate',
		beauty: 'beauty',
		muted: 'muted',
		debug: 'debug',
		userName: 'userName',
		members: 'members',
		userID: 'userID',
		accelerateURL: 'accelerateURL',
		loading: 'loading'
	};

// 随机昵称
var userName = ['林静晓','陆杨','江辰','付小司','陈小希','吴柏松','肖奈','老胡','江锐','立夏'];
// 请求数
var requestNum = 0, gHasPushStarted = false;
var noReport = ['pusher_heartbeat', 'get_room_list', 'create_room', 'delete_pusher','get_pushers'];
// 时间戳
var ts = {
	join_group_srart: 0,
	get_pushers_start: 0,
	get_pushers_end: 0,
	get_pushurl_start: 0,
	add_pusher_start: 0
  } 	

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
	if(!serverDomain) {
		console.log('请求服务器域名为空，请将wxlite/config里面的url配置成你的服务器域名');
		options.fail && options.fail({
			errCode: -9,
			errMsg: '请求服务器域名为空，请将wxlite/config里面的url配置成你的服务器域名'
		});
		return;
	}
	requestNum++;
	// console.log('requestNum: ',requestNum);
	//console.warn("请求url：", serverDomain + options.url + (options.params?('?' + formatParams(options.params) + '&'):'?') + 'userID=' + accountInfo.userID + (accountInfo.token?'&token=' + accountInfo.token:""));
	requestTask[requestSeq++] = wx.request({
		url: serverDomain + options.url + (options.params?('?' + formatParams(options.params) + '&'):'?') + 'userID=' + accountInfo.userID + (accountInfo.token?'&token=' + accountInfo.token:""),
		data: options.data || {},
		method: 'POST',
		header: {
			'content-type': 'application/json' // 默认值
		},
		// dataType: 'json'
		success: function(ret) {
			options.success && options.success(ret);
			if(ret.data.code) {
				var code = -Math.abs(ret.data.code)
				switch (options.url) {
					case 'get_push_url': {
					report.setReportData({ int64_tc_get_pushers: code}); break;
					}
					case 'add_pusher': {
					report.setReportData({ int64_tc_add_pusher: code }); break;
					}
				}
				if (noReport.indexOf(options.url) == -1) {
					console.error('逻辑失败上报：', options.url);
					report.report();
				}
			}
		},
		fail: function(ret) {
			options.fail && options.fail(ret);
			if (noReport.indexOf(options.url) == -1) {
				console.error('请求失败上报：', options.url);
				report.report();
			}
		},
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
 *   	serverDomain: 请求域名
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 *       
 * @return success 
 *   userName: 用户昵称
 */
function login(options) {
	if(!options || !options.data.serverDomain) {
		console.log('init参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'init参数错误'
		});
		return;
	}
	serverDomain = options.data.serverDomain;
	accountInfo.userID = options.data.userID;
	accountInfo.userSig = options.data.userSig;
	accountInfo.sdkAppID = options.data.sdkAppID;
	accountInfo.accountType = options.data.accType;
  	accountInfo.userName = options.data.userName || userName[Math.floor(Math.random()*10)] || accountInfo.userID;
	accountInfo.userAvatar = options.data.userAvatar || '123';

	request({
		url: 'login',
		params: {
			accountType: accountInfo.accountType,
			sdkAppID: accountInfo.sdkAppID,
			userSig: accountInfo.userSig
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
		success: function(ret) {},
		fail: function(ret) {}
	});
	serverDomain = '';
	accountInfo.userID = '';
	accountInfo.userSig = '';
	accountInfo.sdkAppID = '';
	accountInfo.accountType = '';
	accountInfo.userName = '';
	accountInfo.userAvatar = '';
	accountInfo.token = '';
	// 退出IM登录
	webimhandler.logout();
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
function loginIM(options) {
	// 初始化设置参数
	webimhandler.init({
		accountMode: accountInfo.accountMode,
		accountType: accountInfo.accountType,
		sdkAppID: accountInfo.sdkAppID,
		avChatRoomId: options.roomID || 0,
		selType: webim.SESSION_TYPE.GROUP,
		selToID: options.roomID || 0,
		selSess: null //当前聊天会话
	});
	//当前用户身份
	var loginInfo = {
		'sdkAppID': accountInfo.sdkAppID, //用户所属应用id,必填
		'appIDAt3rd': accountInfo.sdkAppID, //用户所属应用id，必填
		'accountType': accountInfo.accountType, //用户所属应用帐号类型，必填
		'identifier': accountInfo.userID, //当前用户ID,必须是否字符串类型，选填
		'identifierNick': accountInfo.userID, //当前用户昵称，选填
		'userSig': accountInfo.userSig, //当前用户身份凭证，必须是字符串类型，选填
	};
	//监听（多终端同步）群系统消息方法，方法都定义在demo_group_notice.js文件中
	var onGroupSystemNotifys = {
		// 群被解散(全员接收)
		"5": function(notify) {
			roomInfo.isDestory = true;
			event.onRoomClose({});
		},
		"11": webimhandler.onRevokeGroupNotify, //群已被回收(全员接收)
		// 用户自定义通知(默认全员接收)
		"255": function(notify) {
			console.error('收到系统通知：',notify.UserDefinedField);
			var content = JSON.parse(notify.UserDefinedField);
			if(!roomInfo.isDestory && content && content.cmd == 'notifyPusherChange') {
				mergePushers();
			}
		} 
	};

	//监听连接状态回调变化事件
	var onConnNotify = function (resp) {
		switch (resp.ErrorCode) {
			case webim.CONNECTION_STATUS.ON:
				//webim.Log.warn('连接状态正常...');
				break;
			case webim.CONNECTION_STATUS.OFF:
				webim.Log.warn('连接已断开，无法收到新消息，请检查下你的网络是否正常');
				break;
			default:
				webim.Log.error('未知连接状态,status=' + resp.ErrorCode);
				break;
		}
	};

	//监听事件
	var listeners = {
		"onConnNotify": webimhandler.onConnNotify, //选填
		"onBigGroupMsgNotify": function (msg) {
			webimhandler.onBigGroupMsgNotify(msg, function (msgs) {
				receiveMsg(msgs);
			})
		}, //监听新消息(大群)事件，必填
		"onMsgNotify": webimhandler.onMsgNotify, //监听新消息(私聊(包括普通消息和全员推送消息)，普通群(非直播聊天室)消息)事件，必填
		"onGroupSystemNotifys": onGroupSystemNotifys, //监听（多终端同步）群系统消息事件，必填
		"onGroupInfoChangeNotify": webimhandler.onGroupInfoChangeNotify,
		// 'onKickedEventCall': self.onKickedEventCall // 踢人操作
	};

	//其他对象，选填
	var others = {
		'isAccessFormalEnv': true, //是否访问正式环境，默认访问正式，选填
		'isLogOn': false //是否开启控制台打印日志,默认开启，选填
	};

	if (accountInfo.accountMode == 1) { //托管模式
		webimhandler.sdkLogin(loginInfo, listeners, others, 0, afterLoginIM, options);
	} else { //独立模式
		//sdk登录
		webimhandler.sdkLogin(loginInfo, listeners, others, 0, afterLoginIM, options);
	}
}
function afterLoginIM(options) {
	if(options.errCode) {
		// webim登录失败
		console.log('IM登录失败:',options);
		options.callback.fail && options.callback.fail({
			errCode: -2,
			errMsg: 'IM登录失败，如果你是在配置线上环境，请将IM域名[https://webim.tim.qq.com]配置到小程序request合法域名'
		});
		// 失败错误上报
		report.setReportData({
			int64_tc_join_group: -2
		});
		report.report();
		return;
	}
	// webim登录成功
	console.log('IM登录成功');
  options.callback.success && options.callback.success({
    userName: accountInfo.userName
  });
}
function afterJoinBigGroup(options) {
	if(options.errCode) {
		console.log('IM进群失败: ',options);
		options.callback.fail && options.callback.fail({
			errCode: -2,
			errMsg: 'IM进群失败'
		});
		// 失败错误上报
		var code = -Math.abs(options.errCode)
		report.setReportData({
		  int64_tc_join_group: code
		});
		report.report();
		return;
	}
	console.log('进入IM房间成功: ',roomInfo.roomID);
	options.callback.success && options.callback.success({});
	// 进入IM群成功耗时
	report.setReportData({
		int64_tc_join_group: +new Date() - ts.join_group_srart
	});
}

/**
 * [receiveMsg 接收消息处理]
 * @param {options}
 *
 * @return event.onRecvRoomTextMsg 
 *   roomID: 房间ID
 *   userID: 用户ID
 *   nickName: 用户昵称
 *   headPic: 用户头像
 *   textMsg: 文本消息
 *   time: 消息时间
 */
function receiveMsg(msg) {
	if (!msg.content) {  return; }
	console.log('IM消息: ',msg);
	if(msg.fromAccountNick == '@TIM#SYSTEM') {
		msg.fromAccountNick = '';
		msg.content = msg.content.split(';');
		msg.content = msg.content[0];
		msg.time = '';
	} else { 
		var time = new Date();
		var h = time.getHours()+'', m = time.getMinutes()+'', s = time.getSeconds()+'';
		h.length == 1 ? (h='0'+h) : '';
		m.length == 1 ? (m='0'+m) : '';
		s.length == 1 ? (s='0'+s) : '';
		time = h + ':' + m + ':' + s;
		msg.time = time;
		var contentObj,newContent;
		newContent = msg.content.split('}}');
		contentObj = JSON.parse(newContent[0] + '}}');
		if(contentObj.cmd == 'CustomTextMsg') {
			msg.nickName = contentObj.data.nickName;
			msg.headPic = contentObj.data.headPic;
			var content = '';
			for(var i = 1; i < newContent.length; i++) {
				if(i == newContent.length - 1) 
					content += newContent[i];
				else content += newContent[i] + '}}';
			}
			msg.content = content;
		}
	}
	event.onRecvRoomTextMsg({
		roomID: roomInfo.roomID,
		userID: msg.fromAccountNick,
		nickName: msg.nickName,
		headPic: msg.headPic,
		textMsg: msg.content,
		time: msg.time
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
	if(!options || !options.data.msg || !options.data.msg.replace(/^\s*|\s*$/g, '')) {
		console.log('sendRoomTextMsg参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'sendRoomTextMsg参数错误'
		});
		return;
	}
	webimhandler.sendCustomMsg({
		data: '{"cmd":"CustomTextMsg","data":{"nickName":"'+accountInfo.userName+'","headPic":"'+accountInfo.userAvatar+'"}}',
		text: options.data.msg
	},function() {
		options.success && options.success();
	});
}

/**
 * [mergePushers pushers merge操作]
 * @param {options}
 *
 * @return event.onPusherJoin 
 *   pushers: 进房人员列表
 *   
 * @return event.onPusherQuit
 *   pushers: 退房人员列表
 */
function mergePushers() {
	// CGI拉取房间成员列表开始时间戳
	ts.get_pushers_start = +new Date();
	getPushers({
		data: {
			roomID: roomInfo.roomID
		},
		success: function(ret) {
			/**
			 * enterPushers：新进推流人员信息
			 * leavePushers：退出推流人员信息
			 * ishave：用于判断去重操作
			 */
			var enterPushers = [],leavePushers = [],ishave = 0;
			console.log('去重操作');
			console.log('旧',roomInfo.pushers);
			console.log('新',ret.pushers);
			ret.pushers.forEach(function(val1){
				ishave = 0;
				roomInfo.pushers.forEach(function(val2) {
					if(val1.userID == val2.userID) {
						ishave = 1;
					}
				});
				if(!ishave)
					enterPushers.push(val1);
				ishave = 0;
			});
			roomInfo.pushers.forEach(function(val1) {
				ishave = 0;
				ret.pushers.forEach(function(val2) {
					if(val1.userID == val2.userID) {
						ishave = 1;
					}
				});
				if(!ishave)
					leavePushers.push(val1);
				ishave = 0;
			});
			roomInfo.roomID = ret.roomID;
			roomInfo.roomInfo = ret.roomInfo;
			roomInfo.roomCreator = ret.roomCreator
			// 重置roomInfo.pushers
			roomInfo.pushers = ret.pushers;
			// 通知有人进入房间
			if(enterPushers.length) {
				console.log('进房:', JSON.stringify(enterPushers));
				event.onPusherJoin({
					pushers: enterPushers
				});
			}
			// 通知有人退出房间
			if(leavePushers.length) {
				console.log('退房:', JSON.stringify(leavePushers));
				event.onPusherQuit({
					pushers: leavePushers
				});
			}

			// CGI拉取房间成员列表结束时间戳
			ts.get_pushers_end = +new Date();
			// CGI拉取房间成员列表耗时
			report.setReportData({
				str_room_creator: roomInfo.roomCreator,
				int64_tc_get_pushers: +new Date() - ts.get_pushers_start
			});
		},
		fail: function(ret) {
			// CGI拉取房间成员列表耗时
			report.setReportData({
				int64_tc_get_pushers: -Math.abs(ret.errCode)
			});
			report.report();
			// event.onRoomClose({
			// 	errCode: ret.errCode,
			// 	errMsg: ret.errMsg
			// });
		}
	});
};

/**
 * [pusherHeartBeat 推流者心跳]
 * @param {options}
 */
function pusherHeartBeat(options) {
	if(options) {
		setTimeout(function(){
			proto_pusherHeartBeat();
		},3000);
	}
	if(heart) {
		setTimeout(function(){
			proto_pusherHeartBeat();
			pusherHeartBeat();
		},7000);
	}
}
function proto_pusherHeartBeat(){
	console.log('心跳请求');
	request({
		url: 'pusher_heartbeat',
		data: {
			roomID: roomInfo.roomID,
			userID: accountInfo.userID
		},
		success: function(ret) {
			if(ret.data.code) {
				console.log('心跳失败：',ret);
				return;
			}
			console.log('心跳成功',ret);
		},
		fail: function(ret) {
			console.log('心跳失败：',ret);
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
	if(!options) { 
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
		success: function(ret) {
			if(ret.data.code) {
				console.error('获取房间列表失败: ',ret);
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
		fail: function(ret) {
			console.log('获取房间列表失败: ',ret);
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
 * 	 data: {
 * 		roomID: 房间号，可选填，后台会使用roomID和userID生成流URL，如果没有roomID，后台会使用随机数代替
 * 	 }
 *   success: 成功回调
 *   fail: 失败回调
 *
 * @return success
 *   pushURL: 推流地址
 */
function getPushURL(options) {
	if(!options) { 
		console.log('getPushURL参数错误',options);
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'getPushURL参数错误'
		});
		return; 
	}
	// 进入房间时间戳
	report.setReportData({
		int64_ts_enter_room: +new Date()
	});
	// 拉取推流地址开始时间戳
	ts.get_pushurl_start = +new Date();

	var data = {};
	if (options.data.roomID) {
		data.roomID = options.data.roomID;
		data.userID = accountInfo.userID;
	} else {
		data.userID = accountInfo.userID;
	}
	request({
		url: 'get_push_url',
		data: data,
		success: function(ret) {
			if(ret.data.code) {
				console.log('获取推流地址失败: ',ret);
				options.fail && options.fail({  
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});	
				return;
			}
			// CGI拉取推流地址耗时
			report.setReportData({
				int64_tc_get_pushurl: +new Date() - ts.get_pushurl_start
			});
			console.log('获取推流地址成功：',ret.data.pushURL);
			options.success && options.success({
				pushURL: ret.data.pushURL
			});
		},
		fail: function(ret) {
			if(ret.errMsg == 'request:fail timeout') {
				var errCode = -1;
				var errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({  
				errCode: errCode || -3,
				errMsg: errMsg || '获取推流地址失败'
			});	
		}
	});
};

/**
 * [getPushers 拉取所有主播信息]
 * @param {options}
 * 	 data.roomID: 房间号
 *   success: 成功回调
 *   fail: 失败回调
 *
 * @return success
 *   mixedPlayURL: 混流地址
 *   pushers: 房间成员
 */
function getPushers(options) {
	if(!options) { 
		console.log('getPushers参数错误',options); 
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'getPushers参数错误'
		});
		return; 
	}
	request({
		url: 'get_pushers',
		data: { roomID: options.data.roomID },
		success: function(ret) {
			if(ret.data.code) {
				console.log('拉取所有主播信息失败: ',ret);
				options.fail && options.fail({  
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});	
				return;
			}
			console.log('拉取所有主播信息成功',ret.data);
			var returnPushers = [],isInRoom = 0;
			ret.data.pushers.forEach(function(val){
				//剔除自己
				if(val.userID != accountInfo.userID) {
					returnPushers.push(val);
				} else {
					isInRoom = 1;
				}
			});
			if(options.type && !isInRoom) {
				options.fail && options.fail({  
					errCode: -1,
					errMsg: '你已退出'
				});	
				return;
			}
			options.success && options.success({
				roomID: ret.data.roomID,
				roomInfo: ret.data.roomInfo,
				roomCreator: ret.data.roomCreator,
				mixedPlayURL: ret.data.mixedPlayURL,
				pushers: returnPushers
			});
		},
		fail: function(ret) {
			if(ret.errMsg == 'request:fail timeout') {
				var errCode = -1;
				var errMsg = '网络请求超时，请检查网络状态';
			}
			options.fail && options.fail({  
				errCode: errCode || -1,
				errMsg: errMsg || '获取主播信息失败'
			});	
		}
	});
}

/**
 * [setListener 设置监听事件]
 * @param {options}
 *   onGetPusherList: 初始化成员列表
 *   onPusherJoin: 进房通知
 *   onPusherQuit: 退房通知
 *   onRoomClose: 群解散通知
 *   onRecvRoomTextMsg: 消息通知
 */
function setListener(options) {
	if(!options) { console.log('setListener参数错误',options); return; }
	event.onGetPusherList = options.onGetPusherList || function () { };
	event.onPusherJoin = options.onPusherJoin || function () { };
	event.onPusherQuit = options.onPusherQuit || function () { };
	event.onRoomClose = options.onRoomClose || function() {};
	event.onRecvRoomTextMsg = options.onRecvRoomTextMsg  || function() {};
}

/**
 * [createRoom 创建房间]
 * @param {options}
 *   data: {
 *   	roomInfo: 房间信息
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 */
function createRoom(options) {
	roomInfo.isDestory = false;
	if(!options) { 
		console.log('createRoom参数错误',options); 
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'createRoom参数错误'
		});
		return; 
	}
	roomInfo.roomInfo = options.data.roomInfo || '';
	roomInfo.pushers = [];
	proto_createRoom(options);
}
function proto_createRoom(options) {
	request({
		url: 'create_room',
		data: {
			userID: accountInfo.userID,
			roomInfo: roomInfo.roomInfo
		},
		success: function(ret) {
			if(ret.data.code) {
				console.log('创建房间失败:',ret);
				options.fail && options.fail({
					errCode: ret.data.code,
					errMsg: ret.data.message + '[' + ret.data.code + ']'
				});	
				return;
			}
			console.log('创建房间成功');
			roomInfo.roomID = ret.data.roomID;
			roomInfo.roomCreator = accountInfo.userID;
			if(roomInfo.isDestory) {
				exitRoom({});
				return;
			}
			options.success && options.success({
				roomID: roomInfo.roomID
			});
		},
		fail: function(ret) {
			console.log('创建后台房间失败:',ret);
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
 * [joinPusher 加入推流]
 * @param {options}
 *   data: {  
 *   	roomID: 房间ID
 *   	pushURL: 推流地址
 * 		roomInfo: 房间名称
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 */
function joinPusher(options) {
	if(!options || !options.data.roomID || !options.data.pushURL) {
		console.log('joinPusher参数错误',options); 
		options.fail && options.fail({
			errCode: -9,
			errMsg: 'joinPusher参数错误'
		});
		return; 
	}
	roomInfo.roomID = options.data.roomID;
	roomInfo.roomInfo = options.data.roomInfo;
	proto_joinPusher(options);
}
function proto_joinPusher(options) {
	// 开始时间戳
	ts.join_group_srart = +new Date();
	// 加入推流时间戳
	ts.add_pusher_start = +new Date();
	request({
		url: 'add_pusher',
		data: {
			roomID: roomInfo.roomID,
			roomInfo: roomInfo.roomInfo,
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
			console.log('加入推流成功');
			// CGI加入房间成员耗时
			report.setReportData({
				int64_tc_add_pusher: +new Date() - ts.add_pusher_start,
				int64_ts_add_pusher: +new Date()
			});
			// 开始心跳
			heart = true;
			pusherHeartBeat(1);
			// 进入IM群
			webimhandler.applyJoinBigGroup(roomInfo.roomID, afterJoinBigGroup, {
				success: function() {
					options.success && options.success({});
				},
				fail: options.fail
			});
			mergePushers();
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
 *   	pushURL: 推流地址
 * 		roomInfo: 房间名称
 *   }
 *   success: 成功回调
 *   fail: 失败回调
 */
function enterRoom(options) {
	roomInfo.isDestory = false;
	// 进入房间时间戳
	report.setReportData({
		str_roomid: options.data.roomID,
		str_userid: accountInfo.userID
	});
	joinPusher(options);
}

/**
 * [clearRequest 中断请求]
 * @param {options}
 */
function clearRequest() {
	for(var i = 0; i < requestSeq; i++) {
		requestTask[i].abort();
	}
	requestTask = [];
	requestSeq = 0;
}

/**
 * [exitRoom 退出房间]
 * @param {options}
 */
function exitRoom(options) {
	// 停止心跳
	stopPusherHeartBeat();
	// clearRequest();
	if(roomInfo.isDestory) return;
	roomInfo.isDestory = true;
	var roomCreator = roomInfo.roomCreator;
	
	if (roomInfo.roomID) {
		request({
			url: 'delete_pusher',
			data: {
				roomID: roomInfo.roomID,
				userID: accountInfo.userID
			},
			success: function(ret) {
				//非房间创建者回调
				// if (roomCreator != roomInfo.roomCreator) {
					if(ret.data.code) {
						console.error('退出房间失败:',ret);
						console.error('退房信息: roomID:' + roomInfo.roomID + ", userID:" + accountInfo.userID);
						options.fail && options.fail({
							errCode: ret.data.code,
							errMsg: ret.data.message + '[' + ret.data.code + ']'
						});
						return;
					}
					console.log('退出推流成功');
					options.success && options.success({});
				// }
			},
			fail: function(ret) {
				//非房间创建者回调
				// if (roomCreator != roomInfo.roomCreator) {
					console.log('退出房间失败:',ret);
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
				// }
			}
		});
	}

	// if (roomInfo.roomCreator == accountInfo.userID && roomInfo.roomID) {
	// 	//房间创建者销毁房间
	// 	request({
	// 		url: 'destroy_room',
	// 		data: {
	// 			userID: accountInfo.userID,
	// 			roomID: roomInfo.roomID
	// 		},
	// 		success: function (ret) {
	// 			if(ret.data.code) {
	// 				console.error('销毁房间失败:',ret);
	// 				console.error('房间信息: roomID:' + roomInfo.roomID + ", userID:" + accountInfo.userID);
	// 				options.fail && options.fail({
	// 					errCode: ret.data.code,
	// 					errMsg: ret.data.message + '[' + ret.data.code + ']'
	// 				});
	// 				return;
	// 			}
	// 			console.log("销毁房间成功");
	// 			options.success && options.success({});
	// 		},
	// 		fail: function (ret) {
	// 			console.error("销毁房间失败:", ret);
	// 			var errCode = ret.errCode || -1;
	// 			var errMsg = ret.errMsg || '销毁房间失败'
	// 			if(ret.errMsg == 'request:fail timeout') {
	// 				errCode = -1;
	// 				errMsg = '网络请求超时，请检查网络状态';
	// 			}
	// 			options.fail && options.fail({
	// 				errCode: errCode,
	// 				errMsg: errMsg
	// 			});
	// 		}
	// 	})
	// }
	webimhandler.quitBigGroup();	// 退出IM大群

	roomInfo.roomID = '';
	roomInfo.pushers = [];
	roomInfo.mixedPlayURL = "";
	roomInfo.roomInfo = "";
	accountInfo.pushURL = "";
	accountInfo.isCreator = false;
}

function getAccountInfo() {
	return accountInfo;
}

function getRoomInfo() {
	return roomInfo;
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
	getPushers: getPushers,
	enterRoom: enterRoom,				// 加入房间，如果房间号不存在，则后台会新建一个
	exitRoom: exitRoom,					// 退出房间
	sendRoomTextMsg: sendRoomTextMsg,	// 发送文本消息
	setListener: setListener,			// 设置监听事件
	getAccountInfo: getAccountInfo,
	getRoomInfo: getRoomInfo
}