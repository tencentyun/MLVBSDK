package com.tencent.liteav.demo.liveplayer.ui;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.google.zxing.Result;
import com.tencent.liteav.demo.liveplayer.R;

import java.util.ArrayList;
import java.util.List;

import me.dm7.barcodescanner.core.IViewFinder;
import me.dm7.barcodescanner.core.ViewFinderView;
import me.dm7.barcodescanner.zxing.ZXingScannerView;

/**
 * 扫描二维码的Activity，扫描成功后将视频源URL返回给{@link LivePlayerMainActivity}
 */
public class QRCodeScanActivity extends Activity implements ZXingScannerView.ResultHandler {

    private ZXingScannerView mViewScanner;

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        ViewGroup view = (ViewGroup) View.inflate(this, R.layout.liveplayer_activity_qr_code_scan, null);
        mViewScanner = new ZXingScannerView(this) {
            @Override
            protected IViewFinder createViewFinderView(Context context) {
                return new CustomViewFinderView(context);
            }
        };
        view.addView(mViewScanner, 0);
        setContentView(view);
    }

    @Override
    public void onResume() {
        super.onResume();
        mViewScanner.setResultHandler(this);
        PermissionUtils.permission(PermissionConstants.CAMERA).callback(new PermissionUtils.FullCallback() {
            @Override
            public void onGranted(List<String> permissionsGranted) {
                mViewScanner.startCamera();
            }

            @Override
            public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                ToastUtils.showShort(R.string.liveplayer_camera);
                finish();
            }
        }).request();
    }

    @Override
    public void onPause() {
        super.onPause();
        mViewScanner.stopCamera();
    }

    @Override
    public void handleResult(Result rawResult) {

        String url = rawResult.toString();
        Intent intent = new Intent();
        /**
         * 把返回数据存入Intent并设置返回数据；
         * */
        if (TextUtils.isEmpty(url)) {
            intent.putExtra(Constants.INTENT_SCAN_RESULT, "");
        } else {
            intent.putExtra(Constants.INTENT_SCAN_RESULT, url);
        }
        setResult(RESULT_OK, intent);
        finish();

        /**
         * Note:
         * Wait 2 seconds to resume the preview.
         * On older devices continuously stopping and resuming camera preview can result in freezing the app.
         * I don't know why this is the case but I don't have the time to figure out.
         */
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mViewScanner.resumeCameraPreview(QRCodeScanActivity.this);
            }
        }, 2000);
    }

    public void onClick(View view) {
        if (view.getId() == R.id.liveplayer_ibtn_back) {
            finish();
        }
    }

    private static class CustomViewFinderView extends ViewFinderView {
        private static final String TRADE_MARK_TEXT = "scan url";
        private static final int TRADE_MARK_TEXT_SIZE_SP = 40;

        private final Paint mPaint = new Paint();

        public CustomViewFinderView(Context context) {
            super(context);
            init();
        }

        public CustomViewFinderView(Context context, AttributeSet attrs) {
            super(context, attrs);
            init();
        }

        private void init() {
            mPaint.setColor(Color.WHITE);
            mPaint.setAntiAlias(true);
            float textPixelSize = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP,
                    TRADE_MARK_TEXT_SIZE_SP, getResources().getDisplayMetrics());
            mPaint.setTextSize(textPixelSize);
        }

        @Override
        public void onDraw(Canvas canvas) {
            super.onDraw(canvas);
            drawTradeMark(canvas);
        }

        private void drawTradeMark(Canvas canvas) {
            Rect framingRect = getFramingRect();
            float tradeMarkTop;
            float tradeMarkLeft;
            if (framingRect != null) {
                tradeMarkTop = framingRect.bottom + mPaint.getTextSize() + 10;
                tradeMarkLeft = framingRect.left;
            } else {
                tradeMarkTop = 10;
                tradeMarkLeft = canvas.getHeight() - mPaint.getTextSize() - 10;
            }
            canvas.drawText(TRADE_MARK_TEXT, tradeMarkLeft, tradeMarkTop, mPaint);
        }
    }
}
