package com.tencent.qcloud.xiaozhibo.videopublish;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.mainui.TCMainActivity;
import com.tencent.qcloud.xiaozhibo.videoupload.TXUGCPublish;
import com.tencent.qcloud.xiaozhibo.videoupload.TXUGCPublishTypeDef;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.umeng.socialize.ShareAction;
import com.umeng.socialize.UMShareAPI;
import com.umeng.socialize.UMShareListener;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMWeb;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.UnsupportedEncodingException;

/**
 * Created by carolsuo on 2017/3/9.
 * UGC发布页面
 */
public class TCVideoPublisherActivity extends Activity implements CompoundButton.OnCheckedChangeListener, View.OnClickListener, TXUGCPublishTypeDef.ITXVideoPublishListener, ITXLivePlayListener {
    private String TAG = TCVideoPublisherActivity.class.getName();

    private static final int PUBLISH_INIT = 0;      // 发布初始状态
    private static final int PUBLISH_ING = 1;       // 发布中
    private static final int PUBLISH_PAUSE = 2;     // 发布暂停
    private static final int PUBLISH_FINISH = 3;    // 发布完成

    //分享相关
    private SHARE_MEDIA mShare_meidia = SHARE_MEDIA.MORE;

    private CompoundButton mCbLastChecked = null;
    private String mVideoPath = null;

    private String mCoverPath = null;
    private TextView mBtnBack;

    private TextView mBtnPublish;
    private LinearLayout mLayoutEdit;

    private RelativeLayout mLayoutPublish;
    private TXUGCPublish mVideoPublish = null;

    boolean mIsPlayRecordType = false;
    private ImageView mIVPublishing;
    private TextView mTVPublish;
    private TextView mTVTitle;
    private EditText mTitleEditText;
    private boolean mIsFetchCosSig = false;
    String mCosSignature = null;

    Handler mHandler = new Handler();
    private String mShareUrl = TCConstants.SVR_LivePlayShare_URL;

    private int mPublishStatus = PUBLISH_INIT;
    private TXLivePlayer mTXLivePlayer = null;
    private TXLivePlayConfig mTXPlayConfig = null;
    private TXCloudVideoView mTXCloudVideoView;
    private NetchangeReceiver mNetchangeReceiver = null;
    private int mRotation;
    private boolean mDisableCache;
    private String mLocalVideoPath;
    ImageView mImageViewBg;


    private int mVideoRecordType;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_publisher);

        mVideoPath = getIntent().getStringExtra(TCConstants.VIDEO_RECORD_VIDEPATH);
        mCoverPath = getIntent().getStringExtra(TCConstants.VIDEO_RECORD_COVERPATH);
        mRotation = getIntent().getIntExtra(TCConstants.VIDEO_RECORD_ROTATION, TXLiveConstants.RENDER_ROTATION_PORTRAIT);
        mDisableCache = getIntent().getBooleanExtra(TCConstants.VIDEO_RECORD_NO_CACHE, false);
        mLocalVideoPath = getIntent().getStringExtra(TCConstants.VIDEO_RECORD_VIDEPATH);

        mVideoRecordType = getIntent().getIntExtra(TCConstants.VIDEO_RECORD_TYPE, 0);
        mIsPlayRecordType = getIntent().getIntExtra(TCConstants.VIDEO_RECORD_TYPE, 0) == TCConstants.VIDEO_RECORD_TYPE_PLAY;

        CheckBox cbShareWX = (CheckBox) findViewById(R.id.vpcb_share_wx);
        CheckBox cbShareCircle = (CheckBox) findViewById(R.id.vpcb_share_circle);
        CheckBox cbShareQQ = (CheckBox) findViewById(R.id.vpcb_share_qq);
        CheckBox cbShareQzone = (CheckBox) findViewById(R.id.vpcb_share_qzone);
        CheckBox cbShareWb = (CheckBox) findViewById(R.id.vpcb_share_wb);

        cbShareWX.setOnCheckedChangeListener(this);
        cbShareCircle.setOnCheckedChangeListener(this);
        cbShareQQ.setOnCheckedChangeListener(this);
        cbShareQzone.setOnCheckedChangeListener(this);
        cbShareWb.setOnCheckedChangeListener(this);

        mBtnBack = (TextView) findViewById(R.id.btn_back);
        mBtnBack.setOnClickListener(this);

        mBtnPublish = (TextView) findViewById(R.id.btn_publish);
        mBtnPublish.setOnClickListener(this);

        mLayoutEdit = (LinearLayout) findViewById(R.id.layout_edit);
        mLayoutPublish = (RelativeLayout) findViewById(R.id.layout_publish);

        mIVPublishing = (ImageView) findViewById(R.id.publishing);
        mTVPublish = (TextView) findViewById(R.id.publish_text);

        mTVTitle = (TextView) findViewById(R.id.publish_title);

        mTitleEditText = (EditText) findViewById(R.id.edit_text);

        mTXLivePlayer = new TXLivePlayer(this);
        mTXPlayConfig = new TXLivePlayConfig();
        mTXCloudVideoView = (TXCloudVideoView) findViewById(R.id.video_view);
        mTXCloudVideoView.disableLog(true);

        mImageViewBg = (ImageView) findViewById(R.id.bg_iv);
        if(mVideoRecordType != TCConstants.VIDEO_RECORD_TYPE_UGC_RECORD){
            mImageViewBg.setScaleType(ImageView.ScaleType.CENTER_CROP);
        }
        Glide.with(this).load(Uri.fromFile(new File(mCoverPath))).into(mImageViewBg);

        Handler h = new Handler();
        h.postDelayed(new Runnable() {
            @Override
            public void run() {
                startPlay();
            }
        }, 500);
//        startPlay();
    }

    private void startPlay() {
        mTXLivePlayer.setPlayerView(mTXCloudVideoView);
        mTXLivePlayer.setPlayListener(this);

        mTXLivePlayer.enableHardwareDecode(false);
        mTXLivePlayer.setRenderRotation(mRotation);
        if(mVideoRecordType == TCConstants.VIDEO_RECORD_TYPE_UGC_RECORD){
            // 短视频录制：适应屏幕
            mTXLivePlayer.setRenderMode(TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION);
        }else{
            mTXLivePlayer.setRenderMode(TXLiveConstants.RENDER_MODE_FULL_FILL_SCREEN);
        }

        mTXLivePlayer.setConfig(mTXPlayConfig);

        mTXLivePlayer.startPlay(mVideoPath, TXLivePlayer.PLAY_TYPE_LOCAL_VIDEO); // result返回值：0 success;  -1 empty url; -2 invalid url; -3 invalid playType;
        mImageViewBg.setVisibility(View.VISIBLE);
    }

    private void fetchSignature() {
        if (mIsFetchCosSig)
            return;
        mIsFetchCosSig = true;

        TCUserMgr.getInstance().getVodSig(new TCUserMgr.Callback() {
            @Override
            public void onSuccess(JSONObject data) {
                try {
                    mCosSignature = data.getString("signature");
                    startPublish();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(int code, final String msg) {
                TCVideoPublisherActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mTVPublish.setText("网络连接断开，视频上传失败");
                    }
                });
            }
        });
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if (isChecked == false) {
            mShare_meidia = SHARE_MEDIA.MORE;
            mCbLastChecked = null;
            return;
        }
        if (mCbLastChecked != null) {
            mCbLastChecked.setChecked(false);
        }
        mCbLastChecked = buttonView;
        switch (buttonView.getId()) {
            case R.id.vpcb_share_wx:
                mShare_meidia = SHARE_MEDIA.WEIXIN;
                break;
            case R.id.vpcb_share_circle:
                mShare_meidia = SHARE_MEDIA.WEIXIN_CIRCLE;
                break;
            case R.id.vpcb_share_qq:
                mShare_meidia = SHARE_MEDIA.QQ;
                break;
            case R.id.vpcb_share_qzone:
                mShare_meidia = SHARE_MEDIA.QZONE;
                break;
            case R.id.vpcb_share_wb:
                mShare_meidia = SHARE_MEDIA.SINA;
                break;
            default:
                break;
        }
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.btn_back:
                this.finish();
                break;
            case R.id.btn_publish:
                publishVideo();
                break;
            default:
                break;
        }
    }

    private void publishVideo() {
        switch (mPublishStatus) {
            case PUBLISH_INIT:
            case PUBLISH_PAUSE:
            {
                if (!TCUtils.isNetworkAvailable(this)) {
                    Toast.makeText(getApplicationContext(), "当前无网络连接", Toast.LENGTH_SHORT).show();
                    return;
                }
                fetchSignature();
                mLayoutEdit.setVisibility(View.GONE);
                mLayoutPublish.setVisibility(View.VISIBLE);
                mBtnPublish.setVisibility(View.GONE);
                //mBtnPublish.setText("暂停");
                mTVTitle.setText("发布");
                mPublishStatus = PUBLISH_ING;
            }
            break;
            case PUBLISH_ING:
            {
                if (mVideoPublish != null) {
                    mVideoPublish.canclePublish();
                    mBtnPublish.setText("发布");
                    mPublishStatus = PUBLISH_PAUSE;
                    mIsFetchCosSig = false;
                }
            }
            break;
            case PUBLISH_FINISH:
            {
                Intent intent = new Intent(TCVideoPublisherActivity.this,TCMainActivity.class);
                startActivity(intent);
            }
            break;
            default:
                break;
        }
    }

    void startPublish() {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mVideoPublish == null) {
                    mVideoPublish = new TXUGCPublish(TCVideoPublisherActivity.this.getApplicationContext(), TCUserMgr.getInstance().getUserId());
                    mVideoPublish.setListener(TCVideoPublisherActivity.this);
                }
                mIVPublishing.setVisibility(View.VISIBLE);
                mTVPublish.setText("正在上传请稍等");

                TXUGCPublishTypeDef.TXPublishParam param = new TXUGCPublishTypeDef.TXPublishParam();
                param.signature = mCosSignature;
                param.videoPath = mVideoPath;
                param.coverPath = mCoverPath;
                int publishCode = mVideoPublish.publishVideo(param);
                if (publishCode != 0) {
                    mIVPublishing.setVisibility(View.INVISIBLE);
                    mTVPublish.setText("发布失败，错误码：" + publishCode);
                }

                stopPlay(true);
                IntentFilter intentFilter = new IntentFilter();
                intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
                if (null == mNetchangeReceiver) {
                    mNetchangeReceiver = new NetchangeReceiver();
                }
                TCVideoPublisherActivity.this.getApplicationContext().registerReceiver(mNetchangeReceiver, intentFilter);
            }
        });
    }

    void startShare(String videoId, String videoURL, String coverURL) {
        // 友盟的分享组件并不完善，为了各种异常情况下正常推流，要多做一些事情
        if (mShare_meidia == SHARE_MEDIA.MORE) {
            finishPublish();
            return;
        }

//        boolean isSupportShare = false;
//        if (mShare_meidia == SHARE_MEDIA.SINA) {
//            isSupportShare = true;
//        } else if (mShare_meidia == SHARE_MEDIA.QZONE) {
//            if (UMShareAPI.get(this).isInstall(this, SHARE_MEDIA.QQ) || UMShareAPI.get(this).isInstall(this, SHARE_MEDIA.QZONE)) {
//                isSupportShare = true;
//            }
//        } else if (UMShareAPI.get(this).isInstall(this, mShare_meidia)) {
//            isSupportShare = true;
//        }
//
//        if (!isSupportShare) {
//            allDone();
//            return;
//        }

        try {
            mShareUrl = mShareUrl + "?sdkappid=" + java.net.URLEncoder.encode(String.valueOf(TCUserMgr.getInstance().getSDKAppID()), "utf-8")
                    + "&acctype=" + java.net.URLEncoder.encode(TCUserMgr.getInstance().getAccountType(), "utf-8")
                    + "&userid=" + java.net.URLEncoder.encode(TCUserMgr.getInstance().getUserId(), "utf-8")
                    + "&type=" + java.net.URLEncoder.encode(String.valueOf(2), "utf-8")
                    + "&fileid=" + java.net.URLEncoder.encode(String.valueOf(videoId), "utf-8")
                    + "&ts=" + java.net.URLEncoder.encode(String.valueOf(0), "utf-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        ShareAction shareAction = new ShareAction(TCVideoPublisherActivity.this);

        String title = mTitleEditText.getText().toString();
        if (TextUtils.isEmpty(title)) {
            title = "小视频";
        }
        UMWeb web = new UMWeb(mShareUrl);
        web.setThumb(new UMImage(TCVideoPublisherActivity.this.getApplicationContext(), coverURL));
        web.setTitle(title);
        shareAction.withText(TCUserMgr.getInstance().getNickname() + "的小视频");
        shareAction.withMedia(web);
        shareAction.setCallback(umShareListener);
        shareAction.setPlatform(mShare_meidia).share();
    }

    private UMShareListener umShareListener = new UMShareListener() {
        @Override
        public void onStart(SHARE_MEDIA platform) {
            Log.d("plat", "platform" + platform);
        }

        @Override
        public void onResult(SHARE_MEDIA platform) {
            Log.d("plat", "platform" + platform);
            Toast.makeText(TCVideoPublisherActivity.this, platform + " 分享成功啦", Toast.LENGTH_SHORT).show();
            TCVideoPublisherActivity.this.mHandler.post(new Runnable() {
                @Override
                public void run() {
                    finishPublish();
                }
            });
        }

        @Override
        public void onError(SHARE_MEDIA platform, Throwable t) {
            Toast.makeText(TCVideoPublisherActivity.this, "分享失败" + t.getMessage(), Toast.LENGTH_LONG).show();
            TCVideoPublisherActivity.this.mHandler.post(new Runnable() {
                @Override
                public void run() {
                    finishPublish();
                }
            });
        }

        @Override
        public void onCancel(SHARE_MEDIA platform) {
            Toast.makeText(TCVideoPublisherActivity.this, platform + " 分享取消了", Toast.LENGTH_SHORT).show();
            TCVideoPublisherActivity.this.mHandler.post(new Runnable() {
                @Override
                public void run() {
                    finishPublish();
                }
            });
        }
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /** attention to this below ,must add this**/
        UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onPublishProgress(long uploadBytes, long totalBytes) {
        //Log.w(TAG, "upload video progress: [" + uploadBytes + "/" + totalBytes + "]");
        int index = (int) (uploadBytes * 8 / totalBytes);
        switch (index) {
            case 1:
                mIVPublishing.setImageResource(R.drawable.publish_1);
                break;
            case 2:
                mIVPublishing.setImageResource(R.drawable.publish_2);
                break;
            case 3:
                mIVPublishing.setImageResource(R.drawable.publish_3);
                break;
            case 4:
                mIVPublishing.setImageResource(R.drawable.publish_4);
                break;
            case 5:
                mIVPublishing.setImageResource(R.drawable.publish_5);
                break;
            case 6:
                mIVPublishing.setImageResource(R.drawable.publish_6);
                break;
            case 7:
                mIVPublishing.setImageResource(R.drawable.publish_7);
                break;
            case 8:
                mIVPublishing.setImageResource(R.drawable.publish_8);
                break;
            default:
                break;
        }
    }

    @Override
    public void onPublishComplete(TXUGCPublishTypeDef.TXPublishResult txPublishResult) {
        if (txPublishResult.retCode == TXUGCPublishTypeDef.PUBLISH_RESULT_OK) {
//            mBtnPublish.setVisibility(View.GONE);
            mIVPublishing.setImageResource(R.drawable.publish_success);
            mTVPublish.setText("发布成功啦！");
            UploadUGCVideo(txPublishResult.videoId, txPublishResult.videoURL, txPublishResult.coverURL);
        } else {
            mIVPublishing.setVisibility(View.INVISIBLE);
            if (txPublishResult.descMsg.contains("java.net.UnknownHostException") || txPublishResult.descMsg.contains("java.net.ConnectException")) {
                mTVPublish.setText("网络连接断开，视频上传失败");
//                mBtnPublish.setText("发布");
//                mPublishStatus = PUBLISH_PAUSE;
//                mIsFetchCosSig = false;
            } else {
                mTVPublish.setText(txPublishResult.descMsg);
            }
            Log.e(TAG, txPublishResult.descMsg);
        }
    }

    private void deleteCache() {
        if (mDisableCache) {
            File file = new File(mVideoPath);
            if (file.exists()) {
                file.delete();
            }
            if (!TextUtils.isEmpty(mCoverPath)) {
                file = new File(mCoverPath);
                if (file.exists()) {
                    file.delete();
                }
            }
            if (mLocalVideoPath != null) {
                Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
                scanIntent.setData(Uri.fromFile(new File(mLocalVideoPath)));
                sendBroadcast(scanIntent);
            }
        }
    }

    private void UploadUGCVideo(final String videoId, final String videoURL, final String coverURL) {
        String title = mTitleEditText.getText().toString();
        if (TextUtils.isEmpty(title)) {
            title = "小视频";
        }
//        try {
//            JSONObject userInfo = new JSONObject();
//            userInfo.put("nickname", TCUserInfoMgr.getInstance().getNickname());
//            userInfo.put("headpic", TCUserInfoMgr.getInstance().getHeadPic());
//            userInfo.put("frontcover", coverURL);
//            userInfo.put("location", TCUserInfoMgr.getInstance().getLocation());
//
//            JSONObject req = new JSONObject();
//            req.put("Action", "UploadUGCVideo");
//            req.put("userid", TCUserInfoMgr.getInstance().getUserId());
//            req.put("file_id", videoId);
//            req.put("title", title);
//            req.put("play_url", videoURL);
//            req.put("userinfo", userInfo);
//
//            mUploadUGCListener = new TCPushUploadUGCVideoListener(this, videoId, videoURL, coverURL);
//            TCHttpEngine.getInstance().post(req, mUploadUGCListener);
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
        try {
            JSONObject body = new JSONObject().put("file_id", videoId)
                    .put("title", title)
                    .put("frontcover", coverURL)
                    .put("location", "")
                    .put("play_url", videoURL);
            TCUserMgr.getInstance().request("/upload_ugc", body, new TCUserMgr.HttpCallback("upload_ugc", new TCUserMgr.Callback() {
                @Override
                public void onSuccess(JSONObject data) {
                    startShare(videoId, videoURL, coverURL);
                }

                @Override
                public void onFailure(int code, final String msg) {
                }
            }));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    // 视频上传完成了
    void finishPublish() {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mBtnBack.setVisibility(View.INVISIBLE);
                mBtnPublish.setText("完成");
                mBtnPublish.setVisibility(View.VISIBLE);
                mPublishStatus = PUBLISH_FINISH;
            }
        });
    }


    @Override
    protected void onResume() {
        super.onResume();
        mTXCloudVideoView.onResume();
        mTXLivePlayer.resume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mTXCloudVideoView.onPause();
        mTXLivePlayer.pause();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mTXCloudVideoView.onDestroy();
        stopPlay(true);
        if (mNetchangeReceiver != null) {
            this.getApplicationContext().unregisterReceiver(mNetchangeReceiver);
        }

        deleteCache();
    }

    protected void stopPlay(boolean clearLastFrame) {
        if (mTXLivePlayer != null) {
            mTXLivePlayer.setPlayListener(null);
            mTXLivePlayer.stopPlay(clearLastFrame);
        }
    }


    @Override
    public void onPlayEvent(int event, Bundle param) {
        if (mTXCloudVideoView != null) {
            mTXCloudVideoView.setLogText(null, param, event);
        }
        if (event == TXLiveConstants.PLAY_ERR_NET_DISCONNECT) {

           Toast.makeText(this, "",Toast.LENGTH_LONG).show();

        } else if (event == TXLiveConstants.PLAY_EVT_PLAY_END) {
            stopPlay(false);
            startPlay();
        } else if (event == TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME) {
            mImageViewBg.setVisibility(View.GONE);
        }
    }

    @Override
    public void onNetStatus(Bundle bundle) {
    }

    public class NetchangeReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())) {
                if (!TCUtils.isNetworkAvailable(TCVideoPublisherActivity.this)) {
                    mIVPublishing.setVisibility(View.INVISIBLE);
                    mTVPublish.setText("网络连接断开，视频上传失败");
                }
            }
        }
    }
}
