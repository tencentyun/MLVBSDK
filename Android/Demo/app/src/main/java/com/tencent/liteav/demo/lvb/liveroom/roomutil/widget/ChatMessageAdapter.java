package com.tencent.liteav.demo.lvb.liveroom.roomutil.widget;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.tencent.liteav.demo.R;

import java.util.List;

/**
 * Created by jac on 2017/11/16.
 * Copyright © 2013-2017 Tencent Cloud. All Rights Reserved.
 */

public class ChatMessageAdapter extends BaseAdapter {

    private List<RoomListViewAdapter.TextChatMsg> textChatMsgList;
    private Context mContext;

    public ChatMessageAdapter(Context mContext, List<RoomListViewAdapter.TextChatMsg> textChatMsgList) {
        this.textChatMsgList = textChatMsgList;
        this.mContext = mContext;
    }

    @Override
    public int getCount() {
        return textChatMsgList.size();
    }

    @Override
    public Object getItem(int position) {
        return textChatMsgList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View view, ViewGroup parent) {
        RoomListViewAdapter.TextChatMsg textChatMsg = textChatMsgList.get(position);

        if (textChatMsg.aligment() == RoomListViewAdapter.TextChatMsg.Aligment.LEFT){
            if (view == null || view.getTag() != RoomListViewAdapter.TextChatMsg.Aligment.LEFT)
                view = LayoutInflater.from(mContext).inflate(R.layout.rtcroom_chatview_item_left, null);
            view.setTag(RoomListViewAdapter.TextChatMsg.Aligment.LEFT);
        }else{
            if (view == null || view.getTag() != RoomListViewAdapter.TextChatMsg.Aligment.RIGHT)
                view = LayoutInflater.from(mContext).inflate(R.layout.rtcroom_chatview_item_right, null);
            view.setTag(RoomListViewAdapter.TextChatMsg.Aligment.RIGHT);
        }

        ((TextView) view.findViewById(R.id.rtcroom_chat_msg_user_and_time_tv))
                .setText(String.format("%s %s", textChatMsg.getName(), textChatMsg.getTime()));
        ((TextView) view.findViewById(R.id.rtc_room_chat_msg_msg_tv))
                .setText(textChatMsg.getMsg());

        return view;
    }
}
