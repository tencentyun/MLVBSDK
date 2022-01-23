//
//  TCBeautyPanelActionProxy.h
//  TCBeautyPanel
//
//  Created by cui on 2019/12/23.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCBeautyPanelActionPerformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCBeautyPanelActionProxy : NSProxy <TCBeautyPanelActionPerformer>
@property (weak, nonatomic) id beautyManager;
+ (instancetype)proxyWithBeautyManager:(id)beautyManager;
@end

NS_ASSUME_NONNULL_END
