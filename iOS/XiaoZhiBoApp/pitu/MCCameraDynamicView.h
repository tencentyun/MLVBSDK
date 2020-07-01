//
//  MCCameraDynamicView.h
//  PituMotionDemo
//
//  Created by ricocheng on 6/15/16.
//  Copyright © 2016 Pitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCCameraDynamicDelegate <NSObject>

- (void)motionTmplSelected:(NSString *)materialID;

@end

@interface MCCameraDynamicView : UIView

@property (nonatomic, weak) id<MCCameraDynamicDelegate> delegate;
@property (nonatomic, copy) NSString *selectedMaterialID;

@end
