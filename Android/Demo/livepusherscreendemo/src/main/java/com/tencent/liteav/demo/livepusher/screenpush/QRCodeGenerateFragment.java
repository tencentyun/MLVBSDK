package com.tencent.liteav.demo.livepusher.screenpush;

import android.app.DialogFragment;
import android.app.FragmentManager;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.util.HashMap;
import java.util.Map;

/**
 * 推流时，生成对应的拉流二维码，供Player拉流播放
 */
public class QRCodeGenerateFragment extends DialogFragment {

    private static final int QR_CODE_SIDE_LENGTH = 300;      //二维码边长

    /**
     * 定义一个剪贴板管理
     */
    private ClipboardManager mClipboardManager;
    private ClipData         mClipData;

    private ImageView        mImageQRCode;
    private LinearLayout     mLayoutCopy;
    private Button           mButtonClose;

    private String mQRCodeURL;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.LivePusherMlvbDialogFragment);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.livepusherscreen_fragment_play_qr_code, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mClipboardManager = (ClipboardManager) getActivity().getSystemService(Context.CLIPBOARD_SERVICE);
        initViews(view);
        initData();
    }

    @Override
    public void dismissAllowingStateLoss() {
        try {
            super.dismissAllowingStateLoss();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void show(FragmentManager manager, String tag) {
        try {
            //在每个add事务前增加一个remove事务，防止连续的add
            manager.beginTransaction().remove(this).commit();
            super.show(manager, tag);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void toggle(FragmentManager manager, String tag) {
        if (isVisible()) {
            dismissAllowingStateLoss();
        } else {
            show(manager, tag);
        }
    }

    public void setQRCodeURL(String playURL) {
        mQRCodeURL = playURL;
    }

    public void updateQRCodeURL(String playURL) {
        mQRCodeURL = playURL;
        setPlayURLQRCode();
    }

    private void initViews(View view) {

        mImageQRCode = (ImageView) view.findViewById(R.id.livepusher_iv_qr_code);
        mLayoutCopy = (LinearLayout) view.findViewById(R.id.livepusher_ll_copy);
        mLayoutCopy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mClipData = ClipData.newPlainText("text", mQRCodeURL);
                mClipboardManager.setPrimaryClip(mClipData);
                Toast.makeText(getActivity(), getString(R.string.livepusher_screen_primary_clip), Toast.LENGTH_SHORT).show();
            }
        });

        mButtonClose = (Button) view.findViewById(R.id.livepusher_btn_close);
        mButtonClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismissAllowingStateLoss();
            }
        });
    }

    private void initData() {
        setPlayURLQRCode();
    }

    /**
     * 根据播放连接生成二维码，设置到View中
     *
     */
    private void setPlayURLQRCode() {
        AsyncTask.execute(new Runnable() { // 生成二维码，耗时操作，放到AsyncTask中
            @Override
            public void run() {
                final Bitmap bitmap = generateBitmap(mQRCodeURL, QR_CODE_SIDE_LENGTH, QR_CODE_SIDE_LENGTH);
                if (bitmap != null) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            if (mImageQRCode != null) {
                                mImageQRCode.setImageBitmap(bitmap);
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 利用 QRCode 生成 Bitmap的工具函数
     *
     * @param content
     * @param width
     * @param height
     * @return
     */
    public static Bitmap generateBitmap(String content, int width, int height) {
        if (TextUtils.isEmpty(content)) {
            return null;
        }
        try {
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
            hints.put(EncodeHintType.MARGIN, 1);

            BitMatrix matrix = new QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, width, height, hints);
            matrix = deleteWhite(matrix);//删除白边

            width = matrix.getWidth();
            height = matrix.getHeight();
            int[] pixels = new int[width * height];

            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    if (matrix.get(x, y)) {
                        pixels[y * width + x] = Color.BLACK;
                    } else {
                        pixels[y * width + x] = Color.WHITE;
                    }
                }
            }

            Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
            return bitmap;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 去除二维码的白边
     *
     * @param matrix
     * @return
     */
    private static BitMatrix deleteWhite(BitMatrix matrix) {
        int[] rec = matrix.getEnclosingRectangle();
        int resWidth = rec[2] + 1;
        int resHeight = rec[3] + 1;

        BitMatrix resMatrix = new BitMatrix(resWidth, resHeight);
        resMatrix.clear();
        for (int i = 0; i < resWidth; i++) {
            for (int j = 0; j < resHeight; j++) {
                if (matrix.get(i + rec[0], j + rec[1]))
                    resMatrix.set(i, j);
            }
        }
        return resMatrix;
    }
}
