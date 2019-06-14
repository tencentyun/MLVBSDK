package com.tencent.qcloud.xiaozhibo.main.splash;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;

/**
 *  Module:   URLGuideDialogFragment
 *
 *  Function: 指引链接的弹窗 Fragment
 *
 *  主要用于对 APP 指引方面进行强提示。
 */
public class URLGuideDialogFragment extends DialogFragment {
    public static final String ERROR_TITLE = "error_title";
    public static final String ERROR_MSG = "error_msg";
    public static final String ERROR_LINK = "error_link";

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Bundle bundle = getArguments();

        String title = bundle != null ? getArguments().getString(ERROR_TITLE) : null;
        String msg = bundle != null ? getArguments().getString(ERROR_MSG) : null;
        String link = bundle != null ? getArguments().getString(ERROR_LINK) : null;

        if (TextUtils.isEmpty(title)) {
            title = "";
        }
        if (TextUtils.isEmpty(msg)) {
            msg = "";
        }
        if (TextUtils.isEmpty(link)) {
            link = "";
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity(), R.style.ConfirmDialogStyle)
                .setCancelable(false)
                .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        Activity activity = getActivity();
                        if (activity != null) {
                            activity.finish();
                        }
                    }
                });

        String shownText = msg;
        int linkStart = shownText.indexOf("[");
        int linkEnd = shownText.indexOf("]");
        SpannableStringBuilder sb = null;
        // 约定 msg 中都包含 "[]"，用于指引链接的文本跳转。 所以当没有 "[]" 的时候，都认为是普通文本。
        if (shownText.length() > 2 && linkStart != -1 && linkEnd != -1 && link != null) {
            sb = new SpannableStringBuilder(shownText);
            sb.setSpan(new ForegroundColorSpan(Color.BLUE), linkStart, linkEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            final String _link = link;
            ClickableSpan clickableSpan = new ClickableSpan() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent();
                    intent.setAction("android.intent.action.VIEW");
                    Uri content_url = Uri.parse(_link);
                    intent.setData(content_url);
                    startActivity(intent);
                }
            };
            sb.setSpan(clickableSpan, linkStart, linkEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
        if (getActivity() != null) {
            TextView tv = new TextView(getActivity());
            tv.setMovementMethod(LinkMovementMethod.getInstance());
            if (sb != null) {
                tv.setText(sb);
            } else {
                tv.setText(msg);
            }
            tv.setPadding(20, 50, 20, 0);
            builder.setView(tv);
        }
        builder.setTitle(title);

        AlertDialog alertDialog = builder.create();
        alertDialog.setCancelable(false);
        alertDialog.setCanceledOnTouchOutside(false);
        return alertDialog;
    }
}
