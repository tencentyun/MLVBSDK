package com.tencent.qcloud.xiaozhibo.videoupload.impl;

import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

/**
 * Created by carolsuo on 2017/10/9.
 */

public class TVCDirectCredentialProvider extends BasicLifecycleCredentialProvider {
    private String secretId;
    private String secretKey;
    private String token;
    private long expiredTime;
    private long startTime;


    public TVCDirectCredentialProvider(String secretId, String secretKey, String token, long startTime, long expiredTime) {
        this.secretId = secretId;
        this.secretKey = secretKey;
        this.token = token;
        this.startTime = startTime;
        this.expiredTime = expiredTime;
    }

    @Override
    protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {
        return new SessionQCloudCredentials(secretId, secretKey, token, startTime, expiredTime);
    }
}
