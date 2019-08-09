package com.tencent.liteav.demo.ugccommon;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.tencent.liteav.basic.log.TXCLog;
import com.tencent.liteav.demo.common.R;
import com.tencent.liteav.demo.common.utils.TCConstants;

import java.io.File;
import java.util.ArrayList;

public class TCVideoJoinChooseActivity extends Activity implements View.OnClickListener, ActivityCompat.OnRequestPermissionsResultCallback {
    private static final String TAG = TCVideoJoinChooseActivity.class.getSimpleName();

    public static final int TYPE_SINGLE_CHOOSE = 0;
    public static final int TYPE_MULTI_CHOOSE = 1;
    public static final int TYPE_PUBLISH_CHOOSE = 2; //
    public static final int TYPE_MULTI_CHOOSE_PICTURE = 3; // 选择多图片
    public static final int TYPE_VIDEO_CHOOSE = 4; // 本地文件选择

    private Button mBtnOk;
    private ImageButton mBtnLink;
    private RecyclerView mRecyclerView;
    private TextView mTvRight;
    private TextView mTvTitle;

    private int mType;

    private TCVideoEditerListAdapter mAdapter;

    private Handler mHandler;
    private HandlerThread mHandlerThread;

    private Handler mMainHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            ArrayList<TCVideoFileInfo> fileInfoArrayList = (ArrayList<TCVideoFileInfo>) msg.obj;
            mAdapter.addAll(fileInfoArrayList);
        }
    };

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setContentView(R.layout.activity_ugc_video_list);

        mHandlerThread = new HandlerThread("LoadList");
        mHandlerThread.start();
        mHandler = new Handler(mHandlerThread.getLooper());

        mType = getIntent().getIntExtra("CHOOSE_TYPE", TYPE_SINGLE_CHOOSE);

        init();
        if (mType == TYPE_MULTI_CHOOSE_PICTURE) {
            loadPictureList();
        } else {
            loadVideoList();
        }
    }

    private void loadPictureList() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    ArrayList<TCVideoFileInfo> fileInfoArrayList = TCVideoEditerMgr.getAllPictrue(TCVideoJoinChooseActivity.this);

                    Message msg = new Message();
                    msg.obj = fileInfoArrayList;
                    mMainHandler.sendMessage(msg);
                }
            });
        } else {
            if (Build.VERSION.SDK_INT >= 23) {
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
            }
        }
    }

    @Override
    protected void onDestroy() {
        mHandler.removeCallbacksAndMessages(null);
        mHandler = null;
        mHandlerThread.quit();
        mHandlerThread = null;
        LinearLayout backLL = (LinearLayout) findViewById(R.id.back_ll);
        backLL.setOnClickListener(null);

        mBtnOk.setOnClickListener(null);

        mTvRight.setOnClickListener(null);
        super.onDestroy();
    }

    private void loadVideoList() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    ArrayList<TCVideoFileInfo> fileInfoArrayList = TCVideoEditerMgr.getAllVideo(TCVideoJoinChooseActivity.this);

                    Message msg = new Message();
                    msg.obj = fileInfoArrayList;
                    mMainHandler.sendMessage(msg);
                }
            });
        } else {
            if (Build.VERSION.SDK_INT >= 23) {
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (grantResults != null && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            loadVideoList();
        }
    }

    private void init() {
        LinearLayout backLL = (LinearLayout) findViewById(R.id.back_ll);
        backLL.setOnClickListener(this);

        mBtnOk = (Button) findViewById(R.id.btn_ok);
        mBtnOk.setOnClickListener(this);
        mBtnLink = (ImageButton) findViewById(R.id.webrtc_link_button);
        mBtnLink.setOnClickListener(this);

        mTvRight = (TextView) findViewById(R.id.tv_right);
        mTvRight.setOnClickListener(this);

        mTvTitle = (TextView) findViewById(R.id.title_tv);

        mRecyclerView = (RecyclerView) findViewById(R.id.recycler_view);
        mRecyclerView.setLayoutManager(new GridLayoutManager(this, 4));
        mAdapter = new TCVideoEditerListAdapter(this);
        mRecyclerView.setAdapter(mAdapter);

        if (mType == TYPE_SINGLE_CHOOSE || mType == TYPE_PUBLISH_CHOOSE) {
            mAdapter.setMultiplePick(false);
        } else {
            mAdapter.setMultiplePick(true);
        }

        if (mType == TYPE_PUBLISH_CHOOSE) {
            mTvRight.setText("回放");
            mTvRight.setVisibility(View.VISIBLE);
        }

        if (mType == TYPE_MULTI_CHOOSE_PICTURE) {
            mTvTitle.setText("选择图片");
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_ok) {
            doSelect();

        } else if (id == R.id.back_ll) {
            finish();

        } else if (id == R.id.tv_right) {
            if (mType == TYPE_PUBLISH_CHOOSE) {
//                Intent intent = new Intent(TCVideoJoinChooseActivity.this, SuperPlayerActivity.class);
                Intent intent = new Intent();
                intent.setAction("com.tencent.liteav.demo.play.action.float.click");
                intent.putExtra(TCConstants.PLAYER_DEFAULT_VIDEO, false);
                startActivity(intent);
            }

        } else if (id == R.id.webrtc_link_button) {
            showCloudLink();

        }
    }

    private void showCloudLink() {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        if (mType == TYPE_PUBLISH_CHOOSE) {
            intent.setData(Uri.parse("https://cloud.tencent.com/document/product/584/15535"));
        } else if (mType == TYPE_MULTI_CHOOSE_PICTURE) {
            intent.setData(Uri.parse("https://cloud.tencent.com/document/product/584/9502#16.-.E5.9B.BE.E7.89.87.E7.BC.96.E8.BE.91"));
        } else {
            intent.setData(Uri.parse("https://cloud.tencent.com/document/product/584/9503"));
        }
        startActivity(intent);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Glide.with(this).pauseRequests();
    }

    @Override
    protected void onResume() {
        super.onResume();
        Glide.with(this).resumeRequests();
    }

    private void doSelect() {
        if (mType == TYPE_SINGLE_CHOOSE) {
//            Class preprocesActivityClass = null;
//            try {
//                preprocesActivityClass = Class.forName("com.tencent.liteav.demo.shortvideo.editor.TCVideoPreprocessActivity");
//            } catch (ClassNotFoundException e) {
//                e.printStackTrace();
//            }
//            Intent intent = new Intent(this, preprocesActivityClass);
            Intent intent = new Intent();
            intent.setAction("com.tencent.liteav.demo.videopreprocess");
            TCVideoFileInfo fileInfo = mAdapter.getSingleSelected();
            if (fileInfo == null) {
                return;
            }
            if (TCVideoEditUtil.isVideoDamaged(fileInfo)) {
                TCVideoEditUtil.showErrorDialog(this, "该视频文件已经损坏");
                return;
            }
            File file = new File(fileInfo.getFilePath());
            if (!file.exists()) {
                TCVideoEditUtil.showErrorDialog(this, "选择的文件不存在");
                return;
            }
            intent.putExtra(TCConstants.VIDEO_EDITER_PATH, fileInfo.getFilePath());
            startActivity(intent);
        } else if (mType == TYPE_MULTI_CHOOSE) {
            // ugc精简版本没有TCVideoJoinerActivity
//            Class joinerActivityClass = null;
//            try {
//                joinerActivityClass = Class.forName("com.tencent.liteav.demo.shortvideo.joiner.TCVideoJoinerActivity");
//            } catch (ClassNotFoundException e) {
//                e.printStackTrace();
//            }
//            Intent intent = new Intent(this, joinerActivityClass);
            Intent intent = new Intent();
            intent.setAction("com.tencent.liteav.demo.videojoiner");
            ArrayList<TCVideoFileInfo> videoFileInfos = mAdapter.getMultiSelected();
            if (videoFileInfos == null || videoFileInfos.size() == 0) {
                return;
            }
            if (videoFileInfos.size() < 2) {
                Toast.makeText(this, "必须选择两个以上视频文件", Toast.LENGTH_SHORT).show();
                return;
            }
            if (TCVideoEditUtil.isVideoDamaged(videoFileInfos)) {
                TCVideoEditUtil.showErrorDialog(this, "包含已经损坏的视频文件");
                return;
            }
            for (TCVideoFileInfo info : videoFileInfos) {
                File file = new File(info.getFilePath());
                if (!file.exists()) {
                    TCVideoEditUtil.showErrorDialog(this, "选择的文件不存在");
                    return;
                }
            }
            intent.putExtra(TCConstants.INTENT_KEY_MULTI_CHOOSE, videoFileInfos);
            startActivity(intent);
        } else if (mType == TYPE_MULTI_CHOOSE_PICTURE) {
            // ugc精简版本没有TCVideoEditerActivity
//            Class editActivityClass = null;
//            try {
//                editActivityClass = Class.forName("com.tencent.liteav.demo.shortvideo.editor.TCVideoEditerActivity");
//            } catch (ClassNotFoundException e) {
//                e.printStackTrace();
//            }
//            Intent intent = new Intent(this, editActivityClass);
            Intent intent = new Intent();
            intent.setAction("com.tencent.liteav.demo.videoediter");
            ArrayList<TCVideoFileInfo> pictureList = mAdapter.getInOrderMultiSelected();
            if (pictureList == null || pictureList.size() == 0) {
                return;
            }
            if (pictureList.size() < 3) {
                Toast.makeText(this, "必须选择三个以上图片", Toast.LENGTH_SHORT).show();
                return;
            }
            ArrayList picturePathList = new ArrayList();
            for (TCVideoFileInfo info : pictureList) {
                File file = new File(info.getFilePath());
                if (!file.exists()) {
                    TCVideoEditUtil.showErrorDialog(this, "选择的文件不存在");
                    return;
                }
                picturePathList.add(info.getFilePath());
            }
            intent.putExtra(TCConstants.INTENT_KEY_MULTI_PIC_CHOOSE, true);
            intent.putStringArrayListExtra(TCConstants.INTENT_KEY_MULTI_PIC_LIST, picturePathList);
            startActivity(intent);
        } else if (mType == TYPE_PUBLISH_CHOOSE) {
//            Intent intent = new Intent(this, TCCompressActivity.class);
            Intent intent = new Intent();
            intent.setAction("com.tencent.liteav.demo.videocompress");
            TCVideoFileInfo fileInfo = mAdapter.getSingleSelected();
            if (fileInfo == null) {
                TXCLog.d(TAG, "select file null");
                return;
            }
            if (TCVideoEditUtil.isVideoDamaged(fileInfo)) {
                TCVideoEditUtil.showErrorDialog(this, "该视频文件已经损坏");
                return;
            }
            File file = new File(fileInfo.getFilePath());
            if (!file.exists()) {
                TCVideoEditUtil.showErrorDialog(this, "选择的文件不存在");
                return;
            }
            intent.putExtra(TCConstants.VIDEO_EDITER_PATH, fileInfo.getFilePath());
            startActivity(intent);
        } else if (mType == TYPE_VIDEO_CHOOSE) {
            Intent intent = new Intent();
            TCVideoFileInfo fileInfo = mAdapter.getSingleSelected();
            if (fileInfo == null) {
                return;
            }
            if (TCVideoEditUtil.isVideoDamaged(fileInfo)) {
                TCVideoEditUtil.showErrorDialog(this, "该视频文件已经损坏");
                return;
            }
            File file = new File(fileInfo.getFilePath());
            if (!file.exists()) {
                TCVideoEditUtil.showErrorDialog(this, "选择的文件不存在");
                return;
            }
            intent.putExtra("videoFile", fileInfo.getFilePath());
            //设置返回数据
           setResult(RESULT_OK, intent);
        }
        finish();
    }

}
