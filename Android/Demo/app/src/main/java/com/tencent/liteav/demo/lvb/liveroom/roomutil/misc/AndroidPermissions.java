package com.tencent.liteav.demo.lvb.liveroom.roomutil.misc;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.StyleRes;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import com.tencent.liteav.demo.R;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


public class AndroidPermissions {

    private Activity mContext;
    private String[] mRequiredPermissions;
    private List<String> mPermissionsToRequest = new ArrayList<>();

    public AndroidPermissions(Activity context, String... requiredPermissions) {
        mContext = context;
        mRequiredPermissions = requiredPermissions;
    }


    public boolean checkPermissions() {
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.LOLLIPOP_MR1)
            return true;

        for (String permission : mRequiredPermissions) {
            if (ContextCompat.checkSelfPermission(mContext, permission) != PackageManager.PERMISSION_GRANTED) {
                mPermissionsToRequest.add(permission);
            }
        }

        if (mPermissionsToRequest.isEmpty()) {
            return true;
        }

        return false;
    }


    public void requestPermissions(int requestCode) {
        String[] request = mPermissionsToRequest.toArray(new String[mPermissionsToRequest.size()]);

        StringBuilder sb = new StringBuilder();
        sb.append("Requesting permissions:\n");

        for (String permission : request) {
            sb.append(permission).append("\n");
        }

        Log.i(getClass().getSimpleName(), sb.toString());

        ActivityCompat.requestPermissions(mContext, request, requestCode);
    }


    public boolean areAllRequiredPermissionsGranted(String[] permissions, int[] grantResults) {
        if (permissions == null || permissions.length == 0
                || grantResults == null || grantResults.length == 0) {
            return false;
        }

        LinkedHashMap<String, Integer> perms = new LinkedHashMap<>();

        for (int i = 0; i < permissions.length; i++) {
            if (!perms.containsKey(permissions[i])
                    || (perms.containsKey(permissions[i]) && perms.get(permissions[i]) == PackageManager.PERMISSION_DENIED))
                perms.put(permissions[i], grantResults[i]);
        }

        for (Map.Entry<String, Integer> entry : perms.entrySet()) {
            if (entry.getValue() != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }

        return true;
    }

    /**
     * Created by jac on 2017/10/11.
     */

    public static class HintDialog extends Dialog implements View.OnClickListener {

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
}