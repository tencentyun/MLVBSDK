package com.tencent.qcloud.xiaozhibo.main.videolist.ui;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.qcloud.xiaozhibo.R;
import com.tencent.qcloud.xiaozhibo.common.utils.TCConstants;
import com.tencent.qcloud.xiaozhibo.main.videolist.utils.TCVideoInfo;
import com.tencent.qcloud.xiaozhibo.main.videolist.utils.TCVideoListMgr;
import com.tencent.qcloud.xiaozhibo.audience.TCAudienceActivity;
import com.tencent.qcloud.xiaozhibo.playback.TCPlaybackActivity;

import java.util.ArrayList;
import java.util.List;


/**
 *  Module:   TCVideoListFragment
 *
 *  Function: 直播列表页面，展示当前直播、回放
 *
 */
public class TCVideoListFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener, View.OnClickListener{
    public static final int START_LIVE_PLAY = 100;
    public static final int LIST_TYPE_LIVE = 0;
    public static final int LIST_TYPE_VOD  = 1;
//    public static final int LIST_TYPE_UGC  = 2;

    private static final String TAG = "TCVideoListFragment";
    private GridView mVideoListView;
    private TCVideoListAdapter mVideoListViewAdapter;
    private SwipeRefreshLayout mSwipeRefreshLayout;

    //避免连击
    private long mLastClickTime = 0;

    private List<ListTabItem> mListTabs;

    private int mDataType = LIST_TYPE_VOD;
    private boolean mLiveListFetched = false;
    private boolean mUGCListFetched = false;
    private View mEmptyView;

    private static class ListTabItem {
        public ListTabItem(int type, TextView textView, ImageView imageView, View.OnClickListener listener) {
            this.type = type;
            this.textView = textView;
            this.imageView = imageView;
            this.textView.setOnClickListener(listener);
        }
        public int type;
        public TextView textView;
        public ImageView imageView;
    }

    public TCVideoListFragment() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_videolist, container, false);

        mSwipeRefreshLayout = (SwipeRefreshLayout) view.findViewById(R.id.swipe_refresh_layout_list);
        mSwipeRefreshLayout.setColorSchemeResources(android.R.color.holo_blue_bright,
                android.R.color.holo_green_light, android.R.color.holo_orange_light, android.R.color.holo_red_light);
        mSwipeRefreshLayout.setOnRefreshListener(this);

        mVideoListViewAdapter = new TCVideoListAdapter(getActivity(), new ArrayList<TCVideoInfo>());

        mVideoListView = (GridView) view.findViewById(R.id.live_list);
        mVideoListView.setAdapter(mVideoListViewAdapter);
        mVideoListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                try {
                    if (i >= mVideoListViewAdapter.getCount()) {
                        return;
                    }
                    if (0 == mLastClickTime || System.currentTimeMillis() - mLastClickTime > 1000) {
                        TCVideoInfo item = mVideoListViewAdapter.getItem(i);
                        if (item == null) {
                            Log.e(TAG, "live list item is null at position:" + i);
                            return;
                        }

                        startLivePlay(item);
                    }
                    mLastClickTime = System.currentTimeMillis();
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        mEmptyView = view.findViewById(R.id.tv_listview_empty);
        mEmptyView.setVisibility(mVideoListViewAdapter.getCount() == 0? View.VISIBLE: View.GONE);

        mListTabs = new ArrayList<>();
        mListTabs.add(LIST_TYPE_LIVE, new ListTabItem(LIST_TYPE_LIVE, (TextView) view.findViewById(R.id.text_live), (ImageView) view.findViewById(R.id.image_live), this));
        mListTabs.add(LIST_TYPE_VOD, new ListTabItem(LIST_TYPE_VOD, (TextView) view.findViewById(R.id.text_vod), (ImageView) view.findViewById(R.id.image_vod), this));
//        mListTabs.add(LIST_TYPE_UGC, new ListTabItem(LIST_TYPE_UGC, (TextView) view.findViewById(R.id.text_ugc), (ImageView) view.findViewById(R.id.image_ugc), this));

        refreshListView();

        return view;
    }

    @Override
    public void onRefresh() {
        refreshListView();
    }

    /**
     * 刷新直播列表
     */
    private void refreshListView() {
        if (reloadLiveList()) {
            mSwipeRefreshLayout.post(new Runnable() {
                @Override
                public void run() {
                    mSwipeRefreshLayout.setRefreshing(true);
                }
            });
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data){
        super.onActivityResult(requestCode, resultCode,data);

        try {
            if (START_LIVE_PLAY == requestCode) {
                if (0 != resultCode) {
                    //观看直播返回错误信息后，刷新列表，但是不显示动画
                    reloadLiveList();
                } else {
                    if (data == null) {
                        return;
                    }
                    //更新列表项的观看人数和点赞数
                    String userId = data.getStringExtra(TCConstants.PUSHER_ID);
                    for (int i = 0; i < mVideoListViewAdapter.getCount(); i++) {
                        TCVideoInfo info = mVideoListViewAdapter.getItem(i);
                        if (info != null && info.userId.equalsIgnoreCase(userId)) {
                            info.viewerCount = (int) data.getLongExtra(TCConstants.MEMBER_COUNT, info.viewerCount);
                            info.likeCount = (int) data.getLongExtra(TCConstants.HEART_COUNT, info.likeCount);
                            mVideoListViewAdapter.notifyDataSetChanged();
                            break;
                        }
                    }
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 重新加载直播列表
     */
    private boolean reloadLiveList() {
        switch (mDataType) {
            case LIST_TYPE_LIVE:
                TCVideoListMgr.getInstance().fetchLiveList(getActivity(), new TCVideoListMgr.Listener() {
                    @Override
                    public void onVideoList(int retCode, ArrayList<TCVideoInfo> result, boolean refresh) {
                        onRefreshVideoList(retCode, result, refresh, mVideoListViewAdapter);
                    }
                });
                return true;
            case LIST_TYPE_VOD:
                TCVideoListMgr.getInstance().fetchVodList(new TCVideoListMgr.Listener() {
                    @Override
                    public void onVideoList(int retCode, ArrayList<TCVideoInfo> result, boolean refresh) {
                        onRefreshVideoList(retCode, result, refresh, mVideoListViewAdapter);
                    }
                });
                return true;
            default:
                return false;
        }
    }

    private void onRefreshVideoList(final int retCode, final ArrayList<TCVideoInfo> result, final boolean refresh, final ArrayAdapter adapter) {
        if (getActivity() != null) {
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (retCode == 0 ) {
                        adapter.clear();
                        if (result != null) {
                            adapter.addAll((ArrayList<TCVideoInfo>)result.clone());
                        }
                        if (refresh) {
                            adapter.notifyDataSetChanged();
                        }
                    } else {
                        Toast.makeText(getActivity(), "刷新列表失败", Toast.LENGTH_LONG).show();
                    }
                    mEmptyView.setVisibility(adapter.getCount() == 0? View.VISIBLE: View.GONE);
                    mSwipeRefreshLayout.setRefreshing(false);
                }
            });
        }
    }

    /**
     * 开始播放视频
     * @param item 视频数据
     */
    private void startLivePlay(final TCVideoInfo item) {
        Intent intent;
        if (item.livePlay) {
            intent = new Intent(getActivity(), TCAudienceActivity.class);
            intent.putExtra(TCConstants.PLAY_URL, item.playUrl);
        } else {
            intent = new Intent(getActivity(), TCPlaybackActivity.class);
            intent.putExtra(TCConstants.PLAY_URL, TextUtils.isEmpty(item.hlsPlayUrl) ? item.playUrl : item.hlsPlayUrl);
        }

        intent.putExtra(TCConstants.PUSHER_ID, item.userId !=null?item.userId :"");
        intent.putExtra(TCConstants.PUSHER_NAME, TextUtils.isEmpty(item.nickname) ? item.userId : item.nickname);
        intent.putExtra(TCConstants.PUSHER_AVATAR, item.avatar);
        intent.putExtra(TCConstants.HEART_COUNT, "" + item.likeCount);
        intent.putExtra(TCConstants.MEMBER_COUNT, "" + item.viewerCount);
        intent.putExtra(TCConstants.GROUP_ID, item.groupId);
        intent.putExtra(TCConstants.PLAY_TYPE, item.livePlay);
        intent.putExtra(TCConstants.FILE_ID, item.fileId !=null?item.fileId :"");
        intent.putExtra(TCConstants.COVER_PIC, item.frontCover);
        intent.putExtra(TCConstants.TIMESTAMP, item.createTime);
        intent.putExtra(TCConstants.ROOM_TITLE, item.title);
        startActivityForResult(intent,START_LIVE_PLAY);
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.text_live:
                mDataType = LIST_TYPE_LIVE;
                break;
            case R.id.text_vod:
                mDataType = LIST_TYPE_VOD;
                break;
        }
        setStatus(mDataType);
        refreshListView();
    }

    private void setStatus(int dataType) {
        for (ListTabItem item : mListTabs) {
            if (item.type == dataType) {
                item.textView.setTextColor(Color.rgb(0, 0, 0));
                item.imageView.setVisibility(View.VISIBLE);
            } else {
                item.textView.setTextColor(Color.rgb(119, 119, 119));
                item.imageView.setVisibility(View.INVISIBLE);
            }
        }

        mVideoListView.setNumColumns(1);
        mVideoListView.setHorizontalSpacing(0);
        mVideoListView.setVerticalSpacing(0);
        mVideoListViewAdapter.clear();
        mVideoListViewAdapter.notifyDataSetChanged();
        mVideoListView.setAdapter(mVideoListViewAdapter);
        mEmptyView.setVisibility(mVideoListViewAdapter.getCount() == 0? View.VISIBLE: View.GONE);
    }
}