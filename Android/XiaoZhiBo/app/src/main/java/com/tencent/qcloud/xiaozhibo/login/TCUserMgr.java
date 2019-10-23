package com.tencent.qcloud.xiaozhibo.login;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.debug.GenerateTestUserSig;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.LoginInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.misc.NameGenerator;
import com.tencent.qcloud.xiaozhibo.TCGlobalConfig;
import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.report.TCELKReportMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.rtmp.TXLog;

import org.json.JSONObject;

/**
 * Module:   TCUserMgr
 * <p>
 * Function: 用户信息管理
 * <p>
 * 1. 管理用户的信息属性：userId、密码、token、昵称、头像地址等等数据
 * <p>
 * 2. 登录之后会拉取重要的信息内容如：COS相关的信息、IM的UserSign等等
 * <p>
 * 3. 提供登录、注册、更新头像等
 * <p>
 * 4. 登录成功之后，会自动初始化 MLVB 组件 {@link TCUserMgr#loginMLVB()}
 */
public class TCUserMgr {
    public static final String TAG = TCUserMgr.class.getSimpleName();

    private Context mContext;              // context 上下文
    private String mUserId = "";           // 用户id
    private String mUserPwd = "";          // 用户密码
    private String mToken = "";            // token
    private long mSdkAppID = 0;            // sdkAppId
    private String mUserSig = "";          // 用于登录到 MLVB 的userSign
    private String mAccountType;
    private String mNickName = "";         // 昵称
    private String mUserAvatar = "";       // 头像连接地址
    private int mSex = -1;//0:male,1:female,-1:unknown  // 性别
    private String mCoverPic;             //  直播用的封面图
    private String mLocation;              // 地址信息
    private CosInfo mCosInfo = new CosInfo();   // COS 存储的 sdkappid

    private static class TCUserMgrHolder {
        private static TCUserMgr instance = new TCUserMgr();
    }

    public static TCUserMgr getInstance() {
        return TCUserMgrHolder.instance;
    }

    private TCUserMgr() {
    }

    //cos 配置
    public static class CosInfo {
        public String bucket = "";
        public String appID = "";
        public String secretID = "";
        public String region = "";
    }


    public CosInfo getCosInfo() {
        return mCosInfo;
    }

    public void initContext(Context context) {
        mContext = context.getApplicationContext();
        loadUserInfo();
    }

    public boolean hasUser() {
        return !TextUtils.isEmpty(mUserId) && !TextUtils.isEmpty(mUserPwd);
    }

    public String getUserSign() {
        return mUserSig;
    }
    public String getUserToken() {
        return mToken;
    }

    public String getUserId() {
        return mUserId;
    }

    public String getNickname() {
        return mNickName;
    }

    public String getUserAvatar() {
        return mUserAvatar;
    }

    public void setNickName(String nickName, TCHTTPMgr.Callback callback) {
        mNickName = nickName;
        uploadUserInfo(callback);
    }

    public String getAvatar() {
        return mUserAvatar;
    }

    public void setAvatar(String pic, TCHTTPMgr.Callback callback) {
        mUserAvatar = pic;
        uploadUserInfo(callback);
    }

    public String getCoverPic() {
        return mCoverPic;
    }

    public void setCoverPic(String pic, TCHTTPMgr.Callback callback) {
        mCoverPic = pic;
        uploadUserInfo(callback);
    }

    public String getLocation() {
        return mLocation;
    }

    public void setLocation(String location, TCHTTPMgr.Callback callback) {
        mLocation = location;
    }

    public int getUserSex() {
        return mSex;
    }

    public void setUserSex(int sex, TCHTTPMgr.Callback callback) {
        mSex = sex;
        uploadUserInfo(callback);
    }

    public long getSDKAppID() {
        return mSdkAppID;
    }

    public String getAccountType() {
        return mAccountType;
    }


    public void logout() {
        mUserId = "";
        mUserPwd = "";
        mCoverPic = "";
        mUserAvatar = "";
        mLocation = "";
        clearUserInfo();
    }


    private void loadUserInfo() {
        //TODO: decrypt
        if (mContext == null) return;
        TXLog.d(TAG, "xzb_process: load local user info");
        SharedPreferences settings = mContext.getSharedPreferences("TCUserInfo", Context.MODE_PRIVATE);
        mUserId = settings.getString("userid", "");
        mUserPwd = settings.getString("userpwd", "");
    }

    private void saveUserInfo() {
        //TODO: encrypt
        if (mContext == null) return;
        TXLog.d(TAG, "xzb_process: save local user info");
        SharedPreferences settings = mContext.getSharedPreferences("TCUserInfo", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("userid", mUserId);
        editor.putString("userpwd", mUserPwd);
        editor.commit();
    }

    private void clearUserInfo() {
        if (mContext == null) return;
        SharedPreferences settings = mContext.getSharedPreferences("TCUserInfo", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("userid", "");
        editor.putString("userpwd", "");
        editor.commit();
    }

    /**
     *     /////////////////////////////////////////////////////////////////////////////////
     *     //
     *     //                      网络请求相关
     *     //
     *     /////////////////////////////////////////////////////////////////////////////////
     */

    /**
     * 发起网络请求注册账号
     *
     * @param userId
     * @param password
     * @param callback
     */
    public void register(final String userId, final String password, final TCHTTPMgr.Callback callback) {
        try {
            String pwd = TCUtils.md5(TCUtils.md5(password) + userId);
            JSONObject body = new JSONObject()
                    .put("userid", userId)
                    .put("password", pwd);
            TCHTTPMgr.getInstance().request(TCGlobalConfig.APP_SVR_URL + "/register", body, callback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 发起网络请求登录
     * <p>
     * 此方法为自动获取本地的 id 和 psw 进行自动登录
     *
     * @param callback
     */
    public void autoLogin(final TCHTTPMgr.Callback callback) {
        loginInternal(mUserId, mUserPwd, callback);
    }

    /**
     * 发起网络请求登录
     *
     * @param userid
     * @param password
     * @param callback
     */
    public void login(final String userid, final String password, final TCHTTPMgr.Callback callback) {
        final String pwd = TCUtils.md5(TCUtils.md5(password) + userid);
        loginInternal(userid, pwd, callback);
    }

    /**
     * 具体的登录实现
     *
     * @param userId
     * @param pwd
     * @param callback
     */
    private void loginInternal(final String userId, final String pwd, final TCHTTPMgr.Callback callback) {
        try {
            JSONObject body = new JSONObject()
                    .put("userid", userId)
                    .put("password", pwd);

            if (!TextUtils.isEmpty(TCGlobalConfig.APP_SVR_URL)) {
                TCHTTPMgr.getInstance().request(TCGlobalConfig.APP_SVR_URL + "/login", body, new TCHTTPMgr.Callback() {
                    @Override
                    public void onSuccess(JSONObject data) {
                        mUserId = userId;
                        mUserPwd = pwd;
                        int code = data.optInt("code");
                        String msg = data.optString("message");
                        final JSONObject retData = data.optJSONObject("data");
                        if (code == 200 && retData != null) {
                            mToken = retData.optString("token");                   // 用于计算网络请求的 sig
                            JSONObject serviceSig = retData.optJSONObject("roomservice_sign");
                            mUserSig = serviceSig.optString("userSig");         // IM 的 sign
                            mUserId = serviceSig.optString("userID");           // 后台分配的userId
                            mAccountType = serviceSig.optString("accountType"); //
                            mSdkAppID = serviceSig.optInt("sdkAppID");          // sdkappId

                            JSONObject cosInfo = retData.optJSONObject("cos_info");      // COS 存储相关的信息
                            mCosInfo.bucket = cosInfo.optString("Bucket");      // COS 存储的Buket
                            mCosInfo.appID = cosInfo.optString("Appid");        // COS 对应的AppId
                            mCosInfo.region = cosInfo.optString("Region");      // COS 的存储区域
                            mCosInfo.secretID = cosInfo.optString("SecretId");  // COS 的密钥ID
                            // 登录到 MLVB 组件
                            loginMLVB(new IMLVBLiveRoomListener.LoginCallback() {
                                @Override
                                public void onError(int errCode, String errInfo) {
                                    Log.i(TAG, "onError: errorCode = " + errInfo + " info = " + errInfo);
                                }

                                @Override
                                public void onSuccess() {
                                    if (callback != null) {
                                        callback.onSuccess(retData);
                                    }
                                    Log.i(TAG, "onSuccess: ");
                                }
                            });

                            // 拉取用户信息
                            fetchUserInfo(null);

                            // 保存用户信息到本地
                            saveUserInfo();


                            // 登录成功上报
                            TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_LOGIN, userId, 0, "登录成功", null);


                            TCHTTPMgr.getInstance().setUserIdAndToken(mUserId, mToken);
                        } else {
                            String errorMsg = msg;
                            if (code == 620) {
                                errorMsg = "用户不存在";
                                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_LOGIN, userId, -1, msg, null);
                            } else if (code == 621) {
                                errorMsg = "密码错误";
                                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_LOGIN, userId, -2, msg, null);
                            }
                            if (callback != null) {
                                callback.onFailure(code, errorMsg);
                            }
                            clearUserInfo();
                        }
                    }

                    @Override
                    public void onFailure(int code, String msg) {
                        if (callback != null) {
                            callback.onFailure(code, msg);
                        }
                        clearUserInfo();
                    }
                });
            } else { //没有后台，仅本地运行
                mUserId = userId;
                mSdkAppID = TCGlobalConfig.SDKAPPID;
                mUserSig = GenerateTestUserSig.genTestUserSig(mUserId);

                // 登录到 MLVB 组件
                loginMLVB(new IMLVBLiveRoomListener.LoginCallback() {
                    @Override
                    public void onError(int errCode, String errInfo) {
                        Log.i(TAG, "onError: errorCode = " + errInfo + " info = " + errInfo);
                    }

                    @Override
                    public void onSuccess() {
                        if (callback != null) {
                            callback.onSuccess(null);
                        }
                        Log.i(TAG, "onSuccess: ");
                    }
                });

                if (TextUtils.isEmpty(mNickName)) {
                    mNickName = NameGenerator.getRandomName();
                }

                // 保存用户信息到本地
                saveUserInfo();

                // 登录成功上报
                TCELKReportMgr.getInstance().reportELK(TCConstants.ELK_ACTION_LOGIN, userId, 0, "登录成功", null);
            }
        } catch (Exception e) {
            if (callback != null) {
                callback.onFailure(-1, "");
            }
        }
    }

    /**
     * 获取用户的信息
     *
     * @param callback
     */
    public void fetchUserInfo(final TCHTTPMgr.Callback callback) {
        if (!TextUtils.isEmpty(TCGlobalConfig.APP_SVR_URL)) {
            JSONObject body = new JSONObject();
            TCHTTPMgr.getInstance().requestWithSign(TCGlobalConfig.APP_SVR_URL + "/get_user_info", body, new TCHTTPMgr.Callback() {
                @Override
                public void onSuccess(JSONObject data) {
                    if (data != null) {
                        mUserAvatar = data.optString("avatar");
                        mNickName = data.optString("nickname");
                        mCoverPic = data.optString("frontcover");
                        mSex = data.optInt("sex");
                    }
                    if (callback != null) {
                        callback.onSuccess(data);
                    }
                    saveUserInfo();
                }

                @Override
                public void onFailure(int code, String msg) {
                    if (callback != null) {
                        callback.onFailure(code, msg);
                    }
                }
            });
        } else {
            if (callback != null) {
                callback.onSuccess(null);
            }
        }
    }

    /**
     * 更新用户信息
     *
     * @param callback
     */
    public void uploadUserInfo(final TCHTTPMgr.Callback callback) {
        if (!TextUtils.isEmpty(TCGlobalConfig.APP_SVR_URL)) {
            try {
                JSONObject body = new JSONObject()
                        .put("nickname", mNickName != null ? mNickName : "")
                        .put("avatar", mUserAvatar != null ? mUserAvatar : "")
                        .put("sex", mSex)
                        .put("frontcover", mCoverPic != null ? mCoverPic : "");
                TCHTTPMgr.getInstance().requestWithSign(TCGlobalConfig.APP_SVR_URL + "/upload_user_info", body, callback);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }


    /**
     * 初始化 MLVB 组件
     */
    private void loginMLVB(IMLVBLiveRoomListener.LoginCallback mlvbCb) {
        if (mContext == null) return;
        LoginInfo loginInfo = new LoginInfo();
        loginInfo.sdkAppID = getSDKAppID();
        loginInfo.userID =  getUserId();
        loginInfo.userSig = getUserSign();

        String userName =getNickname();
        loginInfo.userName = !TextUtils.isEmpty(userName) ? userName : getUserId();
        loginInfo.userAvatar = getUserAvatar();
        MLVBLiveRoom liveRoom = MLVBLiveRoom.sharedInstance(mContext);
        liveRoom.login(loginInfo, mlvbCb);
    }

}
