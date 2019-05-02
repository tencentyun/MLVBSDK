//
//  TCPlayDecorateView.h
//  TCLVBIMDemo
//
//  Created by zhangxiang on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMsgModel.h"
#import "TCMsgListTableView.h"

@protocol TCPlayDecorateDelegate <NSObject>
-(void)closeVC:(BOOL)popViewController;
-(void)clickScreen:(CGPoint)position;
-(void)clickPlayVod;
-(void)onSeek:(UISlider *)slider;
-(void)onSeekBegin:(UISlider *)slider;
-(void)onDrag:(UISlider *)slider;
-(void)clickLog:(UIButton *)button;
-(void)clickShare:(UIButton *)button;
-(void)clickRecord:(UIButton *)button;
-(void)onRecvGroupDeleteMsg;
@end


/**
 *  播放模块逻辑view，里面展示了消息列表，弹幕动画，观众列表等UI，其中与SDK的逻辑交互需要交给主控制器处理
 */
@interface TCPlayDecorateView : UIView<UITextFieldDelegate, UIAlertViewDelegate/*, TIMGroupAssistantListener imTODO:*/, TCAudienceListDelegate>

@property(nonatomic,weak) id<TCPlayDecorateDelegate>delegate;
@property(nonatomic,retain)  UILabel            *playDuration;
@property(nonatomic,retain)  UISlider           *playProgress;
@property(nonatomic,retain)  UILabel            *playLabel;
@property(nonatomic,retain)  UIButton           *playBtn;
@property(nonatomic,retain)  UIButton           *closeBtn;
@property(nonatomic,retain)  UIButton           *btnChat;
@property(nonatomic,retain)  UIButton           *btnLog;
@property(nonatomic,retain)  UIButton           *btnShare;
//@property(nonatomic,retain)  UIButton           *btnRecord;
@property(nonatomic,retain)  UIView             *cover;
@property(nonatomic,retain)  UITextView         *statusView;
@property(nonatomic,retain)  UITextView         *logViewEvt;

-(instancetype)initWithFrame:(CGRect)frame liveInfo:(TCLiveInfo *)liveInfo withLinkMic:(BOOL)linkmic;

-(void)setViewerCount:(int)viewerCount likeCount:(int)likeCount;

-(BOOL)isAlreadyInAudienceList:(TCMsgModel *)model;

-(void)initAudienceList:(NSArray *)audienceList;

-(void)keyboardFrameDidChange:(NSNotification*)notice;

- (void)handleIMMessage:(IMUserAble*)info msgText:(NSString*)msgText;

@end
