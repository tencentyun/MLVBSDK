package com.tencent.qcloud.xiaozhibo.profile.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.os.Handler;
import android.os.Looper;
import android.text.InputFilter;
import android.text.Spanned;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.net.TCHTTPMgr;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.common.utils.TCUtils;
import com.tencent.qcloud.xiaozhibo.login.TCUserMgr;

import org.json.JSONObject;


/**
 * Module:   TCLineEditTextView
 *
 * Function: 文本修改控件，对控件EditText的简单封装，可以用来修改文本，并显示相关信息
 *
 **/
public class TCLineEditTextView extends LinearLayout {
    private String name;
    private boolean isBottom;
    private String content;
    private EditText contentEditView;
    private Context mContext;

    public TCLineEditTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;

        LayoutInflater.from(mContext).inflate(R.layout.layout_view_line_edit_text, this);
        TypedArray ta = mContext.obtainStyledAttributes(attrs, R.styleable.TCLineView, 0, 0);
        try {
            name = ta.getString(R.styleable.TCLineView_name);
            content = ta.getString(R.styleable.TCLineView_content);
            isBottom = ta.getBoolean(R.styleable.TCLineView_isBottom, false);
            setUpView();

            //昵称长度限制
            filterLength(TCConstants.NICKNAME_MAX_LEN, "昵称长度不能超过" + TCConstants.NICKNAME_MAX_LEN / 2);
            contentEditView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    contentEditView.setCursorVisible(true);
                }
            });
            contentEditView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                    if (actionId == EditorInfo.IME_ACTION_DONE || (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER)) {
                        if (TextUtils.isEmpty(getContent().trim())) {
                            contentEditView.setError("昵称不能为空");
                            InputMethodManager imm = (InputMethodManager) mContext.getSystemService(Context.INPUT_METHOD_SERVICE);
                            imm.showSoftInputFromInputMethod(contentEditView.getWindowToken(), 0);
                            return true;
                         }
                        TCUserMgr.getInstance().setNickName(getContent(), new TCHTTPMgr.Callback() {
                                @Override
                                public void onSuccess(JSONObject data) {
                                    Handler handler = new Handler(Looper.getMainLooper());
                                    handler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            contentEditView.clearFocus();
                                            InputMethodManager imm = (InputMethodManager) mContext.getSystemService(Context.INPUT_METHOD_SERVICE);
                                            imm.hideSoftInputFromWindow(contentEditView.getWindowToken(), 0);
                                        }
                                    });
                                }

                                @Override
                                public void onFailure(int code, final String msg) {
                                    Handler handler = new Handler(Looper.getMainLooper());
                                    handler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            contentEditView.setError("昵称不合法，请更换 : " + msg);
                                        }
                                    });
                                }
                        });
                        contentEditView.setError(null);
                        contentEditView.setCursorVisible(false);
                        return true;
                    }
                    return false;
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            ta.recycle();
        }
    }

    private void setUpView() {
        TextView tvName = (TextView) findViewById(R.id.ett_name);
        tvName.setText(name);
        contentEditView = (EditText) findViewById(R.id.ett_content);
        contentEditView.setText(content);
        View bottomLine = findViewById(R.id.ett_bottomLine);
        bottomLine.setVisibility(isBottom ? VISIBLE : GONE);
    }


    /**
     * 设置EditText内容
     */
    public void setContent(String content) {
        contentEditView.setText(content);
        contentEditView.setSelection(contentEditView.getText().length());
    }

    /**
     * 获取EditText内容
     */
    public String getContent() {
        return contentEditView.getText().toString();
    }


    /**
     * contentEditView可输入最大长度限制检测
     *
     * @param max_length 可输入最大长度
     * @param err_msg    达到可输入最大长度时的提示语
     */
    private void filterLength(final int max_length, final String err_msg) {
        InputFilter[] filters = new InputFilter[1];
        filters[0] = new InputFilter.LengthFilter(max_length) {
            @Override
            public CharSequence filter(CharSequence source, int start, int end,
                                       Spanned dest, int dstart, int dend) {
                int destLen = TCUtils.getCharacterNum(dest.toString()); //获取字符个数(一个中文算2个字符)
                int sourceLen = TCUtils.getCharacterNum(source.toString());
                if (destLen + sourceLen > max_length) {
                    contentEditView.setError(err_msg);
                    return "";
                }
                return source;
            }
        };
        contentEditView.setFilters(filters);
    }

}
