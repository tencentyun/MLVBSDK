package com.tencent.liteav.demo.livepusher.camerapush.ui.view;

import android.app.DialogFragment;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.liteav.demo.livepusher.R;

public class LoadingFragment extends DialogFragment {

    private ImageView mImageLoading;
    private TextView mTextTitle;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.LivePusherMlvbDialogFragment);
        setCancelable(false);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.livepusher_fragment_loading, container, false);
    }

    @Override
    public void onViewCreated(final View view, @Nullable Bundle savedInstanceState) {
        mImageLoading = (ImageView) view.findViewById(R.id.livepusher_iv_fragment_loading);
        mTextTitle = (TextView) view.findViewById(R.id.livepusher_tv_fragment_title);
    }

    @Override
    public void onResume() {
        super.onResume();
        startLoadingAnimation();
    }

    @Override
    public void onPause() {
        super.onPause();
        stopLoadingAnimation();
    }

    @Override
    public void dismissAllowingStateLoss() {
        try {
            super.dismissAllowingStateLoss();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void startLoadingAnimation() {
        if (mImageLoading != null) {
            mImageLoading.setVisibility(View.VISIBLE);
            ((AnimationDrawable) mImageLoading.getDrawable()).start();
        }
    }

    private void stopLoadingAnimation() {
        if (mImageLoading != null) {
            mImageLoading.setVisibility(View.GONE);
            ((AnimationDrawable) mImageLoading.getDrawable()).stop();
        }
    }
}
