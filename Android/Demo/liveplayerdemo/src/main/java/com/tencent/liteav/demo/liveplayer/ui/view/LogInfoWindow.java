package com.tencent.liteav.demo.liveplayer.ui.view;

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
import android.widget.ProgressBar;
import android.widget.TextView;

import com.tencent.liteav.demo.liveplayer.R;
import com.tencent.rtmp.TXLiveConstants;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.liteav.demo.beauty.utils.ResourceUtils.getResources;

/**
 * 自定义 Log 信息展示弹窗
 *
 * - 设备版本、型号
 * - 下载速度
 * - 分辨率
 * - FPS
 * - 信号强度
 */
public class LogInfoWindow extends PopupWindow {

    private static final String TAG = "LogInfoWindow";

    private static final int DECODER_HARD = 1;                      //硬解码器

    public static final int CHECK_RTMP_URL_OK   = 999;     //视频播放检查：地址合法
    public static final int CHECK_RTMP_URL_FAIL = 998;     //视频播放检查：地址不合法

    private Context         mContext;
    private LinearLayout    mLayout;
    private ImageView       mImageNetSpeed;
    private View            mBalanceView;
    private ProgressBar     mProgressVideoCache;
    private ProgressBar     mProgressAudioCache;
    private BalanceSeekBar  mSeekBarBalance;
    private TextView        mTextMaxAutoAdjustCacheTime;

    private float mMaxAutoAdjustCacheTime = 0f;
    private int   mNetSpeed;

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
        mLayout.addView(mBalanceView, mLayout.indexOfChild(getItem(LogInfo.ID_STEP_1)));
    }

    public void updateLogInfo(LogInfo logInfo) {
        ItemView item = getItem(logInfo.getId());
        if (item == null) {
            addItem(logInfo);
        } else {
            updateItemText(item, String.format("%s：%s", logInfo.getTitle(), logInfo.getValue()));
        }
    }

    public void setCacheTime(float maxAutoAdjustCacheTime) {
        mMaxAutoAdjustCacheTime = maxAutoAdjustCacheTime;
        Log.i(TAG, "setCacheTime:" + maxAutoAdjustCacheTime);

        if (mTextMaxAutoAdjustCacheTime != null) {
            mTextMaxAutoAdjustCacheTime.setText(String.format("%ss", mMaxAutoAdjustCacheTime));
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

    public void clear() {
        initData();
    }

    private void initView() {
        View rootView = LayoutInflater.from(mContext).inflate(R.layout.liveplayer_view_loginfo, null);
        setContentView(rootView);
        mLayout = (LinearLayout) rootView.findViewById(R.id.liveplayer_ll_layout);
        mImageNetSpeed = (ImageView) rootView.findViewById(R.id.liveplayer_iv_net_speed);

        mBalanceView = LayoutInflater.from(mContext).inflate(R.layout.liveplayer_view_loginfo_balance, null);
        mProgressVideoCache = (ProgressBar) mBalanceView.findViewById(R.id.liveplayer_pb_video_cache);
        mProgressAudioCache = (ProgressBar) mBalanceView.findViewById(R.id.liveplayer_pb_audio_cache);
        mSeekBarBalance = (BalanceSeekBar) mBalanceView.findViewById(R.id.liveplayer_seekbar_balance);
        mSeekBarBalance.setEnabled(false);
        mTextMaxAutoAdjustCacheTime = (TextView) mBalanceView.findViewById(R.id.liveplayer_tv_max_auto_adjust_cache_time);
    }

    private void initData() {
        List<LogInfo> list = new ArrayList<>();
        list.add(LogInfo.createModelLogInfo(Build.MODEL));
        list.add(LogInfo.createVersionLogInfo(Build.VERSION.RELEASE));
        list.add(LogInfo.createDownloadSpeedLogInfo("0kbps"));
        list.add(LogInfo.createResolutionLogInfo("0*0"));
        list.add(LogInfo.createFpsGopLogInfo("0"));
        setLogInfoList(list);

        mSeekBarBalance.setText("0");
        mSeekBarBalance.setProgress(0);
        mProgressVideoCache.setProgress(0);
        mProgressAudioCache.setProgress(0);
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
        int speed = status.getInt(TXLiveConstants.NET_STATUS_NET_SPEED);
        int width = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_WIDTH);
        int height = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_HEIGHT);

        int fps = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_FPS);
        int gop = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_GOP);

        if (mNetSpeed == 0) {
            mNetSpeed = speed;
        } else {
            mNetSpeed = (int) (speed * 1.0f / 4 + mNetSpeed * 3.0f / 4);
        }

        if (mNetSpeed > 1500) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed5);
        } else if (mNetSpeed > 1000) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed4);
        } else if (mNetSpeed > 500) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed3);
        } else if (mNetSpeed > 250 && speed <= 500) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed2);
        } else if (mNetSpeed > 0 && mNetSpeed <= 250) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed1);
        } else if (mNetSpeed == 0) {
            mImageNetSpeed.setImageResource(R.drawable.liveplayer_ic_net_speed0);
        }

        if (mMaxAutoAdjustCacheTime != 0) {
            String balance = String.format("%.1f", status.getFloat(TXLiveConstants.NET_STATUS_AUDIO_CACHE_THRESHOLD));
            int progress = (int) (Float.parseFloat(balance) * 100 / mMaxAutoAdjustCacheTime);

            mSeekBarBalance.setText(balance);
            mSeekBarBalance.setProgress(progress);
            Log.i(TAG, "balance:" + balance + ",progress:" + progress);

            float video_cache_ts = status.getInt(TXLiveConstants.NET_STATUS_VIDEO_CACHE) * 1.0f / 1000;//s
            float audio_cache_ts = status.getInt(TXLiveConstants.NET_STATUS_AUDIO_CACHE) * 1.0f / 1000;//s

            int vp = (int) (video_cache_ts * 100 / mMaxAutoAdjustCacheTime);
            int ap = (int) (audio_cache_ts * 100 / mMaxAutoAdjustCacheTime);
            mProgressVideoCache.setProgress(vp);
            mProgressAudioCache.setProgress(ap);
            Log.i(TAG, "max:" + mMaxAutoAdjustCacheTime + " video_cache_ts:" + video_cache_ts + " audio_cache_ts:" + audio_cache_ts + ",vp:" + vp + ",ap:" + ap);
        }

        updateLogInfo(LogInfo.createDownloadSpeedLogInfo(speed + "kbps"));
        updateLogInfo(LogInfo.createResolutionLogInfo(width + "*" + height));
        updateLogInfo(LogInfo.createFpsGopLogInfo(fps + ""));
    }

    private void handleLogEvent(Bundle event, int eventId) {
        String message = event.getString(TXLiveConstants.EVT_DESCRIPTION);
        if (message != null && !message.isEmpty()) {
            switch (eventId) {
                case CHECK_RTMP_URL_OK:
                    updateItemStatus(LogInfo.createStep1LogInfo(LogInfo.STATUS_SUCCESS));
                    break;
                case CHECK_RTMP_URL_FAIL:
                    updateItemStatus(LogInfo.createStep1LogInfo(LogInfo.STATUS_FAIL));
                    break;
                case TXLiveConstants.PLAY_EVT_START_VIDEO_DECODER:
                    int mode = event.getInt("EVT_PARAM1");
                    if (mode == DECODER_HARD) {
                        updateItemText(LogInfo.createStep2LogInfo(getResources().getString(R.string.liveplayer_text_hw_decode_start)));
                    } else {
                        updateItemText(LogInfo.createStep2LogInfo(getResources().getString(R.string.liveplayer_text_sw_decode_start)));
                    }
                    updateItemStatus(LogInfo.createStep2LogInfo(LogInfo.STATUS_SUCCESS));
                    break;
                case TXLiveConstants.PLAY_EVT_CONNECT_SUCC:
                    updateItemStatus(LogInfo.createStep3LogInfo(LogInfo.STATUS_SUCCESS));
                    break;
                case TXLiveConstants.PLAY_EVT_PLAY_BEGIN:
                    updateItemStatus(LogInfo.createStep4LogInfo(LogInfo.STATUS_SUCCESS));
                    break;
                case TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME:
                    updateItemStatus(LogInfo.createStep5LogInfo(LogInfo.STATUS_SUCCESS));
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
            LinearLayout.LayoutParams imageParams = new LayoutParams(dip2px(12), dip2px(12));
            imageParams.rightMargin = dip2px(6);

            mTextView = new TextView(mContext);
            mTextView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 12);
            mTextView.setTextColor(getResources().getColor(R.color.liveplayer_white));
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
                    mImageView.setBackgroundResource(R.drawable.liveplayer_log_info_step_fail);
                    break;
                case LogInfo.STATUS_SUCCESS:
                    mImageView.setVisibility(View.VISIBLE);
                    mImageView.setBackgroundResource(R.drawable.liveplayer_log_info_step_success);
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
        public static final int ID_DOWNLOAD_SPEED = 2;
        public static final int ID_RESOLUTION = 3;
        public static final int ID_FPS_GOP = 4;
        public static final int ID_STEP_1 = 5;
        public static final int ID_STEP_2 = 6;
        public static final int ID_STEP_3 = 7;
        public static final int ID_STEP_4 = 8;
        public static final int ID_STEP_5 = 9;

        public static final int STATUS_NONE = 0;
        public static final int STATUS_FAIL = 1;
        public static final int STATUS_SUCCESS = 2;

        private int id;
        private int status;
        private String title;
        private String value;

        public static LogInfo createModelLogInfo(String value) {
            return new LogInfo(ID_MODEL, getResources().getString(R.string.liveplayer_model), value);
        }

        public static LogInfo createVersionLogInfo(String value) {
            return new LogInfo(ID_VERSION, getResources().getString(R.string.liveplayer_version), value);
        }

        public static LogInfo createDownloadSpeedLogInfo(String value) {
            return new LogInfo(ID_DOWNLOAD_SPEED, getResources().getString(R.string.liveplayer_text_download_speed), value);
        }

        public static LogInfo createResolutionLogInfo(String value) {
            return new LogInfo(ID_RESOLUTION, getResources().getString(R.string.liveplayer_text_resolution_detail), value);
        }

        public static LogInfo createFpsGopLogInfo(String value) {
            return new LogInfo(ID_FPS_GOP, getResources().getString(R.string.liveplayer_text_fps), value);
        }

        public static LogInfo createStep1LogInfo(String value) {
            return new LogInfo(ID_STEP_1, STATUS_FAIL, getResources().getString(R.string.liveplayer_start_step1), value);
        }

        public static LogInfo createStep1LogInfo(int status) {
            return new LogInfo(ID_STEP_1, status, getResources().getString(R.string.liveplayer_start_step1), "");
        }

        public static LogInfo createStep2LogInfo(String value) {
            return new LogInfo(ID_STEP_2, STATUS_FAIL, getResources().getString(R.string.liveplayer_start_step2), value);
        }

        public static LogInfo createStep2LogInfo(int status) {
            return new LogInfo(ID_STEP_2, status, getResources().getString(R.string.liveplayer_start_step2), "");
        }

        public static LogInfo createStep3LogInfo(String value) {
            return new LogInfo(ID_STEP_3, STATUS_FAIL, getResources().getString(R.string.liveplayer_start_step3), value);
        }

        public static LogInfo createStep3LogInfo(int status) {
            return new LogInfo(ID_STEP_3, status, getResources().getString(R.string.liveplayer_start_step3), "");
        }

        public static LogInfo createStep4LogInfo(String value) {
            return new LogInfo(ID_STEP_4, STATUS_FAIL, getResources().getString(R.string.liveplayer_start_step4), value);
        }

        public static LogInfo createStep4LogInfo(int status) {
            return new LogInfo(ID_STEP_4, status, getResources().getString(R.string.liveplayer_start_step4), "");
        }

        public static LogInfo createStep5LogInfo(String value) {
            return new LogInfo(ID_STEP_5, STATUS_FAIL, getResources().getString(R.string.liveplayer_start_step5), value);
        }

        public static LogInfo createStep5LogInfo(int status) {
            return new LogInfo(ID_STEP_5, status, getResources().getString(R.string.liveplayer_start_step5), "");
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
