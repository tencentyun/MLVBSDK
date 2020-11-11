/**
 * tim v2.7.6
 */
const TIM = require('tim_wx.js');
let selToID
    ,loginInfo
    ,sdkAppID
    ,avChatRoomId
    ,selSess
    ,tim
;

function sdkLogin(userInfo,  avChatRoomId, callback, callbackOptions) {
   tim.login({userID: userInfo.identifier, userSig: userInfo.userSig})
     .then(()=> {
        //登录成功 加入大群
        loginInfo = userInfo;
        avChatRoomId = avChatRoomId;
        callback & callback({
            callback: callbackOptions
         });

     })
     .catch((err) => {
         callback & callback({
             errCode: err,
             errMsg: err.ErrorInfo,
             callback: callbackOptions
         });
     });
}


// 创建群
function createBigGroup(options, callback, callbackOptions) {
  avChatRoomId = options.roomID;
  tim.createGroup({
        groupID: options.roomID,
        type: TIM.TYPES.GRP_AVCHATROOM,
        maxMemberNum:500,
        name: options.roomName || '',
        memberList: [],
    })
    .then(()=> { // 创建成功
          selToID = options.roomID;
          tim.joinGroup({ groupID: options.roomID, type: TIM.TYPES.GRP_AVCHATROOM })
            .then(function(imResponse) {
              callback && callback({
                errCode: 0,
                callback: callbackOptions
              });
        })
    })
    .catch((ret) => {
          callback && callback({
              errCode: ret.ErrorCode,
              errMsg: ret.err_msg,
              callback: callbackOptions
          });
    })
}

//进入群
function applyJoinBigGroup(groupId, callback, callbackOptions) {
    selSess = null;
    tim.joinGroup({ groupID: groupId, type: TIM.TYPES.GRP_AVCHATROOM })
      .then(function(imResponse) {
        switch (imResponse.data.status) {
            case TIM.TYPES.JOIN_STATUS_WAIT_APPROVAL: // 等待管理员同意
                break;
            case TIM.TYPES.JOIN_STATUS_SUCCESS: // 加群成功
                selToID = groupId;
                callback && callback({
                    errCode: 0,
                    callback: callbackOptions
                });
                console.log(imResponse.data.group); // 加入的群组资料
                break;
            case TIM.TYPES.JOIN_STATUS_ALREADY_IN_GROUP: // 已经在群中
                callback && callback({
                  errCode: 0,
                  callback: callbackOptions
                });
                break;
            default:
                break;
        }
    }).catch(function(err){
        console.error('进群请求失败', err.ErrorInfo);
        callback && callback({
            errCode: 999,
            errMsg: err.ErrorInfo || 'IM进群失败',
            callback: callbackOptions
        });
        console.warn('joinGroup error:', err); // 申请加群失败的相关信息
    });
}


// 连麦发送自定义消息
function sendC2CCustomMsg(toUserID, msg, callback) {
    let form = {
        data: msg.data || '',
        description: msg.desc || '',
        extension: msg.ext || ''
    }
    if (
      form.data.length === 0 &&
      form.description.length === 0 &&
      form.extension.length === 0
    ) {
      return
    }
    const message = tim.createCustomMessage({
        to: toUserID,
        conversationType: TIM.TYPES.CONV_C2C,
        payload: {
            data: form.data,
            description: form.description,
            extension: form.extension
        }
    })
    tim.sendMessage(message)
      .then(() => {
          console.log('发自定义消息成功');
          callback && callback({
              errCode: 0,
              errMsg: ""
          });
      })
      .catch(err => {
          console.error('发自定义消息失败:', err);
          callback && callback({
              errCode: -1,
              errMsg: '发自定义消息失败:' + err.ErrorInfo
          });
    })
    Object.assign(form, {
        data: '',
        description: '',
        extension: ''
    })
}

//发送文本消息
function sendTextMessage(msg,callback) {
  let message = tim.createTextMessage({
    to: msg.to,
    conversationType: TIM.TYPES.CONV_GROUP,
    // 消息优先级，用于群聊（v2.4.2起支持）。如果某个群的消息超过了频率限制，后台会优先下发高优先级的消息，详细请参考：https://cloud.tencent.com/document/product/269/3663#.E6.B6.88.E6.81.AF.E4.BC.98.E5.85.88.E7.BA.A7.E4.B8.8E.E9.A2.91.E7.8E.87.E6.8E.A7.E5.88.B6)
    // 支持的枚举值：TIM.TYPES.MSG_PRIORITY_HIGH, TIM.TYPES.MSG_PRIORITY_NORMAL（默认）, TIM.TYPES.MSG_PRIORITY_LOW, TIM.TYPES.MSG_PRIORITY_LOWEST
    // priority: TIM.TYPES.MSG_PRIORITY_NORMAL,
    payload: {
      text: msg.text
    }
  });
// 2. 发送消息
  tim.sendMessage(message)
    .then(function(imResponse) {
    // 发送成功
    console.log(imResponse,'文本消息发送成功');
    callback && callback();
  }).catch(function(imError) {
    // 发送失败
    console.warn('sendMessage error:', imError);
  });

}



// 解散群
function destroyGroup() {
    tim.dismissGroup(avChatRoomId)
      .then(function(imResponse) { // 解散成功
        avChatRoomId = '';
        console.log(imResponse.data.groupID,'解散成功'); // 被解散的群组 ID
    }).catch(function(imError) {
        console.warn('dismissGroup error:', imError); // 解散群组失败的相关信息
    });
}


//退出群
function quitBigGroup() {
  if(avChatRoomId){
    tim.quitGroup(avChatRoomId)
      .then(function(imResponse) {
        console.log(imResponse.data.groupID, 'IM退群成功'); // 退出成功的群 ID
      }).catch(function(imError){
      console.warn('quitGroup error:', imError); // 退出群组失败的相关信息
    })
  }
}

//登出
function logout() {
    //登出
    tim.logout()
      .then(function(imResponse) {
        console.log(imResponse.data,'IM登出成功'); // 登出成功
          if(loginInfo) {
              loginInfo.identifier = null;
              loginInfo.userSig = null;
          }
    }).catch(function(imError) {
        console.warn('logout error:', imError);
    })
}

function init(opts){
    sdkAppID = opts.sdkAppID;
    avChatRoomId = opts.avChatRoomId || 0;
    selToID = opts.selToID;
// 初始化 SDK 实例
    tim = opts.tim;
}
module.exports = {
    init : init,
    sdkLogin : sdkLogin,
    createBigGroup : createBigGroup,
    applyJoinBigGroup : applyJoinBigGroup,
    sendC2CCustomMsg : sendC2CCustomMsg,
    sendTextMessage : sendTextMessage,
    quitBigGroup : quitBigGroup,
    destroyGroup : destroyGroup,
    logout : logout,
};
