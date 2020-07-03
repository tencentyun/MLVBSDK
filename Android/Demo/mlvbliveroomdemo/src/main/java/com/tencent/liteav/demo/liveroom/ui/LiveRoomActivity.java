package com.tencent.liteav.demo.liveroom.ui;

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

import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.demo.liveroom.R;
import com.tencent.liteav.demo.liveroom.roomutil.misc.CommonAppCompatActivity;
import com.tencent.liteav.demo.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.liveroom.ui.fragment.LiveRoomChatFragment;
import com.tencent.liteav.demo.liveroom.ui.fragment.LiveRoomListFragment;
import com.tencent.liteav.demo.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.liveroom.roomutil.commondef.LoginInfo;
import com.tencent.liteav.demo.liveroom.roomutil.misc.NameGenerator;
import com.tencent.liteav.login.model.ProfileManager;

import java.text.SimpleDateFormat;
import java.util.Date;
import okhttp3.logging.HttpLoggingInterceptor;


public class LiveRoomActivity extends CommonAppCompatActivity implements LiveRoomActivityInterface {

    public final Handler mUiHandler = new Handler();

    private MLVBLiveRoom mMLVBLiveRoom;
    private Runnable     mRetryInitRoomRunnable;

    private String       mUserId;
    private String       mUserName;
    private String       mUserAvatar = "avatar";

    private TextView     mTextTitle;
    private TextView     mTextGlobalLog;
    private ScrollView   mTextGlobalLogContainer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(R.style.MlvbBeautyTheme);
        setContentView(R.layout.mlvb_activity_live_room);

        findViewById(R.id.mlvb_liveroom_back_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        mTextTitle = ((TextView) findViewById(R.id.mlvb_liveroom_title_textview));
        mTextTitle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRetryInitRoomRunnable != null) {
                    synchronized (LiveRoomActivity.this) {
                        mRetryInitRoomRunnable.run();
                        mRetryInitRoomRunnable = null;
                    }
                }
            }
        });

        mTextGlobalLog = ((TextView) findViewById(R.id.mlvb_liveroom_global_log_textview));
        mTextGlobalLog.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                new AlertDialog.Builder(LiveRoomActivity.this, R.style.MlvbRtmpRoomDialogTheme)
                        .setTitle(getString(R.string.mlvb_global_log))
                        .setMessage(getString(R.string.mlvb_clear_log))
                        .setNegativeButton(getString(R.string.mlvb_cancel), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).setPositiveButton(getString(R.string.mlvb_clear), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mTextGlobalLog.setText("");
                        dialog.dismiss();
                    }
                }).show();

                return true;
            }
        });
        findViewById(R.id.mlvb_liveroom_link_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/454/14606"));
                startActivity(intent);
            }
        });

        mTextGlobalLogContainer = ((ScrollView) findViewById(R.id.mlvb_liveroom_global_log_container));

        mMLVBLiveRoom = MLVBLiveRoom.sharedInstance(this.getApplicationContext());
        mMLVBLiveRoom.setListener(new MLVBLiveRoomListener());

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
    }

    @Override
    public void onBackPressed() {
        Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
        if (fragment instanceof LiveRoomChatFragment) {
            ((LiveRoomChatFragment) fragment).onBackPressed();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public void onPermissionDisable() {
        new AlertDialog.Builder(this, R.style.MlvbRtmpRoomDialogTheme)
                .setMessage(getString(R.string.mlvb_permission_hint))
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
        public int    code;
        public int    sdkAppID;
        public String message;
        public String accType;
        public String userID;
        public String userSig;
    }

    private static class HttpInterceptorLog implements HttpLoggingInterceptor.Logger {
        @Override
        public void log(String message) {
            Log.i("HttpRequest", message + "\n");
        }
    }

    private void initializeLiveRoom() {
        setTitle(getString(R.string.mlvb_connecting));

        final SharedPreferences sp = getSharedPreferences("com.tencent.demo", Context.MODE_PRIVATE);
        String userIdFromSp = sp.getString("userID", "");
        String userNameFromSp = sp.getString("userName", "");
        if (!TextUtils.isEmpty(userNameFromSp)) {
            mUserName = userNameFromSp;
        } else {
            mUserName = NameGenerator.getRandomName();
            sp.edit().putString("userName", mUserName).commit();
        }
        SharedPreferences spf = getSharedPreferences("com.tencent.demo", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = spf.edit();
        editor.putString("userID", mUserName);
        editor.commit();
        internalInitializeLiveRoom();
    }

    private void internalInitializeLiveRoom() {
        LoginInfo loginInfo = new LoginInfo();
        loginInfo.sdkAppID = GenerateTestUserSig.SDKAPPID;
        loginInfo.userID = ProfileManager.getInstance().getUserModel().userId;
        loginInfo.userSig = ProfileManager.getInstance().getUserModel().userSig;
        loginInfo.userName = mUserName;
        loginInfo.userAvatar = mUserAvatar;
        LiveRoomActivity.this.mUserId = ProfileManager.getInstance().getUserModel().userId;

        mMLVBLiveRoom.login(loginInfo, new IMLVBLiveRoomListener.LoginCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                setTitle(errInfo);
                printGlobalLog(getString(R.string.mlvb_live_room_init_fail, errInfo));
                mRetryInitRoomRunnable = new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(LiveRoomActivity.this, getString(R.string.mlvb_retry), Toast.LENGTH_SHORT).show();
                        initializeLiveRoom();
                    }
                };
            }

            @Override
            public void onSuccess() {
                setTitle(getString(R.string.mlvb_phone_live));
                printGlobalLog(getString(R.string.mlvb_live_room_init_success), mUserId);
                Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
                if (!(fragment instanceof LiveRoomChatFragment)) {
                    FragmentTransaction ft = getFragmentManager().beginTransaction();
                    fragment = LiveRoomListFragment.newInstance(mUserId);
                    ft.replace(R.id.mlvb_rtmproom_fragment_container, fragment);
                    ft.commit();
                }
            }
        });
    }

    @Override
    public MLVBLiveRoom getLiveRoom() {
        return mMLVBLiveRoom;
    }

    @Override
    public String getSelfUserID() {
        return mUserId;
    }

    @Override
    public String getSelfUserName() {
        return mUserName;
    }

    @Override
    public void showGlobalLog(final boolean enable) {
        if (mUiHandler != null)
            mUiHandler.post(new Runnable() {
                @Override
                public void run() {
                    mTextGlobalLogContainer.setVisibility(enable ? View.VISIBLE : View.GONE);
                }
            });
    }

    @Override
    public void printGlobalLog(final String format, final Object... args) {
        if (mUiHandler != null) {
            mUiHandler.post(new Runnable() {
                @Override
                public void run() {
                    SimpleDateFormat dataFormat = new SimpleDateFormat("HH:mm:ss");
                    String line = String.format("[%s] %s\n", dataFormat.format(new Date()), String.format(format, args));
                    mTextGlobalLog.append(line);
                    if (mTextGlobalLogContainer.getVisibility() != View.GONE) {
                        mTextGlobalLogContainer.fullScroll(ScrollView.FOCUS_DOWN);
                    }
                }
            });
        }
    }

    @Override
    public void setTitle(final String s) {
        mUiHandler.post(new Runnable() {
            @Override
            public void run() {
                String ss = NameGenerator.replaceNonPrintChar(s, 20, "...", false);
                mTextTitle.setLinksClickable(false);
                mTextTitle.setText(ss);
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onAudienceEnter(audienceInfo);
            }
        }

        /**
         * 收到观众退房通知
         *
         * @param audienceInfo 退房观众信息
         */
        @Override
        public void onAudienceExit(AudienceInfo audienceInfo) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()){
                ((LiveRoomChatFragment) fragment).onAudienceExit(audienceInfo);
            }
        }

        /**
         * 主播收到观众连麦请求时的回调
         *
         * @param anchorInfo 观众信息
         * @param reason     连麦原因描述
         */
        @Override
        public void onRequestJoinAnchor(AnchorInfo anchorInfo, String reason) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
                ((LiveRoomChatFragment) fragment).onRequestRoomPK(anchorInfo);
            }
        }

        /**
         * 收到断开跨房 PK 通知
         */
        @Override
        public void onQuitRoomPK(AnchorInfo anchorInfo) {
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
            Fragment fragment = getFragmentManager().findFragmentById(R.id.mlvb_rtmproom_fragment_container);
            if (fragment instanceof LiveRoomChatFragment && fragment.isVisible()) {
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
