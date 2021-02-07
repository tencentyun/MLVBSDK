package com.tencent.liteav.demo.liveroom.ui.fragment;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.Editable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.demo.liveroom.R;
import com.tencent.liteav.demo.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.liveroom.ui.LiveRoomActivityInterface;
import com.tencent.liteav.demo.liveroom.roomutil.misc.NameGenerator;
import com.tencent.liteav.demo.liveroom.roomutil.widget.RoomListViewAdapter;
import com.tencent.liteav.demo.liveroom.roomutil.commondef.RoomInfo;
import com.tencent.liteav.demo.liveroom.roomutil.misc.HintDialog;

import java.util.ArrayList;
import java.util.List;

/**
 * A placeholder fragment containing a simple view.
 */
public class LiveRoomListFragment extends Fragment {

    private Activity                  mActivity;
    private LiveRoomActivityInterface mLiveRoomActivityInterface;

    private List<RoomInfo>            mRoomList = new ArrayList<>();
    private RoomListViewAdapter       mRoomListViewAdapter;

    public static LiveRoomListFragment newInstance(String userID) {
        Bundle args = new Bundle();
        args.putString("userID", userID);
        LiveRoomListFragment fragment = new LiveRoomListFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(final LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.mlvb_fragment_live_room_list, container, false);

        view.findViewById(R.id.mlvb_btn_rtmproom_create_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showCreateDialog();
            }
        });

        ((SwipeRefreshLayout) view.findViewById(R.id.mlvb_rtmproom_swiperefresh)).setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                freshRooms();
            }
        });

        if (mLiveRoomActivityInterface != null) {
            mLiveRoomActivityInterface.showGlobalLog(false);
        }

        mRoomListViewAdapter = new RoomListViewAdapter();
        mRoomListViewAdapter.setDataList(mRoomList);
        mRoomListViewAdapter.setRoomType(RoomListViewAdapter.ROOM_TYPE_LIVE);

        ListView roomListView = ((ListView) view.findViewById(R.id.rtmproom_room_listview));
        roomListView.setAdapter(mRoomListViewAdapter);
        roomListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (mRoomList.size() > position) {
                    final RoomInfo roomInfo = mRoomList.get(position);
                    enterRoom(roomInfo, mLiveRoomActivityInterface.getSelfUserID(), false);
                }
            }
        });
        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        this.mLiveRoomActivityInterface = ((LiveRoomActivityInterface) context);
        this.mActivity = ((Activity) context);
    }

    /**
     * 国内低端手机，低版本兼容问题
     *
     * @param activity
     */
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mLiveRoomActivityInterface = ((LiveRoomActivityInterface) activity);
        this.mActivity = activity;
    }

    @Override
    public void onResume() {
        super.onResume();
        mLiveRoomActivityInterface.setTitle(getString(R.string.mlvb_phone_live));
        freshRooms();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    private void showCreateDialog() {
        final View view = LayoutInflater.from(mActivity)
                .inflate(R.layout.mlvb_layout_rtmproom_dialog_create_room, null, false);
        EditText et = (EditText) view.findViewById(R.id.mlvb_et_rtmproom_dialog_create_room);
        et.setHint(getString(R.string.mlvb_input_live_room_name));
        new AlertDialog.Builder(mActivity, R.style.MlvbRtmpRoomDialogTheme)
                .setView(view)
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        EditText et = (EditText) view.findViewById(R.id.mlvb_et_rtmproom_dialog_create_room);
                        Editable text = et.getText();
                        if (text != null) {
                            String name = NameGenerator.replaceNonPrintChar(text.toString(), -1, null, false);
                            if (name != null && name.length() > 0) {
                                if (mLiveRoomActivityInterface.getSelfUserID() != null) {
                                    createRoom(name);
                                }
                                InputMethodManager m = (InputMethodManager) mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
                                m.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
                                dialog.dismiss();
                                return;
                            }
                        }
                        Toast.makeText(mActivity.getApplicationContext(), getString(R.string.mlvb_live_room_name_cannot_null), Toast.LENGTH_SHORT).show();
                    }
                })
                .setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        InputMethodManager m = (InputMethodManager) mActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
                        m.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
                        dialog.dismiss();
                    }
                }).create().show();
    }

    private void createRoom(final String roomName) {
        RoomInfo roomInfo = new RoomInfo();
        roomInfo.roomInfo = roomName;
        enterRoom(roomInfo, mLiveRoomActivityInterface.getSelfUserID(), true);
    }

    private void enterRoom(final RoomInfo roomInfo, final String userID, final boolean requestCreateRoom) {
        mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                LiveRoomChatFragment roomFragment = LiveRoomChatFragment.newInstance(roomInfo, userID, requestCreateRoom);
                FragmentManager fm = mActivity.getFragmentManager();
                FragmentTransaction ts = fm.beginTransaction();
                ts.replace(R.id.mlvb_rtmproom_fragment_container, roomFragment);
                ts.addToBackStack(null);
                ts.commit();
            }
        });
    }

    public void freshRooms() {
        if (mLiveRoomActivityInterface == null) {
            mLiveRoomActivityInterface = ((LiveRoomActivityInterface) getActivity());
            if (mLiveRoomActivityInterface == null) {
                return;
            }
        }

        if (!isVisible()) {
            return;
        }

        final SwipeRefreshLayout refreshView = ((SwipeRefreshLayout) mActivity.findViewById(R.id.mlvb_rtmproom_swiperefresh));
        final TextView enterRoomTips = ((TextView) mActivity.findViewById(R.id.mlvb_rtmproom_tip_textview));
        final TextView nullRoomTips = ((TextView) mActivity.findViewById(R.id.mlvb_tv_rtmproom_tip_null_list));

        mLiveRoomActivityInterface.getLiveRoom().getRoomList(0, 20, new IMLVBLiveRoomListener.GetRoomListCallback() {
            @Override
            public void onSuccess(ArrayList<RoomInfo> data) {
                refreshView.setRefreshing(false);
                nullRoomTips.setVisibility(View.GONE);
                mRoomList.clear();
                if (data != null && data.size() > 0) {
                    nullRoomTips.setVisibility(View.GONE);
                    enterRoomTips.setVisibility(View.VISIBLE);
                    mRoomList.addAll(data);
                } else {
                    enterRoomTips.setVisibility(View.GONE);
                    nullRoomTips.setVisibility(View.VISIBLE);
                }
                mRoomListViewAdapter.notifyDataSetChanged();
            }

            @Override
            public void onError(int errCode, String e) {
                refreshView.setRefreshing(false);
                mRoomList.clear();
                mRoomListViewAdapter.notifyDataSetChanged();
                nullRoomTips.setVisibility(View.VISIBLE);
                new HintDialog.Builder(mActivity)
                        .setTittle(getString(R.string.mlvb_fetch_live_room_list_fail))
                        .setContent(e)
                        .show();
            }
        });
    }
}
