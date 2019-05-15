var constants = require('./constants');
var login = require('./login');
var Session = require('./session');
var request = require('./request');
var Tunnel = require('./tunnel');
var SocketTunnel = require('./socketTunnel');

var exports = module.exports = {
    login: login.login,
    setLoginUrl: login.setLoginUrl,
    LoginError: login.LoginError,

    clearSession: Session.clear,

    request: request.request,
    RequestError: request.RequestError,

    Tunnel: Tunnel,
    SocketTunnel: SocketTunnel,
};

// 导出错误类型码
Object.keys(constants).forEach(function (key) {
    if (key.indexOf('ERR_') === 0) {
        exports[key] = constants[key];
    }
});