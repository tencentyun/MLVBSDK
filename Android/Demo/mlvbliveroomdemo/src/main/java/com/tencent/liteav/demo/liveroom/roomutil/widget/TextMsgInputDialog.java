package com.tencent.liteav.demo.liveroom.roomutil.widget;

import android.app.Dialog;
import android.content.Context;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.text.InputType;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.liveroom.R;

/**
 * 文本输入框
 */
public class TextMsgInputDialog extends Dialog {

    public interface OnTextSendListener {
       void onTextSend(String msg, boolean danmuOpen);
    }

    private Context         mContext;

    private TextView        mTextConfirmBtn;
    private EditText        mEditMessage;
    private LinearLayout    mLinearBarrageArea;
    private LinearLayout    mLinearConfirmArea;
    private RelativeLayout  mRelativeDlg;

    private InputMethodManager mInputMethodManager;
    private OnTextSendListener mOnTextSendListener;

    private int     mLastDiff   = 0;
    private boolean mDanmuOpen  = false;

    public TextMsgInputDialog(Context context, int theme) {
        super(context, theme);
        mContext = context;
        setContentView(R.layout.mlvb_dialog_input_text);

        mEditMessage = (EditText) findViewById(R.id.mlvb_et_input_message);
        mEditMessage.setInputType(InputType.TYPE_CLASS_TEXT);
        //修改下划线颜色
        mEditMessage.getBackground().setColorFilter(context.getResources().getColor(R.color.mlvb_transparent), PorterDuff.Mode.CLEAR);

        mTextConfirmBtn = (TextView) findViewById(R.id.mlvb_tv_confrim_btn);
        mInputMethodManager = (InputMethodManager) mContext.getSystemService(Context.INPUT_METHOD_SERVICE);
        mTextConfirmBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String msg = mEditMessage.getText().toString().trim();
                if (!TextUtils.isEmpty(msg)) {

                    mOnTextSendListener.onTextSend(msg, mDanmuOpen);
                    mInputMethodManager.showSoftInput(mEditMessage, InputMethodManager.SHOW_FORCED);
                    mInputMethodManager.hideSoftInputFromWindow(mEditMessage.getWindowToken(), 0);
                    mEditMessage.setText("");
                    dismiss();
                } else {
                    Toast.makeText(mContext, mContext.getString(R.string.mlvb_input_can_not_be_empty), Toast.LENGTH_LONG).show();
                }
                mEditMessage.setText(null);
            }
        });

        final Button barrageBtn = (Button) findViewById(R.id.mlvb_btn_barrage);
        barrageBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mDanmuOpen = !mDanmuOpen;
            }
        });

        mLinearBarrageArea = (LinearLayout) findViewById(R.id.mlvb_ll_barrage_area);
        mLinearBarrageArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDanmuOpen = !mDanmuOpen;
            }
        });

        mEditMessage.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                switch (actionId) {
                    case KeyEvent.KEYCODE_ENDCALL:
                    case KeyEvent.KEYCODE_ENTER:
                        if (mEditMessage.getText().length() > 0) {
                            mInputMethodManager.hideSoftInputFromWindow(mEditMessage.getWindowToken(), 0);
                            dismiss();
                        } else {
                            Toast.makeText(mContext, mContext.getString(R.string.mlvb_input_can_not_be_empty), Toast.LENGTH_LONG).show();
                        }
                        return true;
                    case KeyEvent.KEYCODE_BACK:
                        dismiss();
                        return false;
                    default:
                        return false;
                }
            }
        });

        mLinearConfirmArea = (LinearLayout) findViewById(R.id.mlvb_ll_confirm_area);
        mLinearConfirmArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String msg = mEditMessage.getText().toString().trim();
                if (!TextUtils.isEmpty(msg)) {
                    mOnTextSendListener.onTextSend(msg, mDanmuOpen);
                    mInputMethodManager.showSoftInput(mEditMessage, InputMethodManager.SHOW_FORCED);
                    mInputMethodManager.hideSoftInputFromWindow(mEditMessage.getWindowToken(), 0);
                    mEditMessage.setText("");
                    dismiss();
                } else {
                    Toast.makeText(mContext, mContext.getString(R.string.mlvb_input_can_not_be_empty), Toast.LENGTH_LONG).show();
                }
                mEditMessage.setText(null);
            }
        });

        mEditMessage.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View view, int i, KeyEvent keyEvent) {
                Log.d("My test", "onKey " + keyEvent.getCharacters());
                return false;
            }
        });

        mRelativeDlg = (RelativeLayout) findViewById(R.id.mlvb_rl_outside_view);
        mRelativeDlg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(v.getId() != R.id.mlvb_ll_inputdlg_view)
                    dismiss();
            }
        });

        final LinearLayout llInputDlg = (LinearLayout) findViewById(R.id.mlvb_ll_inputdlg_view);

        llInputDlg.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View view, int i, int i1, int i2, int i3, int i4, int i5, int i6, int i7) {
                Rect r = new Rect();
                //获取当前界面可视部分
                getWindow().getDecorView().getWindowVisibleDisplayFrame(r);
                //获取屏幕的高度
                int screenHeight =  getWindow().getDecorView().getRootView().getHeight();
                //此处就是用来获取键盘的高度的， 在键盘没有弹出的时候 此高度为0 键盘弹出的时候为一个正数
                int heightDifference = screenHeight - r.bottom;

                if (heightDifference <= 0 && mLastDiff > 0){
                    dismiss();
                }
                mLastDiff = heightDifference;
            }
        });
        llInputDlg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mInputMethodManager.hideSoftInputFromWindow(mEditMessage.getWindowToken(), 0);
                dismiss();
            }
        });
    }

    public void setOnTextSendListener(OnTextSendListener onTextSendListener) {
        this.mOnTextSendListener = onTextSendListener;
    }

    @Override
    public void dismiss() {
        super.dismiss();
        //dismiss之前重置mLastDiff值避免下次无法打开
        mLastDiff = 0;
    }

    @Override
    public void show() {
        super.show();
    }
}
