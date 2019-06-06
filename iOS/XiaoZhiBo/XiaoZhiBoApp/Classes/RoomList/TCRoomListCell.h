/**
 * Module: TCRoomListCell
 *
 * Function: 直播/点播列表的Cell类，主要展示封面、标题、昵称、在线数、点赞数、定位位置
 */

#import <UIKit/UIKit.h>
#import "TCRoomListModel.h"

@class TCRoomInfo;

@interface TCRoomListCell : UICollectionViewCell
{
    TCRoomInfo *_model;
}

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic , retain) TCRoomInfo *model;
@property (nonatomic , assign) BOOL isLive;

@end
