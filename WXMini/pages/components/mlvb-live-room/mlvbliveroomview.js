var liveroom = require('./mlvbliveroomcore.js');
const app = getApp()

// 没使用到
var errorCode = [
    { '-9001': '创建房间失败' },
    { '-9002': '获取推流地址失败' },
    { '-9003': '进入房间失败' },
    { '-9004': '请求连麦失败' },
    { '-9005': '发送消息失败'},
    { '-9006': '房间已经解散了'},
]

var _this = null;
var gListMenus = [
    {name: '静音'},
    {name: '美颜'},
    {name: '相机'},
    {name: '连麦'}
]
Component({
    options: {
      multipleSlots: true // 启用多slot支持
    },
    properties: {
        role: { type: String, value: 'audience' },
        roomid: {
            type: String, value: '', observer: function (newVal, oldVal) {
                this.data.roomID = newVal;
            }
        },
        roomname: { type: String, value: 'undefined' },
        debug: { type: Boolean, value: false },
        template: { type: String, value: 'float' },
        beauty: { type: Number, value: 5 },
        muted: {type: Boolean, value: false},
        pureaudio: {type: Boolean, value: false},
    },

    data: {
        isCaster: true,
        menuItems: [],
        userName: '',
        userID: '',
        roomID: '',
        pusherContext: null,
        playerContext: null,
        linkedPlayerContext: null,
        unload: 1,
        isInRoom: 0,
        unfold: false,
        mainPusherInfo: {
            url: '',
            aspect: '3:4',
            minBitrate: 850,
            maxBitrate: 850,
            puserID: '',
        },
        audience: {
            url: null,
            mixUrl: null,
            accelerateUrl: null,
            pusherName: '',
            pusherID: '',
            isLinked: false,
            aspect: '3:4',
            loading: false,
            objectFit: false
        },
        linkPusherInfo: {
            url: '',
            loading: true,
            debug: true,
        },
        members: [],
        visualPlayers: [],
        requestLinking: false,
        mode: 'RTC',
        headerHeight: app.globalData.headerHeight,
        statusBarHeight: app.globalData.statusBarHeight,
        quitLinking: false,
    },

    methods: {
        toggleDebug(){
            var self = this;
            self.setData({
                debug: !self.data.debug
            }, () => {
                console.log('>> Debug: ', self.data.debug);
            })
        },
        toggleBeauty(){
            var self = this;
            var bty = self.data.beauty == 5 ? 0 : 5;
            self.setData({
                beauty: bty
            }, () => {
                console.log(bty > 0 ? '开启美颜' : '关闭美颜')
            })

        },
        toggleMuted(){
            var self = this;
            self.setData({
                muted: !self.data.muted
            }, () => {
                console.log(self.data.muted ? '静音' : '非静音')
            })
        },
        clipPusherIDs(){
            var self = this;
            var data = '';
            var main = ''; 
            var link = '';
            if (self.data.mainPusherInfo.url) main = substring(aa.lastIndexOf('/') + 1, aa.indexOf('?'))
            if (self.data.linkPusherInfo.url) link = substring(aa.lastIndexOf('/') + 1, aa.indexOf('?'))
            data = `MAIN: ${main}; LINK: ${link}`
            wx.setClipboardData({
                data: data,
                success: function (res) {
                    wx.showToast({
                        title: `复制成功`,
                        duration: 500,
                        mask: true,
                    })
                }
            })
        },
        unfoldCtrlMenu(){
            var self = this;
            
            var items = self.data.menuItems;
            if (items.length > 0){
                items = [];
            }else {
                items = gListMenus;
            }
            self.setData({
                menuItems: items,
                unfold: !self.data.unfold
            }, () => {
                wx.showToast({
                    title: items.length > 0 ? 'unfold' : 'close',
                    duration: 500,
                    mask: true,
                })
            })
        },
        selectMenu(e){
            var self = this;
            var index = e.currentTarget.dataset.index;
            wx.showToast({
                title: `选中 ${index}: ${self.data.menuItems[index]}`,
                duration: 500,
                mask: true,
            })
        },
        sendTextMsg(text) {
            var self = this;
            if (text.startsWith('>')){
                switch(text){
                    case '>debug': {
                        self.toggleDebug();
                        return;
                    }
                }
            }
            liveroom.sendRoomTextMsg({
                data:{msg: text},
                success: ()=>{
                },
                fail: (e) => {
                    console.log("发送消息失败: ", e)
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -9005,
                        detail: `发送消息失败`
                    })
                }
            });
        },

        switchCamera(){
            var self = this;
            console.log('切换摄像头: ', self.data.pusherContext)
            self.data.pusherContext && self.data.pusherContext.switchCamera({});
        },

        respondJoinAnchor(agree, audience) {
            console.info(`respondJoinAnchor(agree:${agree}, audience:${audience}) called`)
            var self = _this;
            if (agree) {
                liveroom.acceptJoinAnchor({
                    data: audience
                });
            } else {
                liveroom.rejectJoinAnchor({
                    data: audience
                });
            }
        },

        setupLiveRoomListener() {
            var self = this;
            liveroom.setListener({
                onRoomDestroy: self.onRoomDestroy,
                onRecvRoomTextMsg: self.onRecvRoomTextMsg,
                onSketchpadData: self.onSketchpadData,
                onKickoutJoinAnchor: self.onKickoutJoinAnchor,
                onRequestJoinAnchor: self.onRequestJoinAnchor,
                onAnchorExit: self.onAnchorExit,
                onAnchorEnter: self.onAnchorEnter
            });
        },

        start() {
            console.info('start() called')
            var self = this;
            if (self.data.isCaster == false) {     //观众
                self.enter();
            } else {                                //主播
                //请求CGI:get_push_url，异步获取到推流地址pushUrl
                liveroom.getPushURL({
                    success: function (ret) {
                        console.log('getPushURL 成功，', ret);
                        self.data.mainPusherInfo.url = ret.pushURL;
                        // console.log('设置推流模式为:SD');
                        self.setData({
                            mainPusherInfo: self.data.mainPusherInfo
                            // mode: 'SD'
                        }, function () {
                            self.setupLiveRoomListener();
                            self.data.pusherContext = wx.createLivePusherContext('pusher', self);
                            console.warn('创建 pusherContext：', self.data.pusherContext);
                            //开始推流
                            self.data.pusherContext.start();
                        });
                    },
                    fail: function (ret) {
                        console.log('获取推流地址失败: ', ret);
                        self.triggerEvent('RoomEvent', {
                            tag: 'error',
                            code: -9002,
                            detail: `获取推流地址失败`
                        })
                    }
                });
            }
        },
        stop() {
            console.log('stop() called');                        
            var self = this;
            console.log('stop pusherContext：', self.data.pusherContext, self.data.playerContext);
            self.data.pusherContext && self.data.pusherContext.stop();
            self.data.playerContext && self.data.playerContext.stop();
            var players = self.data.members;
            players && players.forEach(p => { p.context && p.context.stop() });
            // 重置信息
            self.setData({
                unload: 1,
                members: [{}],
                visualPlayer: [],
                pusherContext: null,
                playerContext: null,
                linkedPlayerContext: null,
            });
            self.exit();
            liveroom.setListener({});
        },
        pause() {
            console.log('pause() called');
            var self = this;
            self.data.pusherContext && self.data.pusherContext.pause();
            self.data.playerContext && self.data.playerContext.pause();
        },
        resume() {
            console.log('resume() called');            
            var self = this;
            self.data.pusherContext && self.data.pusherContext.resume();
            self.data.playerContext && self.data.playerContext.resume();
        },

        onAnchorEnter(ret) {
            console.log('==> onPusherJion() called: ', ret)
            var self = _this;
            var temp = self.data.members.filter(e => e.userID);
            var pushers = ret.pushers;
            //去掉自己
            var index = pushers.map(p => p.userID).indexOf(self.data.userID);
            if (index != -1) pushers.splice(index, 1);
            //去掉主播
            index = pushers.map(p => p.userID).indexOf(self.data.audience.pusherID);
            if (index != -1) pushers.splice(index, 1);

            console.log(`%c===> ${pushers.length} 人加入Link`, "color: red")
            pushers = pushers.map(p => {
                return {
                    userID: p.userID,
                    userName: p.userName,
                    accelerateURL: p.accelerateURL,
                    context: null
                }
            });     
            
            temp = temp.concat(pushers);
            console.log('设置推流模式为:RTC');
            self.setData({
                members: temp
                // mode: 'RTC'
            }, function () {
                temp.forEach(p => {
                    if (p.context) return;
                    if (p.userID) p.context = wx.createLivePlayerContext(p.userID, self)
                })
                console.log('data.members: ', self.data.members)
            })
        },

        onAnchorExit(ret) {
            console.log('===> onAnchorExit() called: ', ret)
            var self = _this;
            var temp = [];
            var pushers = ret.pushers;
            var members = self.data.members;
            for (var p of pushers) {
                for (var i in members) {
                    if (p.userID == members[i].userID) {
                        members[i].context && members[i].context.stop();
                        members.splice(i, 1);
                        members.push({});
                        break;
                    }
                }
            }

            // var mode = 'SD';
            // for (var i=0; i<members.length; ++i) {
            //     if (members[i].userID) {
            //         mode = 'RTC';
            //     }
            // }
            // console.log('设置推流模式为:', mode);

            self.setData({
                members: members
                // mode: mode
            }, () => {
                console.log('members after onAnchorExit: ', self.data.members)
            })
        },
        onRequestJoinAnchor(pusher) {
            var self = _this;
            console.log('onRequestJoinAnchor() called, pusher = ', JSON.stringify(pusher))
            self.triggerEvent('RoomEvent', {
                tag: 'requestJoinAnchor',
                code: 0,
                detail: pusher
            })
        },
        onKickoutJoinAnchor() {
            console.log('onKickoutJoinAnchor() called')
        },
        enter() {
            var self = this;
            console.log('enter room width roomid: ', self.data.roomID);
            liveroom.setListener({
                onRoomDestroy: self.onRoomDestroy,
                onRecvRoomTextMsg: self.onRecvRoomTextMsg,
                onSketchpadData: self.onSketchpadData,
                onAnchorExit: self.onLinkPusherQuit,
                onAnchorEnter: self.onAnchorEnter,
                onKickoutJoinAnchor: self.onKickoutJoinAnchor
            });
            liveroom.enterRoom({
                data: {
                    roomID: self.data.roomID
                },
                success: function (ret) {
                    console.info('enterRoom 成功: ', ret)
                    self.data.audience.url = ret.mixedPlayURL;
                    self.data.audience.mixUrl = ret.mixedPlayURL;
                    self.data.mainPusherInfo.puserID = ret.roomCreator;
                    if (ret.pushers && ret.pushers.length > 0) {
                        self.data.audience.pusherName = ret.pushers[0].userName;
                        self.data.audience.pusherID = ret.pushers[0].userID;
                        self.data.audience.accelerateUrl = ret.pushers[0].accelerateURL;
                    } else {
                        console.error('缺少加速流');
                    }
                    //{ "cmd":"C2CCustomMsg", "data":{ userName: "xxx", userAvatar:"xxx", "roomID":"XXX", "cmd":"xx", msg:"xx" } }
                    liveroom.sendC2CCustomMsg({ cmd: "sketchpad", msg: '{"type":"request", "action":"currentPPT"}' })
                    self.playMixedUrl().then(() => {
                        console.log('playMixedUrl done');
                    }).catch(e => {
                        console.log('playMixedUrl Error: ', e)
                    });
                },
                fail: function (ret) {
                    console.error('enterRoom 失败: ', ret)
                    if (!self.data.unload) {
                        self.data.playerContex && self.data.playerContext.stop();
                        self.triggerEvent('RoomEvent', {
                            tag: 'error',
                            code: -9003,
                            detail: 'enterRoom 失败'
                        })
                    }
                }
            });
        },

        create() {
            console.log('create() called')
            var self = this;
            var createRoomInfo = {
              roomInfo: self.data.roomname,
              pushURL: self.data.mainPusherInfo.url
            };
            if (self.data.roomID && self.data.roomID.length > 0) {
              createRoomInfo.roomID = self.data.roomID;
            }
            liveroom.createRoom({
                data: createRoomInfo,
                success: function (ret) {
                    console.log('创建房间成功, ret = ', ret)
                    self.setData({
                        roomID: ret.roomID
                    })
                    self.triggerEvent('RoomEvent', {
                        tag: 'created',
                        code: 0,
                        detail: '创建房间成功'
                    })
                },
                fail: function (ret) {
                    console.error("创建房间失败", ret);
                    if (!self.data.unload) {
                        self.data.pusherContext.stop();
                    }
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -9001,
                        detail: '创建房间失败'
                    })
                }
            });
        },

        exit: function () {
            console.log('exit() called')
            liveroom.exitRoom({});
        },

        onPlay(ret) {
            var self = this;
            console.error('拉流情况：', ret.detail.code);
            switch (ret.detail.code) {
                case -2301: {
                    // 多次拉流失败
                    console.error('多次拉流失败')
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: ret.detail.code,
                        detail: '多次拉流失败'
                    });
                    break;
                };
            }
        },

        linkJionPusher() {
            console.log("linkJionPusher() called")
            var self = this;
            if (!self.data.linkPusherInfo.url || !self.data.roomID) {
              console.warn("linkJionPusher() stop.");
              return;
            }
            if (self.data.quitLinking) {
              //正在退出连麦，所以不进行连麦操作
              console.warn("正在退出连麦");
              return;
            }
            liveroom.joinAnchor({
                data: {
                    pushURL: self.data.linkPusherInfo.url,
                    roomID: self.data.roomID
                },
                success: function () {
                    console.log('连麦成功完成')
                    if (self.data.isCaster == false) {
                        self.triggerEvent('RoomEvent', {
                            tag: 'linkOn',
                            code: 0,
                            detail: '连麦成功完成'
                        })
                    }
                },
                fail: function (e) {
                    console.error('连麦失败: ', e)
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: 0,
                        detail: '连麦失败'
                    })
                }
            })
        },

        playMixedUrl() {
            console.log("==> playMixedUrl")
            var self = _this;
            var players = [{
                debug: false,
                mute: false,
                url: self.data.audience.mixUrl,
                mode: 'live',
                maxCache: 3,
                minCache: 1,
                loading: false,
                objectFit: 'fillCrop',
                userName: self.data.audience.pusherName
            }]
            return new Promise((resolve) => {
                self.setData({
                    visualPlayers: players
                }, function () {
                    // self.data.playerContext = wx.createLivePlayerContext('player', self);
                    // self.data.playerContext.play();
                    resolve()
                })
            })
        },

        playAccelerateUrl() {
            console.info('playAccelerateUrl() called')
            var self = _this;
            var players = [{
                debug: false,
                mute: false,
                url: self.data.audience.accelerateUrl,
                mode: 'RTC',
                loading: false,
                objectFit: 'fillCrop',                
                userName: self.data.audience.pusherName
            }]
            return new Promise((resolve) => {
                self.setData({
                    visualPlayers: players
                }, function () {
                    players[0].minCache = 0.1;
                    players[0].maxCache = 0.3;
                    self.setData({
                        visualPlayers: players
                    })
                    // self.data.playerContext = wx.createLivePlayerContext('player', self);
                    resolve()
                })
            });
        },

        stopPlayUrl() {
            var self = _this;
            // self.data.playerContext && self.data.playerContext.stop();
            return new Promise((resolve) => {
                self.setData({
                    visualPlayers: [],
                }, function () {
                    resolve()
                })
            });
        },

        getPushUrl() {
            console.info('getPushUrl() called')
            var self = _this;
            return new Promise(function (resolve, reject) {
                liveroom.getPushURL({
                    success: function (ret) {
                        console.log('getPushURL() 成功，', ret);
                        resolve(ret.pushURL)
                    },
                    fail: function (e) {
                        console.log('getPushUrl() 获取推流地址失败: ', e);
                        reject(e)
                    }
                });
            })
        },
        startLinkPush(url) {
            console.info('startLinkPush() called')
            var self = _this;
            return new Promise(function (resolve, reject) {
                self.data.linkPusherInfo.url = url;
                self.data.members.splice(0, 1);

                // console.log('设置推流模式为:RTC');
                self.setData({
                    members: self.data.members,
                    linkPusherInfo: self.data.linkPusherInfo
                    // mode: 'RTC'
                }, function () {
                    self.data.pusherContext = wx.createLivePusherContext('audience_pusher', self);
                    console.log('startLinkPush.创建 pusherContext：', self.data.pusherContext);
                    self.data.pusherContext.start();
                    resolve()
                });
            })
        },
        link() {
            var self = this;
            //停止mix流播放 --> 播放 accelerate流 --> 获取推流连接开始推流 --> onLinkPush 成功后 jionPusher
            Promise.resolve()
                .then(self.stopPlayer)
                .then(self.playAccelerateUrl)
                .then(self.getPushUrl)
                .then(self.startLinkPush)
                .then(function () {
                    return new Promise(function (resolve, reject) {
                        console.log('----> link() self.data: ', self.data)
                        resolve()
                    })
                })
                .catch(function (e) {
                    console.log("过程出错： 停止mix流播放 --> 播放 accelerate流 --> 获取推流连接开始推流 --> onLinkPush 成功后 jionPusher: ", e)
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -1,
                        detail: '连麦过程发生错误'
                    });
                })
        },
        requestJoinAnchor() {
            console.log('requestJoinAnchor() called')
            var self = _this;
            if (self.data.requestLinking){
                wx.showToast({
                    title: '等待大主播接受连麦',
                    duration: 1000,
                })
                return;
            }
            console.info('用户请求连麦')
            self.data.requestLinking = true;                    
            liveroom.requestJoinAnchor({
                data: {
                    timeout: 10000
                },
                success: function (ret) {
                    self.data.requestLinking = false;                    
                    console.log('请求连麦成功: ', ret)
                    self.link();
                },
                fail: function (e) {
                    console.log('请求连麦失败: ', e)
                    self.data.requestLinking = false;                                        
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -9004,
                        detail: e.errMsg
                    })
                }
            });
        },

        onLinkError(e) {
            console.error("onLinkError() called: ", e)
            self.triggerEvent('RoomEvent', {
                tag: 'error',
                code: -2,
                detail: "播放错误"
            })
        },
      kickoutJoinAnchor(e) {
            console.log('kickoutJoinAnchor() called');
            var self = _this;
            console.log('==> kickoutJoinAnchor: ', e)
            var userID = e.currentTarget.dataset.userid;
            liveroom.kickoutJoinAnchor({
                data: { userID: userID },
                success: (ret) => {
                    console.log("--> 踢人成功： ", ret)
                    var members = self.data.members;
                    var index = members.map(m => m.userID).indexOf(userID);
                    if (index != -1) {
                        // members[index].context && members[index].context.stop();
                        members.splice(index, 1)
                        members.push({})
                    }
                    self.setData({
                        members: members
                    })
                    console.log('data.members: ', self.data.members)
                },
                fail: (e) => {
                    console.log("---> 踢人失败： ", e)
                }
            })
            //todo
        },
        quitLink() {
            console.log('quitLink() called')
            var self = this;
            if (self.data.pusherContext == null || self.data.quitLinking) {
                console.warn("no need quitLink again")
                return;
            }
            self.data.quitLinking = true;
            liveroom.quitJoinAnchor({
              success: (ret) => {
                    console.log('quitJoinAnchor 成功：', ret)
                    self.resetToAudience();
                    self.data.quitLinking = false;
                },
              fail: (e) => {
                    console.error('quitJoinAnchor Error: ', e);
                    self.resetToAudience();
                    // self.triggerEvent('RoomEvent', {
                    //     tag: 'error',
                    //     code: -1,
                    //     detail: '退出连麦"quitJoinAnchor"返回错误'
                    // })
                    self.data.quitLinking = false;
                }
            })
        },
        resetToAudience() {
            console.log('resetToAudience() called');
            var self = _this;
            Promise.resolve()
                .then(() => {  // 停止推流
                    console.log('停止推流')
                    return new Promise((resolve) => {
                        console.log('停止推流')
                        self.data.pusherContext && self.data.pusherContext.stop();
                        self.data.linkPusherInfo.url = null;
                        self.setData({
                            pusherContext: null,
                            linkPusherInfo: self.data.linkPusherInfo
                        }, () => resolve())
                    })
                })
                .then(() => { // 清理member players
                    console.log('清理 member players')
                    return new Promise((resolve) => {
                        var pushers = self.data.members;
                        pushers && pushers.forEach(p => { p.context && p.context.stop() })
                        pushers = [{},{},{}]
                        self.setData({ members: pushers }, () => resolve());
                    });
                })
                .then(self.stopPlayUrl) // 停止播放 acelerate 流
                .then(self.playMixedUrl) //播放mixed 流
                .then(()=>{
                    return new Promise((resolve)=>{
                        self.triggerEvent('RoomEvent', {
                            tag: 'linkOut',
                            code: 0,
                            detail: '连麦断开'
                        })
                        resolve();
                    })
                })
                .catch((e) => {
                    console.error('resetToAudience 流程出现错误：', e);
                })
        },
        onLinkPusherQuit(ret) {
            console.log('onLinkPusherQuit() called ', ret)
            var self = _this;
            var pushers = ret.pushers;
            if (!pushers) return;
            var userIndex = pushers.map(p => { return p.userID }).indexOf(self.data.userID);
            if (userIndex != -1) { // 自己退出link
                
                self.resetToAudience();
            } else { // 别人退出link
                self.onAnchorExit(ret);
            }
        },

        onKickoutJoinAnchor(ret) {
            console.log('onKickoutJoinAnchor() called');
            var self = _this;
            console.log('%c onKickoutJoinAnchor: ', 'color: red;', ret)
            self.quitLink();
        },

        onPushEvent(code) {
            var self = this;
            switch (code) {
                case -1301: {
                    console.log('打开摄像头失败: ', code);
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -1301,
                        detail: '打开摄像头失败'
                    })
                    break;
                };
                case -1302: {
                    console.log('打开麦克风失败: ', code);
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -1302,
                        detail: '打开麦克风失败'
                    })
                    break;
                };
                case -1307: {
                    console.error('推流连接断开: ', code);
                    // 推流连接断开就做退房操作
                    self.exit();
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -1307,
                        detail: '推流连接断开'
                    })
                    break;
                };
                case -1305 : {
                    console.log('不支持的视频分辨率');
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -1305,
                        detail: '不支持的视频分辨率'
                    })
                    break;
                }
                case -1306 : {
                    console.log('不支持的音频采样率');
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -1306,
                        detail: '不支持的音频采样率'
                    })
                    break;
                }
                default: {
                    console.log('推流事件：', code);
                    break;
                }
            }
        },
        onLinkPush(ret) {
            var self = this;
            console.log('onLinkPush推流情况：', ret.detail.code);
            switch (ret.detail.code) {
                case 1002: {
                    console.log('onLinkPush推流成功：', ret.detail.code);
                    self.linkJionPusher();
                    break;
                };
                case 5000: {
                    console.log('收到5000: ', ret.detail.code);
                    // 收到5000就退房
                    self.exit();
                    self.data.exit = 5000;
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: 5000,
                        detail: '收到5000就退房'
                    })
                    break;
                };
                default: {
                    self.onPushEvent(ret.detail.code);
                    break;
                }
            }

        },
        onMainPush(ret) {
            var self = this;
            console.log('>> onMainPush() called: ', ret)
            console.log('推流情况：', ret.detail.code);
            switch (ret.detail.code) {
                case 1005: {
                    console.log("推流动态分辨率改变： ", ret);
                    break;
                }
                case 1002: {
                    console.log('推流成功：', ret.detail.code);
                    if (!self.data.isInRoom) {
                        self.setData({ isInRoom: 1 });
                        //4.推流成功，请求CGI:create_room，获取roomID、roomSig
                        self.create();
                    }
                    break;
                };
                case -1307: {
                    console.error('推流连接断开: ', ret.detail.code);
                    self.exit();
                    self.data.exit = -1307;
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: -1307,
                        detail: '推流连接断开'
                    })
                    break;
                }
                case 5000: {
                    console.log('收到5000: ', ret.detail.code);
                    // 收到5000就退房
                    self.exit();
                    self.data.exit = 5000;
                    self.triggerEvent('RoomEvent', {
                        tag: 'error',
                        code: 5000,
                        detail: '收到5000就退房'
                    })
                    break;
                };
                default: {
                    self.onPushEvent(ret.detail.code);
                    break;
                }
            }
        },
        onMainError(e) {
            var self = this;
            console.error("onMainError called: ", e)
            self.triggerEvent('RoomEvent', {
                tag: 'error',
                code: -1,
                detail: e.detail && e.detail.errMsg || "推流错误"
            })
        },

        onMainPlayState(e) {
            console.log('===> onMainPlayState: ', e)
            var self = this;
            //主播拉流失败不抛错误事件出去 
            if (self.data.isCaster == true) {
              return;
            }
            switch (e.detail.code) {
              case -2301: {
                // 多次拉流失败
                console.error('多次拉流失败')
                self.triggerEvent('RoomEvent', {
                  tag: 'error',
                  code: e.detail.code,
                  detail: '多次拉流失败'
                });
                break;
              };
            }
        },

        onMainPlayError(e) {
            console.log('===> onMainPlayError: ', e)
        },

        onRoomDestroy(e) {
            console.log('onRoomDestroy: e=', e)
            _this && _this.triggerEvent('RoomEvent', { tag: 'roomClosed', code: -9006, detail: '房间已经解散了' })
        },

        onRecvRoomTextMsg(ret) {
            var self = _this;
            console.log("onRecvRoomTextMsg called, ret: ", ret)
            self.triggerEvent('RoomEvent', {
                tag: 'recvTextMsg',
                code: 0,
                detail: ret
            })
        },
        onSketchpadData(ret) {
            var self = _this;
            console.log("onSketchpadData called, ret: ", ret)
            self.triggerEvent('RoomEvent', {
                tag: 'sketchpadData',
                code: 0,
                detail: ret
            })
        }
    },

    attached: function () {
        console.log('ready() called')
        // 保持屏幕常亮
        wx.setKeepScreenOn({
            keepScreenOn: true
        })

        var self = this;
        _this = this;
        var { userID, userName } = liveroom.getAccountInfo();
        self.data.isCaster = self.data.role == 'anchor';

        self.setData({
            isCaster: self.data.isCaster,
            userID: userID,
            userName: userName,
            unload: 0,
            members: [{},{},{}]
        });
        console.log('data: ', self.data)
    },

    detached: function () {
        console.log('detached() called')
        var self = this;
        _this = null;
        self.stop();
    },

})