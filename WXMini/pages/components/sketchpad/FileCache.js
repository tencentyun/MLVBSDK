class FileCache {

    constructor() {
        this.fileInfos = {};
    }

    _load(url, callback, retryCount) {
        if (retryCount <= 0) {
            return;
        }
        retryCount--;
        var self = this;
        if (this.fileInfos[url]) {
            callback && callback({
                errCode: 0,
                errMsg: '',
                tmpFilePath: self.fileInfos[url].tmpFilePath
            })
        } else {
            wx.downloadFile({
                url: url,
                success: function (res) {
                    self.fileInfos[url] = {
                        tmpFilePath: res.tempFilePath
                    }
                    callback && callback({
                        errCode: 0,
                        errMsg: '',
                        tmpFilePath: self.fileInfos[url].tmpFilePath
                    })
                },
                fail: function (res) {
                    console.error('下载图片失败:', res);
                    if (retryCount <= 0) {
                        callback && callback(res);
                    } else {
                        self._load(url, callback, retryCount);
                    }
                }
            })
        }
    }

    load(url, callback) {
        this._load(url, callback, 3);
    }
}

module.exports = FileCache;