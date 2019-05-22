package com.tencent.qcloud.xiaozhibo.common.activity;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
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
 * Created by Administrator on 2016/9/26.
 */
public class URLGuideDialogFragment extends DialogFragment {
    public static final String ERROR_TITLE = "error_title";
    public static final String ERROR_MSG = "error_msg";
    public static final String ERROR_LINK = "error_link";

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        String title = getArguments().getString(ERROR_TITLE);
        String msg = getArguments().getString(ERROR_MSG);
        String link = getArguments().getString(ERROR_LINK);

        if (TextUtils.isEmpty(title)) {
            title = "";
        }
        if (TextUtils.isEmpty(msg)) {
            msg = "[]";
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

                        getActivity().finish();
                    }
                });

        String shownText = msg;
        int linkStart = shownText.indexOf("[");
        int linkEnd = shownText.indexOf("]");
        SpannableStringBuilder spannableStrBuidler = new SpannableStringBuilder(shownText);
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
        spannableStrBuidler.setSpan(new ForegroundColorSpan(Color.BLUE), linkStart, linkEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        spannableStrBuidler.setSpan(clickableSpan, linkStart, linkEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        TextView tv = new TextView(this.getActivity());

        tv.setMovementMethod(LinkMovementMethod.getInstance());
        tv.setText(spannableStrBuidler);
        tv.setPadding(20, 50, 20, 0);
        builder.setView(tv).setTitle(title);

        AlertDialog alertDialog = builder.create();
        alertDialog.setCancelable(false);
        alertDialog.setCanceledOnTouchOutside(false);
        return alertDialog;
    }
}
