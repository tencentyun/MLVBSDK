/**
 * Module: TCRoomListViewController
 *
 * Function: 负责展示直播、点播列表，点击后跳转播放界面
 */

#import "TCRoomListViewController.h"
#import "TCRoomListCell.h"
#import "TCRoomListModel.h"
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking.h>
#import "HUDHelper.h"
#import <MJExtension/MJExtension.h>
#import <BlocksKit/BlocksKit.h>
#import "TCRoomListModel.h"
#import "TCAudienceViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "TCPlayBackViewController.h"
#import "ColorMacro.h"
#import <Masonry/Masonry.h>
#import "UIView+Additions.h"
#import "MLVBLiveRoom.h"
#import "AppDelegate.h"
#import "TCAccountMgrModel.h"

@interface TCRoomListViewController () <UICollectionViewDelegate,UICollectionViewDataSource,MLVBLiveRoomDelegate>

@property (strong) TCRoomListMgr *liveListMgr;
/// 直播列表
@property(nonatomic, strong) NSMutableArray *liveArray;
/// 点播放列表
@property(nonatomic, strong) NSMutableArray *vodArray;
@property(nonatomic, strong) UICollectionView *collectionView;
@property BOOL isLoading;

@end

@implementation TCRoomListViewController
{
    BOOL             _hasEnterplayVC;
    UIButton         *_liveVideoBtn;
    UIButton         *_clickVieoBtn;
    UIImageView      *_tabIndicator;

    UIView           *_emptyDataView;
    VideoType        _videoType;
}

- (instancetype)init {
    if (self = [super init]) {
        _liveArray = [NSMutableArray array];
        _liveListMgr = [TCRoomListMgr sharedMgr];
        self.navigationItem.title = @"最新直播";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 顶部 Tab 指示条
    UIGraphicsBeginImageContext(CGSizeMake(35, 4));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        (__bridge CFArrayRef)@[(__bridge id)[UIColor colorWithRed:51/255.0 green:139/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:90/255.0 green:213/255.0 blue:224/255.0 alpha:1.0].CGColor],
                                                        (CGFloat[]){0.0, 1.0});
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(),
                                gradient,
                                CGPointZero,
                                CGPointMake(35, 4),
                                kCGGradientDrawsBeforeStartLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _tabIndicator = [[UIImageView alloc] initWithImage:image];
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    // 顶部 Tab 容器
    UIView *tabContainer = [[UIView alloc] init];
    tabContainer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    tabContainer.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    tabContainer.layer.shadowOffset = CGSizeMake(0,0);
    tabContainer.layer.shadowOpacity = 1;
    tabContainer.layer.shadowRadius = 2;
    
    [self.view addSubview:tabContainer];
    [tabContainer setUserInteractionEnabled:YES];
    [tabContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(@(50+statusBarHeight));
    }];
    
     // 顶部 Tab 按钮
    UIButton *(^createButton)(NSString *) = ^(NSString *title) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x888888), NSFontAttributeName:[UIFont systemFontOfSize:17]}]
                          forState:UIControlStateNormal];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x333333), NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}]
                          forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onTapTab:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        return button;
    };
    
    _liveVideoBtn = createButton(@"秀场直播");
    _liveVideoBtn.tag = 0;
    [tabContainer addSubview:_liveVideoBtn];
    [_liveVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tabContainer.mas_left).offset(15);
        make.centerY.equalTo(tabContainer).offset(statusBarHeight/2);
    }];
    
    _clickVieoBtn = createButton(@"精彩回放");
    _clickVieoBtn.tag = 1;
    [tabContainer addSubview:_clickVieoBtn];
    [_clickVieoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_liveVideoBtn.mas_right).offset(30);
        make.centerY.equalTo(tabContainer).offset(statusBarHeight/2);
    }];
    
    _clickVieoBtn.selected = YES;
    
    [tabContainer addSubview:_tabIndicator];
    _tabIndicator.bottom = 0;
    [_tabIndicator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->_clickVieoBtn);
        make.bottom.equalTo(self->_clickVieoBtn.mas_bottom).offset(3);
    }];

    
    // 内容列表
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[TCRoomListCell class] forCellWithReuseIdentifier:@"TCLiveListCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(tabContainer.mas_bottom);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
#define IS_IPHONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO)
#define kTabBarHeight ((IS_IPHONEX) ? 83 : 49)
    
    // 数据为空时的 View
    _emptyDataView = [[UIView alloc] initWithFrame:CGRectZero];
    _emptyDataView.backgroundColor = UIColor.clearColor;
    _emptyDataView.hidden = YES;
    _emptyDataView.userInteractionEnabled = NO;
    [self.view addSubview:_emptyDataView];
    [_emptyDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"暂无内容哦";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = UIColorFromRGB(0x333333);
    label.alpha = 0.3;
    [_emptyDataView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self->_emptyDataView);
    }];
    
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
    label2.text = @"由腾讯云提供技术服务";
    label2.font = [UIFont systemFontOfSize:12];
    label2.textColor = UIColorFromRGB(0x333333);
    label2.alpha = 0.3;
    [_emptyDataView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->_emptyDataView);
        make.bottom.equalTo(self->_emptyDataView).offset(-12-kTabBarHeight);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.image = [UIImage imageNamed:@"logo"];
    [_emptyDataView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->_emptyDataView);
        make.bottom.equalTo(label2.mas_top).offset(-6);
    }];
    
    _clickVieoBtn.selected = YES;
    [self setup:VideoType_VOD_SevenDay];
    
    [self.view bringSubviewToFront:tabContainer];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TCRoomListMgr sharedMgr].liveRoom.delegate = self;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataAvailable:) name:kTCRoomListNewDataAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listDataUpdated:) name:kTCRoomListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(svrError:) name:kTCRoomListSvrError object:nil];
    
    if(_liveVideoBtn.selected){
        [self setup:VideoType_LIVE_Online];
    }
    
    _playVC = nil;
    _hasEnterplayVC = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCRoomListNewDataAvailable object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kTCLiveListUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTCRoomListSvrError object:nil];
}

- (void)setup:(VideoType)type {
    _videoType = type;
    
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    __weak __typeof(self) wself = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(wself) self = wself;
        if (!self) return;
        self.isLoading = YES;
        self.liveArray = [NSMutableArray array];
        [self.liveListMgr queryVideoList:self->_videoType getType:GetType_Up];
    }];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong __typeof(wself) self = wself;
        if (!self) return;
        self.isLoading = YES;
        [self.liveListMgr queryVideoList:self->_videoType getType:GetType_Down];
    }];
    
    // 先加载缓存的数据，然后再开始网络请求，以防用户打开是看到空数据
    [self.liveListMgr loadLivesFromArchive:type];
    [self doFetchList];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView.mj_header beginRefreshing];
    });
    
    [(MJRefreshHeader *)self.collectionView.mj_header endRefreshingWithCompletionBlock:^{
        self.isLoading = NO;
    }];
    [(MJRefreshHeader *)self.collectionView.mj_footer endRefreshingWithCompletionBlock:^{
        self.isLoading = NO;
    }];
}

/// 点击顶部 Tab 事件响应
- (void)onTapTab:(UIButton *)button {
    if (!button.selected) {
        // Refresh
        [self.liveArray removeAllObjects];
    }
    UIButton *btn = button;
    switch (btn.tag) {
        case 0:
        {
            //if (!self.isLoading) {
            _liveVideoBtn.selected = YES;
            _clickVieoBtn.selected = NO;
            [self setup:VideoType_LIVE_Online];
            //}
        }
            break;
        case 1:
        {
            //if (!self.isLoading) {
            _liveVideoBtn.selected = NO;
            _clickVieoBtn.selected = YES;
            
            [self setup:VideoType_VOD_SevenDay];
            //}
        }
            break;
        default:
            break;
    }
    [_tabIndicator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(button);
        make.bottom.equalTo(button.mas_bottom).offset(3);
    }];
}

#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.liveArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TCRoomListCell *cell = (TCRoomListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TCLiveListCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TCRoomListCell alloc] initWithFrame:CGRectZero ];
        cell.clipsToBounds = YES;
    }
    
    NSInteger index = indexPath.item;

    if (self.liveArray.count > index) {
        TCRoomInfo *live = self.liveArray[index];
        cell.isLive = _videoType == VideoType_LIVE_Online;
//        cell.type = (VideoType_UGC_SevenDay == _videoType ? 1 : 0);
        cell.model = live;
    }
    cell.clipsToBounds = YES;

    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = (collectionView.width - 5 - 30) / 2;
    return CGSizeMake(size, size);
}

//设置每个item的UIEdgeInsets
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(10, 15, 0, 15);
//}

//设置每个item水平间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 5;
//}

//设置每个item垂直间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 5;
//}

#pragma mark - UICollectionView delegate

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 此处一定要用cell的数据，live中的对象可能已经清空了
    TCRoomListCell *cell = (TCRoomListCell *)[collectionView cellForItemAtIndexPath:indexPath];
    TCRoomInfo *info = cell.model;
    
    __weak __typeof(self) wself = self;
    // MARK: 打开播放界面
    if (_playVC == nil) {
        void(^onPlayError)(void) = ^{
            __strong __typeof(wself) self = wself; if (self == nil) return;
            //加房间失败后，刷新列表，不需要刷新动画
            self.liveArray = [NSMutableArray array];
            self.isLoading = YES;
            [self->_liveListMgr queryVideoList:VideoType_LIVE_Online getType:GetType_Up];
        };
        if (info.type == TCRoomListItemType_Live) {
            _playVC = [[TCAudienceViewController alloc] initWithPlayInfo:info videoIsReady:^{
                __strong __typeof(wself) self = wself; if (self == nil) return;
                if (!self->_hasEnterplayVC) {
                    [[AppDelegate sharedInstance] pushViewController:self->_playVC animated:YES];
                    self->_hasEnterplayVC = YES;
                }
            }];
            [(TCAudienceViewController*)_playVC setOnPlayError:onPlayError];
        } else {
            if (info.hls_play_url.length == 0) {
                return;
            }
            _playVC = [[TCPlayBackViewController alloc] initWithPlayInfo:info videoIsReady:^{
                __strong __typeof(wself) self = wself; if (self == nil) return;
                if (!self->_hasEnterplayVC) {
                    [[AppDelegate sharedInstance] pushViewController:self->_playVC animated:YES];
                    self->_hasEnterplayVC = YES;
                }
            }];
            [(TCPlayBackViewController*)_playVC setOnPlayError:onPlayError];
        }
    }
    
    [self performSelector:@selector(enterPlayVC:) withObject:_playVC afterDelay:0.5];
}

- (void)enterPlayVC:(NSObject *)obj {
    if (!_hasEnterplayVC) {
        [[AppDelegate sharedInstance] pushViewController:_playVC animated:YES];
        _hasEnterplayVC = YES;
        
        if (self.delegate) {
            [self.delegate onEnterPlayViewController];
        }
    }
}

#pragma mark - Net fetch
/**
 * 拉取直播列表。TCLiveListMgr在启动是，会将所有数据下载下来。在未全部下载完前，通过loadLives借口，
 * 能取到部分数据。通过finish接口，判断是否已取到最后的数据
 *
 */
- (void)doFetchList {
    if ([NSThread isMainThread]) {
        [self _doFetchList];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _doFetchList];
        });
    }
}

- (void)_doFetchList {
    NSRange range = NSMakeRange(_liveArray.count, 20);
    BOOL finish;
    NSArray *result = [_liveListMgr readRoomList:range finish:&finish];
    if (result.count) {
        result = [self mergeResult:result];
        [self.liveArray addObjectsFromArray:result];
    } else {
        if (!finish) {
            return; // 等待新数据的通知过来
        }
        //[[HUDHelper sharedInstance] tipMessage:@"没有啦"];
    }
    [self.collectionView reloadData];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    
    
    if (self.liveArray.count == 0) {
        self.collectionView.mj_footer.hidden = YES;
        _emptyDataView.hidden = NO;
    }else{
        _emptyDataView.hidden = YES;
    }
}

/**
 *  将取到的数据于已存在的数据进行合并。
 *
 *  @param result 新拉取到的数据
 *
 *  @return 新数据去除已存在记录后，剩余的数据
 */
- (NSArray *)mergeResult:(NSArray *)result {
    
    // 每个直播的播放地址不同，通过其进行去重处理
    NSArray *existArray = [self.liveArray bk_map:^id(TCRoomInfo *obj) {
        return obj.playurl;
    }];
    NSArray *newArray = [result bk_reject:^BOOL(TCRoomInfo *obj) {
        return [existArray containsObject:obj.playurl];
    }];
    
    return newArray;
}

/**
 *  TCLiveListMgr有新数据过来
 *
 *  @param noti
 */
- (void)newDataAvailable:(NSNotification *)noti {
    [self doFetchList];
}

/**
 *  TCLiveListMgr数据有更新
 *
 *  @param noti
 */
- (void)listDataUpdated:(NSNotification *)noti {
    NSDictionary* dict = noti.userInfo;
    NSString* userId = nil;
    NSString* fileId = nil;
    int type = 0;
    if (dict[@"userid"])
        userId = dict[@"userid"];
    if (dict[@"type"])
        type = [dict[@"type"] intValue];
    if (dict[@"fileid"])
        fileId = dict[@"fileid"];
    
    TCRoomInfo* info = [_liveListMgr readRoom:type userId:userId fileId:fileId];
    if (nil == info)
        return;
    
    for (TCRoomInfo* item in self.liveArray)
    {
        if ([info.userid isEqualToString:item.userid])
        {
            item.viewercount = info.viewercount;
            item.likecount = info.likecount;
            break;
        }
    }
    
    [self.collectionView reloadData];
}


/**
 *  TCLiveListMgr内部出错
 *
 *  @param noti
 */
- (void)svrError:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *e = noti.object;
        NSDictionary *userInfo = e.userInfo;
        if ([userInfo isKindOfClass:[NSDictionary class]]) {
            int errCode = [userInfo[@"errCode"] intValue];
            //直播 errCode：-1   点播 errCode ： 498
            if (errCode == 498 || errCode == -1) {
                [HUDHelper alert:@"token 验证失败，请重新登录"];
            }else{
                [HUDHelper alert:[NSString stringWithFormat:@"errCode : %@ des: %@",userInfo[@"errCode"] , userInfo[@"description"]]];
            }
        }else{
            [HUDHelper alert:@"拉取列表失败"];
        }

        // 如果还在加载，停止加载动画
        if (self.isLoading) {
            [self.collectionView.mj_header endRefreshing];
            [self.collectionView.mj_footer endRefreshing];
            self.isLoading = NO;
        }
    });
}

#pragma mark - MLVBLiveRoomDelegate
- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo {
    if (errCode == ROOM_ERR_IM_FORCE_OFFLINE) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TCAccountMgrModel sharedInstance] logout:^{
                [[AppDelegate sharedInstance] enterLoginUI];
            }];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"帐号在其他端登录" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
            [alertView show];
        });
    }
}
@end
