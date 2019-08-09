//
//  LiveRoomListViewController.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveRoomListViewController.h"
#import "MLVBLiveRoom.h"
#import "UIView+Additions.h"
#import "LiveRoomPlayerViewController.h"
#import "AFNetworking.h"
#import "ColorMacro.h"
#import "LiveRoomTableViewCell.h"
#import "LiveRoomNewViewController.h"
#import "AppDelegate.h"
#import "../Debug/GenerateTestUserSig.h"

@interface LiveRoomListViewController () <UITableViewDelegate, UITableViewDataSource, MLVBLiveRoomDelegate> {
    NSArray<MLVBRoomInfo *>  	 *_roomInfoArray;
    
    UILabel                  *_tipLabel;
    UITableView              *_roomlistView;
    UIButton                 *_createBtn;
    UIButton                 *_helpBtn;
    
    UIButton                 *_btnLog;
    UITextView               *_logView;
    BOOL                     _log_switch;
    UIView                   *_coverView;
    
    NSArray<NSString*>       *_userNameArray;
    NSString                 *_userName;
    NSString                 *_userID;
}

@property (nonatomic, strong) MLVBLiveRoom *liveRoom;
@property (nonatomic, assign) BOOL     initSucc;

@end

@implementation LiveRoomListViewController

- (void)dealloc
{
    [_liveRoom logout];
    [MLVBLiveRoom destorySharedInstance];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _liveRoom = [MLVBLiveRoom sharedInstance];
    [_liveRoom setCameraMuteImage:[UIImage imageNamed:@"pause_publish.jpg"]];
    _liveRoom.delegate = self;
    
    _roomInfoArray = [[NSArray alloc] init];
    _userNameArray = [[NSArray alloc] initWithObjects:@"李元芳", @"刘备", @"梦奇", @"王昭君", @"周瑜", @"鲁班", @"后裔", @"安其拉", @"亚瑟", @"曹操",
                      @"百里守约", @"东皇太一", @"花木兰", @"诸葛亮", @"黄忠", @"不知火舞", @"钟馗", @"李白", @"娜可露露", @"张飞", nil];
    
    _userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if (_userName == nil || _userName.length == 0) {
        _userName = _userNameArray[arc4random() % _userNameArray.count];
        [[NSUserDefaults standardUserDefaults] setObject:_userName forKey:@"userName"];
    }
    _initSucc = NO;
    
    [self initUI];
    [self login];
}
#pragma mark - Login
- (void)login {
    __block NSString * userID = [[NSUserDefaults standardUserDefaults] objectForKey: @"userID"];
    if (userID == nil || userID.length == 0) {
        char data[32];
        for ( int x = 0; x < 32; data[x++] = (char)('a'+ (arc4random_uniform(26))));
        userID = [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"userID"];
    }
    
    NSString * userSig = [GenerateTestUserSig genTestUserSig:userID];
    
    _userID = userID;
    
    MLVBLoginInfo *loginInfo = [MLVBLoginInfo new];
    loginInfo.sdkAppID = _SDKAppID;
    loginInfo.userID = userID;
    loginInfo.userName = _userName;
    loginInfo.userAvatar = @"headpic.png";
    loginInfo.userSig = userSig;
    
    __weak __typeof(self) weakSelf = self;
    
    // 初始化LiveRoom
    [weakSelf.liveRoom loginWithInfo:loginInfo completion:^(int errCode, NSString *errMsg) {
        __strong __typeof(weakSelf) self = weakSelf; if (nil == self) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_createBtn.enabled = YES;
        });
        NSLog(@"init LiveRoom errCode[%d] errMsg[%@]", errCode, errMsg);
        if (errCode == 0) {
            [self onLoginSucceed];
            weakSelf.initSucc = YES;
        } else {
            [self onLoginFailed];
            [weakSelf alertTips:@"LiveRoom init失败" msg:errMsg];
        }
    }];
}

#pragma mark -
- (void)onLoginSucceed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_createBtn setTitle:@"新建直播间" forState:UIControlStateNormal];
        _createBtn.enabled = YES;
        [self requestRoomList];
    });
}

- (void)onLoginFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_createBtn setTitle:@"登录" forState:UIControlStateNormal];
        _createBtn.enabled = YES;
    });
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self requestRoomList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_liveRoom setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)initUI {
    self.title = @"MLVBLiveRoom";
    [self.view setBackgroundColor:UIColorFromRGB(0x333333)];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(70*kScaleX, 200*kScaleY, self.view.width - 140*kScaleX, 60*kScaleY)];
    _tipLabel.textColor = UIColorFromRGB(0x999999);
    _tipLabel.text = @"当前没有进行中的直播\n请点击新建直播间";
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.numberOfLines = 2;
    _tipLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_tipLabel];
    
    _roomlistView = [[UITableView alloc] initWithFrame:CGRectMake(12*kScaleX, 120*kScaleY, self.view.width - 24*kScaleX, 400*kScaleY)];
    _roomlistView.delegate = self;
    _roomlistView.dataSource = self;
    _roomlistView.backgroundColor = [UIColor clearColor];
    _roomlistView.allowsMultipleSelection = NO;
    _roomlistView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_roomlistView registerClass:[LiveRoomTableViewCell class] forCellReuseIdentifier:@"LiveRoomTableViewCell"];
    [self.view addSubview:_roomlistView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshClick:) forControlEvents:UIControlEventValueChanged];
    [_roomlistView addSubview:refreshControl];
    //[refreshControl beginRefreshing];
    //[self refreshClick:refreshControl];
    
    _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _createBtn.frame = CGRectMake(40*kScaleX, self.view.height - 100*kScaleY, self.view.width - 80*kScaleX, 50*kScaleY);
    _createBtn.layer.cornerRadius = 8;
    _createBtn.layer.masksToBounds = YES;
    _createBtn.layer.shadowOffset = CGSizeMake(1, 1);
    _createBtn.layer.shadowColor = UIColorFromRGB(0x019b5c).CGColor;
    _createBtn.layer.shadowOpacity = 0.8;
    _createBtn.backgroundColor = UIColorFromRGB(0x05a764);
    [_createBtn setTitle:@"新建直播间" forState:UIControlStateNormal];
    [_createBtn setTitle:@"登录中..." forState:UIControlStateDisabled];
    [_createBtn addTarget:self action:@selector(onCreateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_createBtn];

    
    HelpBtnUI(MLVBLiveRoom)
    
//    // 查看帮助
//    _helpBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 160*kScaleX, self.view.height - 50*kScaleY, 120*kScaleX, 40*kScaleY)];
//    [_helpBtn setImage:[UIImage imageNamed:@"help_small"] forState:UIControlStateNormal];
//    [_helpBtn setTitle:@"查看帮助" forState:UIControlStateNormal];
//    [_helpBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
//    _helpBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
//    _helpBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
//    _helpBtn.backgroundColor = [UIColor clearColor];
//    [_helpBtn addTarget:self action:@selector(clickHelp:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_helpBtn];
//    
//    // log按钮
//    _btnLog = [[UIButton alloc] initWithFrame:CGRectMake(60*kScaleX, self.view.height - 50*kScaleY, 120*kScaleX, 40*kScaleY)];
//    [_btnLog setImage:[UIImage imageNamed:@"look_log"] forState:UIControlStateNormal];
//    [_btnLog setTitle:@"查看log" forState:UIControlStateNormal];
//    [_btnLog setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
//    _btnLog.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
//    _btnLog.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
//    _btnLog.backgroundColor = [UIColor clearColor];
//    [_btnLog addTarget:self action:@selector(clickLog:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_btnLog];
//    
//#ifdef APPSTORE
//    _helpBtn.hidden = YES;
//    _btnLog.hidden = YES;
//#endif
    // LOG界面
    _log_switch = NO;
    _logView = [[UITextView alloc] initWithFrame:CGRectMake(0, 80*kScaleY, self.view.size.width, self.view.size.height - 150*kScaleY)];
    _logView.backgroundColor = [UIColor clearColor];
    _logView.alpha = 1;
    _logView.textColor = [UIColor whiteColor];
    _logView.editable = NO;
    _logView.hidden = YES;
    [self.view addSubview:_logView];
    
    // 半透明浮层，用于方便查看log
    _coverView = [[UIView alloc] init];
    _coverView.frame = _logView.frame;
    _coverView.backgroundColor = [UIColor whiteColor];
    _coverView.alpha = 0.5;
    _coverView.hidden = YES;
    [self.view addSubview:_coverView];
    [self.view sendSubviewToBack:_coverView];
}

- (void)requestRoomList {
    if (!_initSucc) {
        return;
    }
    
    [_liveRoom getRoomList:0 count:100 completion:^(int errCode, NSString *errMsg, NSArray<MLVBRoomInfo *> *roomInfoArray) {
        NSLog(@"getRoomList errCode[%d] errMsg[%@]", errCode, errMsg);
        self->_roomInfoArray = roomInfoArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_roomlistView reloadData];
            if (self->_roomInfoArray.count) {
                self->_tipLabel.text = @"选择直播间点击进入";
                self->_tipLabel.frame = CGRectMake(14*kScaleX, 80*kScaleY, self.view.width, 30*kScaleY);
                self->_tipLabel.textAlignment = NSTextAlignmentLeft;
            } else {
                self->_tipLabel.text = @"当前没有进行中的直播\r\n请点击新建直播间";
                self->_tipLabel.frame = CGRectMake(70*kScaleX, 200*kScaleY, self.view.width - 140*kScaleX, 60*kScaleY);
                self->_tipLabel.textAlignment = NSTextAlignmentCenter;
            }
        });
    }];
}

- (void)refreshClick:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    
    [self requestRoomList];
}

- (void)onCreateBtnClicked:(UIButton *)sender {
    if (!_initSucc) {
        [self login];
        return;
    }
    
    LiveRoomNewViewController *newRoomController = [[LiveRoomNewViewController alloc] init];
    newRoomController.liveRoom = _liveRoom;
    newRoomController.userID   = _userID;
    newRoomController.userName = _userName;
    [self.navigationController pushViewController:newRoomController animated:YES];
}

- (void)clickLog:(UIButton *)sender {
    if (!_log_switch) {
        _log_switch = YES;
        _logView.hidden = NO;
        _coverView.hidden = NO;
        [self.view bringSubviewToFront:_logView];
    }
    else {
        _log_switch = NO;
        _logView.hidden = YES;
        _coverView.hidden = YES;
    }
}

- (void)appendLog:(NSString *)msg {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss";
    NSString *time = [format stringFromDate:[NSDate date]];
    NSString *log = [NSString stringWithFormat:@"[%@] %@", time, msg];
    NSString *logMsg = [NSString stringWithFormat:@"%@\n%@", _logView.text, log];
    [_logView setText:logMsg];
}


#pragma mark - LiveRoomListener

- (void)onAnchorEnter:(MLVBAnchorInfo *)anchorInfo {
    
}

- (void)onAnchorExit:(MLVBAnchorInfo *)anchorInfo {
    
}


- (void)onRoomDestroy:(NSString *)roomID {
    
}

- (void)onDebugLog:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendLog:msg];
    });
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo {
    
}

- (void)alertTips:(NSString *)title msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    });
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _roomInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"LiveRoomTableViewCell";
    LiveRoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[LiveRoomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    if (indexPath.row >= _roomInfoArray.count) {
        return cell;
    }
    
    MLVBRoomInfo *roomInfo = _roomInfoArray[indexPath.row];
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.textLabel.text = roomInfo.roomName;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu人在线", roomInfo.memberInfos.count];
    //cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.52 alpha:1.0];
    
    NSUInteger memberNum = [roomInfo.audienceInfoArray count];
    
    cell.roomInfo = roomInfo.roomInfo;
    cell.roomID = roomInfo.roomID;
    cell.memberNum = memberNum == 0 ? 1 : memberNum;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _roomInfoArray.count) {
        return;
    }
    MLVBRoomInfo *roomInfo = _roomInfoArray[indexPath.row];
    
    // 视图跳转
    LiveRoomPlayerViewController *vc = [[LiveRoomPlayerViewController alloc] init];
    vc.roomID = roomInfo.roomID;
    vc.roomName = roomInfo.roomInfo;
    vc.userName = _userName;
    vc.liveRoom = _liveRoom;
    _liveRoom.delegate = vc;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

@end
