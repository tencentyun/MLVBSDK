package com.tencent.liteav.demo.livepusher.camerapush.ui.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.tencent.liteav.demo.livepusher.R;
import com.tencent.rtmp.TXLiveConstants;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.liteav.demo.beauty.utils.ResourceUtils.getResources;

/**
 * 自定义 Log 信息展示弹窗
 *
 * - 设备版本、型号
 * - 编译码率、上传速度
 * - FPS 和 GOP
 * - 信号强度
 * - 推流执行步骤
 *      1、地址合法性
 *      2、链接服务器
 *      3、摄像头是否打开
 *      4、编码器是否正常
 *      5、开始推流
 */
public class LogInfoWindow extends PopupWindow {

    private static final String TAG = "LogInfoWindow";

    private static final int ENCODER_HARD   = 1;
    private static final int ENCODER_SOFT   = 2;

    public static final int CHECK_RTMP_URL_OK   = 999;
    public static final int CHECK_RTMP_URL_FAIL = 998;

    private Context mContext;
    private LinearLayout mLayout;
    private ImageView mImageNetSpeed;

    private int mNetSpeed;
    private int mCurrentSuccessStep = LogInfo.ID_STEP_1;

    public LogInfoWindow(Context context) {
        super(context);
        mContext = context;
        setBackgroundDrawable(new ColorDrawable(0x55000000));
        initView();
        initData();
    }

    public void setLogText(Bundle status, Bundle event, int eventId) {
        if (eventId == TXLiveConstants.PLAY_EVT_CHANGE_ROTATION || eventId == TXLiveConstants.PLAY_EVT_GET_MESSAGE)
            return;

        if (status != null) {
            handleLogStatus(status);
        }

        if (event != null) {
            handleLogEvent(event, eventId);
        }
    }

    public void setLogInfoList(List<LogInfo> infoList) {
        mLayout.removeAllViews();
        for (LogInfo logInfo : infoList) {
            addItem(logInfo);
        }
    }

    public void updateLogInfoList(List<LogInfo> infoList) {
        for (LogInfo logInfo : infoList) {
            ItemView item = getItem(logInfo.getId());
            if (item == null) {
                addItem(logInfo);
            } else {
                updateItemText(item, String.format("%s：%s", logInfo.getTitle(), logInfo.getValue()));
            }
        }
    }

    public void addLogInfo(LogInfo logInfo) {
        addItem(logInfo);
    }

    public void updateLogInfo(LogInfo logInfo) {
        ItemView item = getItem(logInfo.getId());
        if (item == null) {
            addItem(logInfo);
        } else {
            updateItemText(item, String.format("%s：%s", logInfo.getTitle(), logInfo.getValue()));
        }
    }

    public void show(View anchor) {
        mLayout.measure(0, 0);
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) mContext).getWindowManager().getDefaultDisplay()
                .getMetrics(dm);
        int xoff = (int) (mLayout.getMeasuredWidth() + dip2px(18) - (dm.widthPixels - anchor.getX()));
        showAsDropDown(anchor, -xoff, 0);
    }

    public void reset() {
        initData();
    }

    private void initView() {
        View rootView = LayoutInflater.from(mContext).inflate(R.layout.livepusher_view_loginfo, null);
        setContentView(rootView);
        mLayout = rootView.findViewById(R.id.livepusher_ll_layout);
        mImageNetSpeed = rootView.findViewById(R.id.livepusher_iv_net_speed);
    }

    private void initData() {
        List<LogInfo> list = new ArrayList<>();
        list.add(LogInfo.createModelLogInfo(Build.MODEL));
        list.add(LogInfo.createVersionLogInfo(Build.VERSION.RELEASE));
        list.add(LogInfo.createCodingRate("0kbps"));
        list.add(LogInfo.createUploadSpeedLogInfo("0kbps"));
        list.add(LogInfo.createFpsGopLogInfo("0 GOP：0"));
        list.add(LogInfo.createStep1LogInfo(getResources().getString(R.string.livepusher_step1_value)));
        list.add(LogInfo.createStep2LogInfo(getResources().getString(R.string.livepusher_step2_value)));
        list.add(LogInfo.createStep3LogInfo(getResources().getString(R.string.livepusher_step3_value)));
        list.add(LogInfo.createStep4LogInfo(getResources().getString(R.string.livepusher_step4_value)));
        list.add(LogInfo.createStep5LogInfo(getResources().getString(R.string.livepusher_step5_value)));
        setLogInfoList(list);
        mImageNetSpeed.setImageResource(R.drawable.livepusher_ic_net_speed0);
    }

    private void updateItemText(LogInfo logInfo) {
        ItemView item = getItem(logInfo.getId());
        if (item != null) {
            updateItemText(item, String.format("%s：%s", logInfo.getTitle(), logInfo.getValue()));
        }
    }

    private void updateItemText(ItemView itemView, String text) {
        itemView.setText(text);
    }

    private void updateItemStatus(LogInfo logInfo) {
        ItemView item = getItem(logInfo.getId());
        if (item != null) {
            updateItemStatus(item, logInfo.getStatus());
        }
    }

    private void updateItemStatus(ItemView itemView, int status) {
        itemView.setStatus(status);
    }

    private void addItem(LogInfo logInfo) {
        ItemView itemView = new ItemView(mContext);
        itemView.setTag(logInfo.getId());
        itemView.setText(String.format("%s：%s", logInfo.getTitle(), logInfo.getValue()));
        itemView.setStatus(logInfo.getStatus());
        mLayout.addView(itemView);
    }

    private ItemView getItem(Integer tag) {
        int childCount = mLayout.getChildCount();
        for (int i = 0; i < childCount; i++) {
            View childView = mLayout.getChildAt(i);
            if (tag.equals(childView.getTag())) {
                return (ItemView) childView;
            }
        }
        return null;
    }

    private int dip2px(float dpValue) {
        final float scale = getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    private void handleLogStatus(Bundle status) {
        int vra = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_BITRATE);
        int ara = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_BITRATE);

        int speed = status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED);

        int fps = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS);
        int gop = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP);

        int queMax = gop * fps;
        int queCurrent = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE);

        if (mNetSpeed == 0) {
            mNetSpeed = queCurrent;
        } else {
            mNetSpeed = (int) (queCurrent * 1.0f / 4 + mNetSpeed * 3.0f / 4);
        }
        Log.i(TAG, "que:" + queCurrent + ",mQueDenoising:" + mNetSpeed);
        if (mNetSpeed >= 0 && mNetSpeed < 3) {
            mImageNetSpeed.setImageResource(R.drawable.livepusher_ic_net_speed5);
        } else if (mNetSpeed > 3 && mNetSpeed <= queMax * 0.2) {
            mImageNetSpeed.setImageResource(R.drawable.livepusher_ic_net_speed4);
        } else if (mNetSpeed > queMax * 0.2 && mNetSpeed <= queMax * 0.4) {
            mImageNetSpeed.setImageResource(R.drawable.livepusher_ic_net_speed3);
        } else if (mNetSpeed > queMax * 0.4 && mNetSpeed <= queMax * 0.6) {
            mImageNetSpeed.setImageResource(R.drawable.livepusher_ic_net_speed2);
        } else if (mNetSpeed > queMax * 0.6 && mNetSpeed <= queMax * 0.8) {
            mImageNetSpeed.setImageResource(R.drawable.livepusher_ic_net_speed1);
        } else if (mNetSpeed > queMax * 0.8) {
            mImageNetSpeed.setImageResource(R.drawable.livepusher_ic_net_speed0);
        }

        updateLogInfo(LogInfo.createCodingRate((vra + ara) + "kbps"));
        updateLogInfo(LogInfo.createUploadSpeedLogInfo(speed + "kbps"));
        updateLogInfo(LogInfo.createFpsGopLogInfo(fps + "  GOP：" + gop));
    }

    private void handleLogEvent(Bundle event, int eventId) {
        String message = event.getString(TXLiveConstants.EVT_DESCRIPTION);
        if (message != null && !message.isEmpty()) {
            switch (eventId) {
                case CHECK_RTMP_URL_OK:                             // 检查地址合法性 step1
                    updateItemStatus(LogInfo.createStep1LogInfo(LogInfo.STATUS_SUCCESS));
                    mCurrentSuccessStep = LogInfo.ID_STEP_1;
                    break;
                case CHECK_RTMP_URL_FAIL:
                    updateItemStatus(LogInfo.createStep1LogInfo(LogInfo.STATUS_FAIL));
                    mCurrentSuccessStep = LogInfo.ID_STEP_0;
                    break;
                case TXLiveConstants.PUSH_EVT_CONNECT_SUCC:         // 已经连接推流服务器 step2
                    updateItemStatus(LogInfo.createStep2LogInfo(LogInfo.STATUS_SUCCESS));
                    mCurrentSuccessStep = LogInfo.ID_STEP_2;
                    break;
                case TXLiveConstants.PUSH_EVT_OPEN_CAMERA_SUCC:     // 打开摄像头成功 step3
                    updateItemStatus(LogInfo.createStep3LogInfo(LogInfo.STATUS_SUCCESS));
                    // 这里有可能中途切换摄像头，导致step错乱
                    mCurrentSuccessStep = (mCurrentSuccessStep != LogInfo.ID_STEP_5 ? LogInfo.ID_STEP_3 : LogInfo.ID_STEP_5);
                    break;
                case TXLiveConstants.PUSH_EVT_START_VIDEO_ENCODER:  // 编码器启动 step4
                    int mode = event.getInt(TXLiveConstants.EVT_PARAM1);
                    String text = "";
                    if (mode == ENCODER_HARD) {                     // 硬编码器1 软编码器2
                        text = getResources().getString(R.string.livepusher_hardcode);
                    } else {
                        text = getResources().getString(R.string.livepusher_softcode);
                    }
                    updateItemText(LogInfo.createStep4LogInfo(text));
                    updateItemStatus(LogInfo.createStep4LogInfo(LogInfo.STATUS_SUCCESS));
                    // 这里有可能中途切换软硬解，导致step错乱
                    mCurrentSuccessStep = (mCurrentSuccessStep != LogInfo.ID_STEP_5 ? LogInfo.ID_STEP_4 : LogInfo.ID_STEP_5);
                    break;
                case TXLiveConstants.PUSH_EVT_PUSH_BEGIN:           // 已经与服务器握手完毕,开始推流 step5
                    updateItemStatus(LogInfo.createStep5LogInfo(LogInfo.STATUS_SUCCESS));
                    mCurrentSuccessStep = LogInfo.ID_STEP_5;
                    break;
                case TXLiveConstants.PUSH_WARNING_NET_BUSY:         // 丢帧警告
                    break;
            }
        }
    }

    private class ItemView extends LinearLayout {

        private ImageView mImageView;
        private TextView mTextView;

        public ItemView(Context context) {
            super(context);
            init();
        }

        private void init() {
            setOrientation(HORIZONTAL);
            setGravity(Gravity.CENTER_VERTICAL);
            mImageView = new ImageView(mContext);
            mImageView.setVisibility(View.GONE);
            LayoutParams imageParams = new LayoutParams(dip2px(12), dip2px(12));
            imageParams.rightMargin = dip2px(6);

            mTextView = new TextView(mContext);
            mTextView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 12);
            mTextView.setTextColor(getResources().getColor(R.color.livepusher_white));
            addView(mImageView, imageParams);
            addView(mTextView);
        }

        /**
         * @param status
         */
        public void setStatus(int status) {
            switch (status) {
                case LogInfo.STATUS_NONE:
                    mImageView.setVisibility(View.GONE);
                    break;
                case LogInfo.STATUS_FAIL:
                    mImageView.setVisibility(View.VISIBLE);
                    mImageView.setBackgroundResource(R.drawable.livepusher_ic_red);
                    break;
                case LogInfo.STATUS_SUCCESS:
                    mImageView.setVisibility(View.VISIBLE);
                    mImageView.setBackgroundResource(R.drawable.livepusher_ic_green);
                    break;

            }
        }

        public void setText(String text) {
            mTextView.setText(text);
        }
    }

    public static class LogInfo {

        public static final int ID_MODEL = 0;
        public static final int ID_VERSION = 1;
        public static final int ID_CODING_RATE = 2;
        public static final int ID_DOWNLOAD_SPEED = 3;
        public static final int ID_FPS_GOP = 4;
        public static final int ID_STEP_1 = 5;
        public static final int ID_STEP_2 = 6;
        public static final int ID_STEP_3 = 7;
        public static final int ID_STEP_4 = 8;
        public static final int ID_STEP_5 = 9;
        public static final int ID_STEP_0 = 10;

        public static final int STATUS_NONE = 0;
        public static final int STATUS_FAIL = 1;
        public static final int STATUS_SUCCESS = 2;

        private int id;
        private int status;
        private String title;
        private String value;

        public static LogInfo createModelLogInfo(String value) {
            return new LogInfo(ID_MODEL, getResources().getString(R.string.livepusher_model), value);
        }

        public static LogInfo createVersionLogInfo(String value) {
            return new LogInfo(ID_VERSION, getResources().getString(R.string.livepusher_version), value);
        }

        public static LogInfo createCodingRate(String value) {
            return new LogInfo(ID_CODING_RATE, getResources().getString(R.string.livepusher_coding_rate), value);
        }

        public static LogInfo createUploadSpeedLogInfo(String value) {
            return new LogInfo(ID_DOWNLOAD_SPEED, getResources().getString(R.string.livepusher_upload_speed), value);
        }

        public static LogInfo createFpsGopLogInfo(String value) {
            return new LogInfo(ID_FPS_GOP, getResources().getString(R.string.livepusher_fps), value);
        }

        public static LogInfo createStep1LogInfo(String value) {
            return new LogInfo(ID_STEP_1, STATUS_FAIL, getResources().getString(R.string.livepusher_step1), value);
        }

        public static LogInfo createStep1LogInfo(int status) {
            return new LogInfo(ID_STEP_1, status, getResources().getString(R.string.livepusher_step1), "");
        }

        public static LogInfo createStep2LogInfo(String value) {
            return new LogInfo(ID_STEP_2, STATUS_FAIL, getResources().getString(R.string.livepusher_step2), value);
        }

        public static LogInfo createStep2LogInfo(int status) {
            return new LogInfo(ID_STEP_2, status, getResources().getString(R.string.livepusher_step2), "");
        }

        public static LogInfo createStep3LogInfo(String value) {
            return new LogInfo(ID_STEP_3, STATUS_FAIL, getResources().getString(R.string.livepusher_step3), value);
        }

        public static LogInfo createStep3LogInfo(int status) {
            return new LogInfo(ID_STEP_3, status, getResources().getString(R.string.livepusher_step3), "");
        }

        public static LogInfo createStep4LogInfo(String value) {
            return new LogInfo(ID_STEP_4, STATUS_FAIL, getResources().getString(R.string.livepusher_step4), value);
        }

        public static LogInfo createStep4LogInfo(int status) {
            return new LogInfo(ID_STEP_4, status, getResources().getString(R.string.livepusher_step4), "");
        }

        public static LogInfo createStep5LogInfo(String value) {
            return new LogInfo(ID_STEP_5, STATUS_FAIL, getResources().getString(R.string.livepusher_step5), value);
        }

        public static LogInfo createStep5LogInfo(int status) {
            return new LogInfo(ID_STEP_5, status, getResources().getString(R.string.livepusher_step5), "");
        }

        private LogInfo(int id, String title, String value) {
            this(id, STATUS_NONE, title, value);
        }

        private LogInfo(int id, int status, String title, String value) {
            this.id = id;
            this.status = status;
            this.title = title;
            this.value = value;
        }

        public int getId() {
            return id;
        }

        public int getStatus() {
            return status;
        }

        public String getTitle() {
            return title;
        }

        public String getValue() {
            return value;
        }
    }
}
