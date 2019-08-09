package com.tencent.qcloud.xiaozhibo.common.widget.beauty;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.preference.PreferenceManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.widget.beauty.download.DownloadManager;
import com.tencent.qcloud.xiaozhibo.common.widget.beauty.download.DownloadTask;



import java.util.List;
/**
 * Module:   MaterialAdapter
 *
 * Function: 特效列表的Adapter
 *
 */
public class MaterialAdapter extends RecyclerView.Adapter<MaterialAdapter.VideoViewHolder>{
    private List<FileMetaData> materials;
    private Activity mContext;

    private OnItemClickListener mListener;
    private int mSelectPosition;

    public void setOnItemClickListener(OnItemClickListener listener){
        this.mListener = listener;
    }

    public interface OnItemClickListener{
        void onItemClick(FileMetaData materialMetaData);
    }

    public MaterialAdapter(Activity context, List<FileMetaData> materials) {
        this.materials = materials;
        this.mContext = context;
        mSelectPosition = -1;
    }

    @Override
    public VideoViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new VideoViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.camera_grid_item_video, parent, false));
    }

    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivity = (ConnectivityManager)context.getSystemService("connectivity");
        if(connectivity == null) {
            return false;
        } else {
            NetworkInfo networkInfo = connectivity.getActiveNetworkInfo();
            return networkInfo != null && networkInfo.isConnectedOrConnecting();
        }
    }

    @Override
    public void onBindViewHolder(final VideoViewHolder holder, final int position) {
        final FileMetaData material = materials.get(position);
        Glide.with(holder.thumb.getContext()).load(material.thumbPath).into(holder.thumb);
        holder.download.setVisibility(TextUtils.isEmpty(material.path) ? View.VISIBLE : View.GONE);
        if(mSelectPosition == position) {
            holder.hover.setImageResource(R.drawable.selected_hover_image);
            holder.hover.setVisibility(View.VISIBLE);
        } else{
            holder.hover.setVisibility(View.GONE);
        }
        // 美颜动效需要从网络下载到本地，这里会有下载的逻辑
        holder.frameLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(TextUtils.isEmpty(material.path)){
                    if (!isNetworkAvailable(mContext)) {
                        Toast.makeText(mContext, "网络不通，请检查网络设置", Toast.LENGTH_SHORT).show();
                        return;
                    }
                    final DownloadTask downloadProgress = DownloadManager.getInstance().get(material.id, material.url);
                    holder.hover.setVisibility(View.VISIBLE);
                    holder.hover.setImageResource(R.drawable.ic_camera_download_bg);
                    holder.progress_round.setVisibility(View.VISIBLE);

                    final DownloadTask.Downloadlistener listener = new DownloadTask.Downloadlistener() {
                        @Override
                        public void onDownloadFail(final String errorMsg) {
                            mContext.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    Toast.makeText(mContext, errorMsg, Toast.LENGTH_SHORT).show();
                                    holder.progress_round.setVisibility(View.GONE);
                                    holder.hover.setVisibility(View.GONE);
                                }
                            });
                        }

                        @Override
                        public void onDownloadProgress(final int progress) {
                            mContext.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    holder.progress_round.setProgress(progress);
                                }
                            });
                        }

                        @Override
                        public void onDownloadSuccess(String filePath) {
                            mContext.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    holder.progress_round.setVisibility(View.GONE);
                                    holder.download.setVisibility(View.GONE);
                                    holder.hover.setVisibility(View.GONE);
                                }
                            });
                            material.path = filePath;
                            PreferenceManager.getDefaultSharedPreferences(mContext).edit().putString(material.id, material.path).apply();
                        }
                    };

                    downloadProgress.start(v.getContext(), listener);

                } else{
                    int lastSelectedPosition = mSelectPosition;
                    mSelectPosition = position;
                    if(lastSelectedPosition >= 0){
                        notifyItemChanged(lastSelectedPosition);
                    }
                    notifyItemChanged(mSelectPosition);
                    if(mListener != null){
                        mListener.onItemClick(material);
                    }
                }
            }
        });
    }

    @Override
    public int getItemCount() {
        return materials.size();
    }

    /**
     * 适用于动效拍
     */
    public static class VideoViewHolder extends RecyclerView.ViewHolder{

        public FrameLayout frameLayout;
        public ImageView thumb;
        public ImageView hover;
        public ImageView download;
        public ImageView audio;
        public RoundProgressBar progress_round;

        public VideoViewHolder(View itemView) {
            super(itemView);
            frameLayout = (FrameLayout) itemView.findViewById(R.id.thumb_container);
            thumb = (ImageView) itemView.findViewById(R.id.thumb);
            hover = (ImageView) itemView.findViewById(R.id.hover);
            download = (ImageView) itemView.findViewById(R.id.download);
            audio = (ImageView) itemView.findViewById(R.id.audio);
            progress_round = (RoundProgressBar) itemView.findViewById(R.id.progress_round);
        }
    }
}
