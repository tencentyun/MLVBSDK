package com.tencent.qcloud.xiaozhibo.common.upload;

/**
 */

import android.text.TextUtils;

import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.BasicQCloudCredentials;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;
import com.tencent.qcloud.xiaozhibo.TCGlobalConfig;
import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.rtmp.TXLog;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

/**
 *  Module:   TCCOSNetworkCredentialProvider
 *
 *  Function: COS 存储需要从服务器获取签名 signKey keyTime
 *
 **/
public class TCCOSNetworkCredentialProvider extends BasicLifecycleCredentialProvider {
    static final String TAG = "TCCOSNetworkCredentialProvider";
    String secretId = null;

    public TCCOSNetworkCredentialProvider(String secretId) {
        this.secretId = secretId;
    }


    @Override
    protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {
        String signKey = null;
        String keyTime = null;
        try {
            JSONObject json = new JSONObject();
            String sig = TCHTTPMgr.getInstance().getRequestSig(json);
            String jsonstr = json.toString();
            URL signKeyUrl = new URL(TCGlobalConfig.APP_SVR_URL+"/get_cos_sign");
            HttpURLConnection urlConnection = (HttpURLConnection) signKeyUrl.openConnection();
            urlConnection.setConnectTimeout(3000);
            urlConnection.setUseCaches(false);
            urlConnection.setReadTimeout(3000);
            urlConnection.setDoInput(true);
            urlConnection.setDoOutput(true);
            urlConnection.setRequestMethod("POST");
            urlConnection.setRequestProperty("Liteav-Sig",sig);
            urlConnection.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
            urlConnection.connect();

            OutputStream out = urlConnection.getOutputStream();
            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(out));
            bw.write(jsonstr);
            bw.flush();
            out.close();
            bw.close();
            if (urlConnection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                InputStream in = urlConnection.getInputStream();
                BufferedReader br = new BufferedReader(new InputStreamReader(in));
                String str = null;
                StringBuffer buffer = new StringBuffer();
                while ((str = br.readLine()) != null) {
                    buffer.append(str);
                }
                in.close();
                br.close();
                JSONObject rjson = new JSONObject(buffer.toString());
                if (rjson.has("code") && rjson.getInt("code") == 200) {
                    JSONObject retData = rjson.optJSONObject("data");
                    if (retData.has("signKey")) {
                        signKey = retData.getString("signKey");
                    }
                    if (retData.has("keyTime")) {
                        keyTime = retData.getString("keyTime");
                    }
                    TXLog.w(TAG, "xzb_process: get_cos_sign success");
                } else {
                    TXLog.w(TAG, "xzb_process: get_cos_sign failure");
                }
            }
            urlConnection.disconnect();

        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if (!TextUtils.isEmpty(signKey) && !TextUtils.isEmpty(keyTime))
            return new BasicQCloudCredentials(this.secretId, signKey, keyTime);
        else
            return null;
    }
}
