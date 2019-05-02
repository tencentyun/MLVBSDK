package com.tencent.liteav.demo.lvb.liveroom.roomutil.http;

import android.support.annotation.Nullable;
import android.util.Log;

import com.google.gson.Gson;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.logging.HttpLoggingInterceptor;

import com.google.gson.JsonSyntaxException;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by jac on 2017/10/30.
 */

public class HttpRequests {
    private static final String TAG = HttpRequests.class.getSimpleName();

    public interface HeartBeatCallback {
        void onHeartBeatResponse(String data);
    }

    private final OkHttpClient okHttpClient;
    private static final MediaType MEDIA_JSON = MediaType.parse("application/json; charset=utf-8");
    private final String domain;
    private String userID  = "";
    private String token = "";
    private HeartBeatCallback heartBeatCallback = null;

    private class HttpInteraptorLog implements HttpLoggingInterceptor.Logger{
        @Override
        public void log(String message) {
            Log.i("HttpRequest", message);
        }
    }

    public HttpRequests(String domain) {
        this.domain = domain;

        HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor(new HttpInteraptorLog());
        interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

        this.okHttpClient = new OkHttpClient.Builder()
                .addInterceptor(interceptor)
                .connectTimeout(5, TimeUnit.SECONDS)
                .readTimeout(5, TimeUnit.SECONDS)
                .writeTimeout(5, TimeUnit.SECONDS)
                .build();
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public void setHeartBeatCallback(HeartBeatCallback callback) {
        heartBeatCallback = callback;
    }

    private String getRequestUrl(String cgi) {
        return domain.concat(String.format("%s?userID=%s&token=%s", cgi, this.userID, this.token));
    }

    public void cancelAllRequests(){
        new Thread(new Runnable() {
            @Override
            public void run() {
                okHttpClient.dispatcher().cancelAll();
            }
        }).start();
    }

    private <R extends HttpResponse> void request(Request request, final Class<R> rClass, final OnResponseCallback<R> callback){

        okHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onResponse(-1, "网络请求超时，请检查网络", null);
                }
            }

            @Override
            public void onResponse(Call call, okhttp3.Response response) throws IOException {
                String body = response.body().string();

                Gson gson = new Gson();

                try {
                    R resp = gson.fromJson(body, rClass);
                    String errorMessage = resp.message;
                    if (resp.code != 0) {
                        errorMessage += ("[err=" + resp.code + "]");
                    }
                    if (callback != null) {
                        callback.onResponse(resp.code, errorMessage, resp);
                    }

                } catch (JsonSyntaxException e) {
                    onFailure(call, new IOException(e.getMessage()));
                }
            }
        });
    }

    public void getRoomList(int index, int count,
                            final OnResponseCallback<HttpResponse.RoomList> callback){
        String body = "";

        try {
            body = new JsonBuilder()
                    .put("cnt", count)
                    .put("index", index)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        final Request request = new Request.Builder()
                .url(getRequestUrl("/get_room_list"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.RoomList.class, callback);

    }//getRoomList

    public void getPushUrl(String userID, String roomID, OnResponseCallback<HttpResponse.PushUrl> callback){

        String body = String.format("{\"userID\": \"%s\"}", userID);
        if (roomID != null && roomID.length() > 0) {
            body = String.format("{\"userID\": \"%s\", \"roomID\": \"%s\"}", userID, roomID);
        }
        Request request = new Request.Builder().url(getRequestUrl("/get_anchor_url"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.PushUrl.class, callback);
    }

    public void getAudienceList(String roomId, final OnResponseCallback<HttpResponse.AudienceList> callback){

        String body = String.format("{\"roomID\":\"%s\"}", roomId);

        Request request = new Request.Builder().url(getRequestUrl("/get_audiences"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.AudienceList.class, callback);
    }

    public void getPushers(String roomId, final OnResponseCallback<HttpResponse.PusherList> callback){

        String body = String.format("{\"roomID\":\"%s\"}", roomId);

        Request request = new Request.Builder().url(getRequestUrl("/get_anchors"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.PusherList.class, callback);
    }

    public void createRoom (String userID, String roomName,
                           String userName,
                           String userAvatar,
                           String pushURL,
                           final OnResponseCallback<HttpResponse.CreateRoom> callback){

        String body = "";
        try {
            body = new JsonBuilder()
                    .put("userID", userID)
                    .put("roomName", roomName)
                    .put("userName", userName)
                    .put("pushURL", pushURL)
                    .put("userAvatar", userAvatar)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        final Request request = new Request.Builder().url(getRequestUrl("/create_room"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.CreateRoom.class, callback);

    } //createRoom

    public void createRoom (final String roomID, String userID, String roomInfo, final OnResponseCallback<HttpResponse.CreateRoom> callback){

        String body = "";
        try {
            body = new JsonBuilder()
                    .put("userID", userID)
                    .put("roomID", roomID)
                    .put("roomInfo", roomInfo)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        final Request request = new Request.Builder().url(getRequestUrl("/create_room"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.CreateRoom.class, callback);

    } //createRoom

    public void destroyRoom(String roomID, String userID, final OnResponseCallback<HttpResponse> callback){

        String body = "";
        try {
            body = new JsonBuilder()
                    .put("userID", userID)
                    .put("roomID", roomID)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/destroy_room"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.class, callback);

    } //leaveRoom


    public void addPusher(String roomID, String userID,
                          String  userName, String userAvatar,
                          String pushURL, final OnResponseCallback<HttpResponse> callback){
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("roomID", roomID)
                    .put("userID", userID)
                    .put("userName", userName)
                    .put("userAvatar", userAvatar)
                    .put("pushURL", pushURL)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/add_anchor"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.class, callback);
    }

    public void delPusher(String roomID, String userID,
                          final OnResponseCallback<HttpResponse> callback){
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("userID", userID)
                    .put("roomID", roomID)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/delete_anchor"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.class, callback);

    }

    public void addAudience(String roomID, String userID,
                          String  userInfo, final OnResponseCallback<HttpResponse> callback){
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("roomID", roomID)
                    .put("userID", userID)
                    .put("userInfo", userInfo)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/add_audience"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.class, callback);
    }

    public void delAudience(String roomID, String userID,
                          final OnResponseCallback<HttpResponse> callback){
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("userID", userID)
                    .put("roomID", roomID)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/delete_audience"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.class, callback);

    }

    public void setCustomInfo(String roomID, String fieldName,
                          String  operation, Object value, final OnResponseCallback<HttpResponse> callback){
        String body = "";
        try {
            JsonBuilder builder = new JsonBuilder()
                    .put("roomID", roomID)
                    .put("fieldName", fieldName)
                    .put("operation", operation);
            if (value instanceof String) {
                builder.put("value", (String)value);
            } else if (value instanceof Integer) {
                builder.put("value", ((Integer)value).intValue());
            }
            body = builder.build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/set_custom_field"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.class, callback);
    }

    public void getCustomInfo(String roomID, OnResponseCallback<HttpResponse.GetCustomInfoResponse> callback) {
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("roomID", roomID)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/get_custom_Info"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.GetCustomInfoResponse.class, callback);
    }

    public boolean heartBeat(String user_id, String room_id, int roomStatusCode){
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("userID", user_id)
                    .put("roomID", room_id)
                    .put("roomStatusCode", roomStatusCode)
                    .build();
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }

        Request request = new Request.Builder().url(getRequestUrl("/anchor_heartbeat"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        try {
            okhttp3.Response response = okHttpClient.newCall(request).execute();
            String respStr = response.body().string();
            Gson gson = new Gson();
            try {
                HttpResponse resp = gson.fromJson(respStr, HttpResponse.class);
                if (resp.code == 0) {
                    if (heartBeatCallback != null) {
                        heartBeatCallback.onHeartBeatResponse(respStr);
                    }
                    return true;
                }
            } catch (JsonSyntaxException e) {
                e.printStackTrace();
                return false;
            }

        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
        return false;
    }

    public void mergeStream(String roomID, String userID, JSONObject mergeParams, final OnResponseCallback<HttpResponse.MergeStream> callback) {
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("userID", userID)
                    .put("roomID", roomID)
                    .put("mergeParams", mergeParams)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        Request request = new Request.Builder().url(getRequestUrl("/merge_stream"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.MergeStream.class, callback);
    }

    public void login(long sdkAppID, String userID, String userSig, String platform, final OnResponseCallback<HttpResponse.LoginResponse> callback) {
        try {
            String body = "";
            Request request = new Request.Builder().url(domain.concat("/login").concat(String.format("?sdkAppID=%s&userID=%s&userSig=%s&platform=%s", String.valueOf(sdkAppID), userID, userSig, platform)))
                    .post(RequestBody.create(MEDIA_JSON, body))
                    .build();

            request(request, HttpResponse.LoginResponse.class, new OnResponseCallback<HttpResponse.LoginResponse>() {
                @Override
                public void onResponse(int retcode, String retmsg, HttpResponse.LoginResponse data) {
                    if (data != null) {
                        setUserID(data.userID);
                        setToken(data.token);
                    }
                    if (callback != null) {
                        callback.onResponse(retcode, retmsg, data);
                    }
                }
            });
        }
        catch (Exception e) {
            callback.onResponse(-1, e.getMessage(), null);
        }
    }

    public void logout(final OnResponseCallback<HttpResponse> callback) {
        String body = "";
        Request request = new Request.Builder().url(getRequestUrl("/logout"))
                .post(RequestBody.create(MEDIA_JSON, body))
                .build();

        request(request, HttpResponse.class, callback);
    }

    public void report(String reportID, JSONObject statisticInfo, final OnResponseCallback<HttpResponse> callback) {
        String body = "";
        try {
            body = new JsonBuilder()
                    .put("reportID", reportID)
                    .put("data", statisticInfo)
                    .build();
        } catch (JSONException e) {
            callback.onResponse(-1, e.getMessage(), null);
            return;
        }

        String cgiUrl = "";
        cgiUrl = "https://room.qcloud.com/weapp/utils/report";

        if (cgiUrl.length() > 0) {
            Request request = new Request.Builder().url(cgiUrl)
                    .post(RequestBody.create(MEDIA_JSON, body))
                    .build();

            request(request, HttpResponse.class, callback);
        }
    }

    private class JsonBuilder{
        private JSONObject obj;
        public JsonBuilder(){
            obj = new JSONObject();
        }

        public JsonBuilder put(String k, int v) throws JSONException{
            obj.put(k, v);
            return this;
        }

        public JsonBuilder put(String k, long v) throws JSONException{
            obj.put(k, v);
            return this;
        }

        public JsonBuilder put(String k, double v) throws JSONException{
            obj.put(k, v);
            return this;
        }

        public JsonBuilder put(String k, String v) throws JSONException{
            obj.put(k, v);
            return this;
        }

        public JsonBuilder put(String k, JSONObject v) throws JSONException {
            obj.put(k, v);
            return this;
        }

        public String build(){
            return obj.toString();
        }

    }

    public interface OnResponseCallback<T>{
        public void onResponse(final int retcode, final @Nullable String retmsg, final @Nullable T data);
    }


}
