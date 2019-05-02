package com.tencent.liteav.demo.common.view;

import android.app.Dialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.liteav.demo.common.R;

/**
 * Created by vinsonswang on 2017/11/1.
 */

public class CustomProgressDialog {
    private Dialog mDialog;
    private TextView tvMsg;
    /**
     * 得到自定义的progressDialog
     * @param context
     * @param msg
     * @return
     */
    public void createLoadingDialog(Context context, String msg) {

        LayoutInflater inflater = LayoutInflater.from(context);
        View v = inflater.inflate(R.layout.layout_loading_progress, null);// 得到加载view
        LinearLayout layout = (LinearLayout) v.findViewById(R.id.layout_progress);// 加载布局

        ImageView spaceshipImage = (ImageView) v.findViewById(R.id.progress_img);
        tvMsg = (TextView) v.findViewById(R.id.msg_tv);
        // 加载动画
        Animation hyperspaceJumpAnimation = AnimationUtils.loadAnimation(
                context, R.anim.load_progress_animation);
        // 使用ImageView显示动画
        spaceshipImage.startAnimation(hyperspaceJumpAnimation);

        mDialog = new Dialog(context, R.style.loading_dialog);// 创建自定义样式dialog

        mDialog.setCancelable(false);// 不可以用“返回键”取消
        mDialog.setContentView(layout, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));// 设置布局
    }

    public void setCancelable(boolean cancelable){
        if(mDialog != null){
            mDialog.setCancelable(cancelable);
        }
    }

    public void setCanceledOnTouchOutside(boolean canceledOnTouchOutside){
        if(mDialog != null){
            mDialog.setCanceledOnTouchOutside(canceledOnTouchOutside);
        }
    }

    public void show(){
        if(mDialog != null){
            mDialog.show();
        }
    }

    public void dismiss(){
        if(mDialog != null){
            mDialog.dismiss();
        }
    }

    public void setMsg(String msg){
        if(tvMsg == null){
            return;
        }
        if(tvMsg.getVisibility() == View.GONE){
            tvMsg.setVisibility(View.VISIBLE);
        }
        tvMsg.setText(msg);
    }
}
