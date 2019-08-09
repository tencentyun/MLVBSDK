/**
 * Module:   PushLogView
 *
 * Function: 用来显示App层的关键日志
 */

#import <UIKit/UIKit.h>

/**
 * （1）检查地址合法性
 * （2）连接到云服务器
 * （3）摄像头打开成功
 * （4）编码器正常启动
 * （5）开始进入推流中
 */
@interface PushLogView : UIView

// 设置推流地址是否合法
- (void)setPushUrlValid:(BOOL)valid;

// TXLivePushListener 推流回调，通过下面这两个函数透传进来
- (void)setPushEvent:(int)evtID withParam:(NSDictionary *)param;
- (void)setNetStatus:(NSDictionary *)param;

// 清除所有状态
- (void)clear;

@end
