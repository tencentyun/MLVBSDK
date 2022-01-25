//
//  TUIGiftAnimationManager.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/16.
//

#import "TUIGiftAnimationManager.h"
#import "TUIGiftModel.h"

@interface TUIGiftAnimationManager ()

@property (nonatomic, strong) NSMutableArray *queueArray;
@property (nonatomic, copy) TUIDequeueBlock dequeueBlock;
@property (nonatomic, assign) NSUInteger simulcastCount;
@property (nonatomic, assign) NSInteger playCount;

@end

@implementation TUIGiftAnimationManager

- (instancetype)init {
    if (self = [super init]) {
        self.simulcastCount = 99;
        self.playCount = 0;
        self.queueArray = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithCount:(NSUInteger)simulcastCount {
    if (self = [super init]) {
        self.simulcastCount = simulcastCount;
        self.playCount = 0;
        self.queueArray = [NSMutableArray array];
    }
    return self;
}

- (void)enqueue:(TUIGiftModel *)giftModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playCount < self.simulcastCount) {
            self.playCount++;
            TUIGiftModel *gift = self.queueArray.lastObject;
            if (gift) {
                [self.queueArray removeLastObject];
                [self.queueArray addObject:giftModel];
            }else{
                gift = giftModel;
            }
            if(self.dequeueBlock){
                self.dequeueBlock(gift);
            }
        } else {
            [self.queueArray addObject:giftModel];
        }
    });
}

- (void)dequeue:(TUIDequeueBlock)block {
    self.dequeueBlock = block;
}

- (void)finishPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        TUIGiftModel *gift = self.queueArray.lastObject;
        if (gift) {
            [self.queueArray removeLastObject];
            if (self.dequeueBlock) {
                self.dequeueBlock(gift);
            }
        } else {
            self.playCount--;
            self.playCount = MAX(0, self.playCount);
        }
    });
}

- (void)clearData {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.queueArray = [NSMutableArray array];
        self.playCount = 0;
    });
}

@end
