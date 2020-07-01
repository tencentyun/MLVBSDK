//
//  UMSocialCollectionCell.h
//  UMSocialSDK
//
//  Created by umeng on 16/9/21.
//  Copyright © 2016年 UMeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMSocialCollectionCell : UIView

@property (strong, nonatomic) UIImageView *logoImageView;


@property (strong, nonatomic) UILabel *platformNameLabel;

- (void)reloadDataWithImage:(UIImage *)image platformName:(NSString *)platformName;

@end
