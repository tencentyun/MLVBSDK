#ifndef __TCLinkMicPlayItem_h__
#define __TCLinkMicPlayItem_h__

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MLVBLiveRoom.h"

@interface TCSmallPlayer: NSObject

-(void)emptyPlayInfo;
-(void)startLoading;
-(void)stopLoading;
-(void)startPlay:(NSString*)playUrl;
-(void)stopPlay;
-(void)showLogView:(BOOL)hidden;
-(void)freshStatusMsg:(NSDictionary*)param;
-(void)appendEventMsg:(int)event andParam:(NSDictionary*)param;

@property (nonatomic, assign) BOOL                      pending;
@property (nonatomic, strong) NSString*                 userID;
@property (nonatomic, strong) MLVBAnchorInfo*           anchor;
@property (nonatomic, strong) NSString*                 playUrl;
@property (nonatomic, strong) UIView*                   videoView;
@property (nonatomic, strong) UIView*                   logView;
@property (nonatomic, strong) UIButton*                 btnKickout;
@end



#endif
