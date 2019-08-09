package com.tencent.liteav.demo.lvb.liveroom.ui.fragment;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.AnimationDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.support.constraint.ConstraintLayout;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.common.view.BeautySettingPannel;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.misc.HintDialog;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.widget.SwipeAnimationController;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.widget.TextMsgInputDialog;
import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.ui.LiveRoomActivityInterface;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.RoomInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.widget.RoomListViewAdapter;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import static com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.MLVBCommonDef.LiveRoomErrorCode.ERROR_LICENSE_INVALID;

public class LiveRoomChatFragment extends Fragment implements BeautySettingPannel.IOnBeautyParamsChangeListener, IMLVBLiveRoomListener {

    private static final String TAG = LiveRoomChatFragment.class.getSimpleName();

    private Handler                                         mHandler;
    
    private Activity                                        mActivity;
    private LiveRoomActivityInterface                       mActivityInterface;
    
    private String                                          mSelfUserID;
    private AnchorInfo                                      mPKAnchorInfo;
    private RoomInfo                                        mRoomInfo;

    private List<AnchorInfo>                                mPusherList         = new ArrayList<>();
    private List<RoomVideoView>                             mPlayerViews        = new ArrayList<>();

    private ListView                                        mChatListView;
    private ArrayList<RoomListViewAdapter.TextChatMsg>                          mChatMsgList;
    private RoomListViewAdapter.ChatMessageAdapter mChatMsgAdapter;
    
    private Button                                          mBtnLinkMic;
    private Button                                          mBtnPK;
    private LinearLayout                                    mOperatorLayout;
    private BeautySettingPannel mBeautyPannelView;
    private TextMsgInputDialog                              mTextMsgInputDialog;
    private SwipeAnimationController                        mSwipeAnimationController;

    private int                                             mShowLogFlag        = 0;
    private int                                             mBeautyLevel        = 5;
    private int                                             mWhiteningLevel     = 3;
    private int                                             mRuddyLevel         = 2;
    private int                                             mBeautyStyle        = TXLiveConstants.BEAUTY_STYLE_SMOOTH;

    private boolean                                         mCreateRoom         = false;
    private boolean                                         mPusherMute         = false;

    private boolean                                         mPendingLinkMicReq  = false;
    private boolean                                         mIsBeingLinkMic     = false;
    private boolean                                         mOnLinkMic          = false; // 标记我是否在麦上

    private boolean                                         mPendingPKReq       = false;
    private boolean                                         mIsBeingPK          = false;
    

    public static LiveRoomChatFragment newInstance(RoomInfo config, String userID, boolean createRoom) {
        LiveRoomChatFragment fragment = new LiveRoomChatFragment();
        Bundle bundle = new Bundle();
        bundle.putParcelable("roomInfo", config);
        bundle.putString("userID", userID);
        bundle.putBoolean("createRoom", createRoom);
        fragment.setArguments(bundle);
        return fragment;
    }

    /***********************************************************************************************************************************************
     *
     *                                                      Fragment生命周期函数调用顺序
     *
     *     onAttach() --> onCreateView() --> onActivityCreated() --> onResume() --> onPause() --> onDestroyView() --> onDestroy() --> onDetach()
     *
     ***********************************************************************************************************************************************/
    
    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mActivity = ((Activity) context);
        mActivityInterface = ((LiveRoomActivityInterface) context);

    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mActivity = ((Activity) activity);
        mActivityInterface = ((LiveRoomActivityInterface) activity);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_live_room_chat, container, false);

        TXCloudVideoView videoViews[] = new TXCloudVideoView[3];
        videoViews[0] = ((TXCloudVideoView) view.findViewById(R.id.video_player1));
        videoViews[1] = ((TXCloudVideoView) view.findViewById(R.id.video_player2));
        videoViews[2] = ((TXCloudVideoView) view.findViewById(R.id.video_player3));

        Button kickoutBtns[] = {null, null, null};
        kickoutBtns[0] = (Button)view.findViewById(R.id.btn_kick_out1);
        kickoutBtns[1] = (Button)view.findViewById(R.id.btn_kick_out2);
        kickoutBtns[2] = (Button)view.findViewById(R.id.btn_kick_out3);

        FrameLayout loadingBkgs[] = {null, null, null};
        loadingBkgs[0] = (FrameLayout)view.findViewById(R.id.loading_background1);
        loadingBkgs[1] = (FrameLayout)view.findViewById(R.id.loading_background2);
        loadingBkgs[2] = (FrameLayout)view.findViewById(R.id.loading_background3);

        ImageView loadingImgs[] = {null, null, null};
        loadingImgs[0] = (ImageView)view.findViewById(R.id.loading_imageview1);
        loadingImgs[1] = (ImageView)view.findViewById(R.id.loading_imageview2);
        loadingImgs[2] = (ImageView)view.findViewById(R.id.loading_imageview3);

        mPlayerViews.add(new RoomVideoView(videoViews[0], kickoutBtns[0], loadingBkgs[0], loadingImgs[0]));
        mPlayerViews.add(new RoomVideoView(videoViews[1], kickoutBtns[1], loadingBkgs[1], loadingImgs[1]));
        mPlayerViews.add(new RoomVideoView(videoViews[2], kickoutBtns[2], loadingBkgs[2], loadingImgs[2]));
        
        //切换摄像头
        (view.findViewById(R.id.rtmproom_camera_switcher_btn)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mActivityInterface != null) {
                    mActivityInterface.getLiveRoom().switchCamera();
                }
                showOnlinePushers(false);
            }
        });

        //美颜p图部分
        mBeautyPannelView = (BeautySettingPannel) view.findViewById(R.id.layoutFaceBeauty);
        mBeautyPannelView.setBeautyParamsChangeListener(this);
        mOperatorLayout = (LinearLayout) view.findViewById(R.id.controller_container);
        view.findViewById(R.id.rtmproom_beauty_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mBeautyPannelView.setVisibility(mBeautyPannelView.getVisibility() == View.VISIBLE ? View.INVISIBLE : View.VISIBLE);
                mOperatorLayout.setVisibility(mBeautyPannelView.getVisibility() == View.VISIBLE ? View.INVISIBLE : View.VISIBLE);
                showOnlinePushers(false);
            }
        });

        //连麦
        mBtnLinkMic = (Button)view.findViewById(R.id.rtmproom_linkmic_btn);
        mBtnLinkMic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnLinkMic) {
                    stopLinkMic();
                } else {
                    startLinkMic();
                }
            }
        });

        //静音推流
        view.findViewById(R.id.rtmproom_mute_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mPusherMute = !mPusherMute;
                mActivityInterface.getLiveRoom().muteLocalAudio(mPusherMute);
                v.setBackgroundResource(mPusherMute ? R.drawable.mic_disable : R.drawable.mic_normal);
                showOnlinePushers(false);
            }
        });

        //主播PK
        mBtnPK = (Button)view.findViewById(R.id.rtmproom_pk_btn);
        mBtnPK.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsBeingPK) {
                    stopPK(true, mPKAnchorInfo);
                }
                else {
                    showOnlinePushers(true);
                }
            }
        });

        //日志
        (view.findViewById(R.id.rtmproom_log_switcher_btn)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switchLog();
                showOnlinePushers(false);
            }
        });

        //发送消息
        (view.findViewById(R.id.rtmproom_chat_btn)).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showInputMsgDialog();
                showOnlinePushers(false);
            }
        });

        mTextMsgInputDialog = new TextMsgInputDialog(mActivity, R.style.InputDialog);
        mTextMsgInputDialog.setmOnTextSendListener(new TextMsgInputDialog.OnTextSendListener() {
            @Override
            public void onTextSend(String msg, boolean tanmuOpen) {
                sendMessage(msg);
            }
        });

        mCreateRoom = getArguments().getBoolean("createRoom");
        if (mCreateRoom) {
            //大主播隐藏掉连麦入口
            (view.findViewById(R.id.linkmic_btn_view)).setVisibility(View.GONE);
        }
        else {
            //普通观众隐藏掉切换摄像头、美颜和静音推流的入口、PK入口
            (view.findViewById(R.id.camera_switch_view)).setVisibility(View.GONE);
            (view.findViewById(R.id.beauty_btn_view)).setVisibility(View.GONE);
            (view.findViewById(R.id.mute_btn_view)).setVisibility(View.GONE);
            (view.findViewById(R.id.pk_btn_view)).setVisibility(View.GONE);
        }

        mChatMsgList = new ArrayList<>();
        mChatMsgAdapter = new RoomListViewAdapter.ChatMessageAdapter(mActivity, mChatMsgList);
        mChatListView = ((ListView) view.findViewById(R.id.chat_list_view));
        mChatListView.setAdapter(mChatMsgAdapter);
        mChatListView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                mOperatorLayout.setVisibility(View.VISIBLE);
                mBeautyPannelView.setVisibility(View.INVISIBLE);
                showOnlinePushers(false);
                return false;
            }
        });

        RelativeLayout chatViewLayout = (RelativeLayout)view.findViewById(R.id.chat_layout);
        mSwipeAnimationController = new SwipeAnimationController(mActivity);
        mSwipeAnimationController.setAnimationView(chatViewLayout);

        view.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                mOperatorLayout.setVisibility(View.VISIBLE);
                mBeautyPannelView.setVisibility(View.INVISIBLE);
                showOnlinePushers(false);
                return mSwipeAnimationController.processEvent(event);
            }
        });

        mActivity.findViewById(R.id.liveroom_global_log_textview).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mOperatorLayout.setVisibility(View.VISIBLE);
                mBeautyPannelView.setVisibility(View.INVISIBLE);
                showOnlinePushers(false);
            }
        });

        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        getActivity().getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        Bundle bundle = getArguments();
        mRoomInfo = bundle.getParcelable("roomInfo");
        mSelfUserID = bundle.getString("userID");
        mCreateRoom = bundle.getBoolean("createRoom");

        if (mSelfUserID == null || ( !mCreateRoom && mRoomInfo == null)) {
            return;
        }

        mHandler = new Handler();

        mActivityInterface.setTitle(mRoomInfo.roomInfo + "(" + mActivityInterface.getSelfUserName() + ")");

        TXCloudVideoView videoView = ((TXCloudVideoView) mActivity.findViewById(R.id.video_view_full_screen));
        videoView.setLogMargin(12, 12, 80, 60);

        if (mCreateRoom){
            mActivityInterface.getLiveRoom().startLocalPreview(true, videoView);
            mActivityInterface.getLiveRoom().setCameraMuteImage(BitmapFactory.decodeResource(getResources(), R.drawable.pause_publish));
            mActivityInterface.getLiveRoom().setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
            mActivityInterface.getLiveRoom().muteLocalAudio(mPusherMute);
            mActivityInterface.getLiveRoom().createRoom("",mRoomInfo.roomInfo, new CreateRoomCallback() {
                @Override
                public void onSuccess(String roomId) {
                    mRoomInfo.roomID = roomId;
                }

                @Override
                public void onError(int errCode, String e) {
                    errorGoBack("创建直播间错误", errCode, e);
                }
            });
        }
        else {
            mActivityInterface.getLiveRoom().enterRoom(mRoomInfo.roomID, videoView, new EnterRoomCallback() {
                @Override
                public void onError(int errCode, String errInfo) {
                    errorGoBack("进入直播间错误", errCode, errInfo);
                }

                @Override
                public void onSuccess() {
                    
                }
            });
        }
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mPlayerViews.clear();
        mActivityInterface.getLiveRoom().stopLocalPreview();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        recycleVideoView();
    }

    @Override
    public void onDetach() {
        super.onDetach();
        hideNoticeToast();
        mActivity = null;
        mActivityInterface = null;
    }

    public void onBackPressed() {
        if (mActivityInterface != null) {
            mActivityInterface.getLiveRoom().exitRoom(new ExitRoomCallback() {
                @Override
                public void onSuccess() {
                    Log.i(TAG, "exitRoom Success");
                }

                @Override
                public void onError(int errCode, String e) {
                    Log.e(TAG, "exitRoom failed, errorCode = " + errCode + " errMessage = " + e);
                }
            });
        }

        recycleVideoView();
        backStack();
    }

    private void errorGoBack(String title, int errCode, String errInfo){
        mActivityInterface.getLiveRoom().exitRoom(null);
        SpannableStringBuilder spannableStrBuidler = null;
        errInfo = errInfo + "[" + errCode + "]";
        if (errCode == ERROR_LICENSE_INVALID) {
            int start = (errInfo + " 详情请点击[").length();
            int end = (errInfo + " 详情请点击[License 使用指南").length();
            spannableStrBuidler = new SpannableStringBuilder(errInfo + " 详情请点击[License 使用指南]");
            ClickableSpan clickableSpan = new ClickableSpan() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent();
                    intent.setAction("android.intent.action.VIEW");
                    Uri content_url = Uri.parse("https://cloud.tencent.com/document/product/454/34750");
                    intent.setData(content_url);
                    startActivity(intent);
                }
            };
            spannableStrBuidler.setSpan(new ForegroundColorSpan(Color.BLUE), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            spannableStrBuidler.setSpan(clickableSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } else if (errCode == 10036 /*IM 创建聊天室数量超过限额错误*/) {
            int start = "您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【".length();
            int end = "您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室".length();
            spannableStrBuidler = new SpannableStringBuilder("您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】");
            ClickableSpan clickableSpan = new ClickableSpan() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent();
                    intent.setAction("android.intent.action.VIEW");
                    Uri content_url = Uri.parse("https://buy.cloud.tencent.com/avc");
                    intent.setData(content_url);
                    startActivity(intent);
                }
            };
            spannableStrBuidler.setSpan(new ForegroundColorSpan(Color.BLUE), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            spannableStrBuidler.setSpan(clickableSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        } else {
            spannableStrBuidler = new SpannableStringBuilder(errInfo);
        }
        TextView tv = new TextView(mActivity);
        tv.setMovementMethod(LinkMovementMethod.getInstance());
        tv.setText(spannableStrBuidler);
        tv.setPadding(20, 0, 20, 0);
        new AlertDialog.Builder(mActivity)
                .setTitle(title)
                .setView(tv)
                .setNegativeButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        recycleVideoView();
                        backStack();
                    }
                }).show();
    }

    private void backStack(){
        if (mActivity != null) {
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (mActivity != null) {
                        FragmentManager fragmentManager = mActivity.getFragmentManager();
                        fragmentManager.popBackStack();
                        fragmentManager.beginTransaction().commit();
                    }
                }
            });
        }
    }

    private void switchLog(){
        mShowLogFlag++;
        mShowLogFlag = (mShowLogFlag % 3);
        switch (mShowLogFlag) {
            case 0: {
                TXCloudVideoView videoViewFullScreen = ((TXCloudVideoView) mActivity.findViewById(R.id.video_view_full_screen));
                videoViewFullScreen.showLog(false);

                TXCloudVideoView videoViewPKStream = ((TXCloudVideoView) mActivity.findViewById(R.id.video_view_pk));
                videoViewPKStream.showLog(false);

                for (RoomVideoView item : mPlayerViews) {
                    if (item.isUsed) {
                        item.videoView.showLog(false);
                    }
                }

                if (mActivityInterface != null) {
                    mActivityInterface.showGlobalLog(false);
                }

                break;
            }

            case 1: {
                TXCloudVideoView videoViewFullScreen = ((TXCloudVideoView) mActivity.findViewById(R.id.video_view_full_screen));
                videoViewFullScreen.showLog(false);

                TXCloudVideoView videoViewPKStream = ((TXCloudVideoView) mActivity.findViewById(R.id.video_view_pk));
                videoViewPKStream.showLog(false);

                for (RoomVideoView item : mPlayerViews) {
                    if (item.isUsed) {
                        item.videoView.showLog(false);
                    }
                }

                if (mActivityInterface != null) {
                    mActivityInterface.showGlobalLog(true);
                }

                break;
            }

            case 2: {
                TXCloudVideoView videoViewFullScreen = ((TXCloudVideoView) mActivity.findViewById(R.id.video_view_full_screen));
                videoViewFullScreen.showLog(true);

                TXCloudVideoView videoViewPKStream = ((TXCloudVideoView) mActivity.findViewById(R.id.video_view_pk));
                videoViewPKStream.showLog(true);

                for (RoomVideoView item : mPlayerViews) {
                    if (item.isUsed) {
                        item.videoView.showLog(true);
                    }
                }

                if (mActivityInterface != null) {
                    mActivityInterface.showGlobalLog(false);
                }

                break;
            }
        }
    }

    private void addMessageItem(final String userName, final String message, final RoomListViewAdapter.TextChatMsg.Aligment aligment){
        mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                SimpleDateFormat TIME_FORMAT = new SimpleDateFormat("HH:mm");
                mChatMsgList.add(new RoomListViewAdapter.TextChatMsg(userName, TIME_FORMAT.format(new Date()), message, aligment));
                mChatMsgAdapter.notifyDataSetChanged();
                mChatListView.post(new Runnable() {
                    @Override
                    public void run() {
                        mChatListView.setSelection(mChatMsgList.size() - 1);
                    }
                });
            }
        });
    }

    private void sendMessage(final String message){
        mActivityInterface.getLiveRoom().sendRoomTextMsg(message, new SendRoomTextMsgCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                new AlertDialog.Builder(mActivity, R.style.RtmpRoomDialogTheme).setMessage(errInfo)
                        .setTitle("发送消息失败")
                        .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).show();
            }

            @Override
            public void onSuccess() {
                addMessageItem(mActivityInterface.getSelfUserName(), message, RoomListViewAdapter.TextChatMsg.Aligment.LEFT);
            }
        });
    }

    /**
     * 错误回调
     *
     * SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示
     *
     * @param errCode   错误码
     * @param errMsg    错误信息
     * @param extraInfo 额外信息，如错误发生的用户，一般不需要关注，默认是本地错误
     */
    @Override
    public void onError(int errCode, String errMsg, Bundle extraInfo) {
        errorGoBack("直播间错误", errCode, errMsg);
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
        if (mCreateRoom == false) {
            new HintDialog.Builder(mActivity)
                    .setTittle("系统消息")
                    .setContent(String.format("直播间【%s】解散了", mRoomInfo != null ? mRoomInfo.roomInfo : "null"))
                    .setButtonText("返回")
                    .setDismissListener(new DialogInterface.OnDismissListener() {
                        @Override
                        public void onDismiss(DialogInterface dialog) {
                            onBackPressed();
                        }
                    }).show();
        }
    }

    /**
     * 收到新主播进房通知
     * <p>
     * 房间内的主播（和连麦中的观众）会收到新主播的进房事件，您可以调用 {@link MLVBLiveRoom#startRemoteView(AnchorInfo, TXCloudVideoView, PlayCallback)} 显示该主播的视频画面。
     *
     * @param anchorInfo 新进房用户信息
     * @note 直播间里的普通观众不会收到主播加入和推出的通知。
     */
    @Override
    public void onAnchorEnter(final AnchorInfo anchorInfo) {
        if (anchorInfo == null || anchorInfo.userID == null) {
            return;
        }

        if (mIsBeingPK) {
            mActivityInterface.getLiveRoom().kickoutJoinAnchor(anchorInfo.userID);
        }

        final RoomVideoView videoView = applyVideoView(anchorInfo.userID);
        if (videoView == null) {
            return;
        }

        if (mPusherList != null) {
            boolean exist = false;
            for (AnchorInfo item : mPusherList) {
                if (anchorInfo.userID.equalsIgnoreCase(item.userID)) {
                    exist = true;
                    break;
                }
            }
            if (exist == false) {
                mPusherList.add(anchorInfo);
            }
        }

        videoView.startLoading();
        mActivityInterface.getLiveRoom().startRemoteView(anchorInfo, videoView.videoView, new PlayCallback() {
            @Override
            public void onBegin() {
                videoView.stopLoading(mCreateRoom); //推流成功，stopLoading 大主播显示出踢人的button
            }

            @Override
            public void onError(int errCode, String errInfo) {
                LiveRoomChatFragment.this.onAnchorExit(anchorInfo);
                if (mCreateRoom) {
                    mActivityInterface.getLiveRoom().kickoutJoinAnchor(anchorInfo.userID);
                }
            }

            @Override
            public void onEvent(int event, Bundle param) {
                //TODO
            }
        }); //开启远端视频渲染

        if (mPusherList != null && mPusherList.size() > 0) {
            mIsBeingLinkMic = true;
            showOnlinePushers(false);
            mBtnPK.setEnabled(false);
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
        if (mPusherList != null) {
            Iterator<AnchorInfo> it = mPusherList.iterator();
            while (it.hasNext()) {
                AnchorInfo item = it.next();
                if (anchorInfo.userID.equalsIgnoreCase(item.userID)) {
                    it.remove();
                    break;
                }
            }
        }

        mActivityInterface.getLiveRoom().stopRemoteView(anchorInfo);//关闭远端视频渲染
        recycleVideoView(anchorInfo.userID);

        if (mPusherList != null && mPusherList.size() == 0) {
            mIsBeingLinkMic = false;
            mBtnPK.setEnabled(true);
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
    public void onRequestJoinAnchor(final AnchorInfo anchorInfo, String reason) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(mActivity)
                .setCancelable(true)
                .setTitle("提示")
                .setMessage(anchorInfo.userName + "向您发起连麦请求")
                .setPositiveButton("接受", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mActivityInterface.getLiveRoom().responseJoinAnchor(anchorInfo.userID, true, "");
                        dialog.dismiss();
                        mPendingLinkMicReq = false;
                    }
                })
                .setNegativeButton("拒绝", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mActivityInterface.getLiveRoom().responseJoinAnchor(anchorInfo.userID, false, "主播拒绝了您的连麦请求");
                        dialog.dismiss();
                        mPendingLinkMicReq = false;
                    }
                });

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mPendingPKReq == true || mIsBeingPK) {
                    mActivityInterface.getLiveRoom().responseJoinAnchor(anchorInfo.userID, false, "请稍后，主播正在处理其它人的PK请求");
                    return;
                }

                if (mPendingLinkMicReq == true) {
                    mActivityInterface.getLiveRoom().responseJoinAnchor(anchorInfo.userID, false, "请稍后，主播正在处理其它人的连麦请求");
                    return;
                }

                if (mPusherList.size() >= 3) {
                    mActivityInterface.getLiveRoom().responseJoinAnchor(anchorInfo.userID, false, "主播端连麦人数超过最大限制");
                    return;
                }

                final AlertDialog alertDialog = builder.create();
                alertDialog.setCancelable(false);
                alertDialog.setCanceledOnTouchOutside(false);
                alertDialog.show();

                mPendingLinkMicReq = true;

                mHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        alertDialog.dismiss();
                        mPendingLinkMicReq = false;
                    }
                }, 10000);
            }
        });
    }

    /**
     * 连麦观众收到被踢出连麦的通知
     *
     * 连麦观众收到被主播踢除连麦的消息，您需要调用 {@link MLVBLiveRoom#kickoutJoinAnchor(String)} 来退出连麦
     */
    @Override
    public void onKickoutJoinAnchor() {
        stopLinkMic();
    }

    /**
     * 收到请求跨房 PK 通知
     *
     * 主播收到其他房间主播的 PK 请求
     * 如果同意 PK ，您需要调用 {@link MLVBLiveRoom#startRemoteView(AnchorInfo, TXCloudVideoView, PlayCallback)}  接口播放邀约主播的流
     *
     * @param anchorInfo 发起跨房连麦的主播信息
     */
    @Override
    public void onRequestRoomPK(final AnchorInfo anchorInfo) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(mActivity)
                .setCancelable(true)
                .setTitle("提示")
                .setMessage(anchorInfo.userName + "向您发起PK请求")
                .setPositiveButton("接受", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        mPKAnchorInfo = anchorInfo;
                        mActivityInterface.getLiveRoom().responseRoomPK(anchorInfo.userID, true, "");
                        startPK(anchorInfo);
                    }
                })
                .setNegativeButton("拒绝", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        mActivityInterface.getLiveRoom().responseRoomPK(anchorInfo.userID, false, "主播拒绝了您的PK请求");
                        mPendingPKReq = false;
                    }
                });

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mPendingLinkMicReq == true || mIsBeingLinkMic) {
                    mActivityInterface.getLiveRoom().responseRoomPK(anchorInfo.userID, false, "请稍后，主播正在处理其它人的连麦请求");
                    return;
                }

                if (mPendingPKReq == true || mIsBeingPK) {
                    mActivityInterface.getLiveRoom().responseRoomPK(anchorInfo.userID, false, "请稍后，主播正在处理其它人的PK请求");
                    return;
                }

                final AlertDialog alertDialog = builder.create();
                alertDialog.setCancelable(false);
                alertDialog.setCanceledOnTouchOutside(false);
                alertDialog.show();

                mPendingPKReq = true;

                mHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        alertDialog.dismiss();
                        mPendingPKReq = false;
                    }
                }, 10000);
            }
        });
    }

    /**
     * 收到断开跨房 PK 通知
     */
    @Override
    public void onQuitRoomPK(AnchorInfo anchorInfo) {
        stopPK(false, anchorInfo);
    }

    @Override
    public void onRecvRoomTextMsg(String roomid, String userid, String userName, String userAvatar, String message) {
        addMessageItem(userName, message, RoomListViewAdapter.TextChatMsg.Aligment.LEFT);
    }

    @Override
    public void onRecvRoomCustomMsg(final String roomID, final String userID, final String userName, final String userAvatar, final String cmd, final String message) {
        //do nothing
    }

    @Override
    public void onBeautyParamsChange(BeautySettingPannel.BeautyParams params, int key) {
        MLVBLiveRoom liveRoom = mActivityInterface.getLiveRoom();
        switch (key) {
            case BeautySettingPannel.BEAUTYPARAM_EXPOSURE:
                if (liveRoom != null) {
                    liveRoom.setExposureCompensation(params.mExposure);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_BEAUTY:
                mBeautyStyle = params.mBeautyStyle;
                mBeautyLevel = params.mBeautyLevel;
                if (liveRoom != null) {
                    liveRoom.setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_WHITE:
                mWhiteningLevel = params.mWhiteLevel;
                if (liveRoom != null) {
                    liveRoom.setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_BIG_EYE:
                if (liveRoom != null) {
                    liveRoom.setEyeScaleLevel(params.mBigEyeLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FACE_LIFT:
                if (liveRoom != null) {
                    liveRoom.setFaceSlimLevel(params.mFaceSlimLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FILTER:
                if (liveRoom != null) {
                    liveRoom.setFilter(params.mFilterBmp);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_GREEN:
                if (liveRoom != null) {
                    liveRoom.setGreenScreenFile(params.mGreenFile);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_MOTION_TMPL:
                if (liveRoom != null) {
                    liveRoom.setMotionTmpl(params.mMotionTmplPath);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_RUDDY:
                mRuddyLevel = params.mRuddyLevel;
                if (liveRoom != null) {
                    liveRoom.setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                }
                break;
//            case BeautySettingPannel.BEAUTYPARAM_BEAUTY_STYLE:
//                mBeautyStyle = params.mBeautyStyle;
//                if (liveRoom != null) {
//                    liveRoom.setBeautyFilter(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
//                }
//                break;
            case BeautySettingPannel.BEAUTYPARAM_FACEV:
                if (liveRoom != null) {
                    liveRoom.setFaceVLevel(params.mFaceVLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FACESHORT:
                if (liveRoom != null) {
                    liveRoom.setFaceShortLevel(params.mFaceShortLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_CHINSLIME:
                if (liveRoom != null) {
                    liveRoom.setChinLevel(params.mChinSlimLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_NOSESCALE:
                if (liveRoom != null) {
                    liveRoom.setNoseSlimLevel(params.mNoseScaleLevel);
                }
                break;
            case BeautySettingPannel.BEAUTYPARAM_FILTER_MIX_LEVEL:
                if (liveRoom != null) {
                    liveRoom.setFilterConcentration(params.mFilterMixLevel/10.f);
                }
                break;
        }
    }

    private void startLinkMic() {
        mBtnLinkMic.setEnabled(false);
        showNoticeToast("等待主播接受......");

        mActivityInterface.getLiveRoom().requestJoinAnchor("", new RequestJoinAnchorCallback() {
            @Override
            public void onAccept() {
                hideNoticeToast();
                Toast.makeText(mActivity, "主播接受了您的连麦请求，开始连麦", Toast.LENGTH_SHORT).show();

                RoomVideoView videoView = mPlayerViews.get(0);
                videoView.setUsed(true);
                videoView.userID = mSelfUserID;

                mActivityInterface.getLiveRoom().startLocalPreview(true, videoView.videoView);
                mActivityInterface.getLiveRoom().setCameraMuteImage(BitmapFactory.decodeResource(getResources(), R.drawable.pause_publish));
                mActivityInterface.getLiveRoom().setBeautyStyle(mBeautyStyle, mBeautyLevel, mWhiteningLevel, mRuddyLevel);
                mActivityInterface.getLiveRoom().joinAnchor(new JoinAnchorCallback() {
                    @Override
                    public void onError(int errCode, String errInfo) {
                        stopLinkMic();
                        mBtnLinkMic.setEnabled(true);
                        if (mActivity != null) {
                            Toast.makeText(mActivity, "连麦失败：" + errInfo, Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onSuccess() {
                        mBtnLinkMic.setEnabled(true);
                        mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_stop);
                        mIsBeingLinkMic = true;
                        mOnLinkMic = true;
                    }
                });
            }

            @Override
            public void onReject(String reason) {
                mBtnLinkMic.setEnabled(true);
                hideNoticeToast();
                if (mActivity != null) {
                    Toast.makeText(mActivity, reason, Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onTimeOut() {
                mBtnLinkMic.setEnabled(true);
                hideNoticeToast();
                if (mActivity != null) {
                    Toast.makeText(mActivity, "连麦请求超时，主播没有做出回应", Toast.LENGTH_SHORT).show();
                }

            }

            @Override
            public void onError(int code, String errInfo) {
                hideNoticeToast();
                mBtnLinkMic.setEnabled(true);
            }
        });
    }

    private void stopLinkMic() {
        mIsBeingLinkMic = false;
        mOnLinkMic = false;
        mBtnLinkMic.setEnabled(true);
        mBtnLinkMic.setBackgroundResource(R.drawable.linkmic_start);

        recycleVideoView(mSelfUserID);

        mActivityInterface.getLiveRoom().stopLocalPreview();
        mActivityInterface.getLiveRoom().quitJoinAnchor(new QuitAnchorCallback() {
            @Override
            public void onError(int errCode, String errInfo) {

            }

            @Override
            public void onSuccess() {

            }
        });
    }

    private void showOnlinePushers(boolean show) {
        final RelativeLayout relativeLayout = (RelativeLayout)mActivity.findViewById(R.id.online_pushers_layout);
        if (show && relativeLayout.getVisibility() == View.VISIBLE) {
            show = false;
        }

        relativeLayout.setVisibility(show ? View.VISIBLE : View.GONE);
        if (show == false) {
            return;
        }

        mActivityInterface.getLiveRoom().getRoomList(0, 1000, new GetRoomListCallback() {
            @Override
            public void onError(int errCode, String errInfo) {
                Toast.makeText(getActivity(), "获取在线主播列表失败！", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onSuccess(final ArrayList<RoomInfo> roomList) {
                if (roomList == null || roomList.size() == 0) {
                    return;
                }

                final ArrayList<AnchorInfo> pusherList = new ArrayList<>();
                for (RoomInfo roomInfo : roomList) {
                    if (roomInfo.pushers.size() == 1) {
                        //获取未连麦主播列表
                        AnchorInfo pusherInfo = roomInfo.pushers.get(0);
                        if (pusherInfo.userID.equalsIgnoreCase(mSelfUserID) == false) {
                            pusherList.add(pusherInfo);
                        }
                    }
                }

                ArrayList<String> userNameList = new ArrayList<>();
                for (AnchorInfo info : pusherList) {
                    userNameList.add(info.userName);
                }

                OnlinePusherListViewAdapter adapter = new OnlinePusherListViewAdapter();
                adapter.setDataList(pusherList);

                ListView listView = (ListView)mActivity.findViewById(R.id.online_pushers_list_view);
                listView.setAdapter(adapter);
                listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                        relativeLayout.setVisibility(View.GONE);
                        if (position < pusherList.size()) {
                            sendPKRequest(pusherList.get(position).userID);
                        }
                    }
                });
            }
        });
    }

    private void sendPKRequest(String userID) {
        mPendingPKReq = true;
        mBtnPK.setEnabled(false);
        showNoticeToast("PK请求已发出，等待对方接受......");

        mActivityInterface.getLiveRoom().requestRoomPK(userID, new RequestRoomPKCallback() {
            @Override
            public void onAccept(AnchorInfo anchorInfo) {
                mPKAnchorInfo = anchorInfo;
                mPendingPKReq = false;
                mBtnPK.setEnabled(true);
                hideNoticeToast();
                if (mActivity != null) {
                    Toast.makeText(mActivity, "对方接受了您的PK请求，开始PK", Toast.LENGTH_SHORT).show();
                }
                startPK(anchorInfo);
            }

            @Override
            public void onReject(String reason) {
                handlePKResponse(reason);
            }

            @Override
            public void onTimeOut() {
                handlePKResponse("PK请求超时，对方没有做出回应");
            }

            @Override
            public void onError(int code, String errInfo) {
                handlePKResponse(errInfo);
            }

            private void handlePKResponse(String message) {
                mPendingPKReq = false;
                mBtnPK.setEnabled(true);
                hideNoticeToast();
                if (mActivity != null) {
                    Toast.makeText(mActivity, message, Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void startPK(final AnchorInfo anchorInfo) {
        mPendingPKReq = false;
        mIsBeingPK    = true;

        mBtnPK.setEnabled(true);
        mBtnPK.setBackgroundResource(R.drawable.pk_stop);

        showOnlinePushers(false);

        adjustFullScreenVideoView(false);

        showPKLoadingAnimation(true);

        TXCloudVideoView videoView = (TXCloudVideoView)mActivity.findViewById(R.id.video_view_pk);
        videoView.setLogMargin(12, 12, 35, 12);
        mActivityInterface.getLiveRoom().startRemoteView(anchorInfo, videoView, new PlayCallback() {
            @Override
            public void onBegin() {
                showPKLoadingAnimation(false);
            }

            @Override
            public void onError(int errCode, String errInfo) {
               stopPK(true, anchorInfo);
            }

            @Override
            public void onEvent(int event, Bundle param) {

            }
        });
    }

    private void stopPK(boolean force, AnchorInfo anchorInfo) {
        mPendingPKReq = false;
        mIsBeingPK    = false;

        mBtnPK.setEnabled(true);
        mBtnPK.setBackgroundResource(R.drawable.pk_start);

        adjustFullScreenVideoView(true);

        showPKLoadingAnimation(false);

        mActivityInterface.getLiveRoom().stopRemoteView(anchorInfo);
        if (force) {
            mActivityInterface.getLiveRoom().quitRoomPK(new QuitRoomPKCallback() {
                @Override
                public void onError(int errCode, String errInfo) {

                }

                @Override
                public void onSuccess() {

                }
            });
        }

        mPKAnchorInfo = null;
    }

    private void adjustFullScreenVideoView(boolean fullScreen) {
        FrameLayout frameLayout = (FrameLayout) mActivity.findViewById(R.id.frame_layout_push);
        TXCloudVideoView videoView = (TXCloudVideoView)mActivity.findViewById(R.id.video_view_full_screen);
        ConstraintLayout.LayoutParams layoutParams = (ConstraintLayout.LayoutParams)frameLayout.getLayoutParams();
        if (fullScreen) {
            int parent = layoutParams.topToTop;
            layoutParams.rightToRight = parent;
            layoutParams.bottomToBottom = parent;
            layoutParams.rightToLeft = -1;
            layoutParams.bottomToTop = -1;

            videoView.setLogMargin(12, 12, 80, 60);
        }
        else {
            layoutParams.rightToLeft = R.id.guideline_v;
            layoutParams.bottomToTop = R.id.guideline_h;
            layoutParams.rightToRight = -1;
            layoutParams.bottomToBottom = -1;

            videoView.setLogMargin(12, 12, 35, 12);
        }
        frameLayout.setLayoutParams(layoutParams);
    }

    private void showPKLoadingAnimation(boolean show) {
        FrameLayout frameLayout = (FrameLayout) mActivity.findViewById(R.id.loading_background_pk);
        ImageView   imageView   = (ImageView) mActivity.findViewById(R.id.loading_imageview_pk);
        frameLayout.setVisibility(show ? View.VISIBLE : View.GONE);
        imageView.setVisibility(show ? View.VISIBLE : View.GONE);
        imageView.setImageResource(R.drawable.linkmic_loading);
        AnimationDrawable ad = (AnimationDrawable) imageView.getDrawable();
        if (show) {
            ad.start();
        }
        else {
            ad.stop();
        }
    }

    private Toast mNoticeToast;
    private Timer mNoticeTimer;
    private void showNoticeToast(String text) {
        if (mNoticeToast == null) {
            mNoticeToast = Toast.makeText(mActivity, text, Toast.LENGTH_LONG);
        }

        if (mNoticeTimer == null) {
            mNoticeTimer = new  Timer();
        }

        mNoticeToast.setText(text);
        mNoticeTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                mNoticeToast.show();
            }
        }, 0, 3000);

    }

    private void hideNoticeToast() {
        if (mNoticeToast != null) {
            mNoticeToast.cancel();
            mNoticeToast = null;
        }
        if (mNoticeTimer != null) {
            mNoticeTimer.cancel();
            mNoticeTimer = null;
        }
    }

    private void showInputMsgDialog() {
        WindowManager windowManager = mActivity.getWindowManager();
        Display display = windowManager.getDefaultDisplay();
        WindowManager.LayoutParams lp = mTextMsgInputDialog.getWindow().getAttributes();

        lp.width = (display.getWidth()); //设置宽度
        mTextMsgInputDialog.getWindow().setAttributes(lp);
        mTextMsgInputDialog.setCancelable(true);
        mTextMsgInputDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        mTextMsgInputDialog.show();
    }

    private class RoomVideoView {
        TXCloudVideoView videoView;
        FrameLayout      loadingBkg;
        ImageView        loadingImg;
        Button           kickButton;
        String           userID;
        boolean          isUsed;
        

        public RoomVideoView(TXCloudVideoView view, Button button, FrameLayout loadingBkg, ImageView loadingImg) {
            this.videoView = view;
            this.videoView.setVisibility(View.GONE);
            this.loadingBkg = loadingBkg;
            this.loadingImg = loadingImg;
            this.isUsed = false;
            this.kickButton = button;
            this.kickButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    kickButton.setVisibility(View.INVISIBLE);
                    String userID = RoomVideoView.this.userID;
                    if (userID != null) {
                        for (AnchorInfo item: mPusherList) {
                            if (userID.equalsIgnoreCase(item.userID)) {
                                onAnchorExit(item);
                                break;
                            }
                        }
                        mActivityInterface.getLiveRoom().kickoutJoinAnchor(userID);
                    }
                }
            });
        }

        public void startLoading() {
            kickButton.setVisibility(View.INVISIBLE);
            loadingBkg.setVisibility(View.VISIBLE);
            loadingImg.setVisibility(View.VISIBLE);
            loadingImg.setImageResource(R.drawable.linkmic_loading);
            AnimationDrawable ad = (AnimationDrawable) loadingImg.getDrawable();
            ad.start();
        }

        public void stopLoading(boolean showKickoutBtn) {
            kickButton.setVisibility(showKickoutBtn ? View.VISIBLE : View.GONE);
            loadingBkg.setVisibility(View.GONE);
            loadingImg.setVisibility(View.GONE);
            AnimationDrawable ad = (AnimationDrawable) loadingImg.getDrawable();
            if (ad != null) {
                ad.stop();
            }
        }

        public void stopLoading() {
            kickButton.setVisibility(View.GONE);
            loadingBkg.setVisibility(View.GONE);
            loadingImg.setVisibility(View.GONE);
            AnimationDrawable ad = (AnimationDrawable) loadingImg.getDrawable();
            if (ad != null) {
                ad.stop();
            }
        }

        private void setUsed(boolean used){
            videoView.setVisibility(used ? View.VISIBLE : View.GONE);
            if (used == false) {
                stopLoading(false);
            }
            this.isUsed = used;
        }

    }

    public synchronized RoomVideoView applyVideoView(String id) {
        if (id == null) {
            return null;
        }

        for (RoomVideoView item : mPlayerViews) {
            if (!item.isUsed) {
                item.setUsed(true);
                item.userID = id;
                return item;
            }
            else {
                if (item.userID != null && item.userID.equals(id)) {
                    item.setUsed(true);
                    return item;
                }
            }
        }
        return null;
    }

    public synchronized void recycleVideoView(String id){
        for (RoomVideoView item : mPlayerViews) {
            if (item.userID != null && item.userID.equals(id)){
                item.userID = null;
                item.setUsed(false);
            }
        }
    }

    public synchronized void recycleVideoView(){
        for (RoomVideoView item : mPlayerViews) {
            item.userID = null;
            item.setUsed(false);
        }
    }

    private class OnlinePusherListViewAdapter extends BaseAdapter {
        private List<AnchorInfo> dataList;

        public void setDataList(List<AnchorInfo> dataList){
            this.dataList = dataList;
        }

        @Override
        public int getCount() {
            return dataList.size();
        }

        @Override
        public Object getItem(int position) {
            return dataList.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            LinearLayout view = (LinearLayout)convertView;
            if (view == null) {
                view = (LinearLayout) LayoutInflater.from(mActivity.getApplicationContext()).inflate(R.layout.layout_liveroom_online_pusher, null);
            }

            AnchorInfo pusherInfo = dataList.get(position);
            TextView userName = (TextView) view.findViewById(R.id.user_name_textview);
            userName.setText(pusherInfo.userName);
            return view;
        }
    }
}
