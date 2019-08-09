package com.tencent.qcloud.xiaozhibo.main;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTabHost;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TabHost;

import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.MLVBLiveRoom;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AnchorInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.AudienceInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.MLVBCommonDef;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.main.videolist.ui.TCVideoListFragment;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.anchor.prepare.TCAnchorPrepareActivity;
import com.tencent.qcloud.xiaozhibo.profile.TCUserInfoFragment;

/**
 *  Module:   TCMainActivity
 *
 *  Function: 主界面：直播列表、回放列表、个人信息页
 *
 */
public class TCMainActivity extends FragmentActivity {
    private static final String TAG = TCMainActivity.class.getSimpleName();
    private FragmentTabHost mTabHost;
    private LayoutInflater mLayoutInflater;
    private final Class mFragmentArray[] = {TCVideoListFragment.class, TCVideoListFragment.class, TCUserInfoFragment.class};
    private int mImageViewArray[] = {R.drawable.tab_video, R.drawable.play_click, R.drawable.tab_user};
    private String mTextviewArray[] = {"video", "publish", "user"};
    private long mLastClickPubTS = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mTabHost = (FragmentTabHost) findViewById(android.R.id.tabhost);
        mLayoutInflater = LayoutInflater.from(this);
        mTabHost.setup(this, getSupportFragmentManager(), R.id.contentPanel);

        int fragmentCount = mFragmentArray.length;
        for (int i = 0; i < fragmentCount; i++) {
            TabHost.TabSpec tabSpec = mTabHost.newTabSpec(mTextviewArray[i]).setIndicator(getTabItemView(i));
            mTabHost.addTab(tabSpec, mFragmentArray[i], null);
            mTabHost.getTabWidget().setDividerDrawable(null);
        }

        mTabHost.getTabWidget().getChildTabViewAt(1).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (System.currentTimeMillis() - mLastClickPubTS > 1000) {
                    mLastClickPubTS = System.currentTimeMillis();
                    startActivity(new Intent(TCMainActivity.this, TCAnchorPrepareActivity.class));
                }
            }
        });

        if (Build.VERSION.SDK_INT >= 23) {
            int REQUEST_CODE_CONTACT = 101;
            String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE};
            //验证是否许可权限
            for (String str : permissions) {
                if (this.checkSelfPermission(str) != PackageManager.PERMISSION_GRANTED) {
                    //申请权限
                    this.requestPermissions(permissions, REQUEST_CODE_CONTACT);
                    return;
                }
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        // 如果您的 App 没有做判断是否账号重复的登录的逻辑
        // 那么 MLVB 会监听是否有同一个人登录，所以在 resume 的时候需要重新设置 MLVB Room 的监听
        MLVBLiveRoom.sharedInstance(this).setListener(new IMLVBLiveRoomListener() {
            @Override
            public void onError(int errCode, String errMsg, Bundle extraInfo) {
                if (errCode == MLVBCommonDef.LiveRoomErrorCode.ERROR_IM_FORCE_OFFLINE) {
                    TCUtils.showKickOut(TCMainActivity.this);
                }
            }

            @Override
            public void onWarning(int warningCode, String warningMsg, Bundle extraInfo) {

            }

            @Override
            public void onDebugLog(String log) {

            }

            @Override
            public void onRoomDestroy(String roomID) {

            }

            @Override
            public void onAnchorEnter(AnchorInfo anchorInfo) {

            }

            @Override
            public void onAnchorExit(AnchorInfo anchorInfo) {

            }

            @Override
            public void onAudienceEnter(AudienceInfo audienceInfo) {

            }

            @Override
            public void onAudienceExit(AudienceInfo audienceInfo) {

            }

            @Override
            public void onRequestJoinAnchor(AnchorInfo anchorInfo, String reason) {

            }

            @Override
            public void onKickoutJoinAnchor() {

            }

            @Override
            public void onRequestRoomPK(AnchorInfo anchorInfo) {

            }

            @Override
            public void onQuitRoomPK(AnchorInfo anchorInfo) {

            }

            @Override
            public void onRecvRoomTextMsg(String roomID, String userID, String userName, String userAvatar, String message) {

            }

            @Override
            public void onRecvRoomCustomMsg(String roomID, String userID, String userName, String userAvatar, String cmd, String message) {

            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (TextUtils.isEmpty(TCUserMgr.getInstance().getUserToken())) {
            if (TCUtils.isNetworkAvailable(this) && TCUserMgr.getInstance().hasUser()) {
                TCUserMgr.getInstance().autoLogin(null);
            }
        }
    }

    /**
     * 动态获取tabicon
     * @param index tab index
     * @return
     */
    private View getTabItemView(int index) {
        View view;
        if (index % 2 == 0) {
            view = mLayoutInflater.inflate(R.layout.tab_button1, null);
        } else {
            view = mLayoutInflater.inflate(R.layout.tab_button, null);
        }
        ImageView icon = (ImageView) view.findViewById(R.id.tab_icon);
        icon.setImageResource(mImageViewArray[index]);
        return view;
    }
}
