function Config() {
  this.serverUrl = 'https://sxb.qcloud.com/conf_svr_sdk/conference_server/public/api/conference';
  this.privateMapKeyUrl = "https://sxb.qcloud.com/sxb_dev/?svc=account&cmd=authPrivMap";
  
  this.sdkAppID = 1400042982;
  this.accountType = 17802;
  this.userToken = null;
  this.userSig = null;
  this.userID = null;
  this.password = null;
  this.nickName = null;
}


Config.prototype.setUserID = function (userID) {
  this.userID = userID;
}
Config.prototype.setPassword = function (pwd) {
  this.password = pwd;
}

Config.prototype.setNickName = function (nickName) {
  this.nickName = nickName;
}

Config.prototype.setUserSig = function (userSig) {
  this.userSig = userSig;
}

Config.prototype.setUserToken = function (userToken) {
  this.userToken = userToken;
}

module.exports = new Config;