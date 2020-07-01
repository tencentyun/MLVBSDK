//
//  AddressBarController.m
//  TXLiteAVDemo
//
//  Created by shengcui on 2018/6/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AddressBarController.h"
#import "QRCode.h"

static NSString * const CellIdentifier = @"Cell";

@interface AddressBarController() <UITextFieldDelegate, UICollectionViewDataSource>
{
    AddressBarButtonOption _buttonOption;
}
@end

@implementation AddressBarController

@synthesize view = _view;

- (instancetype)initWithButtonOption:(AddressBarButtonOption)option
{
    self = [super init];
    if (self) {
        _buttonOption = option;
    }
    return self;
}

- (UIView *)view {
    if (!_view) {
        _view = [[AddressBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44) buttons:_buttonOption];
        _view.textField.delegate = self;
        [_view.scanQRButton addTarget:self action:@selector(onScan:) forControlEvents:UIControlEventTouchUpInside];
        [_view.createAddressButton addTarget:self action:@selector(onCreateAddress:) forControlEvents:UIControlEventTouchUpInside];
        [_view.showQRButton addTarget:self action:@selector(onShowQR:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _view;
}

- (void)setText:(NSString *)text
{
    [self.view.textField setText:text];
}

- (NSString *)text
{
    return self.view.textField.text;
}

- (IBAction)onCreateAddress:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addressBarControllerTapCreateURL:)]) {
        [self.delegate addressBarControllerTapCreateURL:self];
    }
}

- (IBAction)onScan:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addressBarControllerTapScanQR:)]) {
        [self.delegate addressBarControllerTapScanQR:self];
    }
}

- (void)setQrStrings:(NSArray<NSString *> *)qrStrings {
    _qrStrings = qrStrings;
    self.view.showQRCode = qrStrings.count > 0;
}

- (IBAction)onShowQR:(id)sender {
    if (self.qrPresentView) {
        CGRect frame = UIEdgeInsetsInsetRect(self.qrPresentView.bounds, UIEdgeInsetsMake(90, 15, 80, 15));
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat h_size = (CGRectGetWidth(frame) - 20) /2;
        CGFloat v_size = (CGRectGetHeight(frame) - 20) / 2;
        CGFloat size = MIN(h_size, v_size);
        layout.itemSize = CGSizeMake(size, size);
        layout.minimumInteritemSpacing = 20;
        layout.minimumLineSpacing = 20;
        
        CGFloat height = ceil(self.qrStrings.count / 2) * (size + 20) - 20;
        frame.size.height = MIN(height, frame.size.height);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
        collectionView.dataSource = self;
        
        UIButton *wrapper = [[UIButton alloc] initWithFrame:self.qrPresentView.bounds];
        [wrapper addTarget:self action:@selector(onDismissQRCode:) forControlEvents:UIControlEventTouchUpInside];
        wrapper.backgroundColor = [UIColor clearColor];
        collectionView.center = CGPointMake(CGRectGetMidX(wrapper.bounds), CGRectGetMidY(wrapper.bounds));
        collectionView.autoresizingMask =  ~(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [wrapper addSubview:collectionView];
        [self.qrPresentView addSubview:wrapper];
        wrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        wrapper.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            wrapper.alpha = 1;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(addressBarControllerTapShowQR:)]) {
                [self.delegate addressBarControllerTapScanQR:self];
            }
        }];      
    } else {
        if ([self.delegate respondsToSelector:@selector(addressBarControllerTapShowQR:)]) {
            [self.delegate addressBarControllerTapScanQR:self];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.qrStrings.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:1234];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.tag = 1234;
        [cell.contentView addSubview:imageView];
    }
    UILabel *label = [cell.contentView viewWithTag:4321];
    if (!label) {
        CGRect frame = cell.contentView.bounds;
        frame.size.height = 20;
        frame.size.width /= 2;
        label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor blueColor];
        label.tag = 4321;
        [cell.contentView addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    NSString *content = self.qrStrings[indexPath.row];
    NSString *title = nil;
    UIImage *image = nil;
    NSRange r = [content rangeOfString:@"," options:NSLiteralSearch];
    if (r.location == NSNotFound) {
        image = [QRCode qrCodeWithString:content size:imageView.bounds.size];
    } else {
        title = [content substringToIndex:r.location];
        NSString *qrString = [content substringFromIndex:NSMaxRange(r)];
        image = [QRCode qrCodeWithString:qrString size:imageView.bounds.size];
    }
    if (title.length > 0) {
        label.text = title;
        label.hidden = NO;
    } else {
        label.hidden = YES;
    }
    imageView.image = image;
    return cell;
}

- (void)onDismissQRCode:(UIButton *)sender {
    UIView *container = sender.superview;
    [sender removeFromSuperview];
    CATransition *anim = [CATransition animation];
    anim.type = kCATransitionFade;
    [container.layer addAnimation:anim forKey:@"dismiss"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(addressBarControllerTextFieldShouldReturn:)]) {
        return [self.delegate addressBarControllerTextFieldShouldReturn:self];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
