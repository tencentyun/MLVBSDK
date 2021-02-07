package com.tencent.liteav.demo.liveroom.roomutil.misc;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.StyleRes;
import android.view.View;
import android.widget.TextView;

import com.tencent.liteav.demo.liveroom.R;

import java.lang.ref.WeakReference;

/**
 * Created by jac on 2017/10/11.
 */

public class HintDialog extends Dialog implements View.OnClickListener {

    private TextView mTextContent;
    private TextView mTextOkButton;
    private TextView mTextTitle;
    private String mTitle;
    private String mContent;
    private String mOkButton;

    public HintDialog(@NonNull Context context) {
        this(context, R.style.MlvbRtmpRoomDialogTheme);
    }

    public HintDialog(@NonNull Context context, @StyleRes int themeResId) {
        super(context, themeResId);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.mlvb_layout_rtmproom_hint_dialog);
        mTextContent = ((TextView) findViewById(R.id.mlvb_rtmproom_hint_dialog_content));
        mTextOkButton = ((TextView) findViewById(R.id.mlvb_btn_rtmproom_hint_dialog_confirm));
        mTextTitle = ((TextView) findViewById(R.id.mlvb_tv_rtmproom_hint_dialog_title));
        if (mOkButton != null){
            mTextOkButton.setText(mOkButton);
        }
        mTextOkButton.setOnClickListener(this);
        mTextTitle.setText(mTitle);
        mTextContent.setText(mContent);
    }

    @Override
    public void onClick(View v) {
        if (v == mTextOkButton){
            dismiss();
        }
    }

    public void setTextTitle(String textTitle) {
        this.mTitle = textTitle;
    }

    public void setTextContent(String textContent) {
        this.mContent = textContent;
    }

    public void setButtonText(String buttonText) {
        this.mOkButton = buttonText;
    }

    public static class Builder {
        private String titile;
        private String mContent;
        private String buttonText;
        private WeakReference<Activity> activity;
        private OnDismissListener mDismissListener;

        public Builder(Activity context){
            this(context, null, null);
        }

        public Builder(Activity activity, String titile, String mContent) {
            this.titile = titile;
            this.mContent = mContent;
            this.activity = new WeakReference<Activity>(activity) ;
        }

        public Builder(Activity activity, int titileResId){
            this(activity, null, null);
            String title = activity.getString(titileResId);
            setTittle(title);
        }

        public Builder setTittle(String title){
            this.titile = title;
            return this;
        }
        public Builder setContent(String content){
            this.mContent = content;
            return this;
        }
        public Builder setDismissListener(OnDismissListener listener){
            mDismissListener = listener;
            return this;
        }

        public Builder setButtonText(String buttonText) {
            this.buttonText = buttonText;
            return this;
        }

        public void show(){
            Activity activity = this.activity.get();
            if (activity == null) return;
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Builder.this.build().show();
                }
            });
        }

        private HintDialog build(){
            HintDialog dialog = new HintDialog(activity.get());
            dialog.setTextTitle(titile);
            dialog.setTextContent(mContent);
            dialog.setOnDismissListener(mDismissListener);
            dialog.setButtonText(buttonText);
            return dialog;
        }

    }
}
