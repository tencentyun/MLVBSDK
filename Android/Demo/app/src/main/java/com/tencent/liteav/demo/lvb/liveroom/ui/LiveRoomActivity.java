package com.tencent.liteav.demo.lvb.liveroom.ui;

import android.app.AlertDialog;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.misc.CommonAppCompatActivity;
import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.ui.fragment.LiveRoomChatFragment;
import com.tencent.liteav.demo.lvb.liveroom.ui.fragment.LiveRoomListFragment;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.LoginInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.misc.NameGenerator;
import com.tencent.liteav.demo.lvb.liveroom.debug.GenerateTestUserSig;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.logging.HttpLoggingInterceptor;


public class LiveRoomActivity extends CommonAppCompatActivity implements LiveRoomActivityInterface {

    private static final String TAG = LiveRoomActivity.class.getSimpleName();

    public final Handler uiHandler = new Handler();

    private MLVBLiveRoom liveRoom;
    private String userId;
    private String          userName;
    private String          userAvatar = "avatar";
    private TextView titleTextView;
    private TextView globalLogTextview;
    private ScrollView globalLogTextviewContainer;
    private Runnable        retryInitRoomRunnable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_live_room);

        findViewById(R.id.liveroom_back_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        titleTextView = ((TextView) findViewById(R.id.liveroom_title_textview));
        titleTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (retryInitRoomRunnable != null) {
                    synchronized (LiveRoomActivity.this) {
                        retryInitRoomRunnable.run();
                        retryInitRoomRunnable = null;
                    }
                }
            }
        });

        globalLogTextview = ((TextView) findViewById(R.id.liveroom_global_log_textview));
        globalLogTextview.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                new AlertDialog.Builder(LiveRoomActivity.this, R.style.RtmpRoomDialogTheme)
                        .setTitle("Global Log")
                        .setMessage("清除Log")
                        .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).setPositiveButton("清除", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        globalLogTextview.setText("");
                        dialog.dismiss();
                    }
                }).show();

                return true;
            }
        });
        findViewById(R.id.liveroom_link_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/454/14606"));
                startActivity(intent);
//                AudioManager mAudioManager = (AudioManager) LiveRoomActivity.this.getSystemService(Context.AUDIO_SERVICE);
//                Toast.makeText(LiveRoomActivity.this, "speakeron = " + mAudioManager.isSpeakerphoneOn()
//                        + ", scoOn = " + mAudioManager.isBluetoothScoOn()
//                        + ", a2dpOn = " + mAudioManager.isBluetoothA2dpOn()
//                        + ", mode = " + mAudioManager.getMode(), Toast.LENGTH_SHORT).show();
            }
        });

        globalLogTextviewContainer = ((ScrollView) findViewById(R.id.liveroom_global_log_container));

        liveRoom = MLVBLiveRoom.sharedInstance(this.getApplicationContext());
        liveRoom.setListener(new MLVBLiveRoomListener());

        initializeLiveRoom();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        liveRoom.setListener(null);
        liveRoom.logout();
    }

    @Override
    public void onBackPressed() {
        Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
        if (fragment instanceof LiveRoomChatFragment){
            ((LiveRoomChatFragment) fragment).onBackPressed();
                }
        else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public void onPermissionDisable() {
        new AlertDialog.Builder(this, R.style.RtmpRoomDialogTheme)
                .setMessage("需要录音和摄像头权限，请到【设置】【应用】打开")
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        finish();
                    }
                });
    }

    @Override
    public void onPermissionGranted() {

    }

    private class LoginInfoResponse {
        public int code;
        public String message;
        public int sdkAppID;
        public String accType;
        public String userID;
        public String userSig;
    }

    private static class HttpInterceptorLog implements HttpLoggingInterceptor.Logger{
        @Override
        public void log(String message) {
            Log.i("HttpRequest", message+"\n");
        }
    }

    private void initializeLiveRoom() {
        setTitle("连接中...");

        SharedPreferences sp = getSharedPreferences("com.tencent.demo", Context.MODE_PRIVATE);
        String userIdFromSp = sp.getString("userID", "");
        String userNameFromSp = sp.getString("userName", "");
        if (!TextUtils.isEmpty(userIdFromSp)) {
            userId = userIdFromSp;
        } else {
            userId = NameGenerator.getRandomUserID();
            sp.edit().putString("userId", userId).commit();
        }

        if (!TextUtils.isEmpty(userNameFromSp)) {
            userName = userNameFromSp;
        } else {
            userName = NameGenerator.getRandomName();
            sp.edit().putString("userName", userName).commit();
        }

        LoginInfo loginInfo       = new LoginInfo();
        loginInfo.sdkAppID       = GenerateTestUserSig.SDKAPPID;
        loginInfo.userID         = userId;
        loginInfo.userSig        = GenerateTestUserSig.genTestUserSig(userId);
        loginInfo.userName       = userName;
        loginInfo.userAvatar     = userAvatar;

        liveRoom.login(loginInfo, new IMLVBLiveRoomListener.LoginCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                setTitle(errInfo);
                printGlobalLog(String.format("[Activity]LiveRoom初始化失败：{%s}", errInfo));
                retryInitRoomRunnable = new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(LiveRoomActivity.this, "重试...", Toast.LENGTH_SHORT).show();
                        initializeLiveRoom();
                    }
                };
            }

            @Override
            public void onSuccess() {
                setTitle("手机直播");
                printGlobalLog("[Activity]LiveRoom初始化成功,userID{%s}", userId);
                Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
                if (!(fragment instanceof LiveRoomChatFragment)) {
                    FragmentTransaction ft = getFragmentManager().beginTransaction();
                    fragment = LiveRoomListFragment.newInstance(userId);
                    ft.replace(R.id.rtmproom_fragment_container, fragment);
                    ft.commit();
                }
            }
        });
    }

    @Override
    public MLVBLiveRoom getLiveRoom() {
        return liveRoom;
    }

    @Override
    public String getSelfUserID() {
        return userId;
    }

    @Override
    public String getSelfUserName() {
        return userName;
    }

    @Override
    public void showGlobalLog(final boolean enable) {
        if (uiHandler != null)
        uiHandler.post(new Runnable() {
            @Override
            public void run() {
                    globalLogTextviewContainer.setVisibility(enable ? View.VISIBLE : View.GONE);
            }
        });
    }

    @Override
    public void printGlobalLog(final String format, final Object ...args){
        if (uiHandler != null) {
        uiHandler.post(new Runnable() {
            @Override
            public void run() {
                    SimpleDateFormat dataFormat = new SimpleDateFormat("HH:mm:ss");
                    String line = String.format("[%s] %s\n", dataFormat.format(new Date()), String.format(format, args));
                    globalLogTextview.append(line);
                    if (globalLogTextviewContainer.getVisibility() != View.GONE){
                        globalLogTextviewContainer.fullScroll(ScrollView.FOCUS_DOWN);
            }
                }
        });
    }
    }

    @Override
    public void setTitle(final String s) {
        uiHandler.post(new Runnable() {
            @Override
            public void run() {
            String ss = NameGenerator.replaceNonPrintChar(s, 20, "...", false);
            titleTextView.setLinksClickable(false);
            titleTextView.setText(ss);
        }
        });
    }

    private final class MLVBLiveRoomListener implements IMLVBLiveRoomListener {

        /**
         * 错误回调
         * <p>
         * SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示
         *
         * @param errCode   错误码 TRTCErrorCode
         * @param errMsg    错误信息
         * @param extraInfo 额外信息，如错误发生的用户，一般不需要关注，默认是本地错误
         */
        @Override
        public void onError(int errCode, String errMsg, Bundle extraInfo) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onError(errCode, errMsg, extraInfo);
            }
        }

        /**
         * 警告回调
         *
         * @param warningCode 错误码 TRTCWarningCode
         * @param warningMsg  警告信息
         * @param extraInfo   额外信息，如警告发生的用户，一般不需要关注，默认是本地错误
         */
        @Override
        public void onWarning(int warningCode, String warningMsg, Bundle extraInfo) {

        }

        @Override
        public void onDebugLog(String log) {
            printGlobalLog(log);
        }

        /**
         * 房间被销毁的回调
         * <p>
         * 主播退房时，房间内的所有用户都会收到此通知
         *
         * @param roomID 房间ID
         */
        @Override
        public void onRoomDestroy(String roomID) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onRoomDestroy(roomID);
            }
        }

        /**
         * 收到新主播进房通知
         * <p>
         * 房间内的主播（和连麦中的观众）会收到新主播的进房事件，您可以调用 {@link MLVBLiveRoom#startRemoteView(AnchorInfo, TXCloudVideoView)} 显示该主播的视频画面。
         *
         * @param anchorInfo 新进房用户信息
         * @note 直播间里的普通观众不会收到主播加入和推出的通知。
         */
        @Override
        public void onAnchorEnter(AnchorInfo anchorInfo) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onAnchorEnter(anchorInfo);
            }
        }

        /**
         * 收到主播退房通知
         * <p>
         * 房间内的主播（和连麦中的观众）会收到新主播的退房事件，您可以调用 {@link MLVBLiveRoom#stopRemoteView(AnchorInfo)} 关闭该主播的视频画面。
         *
         * @param anchorInfo 退房用户信息
         * @note 直播间里的普通观众不会收到主播加入和推出的通知。
         */
        @Override
        public void onAnchorExit(AnchorInfo anchorInfo) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onAnchorExit(anchorInfo);
            }
        }

        /**
         * 收到观众进房通知
         *
         * @param audienceInfo 进房观众信息
         */
        @Override
        public void onAudienceEnter(AudienceInfo audienceInfo) {

        }

        /**
         * 收到观众退房通知
         *
         * @param audienceInfo 退房观众信息
         */
        @Override
        public void onAudienceExit(AudienceInfo audienceInfo) {

        }

        /**
         * 主播收到观众连麦请求时的回调
         *
         * @param anchorInfo 观众信息
         * @param reason     连麦原因描述
         */
        @Override
        public void onRequestJoinAnchor(AnchorInfo anchorInfo, String reason) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onRequestJoinAnchor(anchorInfo, reason);
            }
        }

        /**
         * 连麦观众收到被踢出连麦的通知
         * <p>
         * 连麦观众收到被主播踢除连麦的消息，您需要调用 {@link MLVBLiveRoom#kickoutJoinAnchor(String)} 来退出连麦
         */
        @Override
        public void onKickoutJoinAnchor() {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onKickoutJoinAnchor();
            }
        }

        /**
         * 收到请求跨房 PK 通知
         * <p>
         * 主播收到其他房间主播的 PK 请求
         * 如果同意 PK ，您需要调用 {@link MLVBLiveRoom#startRemoteView(AnchorInfo, TXCloudVideoView, PlayCallback)}  接口播放邀约主播的流
         *
         * @param anchorInfo 发起跨房连麦的主播信息
         */
        @Override
        public void onRequestRoomPK(AnchorInfo anchorInfo) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onRequestRoomPK(anchorInfo);
            }
        }

        /**
         * 收到断开跨房 PK 通知
         */
        @Override
        public void onQuitRoomPK(AnchorInfo anchorInfo) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onQuitRoomPK(anchorInfo);
            }
        }

        /**
         * 收到文本消息
         *
         * @param roomID     房间ID
         * @param userID     发送者ID
         * @param userName   发送者昵称
         * @param userAvatar 发送者头像
         * @param message    文本消息
         */
        @Override
        public void onRecvRoomTextMsg(String roomID, String userID, String userName, String userAvatar, String message) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onRecvRoomTextMsg(roomID, userID, userName, userAvatar, message);
            }
        }

        /**
         * 收到自定义消息
         *
         * @param roomID     房间ID
         * @param userID     发送者ID
         * @param userName   发送者昵称
         * @param userAvatar 发送者头像
         * @param cmd        自定义cmd
         * @param message    自定义消息内容
         */
        @Override
        public void onRecvRoomCustomMsg(String roomID, String userID, String userName, String userAvatar, String cmd, String message) {
            //do nothing
        }
    }
}
