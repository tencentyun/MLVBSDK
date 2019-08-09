package com.tencent.liteav.demo.lvb.liveroom.roomutil.misc;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.StyleRes;
import android.view.View;
import android.widget.TextView;

import com.tencent.liteav.demo.R;

import java.lang.ref.WeakReference;

/**
 * Created by jac on 2017/10/11.
 */

public class HintDialog extends Dialog implements View.OnClickListener {

    private TextView mContent;
    private TextView mOkButton;
    private TextView mTitle;
    private String textTitle;
    private String textContent;
    private String buttonText;

    public HintDialog(@NonNull Context context) {
        this(context, R.style.RtmpRoomDialogTheme);
    }

    public HintDialog(@NonNull Context context, @StyleRes int themeResId) {
        super(context, themeResId);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_rtmproom_hint_dialog);
        mContent = ((TextView) findViewById(R.id.rtmproom_hint_dialog_content));
        mOkButton = ((TextView) findViewById(R.id.rtmproom_hint_dialog_confirm_button));
        mTitle = ((TextView) findViewById(R.id.rtmproom_hint_dialog_title));
        if (buttonText != null){
            mOkButton.setText(buttonText);
        }
        mOkButton.setOnClickListener(this);
        mTitle.setText(textTitle);
        mContent.setText(textContent);
    }

    @Override
    public void onClick(View v) {
        if (v == mOkButton){
            dismiss();
        }
    }

    public void setTextTitle(String textTitle) {
        this.textTitle = textTitle;
    }

    public void setTextContent(String textContent) {
        this.textContent = textContent;
    }

    public void setButtonText(String buttonText) {
        this.buttonText = buttonText;
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
