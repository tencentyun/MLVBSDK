package com.tencent.liteav.demo;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.common.widget.expandableadapter.BaseExpandableRecyclerViewAdapter;
import com.tencent.liteav.demo.lvb.camerapush.CameraPusherActivity;
import com.tencent.liteav.demo.lvb.liveroom.ui.LiveRoomActivity;
import com.tencent.liteav.demo.lvb.liveplayer.LivePlayerActivity;
import com.tencent.rtmp.TXLiveBase;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends Activity {

    private static final String TAG = MainActivity.class.getName();
    private TextView mMainTitle, mTvVersion;
    private RecyclerView mRvList;
    private MainExpandableAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            Log.d(TAG, "brought to front");
            finish();
            return;
        }

        setContentView(R.layout.activity_main);

        mTvVersion = (TextView) findViewById(R.id.main_tv_version);
        mTvVersion.setText("视频云工具包 v" + TXLiveBase.getSDKVersionStr());

        mMainTitle = (TextView) findViewById(R.id.main_title);
        mMainTitle.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                File logFile = getLastModifiedLogFile();
                if (logFile != null) {
                    Intent intent = new Intent(Intent.ACTION_SEND);
                    intent.setType("application/octet-stream");
                    //intent.setPackage("com.tencent.mobileqq");
                    intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(logFile));
                    startActivity(Intent.createChooser(intent, "分享日志"));
                } else {
                    Toast.makeText(MainActivity.this.getApplicationContext(), "日志文件不存在！", Toast.LENGTH_SHORT);
                }
                return false;
            }
        });


        mRvList = (RecyclerView) findViewById(R.id.main_recycler_view);
        List<GroupBean> groupBeans = initGroupData();
        mRvList.setLayoutManager(new LinearLayoutManager(this));
        mAdapter = new MainExpandableAdapter(groupBeans);
        mAdapter.setListener(new BaseExpandableRecyclerViewAdapter.ExpandableRecyclerViewOnClickListener<GroupBean, ChildBean>() {
            @Override
            public boolean onGroupLongClicked(GroupBean groupItem) {
                return false;
            }

            @Override
            public boolean onInterceptGroupExpandEvent(GroupBean groupItem, boolean isExpand) {
                return false;
            }

            @Override
            public void onGroupClicked(GroupBean groupItem) {
                mAdapter.setSelectedChildBean(groupItem);
            }

            @Override
            public void onChildClicked(GroupBean groupItem, ChildBean childItem) {
                if (childItem.mIconId == R.drawable.xiaoshipin) {
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.setData(Uri.parse("http://dldir1.qq.com/hudongzhibo/xiaozhibo/XiaoShiPin.apk"));
                    startActivity(intent);
                    return;
                } else if (childItem.mIconId ==R.drawable.xiaozhibo) {
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.setData(Uri.parse("http://dldir1.qq.com/hudongzhibo/xiaozhibo/xiaozhibo.apk"));
                    startActivity(intent);
                    return;
                }
                Intent intent = new Intent(MainActivity.this, childItem.getTargetClass());
                intent.putExtra("TITLE", childItem.mName);
                if (childItem.mIconId == R.drawable.play) {
                    intent.putExtra("PLAY_TYPE", LivePlayerActivity.ACTIVITY_TYPE_VOD_PLAY);
                } else if (childItem.mIconId == R.drawable.live) {
                    intent.putExtra("PLAY_TYPE", LivePlayerActivity.ACTIVITY_TYPE_LIVE_PLAY);
                } else if (childItem.mIconId == R.drawable.mic) {
                    intent.putExtra("PLAY_TYPE", LivePlayerActivity.ACTIVITY_TYPE_LINK_MIC);
                } else if (childItem.mIconId == R.drawable.cut) {
                } else if (childItem.mIconId == R.drawable.composite) {
                } else if (childItem.mIconId == R.drawable.conf_icon) {
                } else if (childItem.mIconId == R.drawable.realtime_play) {
                    intent.putExtra("PLAY_TYPE", LivePlayerActivity.ACTIVITY_TYPE_REALTIME_PLAY);
                } else if (childItem.mIconId == R.drawable.update) {
                } else if (childItem.mIconId == R.drawable.short_video_picture) {
                }
                MainActivity.this.startActivity(intent);
            }
        });
        mRvList.setAdapter(mAdapter);
    }

    private List<GroupBean> initGroupData() {
        List<GroupBean> groupList = new ArrayList<>();


        // 直播
        List<ChildBean> pusherChildList = new ArrayList<>();
        pusherChildList.add(new ChildBean("MLVBLiveRoom", R.drawable.room_live, LiveRoomActivity.class));
        pusherChildList.add(new ChildBean("摄像头推流", R.drawable.push, CameraPusherActivity.class));
        pusherChildList.add(new ChildBean("直播拉流", R.drawable.live, LivePlayerActivity.class));
        if (pusherChildList.size() != 0) {
            // 这个是网页链接，配合build.sh避免在如ugc_smart版中出现
            pusherChildList.add(new ChildBean("小直播", R.drawable.xiaozhibo, null));
            GroupBean pusherGroupBean = new GroupBean("移动直播", R.drawable.room_live, pusherChildList);
            groupList.add(pusherGroupBean);
        }

        // 初始化播放器
        List<ChildBean> playerChildList = new ArrayList<>();
//        playerChildList.add(new ChildBean("超级播放器", R.drawable.play, SuperPlayerActivity.class));
//        playerChildList.add(new ChildBean("低延时播放", R.drawable.realtime_play, LivePlayerActivity.class));// 不用了
        if (playerChildList.size() != 0) {
            GroupBean playerGroupBean = new GroupBean("播放器", R.drawable.composite, playerChildList);
            groupList.add(playerGroupBean);
        }

        // 短视频
        List<ChildBean> shortVideoChildList = new ArrayList<>();

        if (shortVideoChildList.size() != 0) {
            // 这个是网页链接，配合build.sh避免在其他版本中出现
            shortVideoChildList.add(new ChildBean("小视频", R.drawable.xiaoshipin, null));
            GroupBean shortVideoGroupBean = new GroupBean("短视频", R.drawable.video, shortVideoChildList);
            groupList.add(shortVideoGroupBean);
        }

        // 视频通话
        List<ChildBean> videoConnectChildList = new ArrayList<>();
        if (videoConnectChildList.size() != 0) {
            GroupBean videoConnectGroupBean = new GroupBean("视频通话", R.drawable.room_multi, videoConnectChildList);
            groupList.add(videoConnectGroupBean);
        }


        // 调试工具
        List<ChildBean> debugChildList = new ArrayList<>();
//        debugChildList.add(new ChildBean("RTMP 推流 (Surface)", R.drawable.push, LivePublisherSurfaceActivity.class));
//        debugChildList.add(new ChildBean("直播播放器 (Surface)", R.drawable.live, LivePlayerSurfaceActivity.class));
//        debugChildList.add(new ChildBean("点播播放器", R.drawable.play, VodPlayerActivity.class));
//        debugChildList.add(new ChildBean("在线答题室", R.drawable.room_qa, AnswerRoomActivity.class));
//        debugChildList.add(new ChildBean("答题播放器", R.drawable.room_qa, AnswerPlayerActivity.class));
        if (debugChildList.size() != 0) {
            GroupBean debugGroupBean = new GroupBean("调试工具", R.drawable.debug, debugChildList);
            groupList.add(debugGroupBean);
        }

        return groupList;
    }


    private static class MainExpandableAdapter extends BaseExpandableRecyclerViewAdapter<GroupBean, ChildBean, MainExpandableAdapter.GroupVH, MainExpandableAdapter.ChildVH> {
        private List<GroupBean> mListGroupBean;
        private GroupBean mGroupBean;

        public void setSelectedChildBean(GroupBean groupBean) {
            boolean isExpand = isExpand(groupBean);
            if (mGroupBean != null) {
                GroupVH lastVH = getGroupViewHolder(mGroupBean);
                if (!isExpand)
                    mGroupBean = groupBean;
                else
                    mGroupBean = null;
                notifyItemChanged(lastVH.getAdapterPosition());
            } else {
                if (!isExpand)
                    mGroupBean = groupBean;
                else
                    mGroupBean = null;
            }
            if (mGroupBean != null) {
                GroupVH currentVH = getGroupViewHolder(mGroupBean);
                notifyItemChanged(currentVH.getAdapterPosition());
            }
        }

        public MainExpandableAdapter(List<GroupBean> list) {
            mListGroupBean = list;
        }

        @Override
        public int getGroupCount() {
            return mListGroupBean.size();
        }

        @Override
        public GroupBean getGroupItem(int groupIndex) {
            return mListGroupBean.get(groupIndex);
        }

        @Override
        public GroupVH onCreateGroupViewHolder(ViewGroup parent, int groupViewType) {
            return new GroupVH(LayoutInflater.from(parent.getContext()).inflate(R.layout.module_entry_item, parent, false));
        }

        @Override
        public void onBindGroupViewHolder(GroupVH holder, GroupBean groupBean, boolean isExpand) {
            holder.textView.setText(groupBean.mName);
            holder.ivLogo.setImageResource(groupBean.mIconId);
            if (mGroupBean == groupBean) {
                holder.itemView.setBackgroundResource(R.color.main_item_selected_color);
            } else {
                holder.itemView.setBackgroundResource(R.color.main_item_unselected_color);
            }
        }

        @Override
        public ChildVH onCreateChildViewHolder(ViewGroup parent, int childViewType) {
            return new ChildVH(LayoutInflater.from(parent.getContext()).inflate(R.layout.module_entry_child_item, parent, false));
        }

        @Override
        public void onBindChildViewHolder(ChildVH holder, GroupBean groupBean, ChildBean childBean) {
            holder.textView.setText(childBean.getName());

            if (groupBean.mChildList.indexOf(childBean) == groupBean.mChildList.size() - 1) {//说明是最后一个
                holder.divideView.setVisibility(View.GONE);
            } else {
                holder.divideView.setVisibility(View.VISIBLE);
            }

        }

        public class GroupVH extends BaseExpandableRecyclerViewAdapter.BaseGroupViewHolder {
            ImageView ivLogo;
            TextView textView;

            GroupVH(View itemView) {
                super(itemView);
                textView = (TextView) itemView.findViewById(R.id.name_tv);
                ivLogo = (ImageView) itemView.findViewById(R.id.icon_iv);
            }

            @Override
            protected void onExpandStatusChanged(RecyclerView.Adapter relatedAdapter, boolean isExpanding) {
            }

        }

        public class ChildVH extends RecyclerView.ViewHolder {
            TextView textView;
            View divideView;

            ChildVH(View itemView) {
                super(itemView);
                textView = (TextView) itemView.findViewById(R.id.name_tv);
                divideView = itemView.findViewById(R.id.item_view_divide);
            }

        }
    }

    private class GroupBean implements BaseExpandableRecyclerViewAdapter.BaseGroupBean<ChildBean> {
        private String mName;
        private List<ChildBean> mChildList;
        private int mIconId;

        public GroupBean(String name, int iconId, List<ChildBean> list) {
            mName = name;
            mChildList = list;
            mIconId = iconId;
        }

        @Override
        public int getChildCount() {
            return mChildList.size();
        }

        @Override
        public ChildBean getChildAt(int index) {
            return mChildList.size() <= index ? null : mChildList.get(index);
        }

        @Override
        public boolean isExpandable() {
            return getChildCount() > 0;
        }

        public String getName() {
            return mName;
        }

        public List<ChildBean> getChildList() {
            return mChildList;
        }

        public int getIconId() {
            return mIconId;
        }
    }

    private class ChildBean {
        public String mName;
        public int mIconId;
        public Class mTargetClass;


        public ChildBean(String name, int iconId, Class targetActivityClass) {
            this.mName = name;
            this.mIconId = iconId;
            this.mTargetClass = targetActivityClass;
        }

        public String getName() {
            return mName;
        }


        public int getIconId() {
            return mIconId;
        }


        public Class getTargetClass() {
            return mTargetClass;
        }
    }


    private File getLastModifiedLogFile() {
        File retFile = null;

        File directory = new File("/sdcard/log/tencent/liteav");
        if (directory != null && directory.exists() && directory.isDirectory()) {
            long lastModify = 0;
            File files[] = directory.listFiles();
            if (files != null && files.length > 0) {
                for (File file : files) {
                    if (file.getName().endsWith("xlog")) {
                        if (file.lastModified() > lastModify) {
                            retFile = file;
                            lastModify = file.lastModified();
                        }
                    }
                }
            }
        }

        return retFile;
    }
}
