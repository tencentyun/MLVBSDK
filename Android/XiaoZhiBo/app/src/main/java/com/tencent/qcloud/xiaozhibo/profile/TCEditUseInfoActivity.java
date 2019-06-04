package com.tencent.qcloud.xiaozhibo.profile;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.upload.TCUploadHelper;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.common.widget.TCActivityTitle;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;
import com.tencent.qcloud.xiaozhibo.profile.view.TCLineControllerView;
import com.tencent.qcloud.xiaozhibo.profile.view.TCLineEditTextView;

import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Module:   TCEditUseInfoActivity
 *
 * Function: 用户资料编辑页面
 *
 **/
public class TCEditUseInfoActivity extends Activity implements View.OnClickListener , TCUploadHelper.OnUploadListener {
    private String TAG = getClass().getName();

    private final static int REQ_EDIT_NICKNAME = 0x100;

    private static final int CROP_CHOOSE = 10;
    private static final int CAPTURE_IMAGE_CAMERA = 100;
    private static final int IMAGE_STORE = 200;

    private TCUploadHelper              mCosUploadHelper;       // COS 上传的帮助类
    private ImageView                   mIvAvatar;              // 头像控件类
    private TCActivityTitle             mTvTitle;               // Activity 的标题控件
    private TCLineEditTextView          mEditView;              // 昵称
    private TCLineControllerView        mTcControllerView;      // 性别
    private boolean                     mPermission;            // 权限检测
    private Uri                         mAvatarPicUri, mCropAvatarPicUri; // 头像 Uri 、裁剪头像的 Uri

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_user_info);
        initView();
        mCosUploadHelper = new TCUploadHelper(this,this);
        mPermission = checkCropPermission();
    }

    private void initView(){
        mTvTitle = (TCActivityTitle) findViewById(R.id.at_eui_edit);
        mIvAvatar = (ImageView) findViewById(R.id.iv_eui_head);
        mEditView = (TCLineEditTextView) findViewById(R.id.letv_eui_nickname);
        mTcControllerView = (TCLineControllerView)findViewById(R.id.lcv_eui_sex);
        mTvTitle.setReturnListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mEditView.setContent(TCUserMgr.getInstance().getNickname());
        TCUtils.showPicWithUrl(this, mIvAvatar,TCUserMgr.getInstance().getAvatar(),R.drawable.face);
        mTcControllerView.setContent(TCUtils.EnumGenderToString(TCUserMgr.getInstance().getUserSex()));
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()){
        case R.id.rl_eui_head:
            showPhotoDialog();
            break;
        case R.id.letv_eui_nickname:
//            mEditView.setEditTextFocus();
            break;
        case R.id.lcv_eui_sex:
            ShowSelectSexDialog();
            break;
        default:
            break;
        }
    }


    /**
     * 打开图片裁剪页面
     *
     * @param uri 裁剪图片的URI
     */
    public void startPhotoZoom(Uri uri) {
        mCropAvatarPicUri = createCoverUri("_icon_crop");
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        intent.putExtra("crop", "true");
        intent.putExtra("aspectX", 200);
        intent.putExtra("aspectY", 200);
        intent.putExtra("outputX", 200);
        intent.putExtra("outputY", 200);
        intent.putExtra("return-data", false);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, mCropAvatarPicUri);
        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
        startActivityForResult(intent, CROP_CHOOSE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != RESULT_OK){
            Log.e(TAG,"onActivityResult->failed for requestWithSign: " + requestCode + "/" + resultCode);
            return;
        }
        switch (requestCode){
        case REQ_EDIT_NICKNAME:
//            TCUserMgr.getInstance().setNickName(data.getStringExtra(TCTextEditActivity.RETURN_EXTRA));
            break;
        case CAPTURE_IMAGE_CAMERA:
            startPhotoZoom(mAvatarPicUri);
            break;
        case IMAGE_STORE:
            String path = TCUtils.getPath(this, data.getData());
            if (null != path){
                Log.d(TAG,"cropPhoto->path:" + path);
                File file = new File(path);
                startPhotoZoom(Uri.fromFile(file));
            }
            break;
        case CROP_CHOOSE:
            mCosUploadHelper.uploadPic(mCropAvatarPicUri.getPath());
            break;
        }
    }
    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      选择头像相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    /**
     * 创建封面图片的uri
     *
     * @param type 要创建的URI类型
     *             _icon ：通过相机拍摄图片
     *             _select_icon ： 从文件获取图片文件
     * @return 返回uri
     */
    private Uri createCoverUri(String type) {
        String filename = TCUserMgr.getInstance().getUserId() + type + ".jpg";
        File outputImage = new File(Environment.getExternalStorageDirectory(), filename);
        if (ContextCompat.checkSelfPermission(TCEditUseInfoActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(TCEditUseInfoActivity.this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, TCConstants.WRITE_PERMISSION_REQ_CODE);
            return null;
        }
        if (outputImage.exists()) {
            outputImage.delete();
        }
        return Uri.fromFile(outputImage);
    }


    /**
     * 获取图片资源
     *
     * @param type 类型（本地IMAGE_STORE/拍照CAPTURE_IMAGE_CAMERA）
     */
    private void getPicFrom(int type) {
        if (!mPermission) {
            Toast.makeText(this, getString(R.string.tip_no_permission), Toast.LENGTH_SHORT).show();
            return;
        }
        switch (type) {
            case CAPTURE_IMAGE_CAMERA:
                Intent intent_photo = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                mAvatarPicUri = createCoverUri("_icon");
                intent_photo.putExtra(MediaStore.EXTRA_OUTPUT, mAvatarPicUri);
                startActivityForResult(intent_photo, CAPTURE_IMAGE_CAMERA);
                break;
            case IMAGE_STORE:
                mAvatarPicUri = createCoverUri("_select_icon");
                Intent intent_album = new Intent("android.intent.action.GET_CONTENT");
                intent_album.setType("image/*");
                startActivityForResult(intent_album, IMAGE_STORE);
                break;
        }
    }


    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      权限相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */

    /**
     * 检查裁剪图像相关的权限
     *
     * @return 权限不足返回false，否则返回true
     */
    private boolean checkCropPermission() {
        if (Build.VERSION.SDK_INT >= 23) {
            List<String> permissions = new ArrayList<>();
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TCEditUseInfoActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                permissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
            }
            if (PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(TCEditUseInfoActivity.this, Manifest.permission.READ_PHONE_STATE)) {
                permissions.add(Manifest.permission.READ_PHONE_STATE);
            }
            if (permissions.size() != 0) {
                ActivityCompat.requestPermissions(TCEditUseInfoActivity.this,
                        permissions.toArray(new String[0]),
                        TCConstants.WRITE_PERMISSION_REQ_CODE);
                return false;
            }
        }

        return true;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case TCConstants.WRITE_PERMISSION_REQ_CODE:
                for (int ret : grantResults) {
                    if (ret != PackageManager.PERMISSION_GRANTED) {
                        return;
                    }
                }
                mPermission = true;
                break;
            default:
                break;
        }
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      上传相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    @Override
    public void onUploadResult(int code, String url) {
        if (0 == code) {
            Toast.makeText(this,"上传头像成功",Toast.LENGTH_LONG).show();
            TCUtils.showPicWithUrl(this, mIvAvatar, url, R.color.transparent);
            TCUserMgr.getInstance().setAvatar(url, new TCHTTPMgr.Callback() {
                @Override
                public void onSuccess(JSONObject data) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(getApplicationContext(),"设置头像URL成功" ,Toast.LENGTH_LONG).show();
                        }
                    });
                }

                @Override
                public void onFailure(int code, final String msg) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(getApplicationContext(),"设置头像URL失败" ,Toast.LENGTH_LONG).show();
                        }
                    });
                }
            });
        }else{
            Log.w(TAG, "onUploadResult->failed: "+code);
            Toast.makeText(this, "上传头像失败", Toast.LENGTH_LONG).show();
        }
    }

    /**
     * /////////////////////////////////////////////////////////////////////////////////
     * //
     * //                      弹窗相关
     * //
     * /////////////////////////////////////////////////////////////////////////////////
     */
    /**
     * 图片选择对话框
     */
    private void showPhotoDialog() {
        final Dialog pickDialog = new Dialog(this, R.style.floag_dialog);
        pickDialog.setContentView(R.layout.dialog_pic_choose);

        WindowManager windowManager = getWindowManager();
        Display display = windowManager.getDefaultDisplay();
        Window dlgwin = pickDialog.getWindow();
        WindowManager.LayoutParams lp = dlgwin.getAttributes();
        dlgwin.setGravity(Gravity.BOTTOM);
        lp.width = (int)(display.getWidth()); //设置宽度

        pickDialog.getWindow().setAttributes(lp);

        TextView camera = (TextView) pickDialog.findViewById(R.id.chos_camera);
        TextView picLib = (TextView) pickDialog.findViewById(R.id.pic_lib);
        TextView cancel = (TextView) pickDialog.findViewById(R.id.anchor_btn_cancel);
        camera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getPicFrom(CAPTURE_IMAGE_CAMERA);
                pickDialog.dismiss();
            }
        });

        picLib.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getPicFrom(IMAGE_STORE);
                pickDialog.dismiss();
            }
        });
        cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                pickDialog.dismiss();
            }
        });

        pickDialog.show();
    }

    /**
     * 选择性别对话框
     */
    private void ShowSelectSexDialog(){
        final AlertDialog dialog = new AlertDialog.Builder(this,R.style.ConfirmDialogStyle).create();


        View view = getLayoutInflater().inflate(R.layout.view_selet_sex, null);
        dialog.setView(view, 0, 0, 0, 0);

        int width = getWindowManager().getDefaultDisplay().getWidth();
        WindowManager.LayoutParams params = dialog.getWindow().getAttributes();
        params.width = width;
        params.height =  WindowManager.LayoutParams.WRAP_CONTENT;
        params.gravity = Gravity.CENTER;
        dialog.getWindow().setAttributes(params);

        Button btnMale = (Button) view.findViewById(R.id.btn_ss_male);
        btnMale.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                TCUserMgr.getInstance().setUserSex(TCConstants.MALE, new TCHTTPMgr.Callback() {
                    @Override
                    public void onSuccess(JSONObject data) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mTcControllerView.setContent(TCUtils.EnumGenderToString(TCConstants.MALE));
                            }
                        });
                    }

                    @Override
                    public void onFailure(int code, final String msg) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(getApplicationContext(),"设置性别失败",Toast.LENGTH_LONG).show();
                            }
                        });
                    }
                });
                dialog.dismiss();
            }
        });

        Button btnFemale = (Button) view.findViewById(R.id.btn_ss_female);
        btnFemale.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                TCUserMgr.getInstance().setUserSex(TCConstants.FEMALE, new TCHTTPMgr.Callback() {
                    @Override
                    public void onSuccess(JSONObject data) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mTcControllerView.setContent(TCUtils.EnumGenderToString(TCConstants.FEMALE));
                            }
                        });
                    }

                    @Override
                    public void onFailure(int code, final String msg) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(getApplicationContext(),"设置性别失败",Toast.LENGTH_LONG).show();
                            }
                        });
                    }
                });
                dialog.dismiss();
            }
        });

        dialog.show();
    }
}
