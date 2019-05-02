package com.tencent.qcloud.xiaozhibo.videoeditor.word;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import com.tencent.qcloud.xiaozhibo.R;


/**
 * Created by hanszhli on 2017/6/27.
 */

public class TCWordInputFragment extends Fragment implements View.OnClickListener {
    private static final String KEY_WORD_INFO = "key_word_info";
    private EditText mEtWordEnter;
    private TextView mTvWordContent;
    private TCWordInfo mTCWordInfo;

    private int mCurrentBackgroundColor = 0;//代表没有
    private int mCurrentBackgroundPaddingSize = 0;
    private int mCurrentTextSize = 28;//sp
    private int mCurrentTextColor = Color.WHITE;


    /**
     * 新字幕输入 调用该构造方法
     *
     * @return
     */
    public static TCWordInputFragment newInstance() {
        return new TCWordInputFragment();
    }

    /**
     * 编辑字幕 调用该构造方法
     *
     * @param tcWordInfo
     * @return
     */
    public static TCWordInputFragment newInstance(TCWordInfo tcWordInfo) {
        TCWordInputFragment fragment = new TCWordInputFragment();
        Bundle bundle = new Bundle();
        bundle.putParcelable(KEY_WORD_INFO, tcWordInfo);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_word_input, container, false);
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d("seq", "onResume");
        requestBackKeyListener();
    }

    private void requestBackKeyListener() {
        getView().setFocusableInTouchMode(true);
        getView().requestFocus();
        getView().setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if ( event.getAction() == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
                    // 监听到返回按钮点击事件
                    if (mOnWordInputListener != null) {
                        mOnWordInputListener.onCancelClick();
                    }
                    return true;
                }
                return false;

            }
        });


    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (getArguments() != null)
            mTCWordInfo = getArguments().getParcelable(KEY_WORD_INFO);
        initViews(view);
    }

    private void initViews(View v) {
        mEtWordEnter = (EditText) v.findViewById(R.id.input_et_word);
        mEtWordEnter.requestFocus();
        //自动弹出软键盘
        mEtWordEnter.post(new Runnable() {
            @Override
            public void run() {
                InputMethodManager inputManager = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                inputManager.showSoftInput(mEtWordEnter, 0);
            }
        });

        mEtWordEnter.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                mTvWordContent.setText(s);
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });


        v.findViewById(R.id.input_tv_back).setOnClickListener(this);
        v.findViewById(R.id.input_tv_done).setOnClickListener(this);

        mTvWordContent = (TextView) v.findViewById(R.id.input_tv_word);

        v.findViewById(R.id.input_tv_small).setOnClickListener(this);
        v.findViewById(R.id.input_tv_middle).setOnClickListener(this);
        v.findViewById(R.id.input_tv_big).setOnClickListener(this);

        v.findViewById(R.id.input_tv_padding_none).setOnClickListener(this);
        v.findViewById(R.id.input_tv_padding_five).setOnClickListener(this);
        v.findViewById(R.id.input_tv_padding_ten).setOnClickListener(this);

        v.findViewById(R.id.input_iv_white).setOnClickListener(this);
        v.findViewById(R.id.input_iv_red).setOnClickListener(this);
        v.findViewById(R.id.input_iv_yellow).setOnClickListener(this);
        v.findViewById(R.id.input_iv_blue).setOnClickListener(this);
        v.findViewById(R.id.input_iv_green).setOnClickListener(this);
        v.findViewById(R.id.input_tv_bg_none).setOnClickListener(this);
        v.findViewById(R.id.input_iv_bg_red).setOnClickListener(this);
        v.findViewById(R.id.input_iv_bg_yellow).setOnClickListener(this);
        v.findViewById(R.id.input_iv_bg_blue).setOnClickListener(this);
        v.findViewById(R.id.input_iv_bg_green).setOnClickListener(this);

        if (mTCWordInfo != null) {
            //View绘制才配置参数
            mTvWordContent.post(new Runnable() {
                @Override
                public void run() {
                    mCurrentBackgroundColor = mTCWordInfo.getBackgroundColor();
                    mCurrentBackgroundPaddingSize = mTCWordInfo.getBackgroundPadding();
                    mCurrentTextColor = mTCWordInfo.getTextColor();
                    mCurrentTextSize = mTCWordInfo.getTextSize();

                    mEtWordEnter.setText(mTCWordInfo.getWord());
                    mTvWordContent.setTextColor(mTCWordInfo.getTextColor());
                    mTvWordContent.setTextSize(mTCWordInfo.getTextSize());
                    if (mTCWordInfo.getBackgroundColor() != 0)
                        mTvWordContent.setBackgroundColor(mTCWordInfo.getBackgroundColor());
                    mTvWordContent.setPadding(
                            mTCWordInfo.getBackgroundPadding(),
                            mTCWordInfo.getBackgroundPadding(),
                            mTCWordInfo.getBackgroundPadding(),
                            mTCWordInfo.getBackgroundPadding());
                    mTvWordContent.setText(mTCWordInfo.getWord());
                }
            });
        }
    }

    private void editWordCancel() {
        hideInput();
        if (mOnWordInputListener != null) {
            mOnWordInputListener.onCancelClick();
        }
    }


    private void editWordDone() {
        hideInput();
        //创建一个和TextView一样大的位图Bitmap
        Bitmap bitmap = Bitmap.createBitmap(mTvWordContent.getWidth(), mTvWordContent.getHeight(), Bitmap.Config.ARGB_8888);
        //将TextView的内容绘制到该Bitmap上
        mTvWordContent.draw(new Canvas(bitmap));

        boolean isEdit = mTCWordInfo != null;
        mTCWordInfo = generateWordInfo(bitmap);
        if (mOnWordInputListener != null) {
            if (isEdit) {
                mOnWordInputListener.onEditFinish(mTCWordInfo);
            } else {
                mOnWordInputListener.onNewInputFinish(mTCWordInfo);
            }
            mOnWordInputListener.onDoneClick();
        }
    }

    private TCWordInfo generateWordInfo(Bitmap bitmap) {
        if (mTCWordInfo == null) {
            mTCWordInfo = new TCWordInfo();
        }
        mTCWordInfo.setBitmap(bitmap);
        mTCWordInfo.setWord(mTvWordContent.getText().toString());
        mTCWordInfo.setBackgroundColor(mCurrentBackgroundColor);
        mTCWordInfo.setBackgroundPadding(mCurrentBackgroundPaddingSize);
        mTCWordInfo.setTextColor(mCurrentTextColor);
        mTCWordInfo.setTextSize(mCurrentTextSize);
        return mTCWordInfo;
    }

    private void hideInput() {
        InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(mEtWordEnter, InputMethodManager.SHOW_FORCED);
        imm.hideSoftInputFromWindow(mEtWordEnter.getWindowToken(), 0);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.input_tv_back:
                editWordCancel();
                break;
            case R.id.input_tv_done:
                editWordDone();
                break;
            case R.id.input_tv_small:
                mTvWordContent.setTextSize(24);
                mCurrentTextSize = 24;
                break;
            case R.id.input_tv_middle:
                mTvWordContent.setTextSize(28);
                mCurrentTextSize = 28;
                break;
            case R.id.input_tv_big:
                mTvWordContent.setTextSize(32);
                mCurrentTextSize = 32;
                break;
            case R.id.input_iv_white:
                mTvWordContent.setTextColor(getResources().getColor(R.color.white));
                mCurrentTextColor = getResources().getColor(R.color.white);
                break;
            case R.id.input_iv_red:
                mTvWordContent.setTextColor(getResources().getColor(R.color.edit_red));
                mCurrentTextColor = getResources().getColor(R.color.edit_red);

                break;
            case R.id.input_iv_yellow:
                mTvWordContent.setTextColor(getResources().getColor(R.color.edit_yellow));
                mCurrentTextColor = getResources().getColor(R.color.edit_yellow);
                break;
            case R.id.input_iv_blue:
                mTvWordContent.setTextColor(getResources().getColor(R.color.edit_blue));
                mCurrentTextColor = getResources().getColor(R.color.edit_blue);
                break;
            case R.id.input_iv_green:
                mTvWordContent.setTextColor(getResources().getColor(R.color.edit_green));
                mCurrentTextColor = getResources().getColor(R.color.edit_green);
                break;
            case R.id.input_tv_padding_none:
                changeTVContentPadding(0);
                mCurrentBackgroundPaddingSize = 0;
                break;
            case R.id.input_tv_padding_five:
                changeTVContentPadding(5);
                mCurrentBackgroundPaddingSize = 5;
                break;
            case R.id.input_tv_padding_ten:
                changeTVContentPadding(10);
                mCurrentBackgroundPaddingSize = 10;
                break;
            case R.id.input_tv_bg_none:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                    mTvWordContent.setBackground(null);
                } else {
                    mTvWordContent.setBackgroundDrawable(null);
                }
                mCurrentBackgroundColor = 0;
                break;
            case R.id.input_iv_bg_red:
                mTvWordContent.setBackgroundColor(getResources().getColor(R.color.edit_red));
                mCurrentBackgroundColor = getResources().getColor(R.color.edit_red);
                break;
            case R.id.input_iv_bg_yellow:
                mTvWordContent.setBackgroundColor(getResources().getColor(R.color.edit_yellow));
                mCurrentBackgroundColor = getResources().getColor(R.color.edit_yellow);
                break;
            case R.id.input_iv_bg_blue:
                mTvWordContent.setBackgroundColor(getResources().getColor(R.color.edit_blue));
                mCurrentBackgroundColor = getResources().getColor(R.color.edit_blue);
                break;
            case R.id.input_iv_bg_green:
                mTvWordContent.setBackgroundColor(getResources().getColor(R.color.edit_green));
                mCurrentBackgroundColor = getResources().getColor(R.color.edit_green);
                break;

        }
    }

    /**
     * @param paddingSize dp
     */
    private void changeTVContentPadding(int paddingSize) {
        int paddingSizePx = dip2px(getActivity(), paddingSize);
        mTvWordContent.setPadding(paddingSizePx, paddingSizePx, paddingSizePx, paddingSizePx);
    }

    /**
     * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
     */
    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * 将sp值转换为px值，保证文字大小不变
     *
     * @param spValue （DisplayMetrics类中属性scaledDensity）
     * @return
     */
    public static int sp2px(Context context, float spValue) {
        final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
        return (int) (spValue * fontScale + 0.5f);
    }

    private OnWordInputListener mOnWordInputListener;

    public void setOnWordInputListener(OnWordInputListener listener) {
        mOnWordInputListener = listener;
    }

    public interface OnWordInputListener {
        void onEditFinish(TCWordInfo info);//编辑时候回调该接口

        void onNewInputFinish(TCWordInfo info);//新输入回调该接口

        void onCancelClick();

        void onDoneClick();
    }
}
