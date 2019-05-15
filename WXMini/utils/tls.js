var encrypt = require('encrypt.js');

var sdkappid = 10001;
function anologin(cb){
      wx.request({
            url: 'https://tls.qcloud.com/anologin', //仅为示例，并非真实的接口地址
            data: {
                "passwd": encrypt.getRSAH1(),
                "url": 'https://tls.qcloud.com/demo.html',
                "sdkappid": sdkappid
            },
            method: 'GET',
            header: {
                // 'content-type': 'application/json'
            },
            success: function(res) {
                var matches = res.data.match(/tlsAnoLogin\((.*?)\)/);
                var params = JSON.parse(matches[1]);
                login({
                    TmpSig : params.TmpSig,
                    Identifier: params.Identifier,
                    success : cb
                })
            }
        });
}



function login(opts){
    wx.request({
        url: 'https://tls.qcloud.com/getUserSig', //仅为示例，并非真实的接口地址
        data: {
            "tmpsig": opts.TmpSig,
            "identifier": opts.Identifier,
            "sdkappid": sdkappid
        },
        method: 'GET',
        header: {
            // 'content-type': 'application/json'
        },
        success: function(res) {
            var matches = res.data.match(/tlsGetUserSig\((.*?)\)/);
            var UserSig = JSON.parse(matches[1])['UserSig'];
            opts.success && opts.success({
                Identifier : opts.Identifier,
                UserSig : UserSig
            });
        },
        fail : function(errMsg){
            opts.error && opts.error(errMsg);
        }
    });
}

module.exports = {
    init : function(opts){
        sdkappid = opts.sdkappid;
    },
    anologin : anologin,
    login : login
};