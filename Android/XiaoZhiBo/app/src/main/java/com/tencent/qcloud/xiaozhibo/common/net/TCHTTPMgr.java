package com.tencent.qcloud.xiaozhibo.common.net;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.xiaozhibo.TCGlobalConfig;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/**
 * Module:   TCHTTPMgr
 * <p>
 * Function: 专门用来请求小直播后台的网络请求工具类。
 * <p>
 * 1. APP 基于 OKHTTP 封装了网络请求工具模块，若您不想使用 OKHTTP 仅需修改此类即可。
 * <p>
 * 2. 封装了向小直播后台发起请求的方法 {@link TCHTTPMgr#requestWithSign(String, JSONObject, Callback)}
 * 该方法会自动带上根据 token 以及 userId 生成的 userSign 以保证安全。
 */

public class TCHTTPMgr {
    private static final String TAG = "TCHTTPMgr";

    private OkHttpClient mOkHTTPClient;
    private String mUserId, mToken;

    public static final class TCHTTPClientHolder {
        static TCHTTPMgr INSTANCE = new TCHTTPMgr();
    }

    public static final TCHTTPMgr getInstance() {
        return TCHTTPClientHolder.INSTANCE;
    }

    private TCHTTPMgr() {
        mOkHTTPClient = new OkHttpClient().newBuilder()
                .connectTimeout(10, TimeUnit.SECONDS)
                .readTimeout(10, TimeUnit.SECONDS)
                .writeTimeout(10, TimeUnit.SECONDS)
                .build();
    }

    public void setUserIdAndToken(String userId, String token) {
        mUserId = userId;
        mToken = token;
    }

    /**
     * 一般性的网络请求
     * <p>
     * 项目中可能需要网络请求
     *
     * @param url
     * @param body
     * @param callback
     */
    public void request(String url, JSONObject body, Callback callback) {
        Log.i(TAG, "request: url = " + url + " body = " + (body != null ? body.toString() : ""));
        Request request = new Request.Builder()
                .url(url)
                .post(RequestBody.create(MediaType.parse("application/json; charset=utf-8"), body != null ? body.toString() : ""))
                .build();
        mOkHTTPClient.newCall(request).enqueue(new HttpCallback(callback));
    }


    /**
     * 向小直播后台发起网络请求
     * <p>
     * 对于小直播后台的请求，我们会对访问进行鉴权，保证后台的安全性。
     * <p>
     * 这里会根据 token 以及 userId 生成 userSign {@link TCHTTPMgr#getRequestSig(JSONObject)} 用于鉴权。
     *
     * @param url
     * @param body
     * @param callback
     */
    public void requestWithSign(String url, JSONObject body, Callback callback) {
        if (TextUtils.isEmpty(TCGlobalConfig.APP_SVR_URL)) {
            if (callback != null) {
                callback.onFailure(-999, "没有填写后台地址，此功能暂不支持.");
                Log.e(TAG, "requestWithSign: token or userId can't be null.");
            }
            return;
        }
        if (TextUtils.isEmpty(mToken) || TextUtils.isEmpty(mUserId)) {
            if (callback != null) {
                callback.onFailure(-1, "token or userId can't be null.");
                Log.e(TAG, "requestWithSign: token or userId can't be null.");
            }
            return;
        }
        try {
            String strBody = body.put("userid", mUserId)
                    .put("timestamp", System.currentTimeMillis() / 1000)
                    .put("expires", 10)
                    .toString();
            String sig = getRequestSig(body);
            Log.i(TAG, "requestWithSign: url = " + url + " body = " + strBody + " sign = " + sig);
            Request request = new Request.Builder()
                    .url(url)
                    .addHeader("Liteav-Sig", sig)
                    .post(RequestBody.create(MediaType.parse("application/json; charset=utf-8"), strBody))
                    .build();
            mOkHTTPClient.newCall(request).enqueue(new XZBHttpCallback(callback));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    /**
     * 计算请求的 Sign,用于确认是合法用户访问。
     *
     * @param body
     * @return
     */
    public String getRequestSig(JSONObject body) {
        String strBody = null;
        try {
            strBody = body.put("userid", mUserId)
                    .put("timestamp", System.currentTimeMillis() / 1000)
                    .put("expires", 10)
                    .toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        String sig = TCUtils.md5(mToken + TCUtils.md5(strBody));
        return sig;
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                     网络请求回调
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    /**
     * 考虑到您项目中可能并不是使用 okHTTP 所以我们特意对callback进行了一层封装
     * <p>
     * 这样子你可以仅仅修改 @{@link TCHTTPMgr} 内的代码，即可完整网络模块的改造。
     */
    public interface Callback {

        /**
         * 登录成功
         */
        void onSuccess(JSONObject data);

        /**
         * 登录失败
         *
         * @param code 错误码
         * @param msg  错误信息
         */
        void onFailure(int code, final String msg);
    }

    /**
     * 专用用于解析小直播请求的callback
     */
    private static class HttpCallback implements okhttp3.Callback {
        private Callback callback;

        public HttpCallback(Callback callback) {
            this.callback = callback;
        }

        @Override
        public void onFailure(Call call, IOException e) {
            if (callback != null) {
                callback.onFailure(-1, " requestWithSign failure");
            }
        }

        @Override
        public void onResponse(Call call, Response response) throws IOException {
            String body = response.body().string();
            Log.i(TAG, "HttpCallback : onResponse: body = " + body);
            JSONObject jsonObject = null;
            int code = -1;
            try {
                jsonObject = new JSONObject(body);
                code = 0;
            } catch (JSONException e) {
                code = -1;
            }
            if (code == 0) {
                if (callback != null) callback.onSuccess(jsonObject);
            } else {
                if (callback != null) callback.onFailure(code, "server error.");
            }
        }
    }

    /**
     * 专用用于解析小直播请求的callback
     */
    private static class XZBHttpCallback implements okhttp3.Callback {
        private Callback callback;

        public XZBHttpCallback(Callback callback) {
            this.callback = callback;
        }

        @Override
        public void onFailure(Call call, IOException e) {
            if (callback != null) {
                callback.onFailure(-1, " requestWithSign failure");
            }
        }

        @Override
        public void onResponse(Call call, Response response) throws IOException {
            String body = response.body().string();
            Log.i(TAG, "XZBHttpCallback : onResponse: body = " + body);
            JSONObject jsonObject = null;
            int code = -1;
            String message = "";
            JSONObject data = null;
            try {
                jsonObject = new JSONObject(body);
                code = jsonObject.getInt("code");
                message = jsonObject.getString("message");
                data = jsonObject.optJSONObject("data");
            } catch (JSONException e) {
                e.printStackTrace();
            }

            if (code == 200) {
                if (callback != null) callback.onSuccess(data);
            } else {
                if (callback != null) callback.onFailure(code, message);
            }
        }
    }
}
