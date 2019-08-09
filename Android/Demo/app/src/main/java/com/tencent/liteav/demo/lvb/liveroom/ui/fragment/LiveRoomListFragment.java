package com.tencent.liteav.demo.lvb.liveroom.ui.fragment;

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

import com.tencent.liteav.demo.R;
import com.tencent.liteav.demo.lvb.liveroom.IMLVBLiveRoomListener;
import com.tencent.liteav.demo.lvb.liveroom.ui.LiveRoomActivityInterface;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.misc.NameGenerator;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.widget.RoomListViewAdapter;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.commondef.RoomInfo;
import com.tencent.liteav.demo.lvb.liveroom.roomutil.misc.HintDialog;

import java.util.ArrayList;
import java.util.List;

/**
 * A placeholder fragment containing a simple view.
 */
public class LiveRoomListFragment extends Fragment {

    private static final String TAG = LiveRoomListFragment.class.getSimpleName();

    private Activity                    activity;
    private LiveRoomActivityInterface   activityInterface;

    private List<RoomInfo>              roomList    = new ArrayList<>();
    private RoomListViewAdapter         roomListViewAdapter;

    boolean                             enableLog   = false;

    public static LiveRoomListFragment newInstance(String userID) {
        Bundle args = new Bundle();
        args.putString("userID", userID);
        LiveRoomListFragment fragment = new LiveRoomListFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(final LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_live_room_list, container, false);

//        view.findViewById(R.id.rtmproom_log).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                enableLog = !enableLog;
//                activityInterface.showGlobalLog(enableLog);
//            }
//        });
//
//        view.findViewById(R.id.rtmproom_help).setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                Intent intent = new Intent(Intent.ACTION_VIEW);
//                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/454/12521"));
//                startActivity(intent);
//            }
//        });

        view.findViewById(R.id.rtmproom_create_room_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showCreateDialog();
            }
        });

        ((SwipeRefreshLayout) view.findViewById(R.id.rtmproom_swiperefresh)).setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                freshRooms();
            }
        });

        if (activityInterface != null){
            activityInterface.showGlobalLog(false);
        }

        roomListViewAdapter = new RoomListViewAdapter();
        roomListViewAdapter.setDataList(roomList);
        roomListViewAdapter.setRoomType(RoomListViewAdapter.ROOM_TYPE_LIVE);

        ListView roomListView = ((ListView) view.findViewById(R.id.rtmproom_room_listview));
        roomListView.setAdapter(roomListViewAdapter);
        roomListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (roomList.size() > position) {
                    final RoomInfo roomInfo = roomList.get(position);
                    enterRoom(roomInfo, activityInterface.getSelfUserID(), false);
                }
            }
        });

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        this.activityInterface = ((LiveRoomActivityInterface) context);
        this.activity = ((Activity) context);
    }

    /**
     * 国内低端手机，低版本兼容问题
     * @param activity
     */
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.activityInterface = ((LiveRoomActivityInterface) activity);
        this.activity = activity;
    }

    @Override
    public void onResume() {
        super.onResume();
        activityInterface.setTitle("手机直播");
        freshRooms();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    private void showCreateDialog(){
        final View view = LayoutInflater.from(activity)
                .inflate(R.layout.layout_rtmproom_dialog_create_room, null, false);
        EditText et = (EditText) view.findViewById(R.id.rtmproom_dialog_create_room_edittext);
        et.setHint("请输入直播间名称");
        new AlertDialog.Builder(activity, R.style.RtmpRoomDialogTheme)
                .setView(view)
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        EditText et = (EditText) view.findViewById(R.id.rtmproom_dialog_create_room_edittext);
                        Editable text = et.getText();
                        if (text != null) {
                            String name = NameGenerator.replaceNonPrintChar(text.toString(), -1, null, false);
                            if (name != null && name.length() > 0) {
                                if (activityInterface.getSelfUserID() != null) {
                                    createRoom(name);
                                }
                                InputMethodManager m = (InputMethodManager) activity.getSystemService(Context.INPUT_METHOD_SERVICE);
                                m.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
                                dialog.dismiss();
                                return;
                            }
                        }
                        Toast.makeText(activity.getApplicationContext(), "直播间名称不能为空", Toast.LENGTH_SHORT).show();
                    }
                })
                .setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        InputMethodManager m =(InputMethodManager) activity.getSystemService(Context.INPUT_METHOD_SERVICE);
                        m.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
                        dialog.dismiss();
                    }
                }).create().show();
    }

    private void createRoom(final String roomName) {
        RoomInfo roomInfo = new RoomInfo();
        roomInfo.roomInfo = roomName;
        enterRoom(roomInfo, activityInterface.getSelfUserID(), true);
    }

    private void enterRoom(final RoomInfo roomInfo, final String userID, final boolean requestCreateRoom) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                LiveRoomChatFragment roomFragment = LiveRoomChatFragment.newInstance(roomInfo, userID, requestCreateRoom);
                FragmentManager fm = activity.getFragmentManager();
                FragmentTransaction ts = fm.beginTransaction();
                ts.replace(R.id.rtmproom_fragment_container, roomFragment);
                ts.addToBackStack(null);
                ts.commit();
            }
        });
    }

    public void freshRooms() {
        if (activityInterface == null ) {
            activityInterface = ((LiveRoomActivityInterface) getActivity());
            if (activityInterface == null) {
                return;
            }
        }

        if (!isVisible()) {
            return;
        }

        final SwipeRefreshLayout refreshView    = ((SwipeRefreshLayout) activity.findViewById(R.id.rtmproom_swiperefresh));
        final TextView enterRoomTips            = ((TextView) activity.findViewById(R.id.rtmproom_tip_textview));
        final TextView nullRoomTips             = ((TextView) activity.findViewById(R.id.rtmproom_tip_null_list_textview));

        activityInterface.getLiveRoom().getRoomList(0, 20, new IMLVBLiveRoomListener.GetRoomListCallback() {
            @Override
            public void onSuccess(ArrayList<RoomInfo> data) {
                refreshView.setRefreshing(false);
                nullRoomTips.setVisibility(View.GONE);
                roomList.clear();
                if (data != null && data.size() > 0){
                    nullRoomTips.setVisibility(View.GONE);
                    enterRoomTips.setVisibility(View.VISIBLE);
                    roomList.addAll(data);
                }
                else {
                    enterRoomTips.setVisibility(View.GONE);
                    nullRoomTips.setVisibility(View.VISIBLE);
                }
                roomListViewAdapter.notifyDataSetChanged();
            }

            @Override
            public void onError(int errCode, String e) {
                refreshView.setRefreshing(false);
                roomList.clear();
                roomListViewAdapter.notifyDataSetChanged();
                nullRoomTips.setVisibility(View.VISIBLE);
                new HintDialog.Builder(activity)
                        .setTittle("获取直播间列表失败")
                        .setContent(e)
                        .show();
            }
        });
    }
}
