//
//  MainViewController.m
//  RTMPiOSDemo
//
//  Created by rushanting on 2017/4/28.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "MainViewController.h"
#ifdef ENABLE_PUSH
#import "CameraPushViewController.h"
#endif
#ifdef ENABLE_PLAY
#import "PlayViewController.h"

#endif



#import "ColorMacro.h"
#import "MainTableViewCell.h"

#import "TXLiveBase.h"

#define STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

static NSString * const XiaoZhiBoAppStoreURLString = @"http://itunes.apple.com/cn/app/id1132521667?mt=8";
static NSString * const XiaoShiPinAppStoreURLString = @"http://itunes.apple.com/cn/app/id1374099214?mt=8";

@interface MainViewController ()<
UITableViewDelegate,
UITableViewDataSource,
UIPickerViewDataSource,
UIPickerViewDelegate,
UIAlertViewDelegate
>
#ifdef ENABLE_UGC
@property (strong, nonatomic) UGCKitWrapper *ugcWrapper;
#endif
@property (nonatomic) NSMutableArray<CellInfo*>* cellInfos;
@property (nonatomic) NSArray<CellInfo*>* addNewCellInfos;
@property (nonatomic) MainTableViewCell *selectedCell;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) UIView*   logUploadView;
@property (nonatomic) UIPickerView* logPickerView;
@property (nonatomic) NSMutableArray* logFilesArray;

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#ifdef ENABLE_UGC
    _ugcWrapper = [[UGCKitWrapper alloc] initWithViewController:self theme:nil];
#endif

    [self initCellInfos];
    [self initUI];
}

- (void)initCellInfos
{
    _cellInfos = [NSMutableArray new];
    CellInfo* cellInfo = nil;
    
#if defined(ENABLE_PUSH) || defined(ENABLE_PLAY)
    cellInfo = [CellInfo new];
    cellInfo.title = @"移动直播";
    cellInfo.iconName = @"live_room";
    [_cellInfos addObject:cellInfo];
    cellInfo.subCells = ({
        NSMutableArray *subCells = [NSMutableArray new];
        CellInfo* scellInfo;
        
#if defined(ENABLE_PUSH) && defined(ENABLE_PLAY)
        scellInfo = [CellInfo cellInfoWithTitle:@"MLVBLiveRoom"
                       controllerClassName:@"LiveRoomListViewController"];
        [subCells addObject:scellInfo];
#endif
        
#ifdef ENABLE_PUSH
        scellInfo = [CellInfo cellInfoWithTitle:@"摄像头推流"
                       controllerClassName:@"CameraPushViewController"];
        [subCells addObject:scellInfo];
        
#endif
        
#ifdef ENABLE_PLAY
        scellInfo = [CellInfo cellInfoWithTitle:@"直播拉流"
                       controllerClassName:@"PlayViewController"];
        [subCells addObject:scellInfo];
#endif
        
#if defined(ENABLE_PUSH) && defined(ENABLE_PLAY)
        scellInfo = [CellInfo cellInfoWithTitle:@"录屏直播"
                              controllerClassName:@"ScreenPushViewController"];
        [subCells addObject:scellInfo];
#endif
        
        scellInfo = [CellInfo cellInfoWithTitle:@"小直播" actionBlock:^{
            // 打开小直播AppStore
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:XiaoZhiBoAppStoreURLString]];
        }];
        [subCells addObject:scellInfo];
        
        subCells;
    });
#endif


}

- (void)initUI
{
    int originX = 15;
    CGFloat width = self.view.frame.size.width - 2 * originX;
    
    self.view.backgroundColor = UIColorFromRGB(0x0d0d0d);
    
    //大标题
    UILabel* lbHeadLine = [[UILabel alloc] initWithFrame:CGRectMake(originX, 50, width, 48)];
    lbHeadLine.text = @"腾讯视频云";
    lbHeadLine.textColor = UIColorFromRGB(0xffffff);
    lbHeadLine.font = [UIFont systemFontOfSize:24];
    [lbHeadLine sizeToFit];
    [self.view addSubview:lbHeadLine];
    lbHeadLine.center = CGPointMake(lbHeadLine.superview.center.x, lbHeadLine.center.y);
    
    lbHeadLine.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [lbHeadLine addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer* pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)]; //提取SDK日志暗号!
    pressGesture.minimumPressDuration = 2.0;
    pressGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:pressGesture];
    
    
    //副标题
    UILabel* lbSubHead = [[UILabel alloc] initWithFrame:CGRectMake(originX, lbHeadLine.frame.origin.y + lbHeadLine.frame.size.height + 15, width, 30)];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    lbSubHead.text = [NSString stringWithFormat:@"视频云工具包 v%@", version];
    lbSubHead.text = [lbSubHead.text stringByAppendingString:@"\n本APP用于展示腾讯视频云终端产品的各类功能"];
    lbSubHead.numberOfLines = 2;
    lbSubHead.textColor = UIColor.grayColor;
    lbSubHead.textAlignment = NSTextAlignmentCenter;
    lbSubHead.font = [UIFont systemFontOfSize:14];
    lbSubHead.textColor = UIColorFromRGB(0x535353);
    
    //行间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lbSubHead.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [paragraphStyle setLineSpacing:7.5f];//设置行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, lbSubHead.text.length)];
    lbSubHead.attributedText = attributedString;
    
    [lbSubHead sizeToFit];
    
    [self.view addSubview:lbSubHead];
    lbSubHead.userInteractionEnabled = YES;
    [lbSubHead addGestureRecognizer:tapGesture];
    lbSubHead.frame = CGRectMake(lbSubHead.frame.origin.x, self.view.frame.size.height-lbSubHead.frame.size.height-34, lbSubHead.frame.size.width, lbSubHead.frame.size.height);
    lbSubHead.center = CGPointMake(lbSubHead.superview.frame.size.width/2, lbSubHead.center.y);
    
    //功能列表
    int tableviewY = lbSubHead.frame.origin.y + lbSubHead.frame.size.height + 12;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(originX, tableviewY, width, self.view.frame.size.height - tableviewY)];
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, lbHeadLine.frame.origin.y+lbHeadLine.frame.size.height+12, _tableView.frame.size.width, _tableView.superview.frame.size.height);
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.superview.frame.size.height-_tableView.frame.origin.y);
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _logUploadView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    _logUploadView.backgroundColor = [UIColor whiteColor];
    _logUploadView.hidden = YES;
    
    _logPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _logUploadView.frame.size.height * 0.8)];
    _logPickerView.dataSource = self;
    _logPickerView.delegate = self;
    [_logUploadView addSubview:_logPickerView];
    
    UIButton* uploadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    uploadButton.center = CGPointMake(self.view.bounds.size.width / 2, _logUploadView.frame.size.height * 0.9);
    uploadButton.bounds = CGRectMake(0, 0, self.view.bounds.size.width / 3, _logUploadView.frame.size.height * 0.2);
    [uploadButton setTitle:@"分享上传日志" forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(onSharedUploadLog:) forControlEvents:UIControlEventTouchUpInside];
    [_logUploadView addSubview:uploadButton];
    
    [self.view addSubview:_logUploadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellInfos.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_cellInfos.count < indexPath.row)
        return nil;
    
    static NSString* cellIdentifier = @"MainViewCellIdentifier";
    MainTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CellInfo* cellInfo = _cellInfos[indexPath.row];
    
    [cell setCellData:cellInfo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_logUploadView.hidden) {
        _logUploadView.hidden = YES;
    }
    
    if (_cellInfos.count < indexPath.row)
        return ;
    
    MainTableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    CellInfo* cellInfo = currentCell.cellData;
    
    if (cellInfo.subCells != nil) {
        [tableView beginUpdates];
        NSMutableArray *indexArray = [NSMutableArray new];
        if (self.addNewCellInfos) {
            NSUInteger deleteFrom = [_cellInfos indexOfObject:self.addNewCellInfos[0]];
            for (int i = 0; i < self.addNewCellInfos.count; i++) {
                [indexArray addObject:[NSIndexPath indexPathForRow:i+deleteFrom inSection:0]];
            }
            [tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
            [_cellInfos removeObjectsInArray:self.addNewCellInfos];
        }
        [tableView endUpdates];
        
        [tableView beginUpdates];
        if (!cellInfo.isUnFold) {
            self.selectedCell.highLight = NO;
            self.selectedCell.cellData.isUnFold = NO;
            
            NSUInteger row = [_cellInfos indexOfObject:cellInfo]+1;
            [indexArray removeAllObjects];
            for (int i = 0; i < cellInfo.subCells.count; i++) {
                [indexArray addObject:[NSIndexPath indexPathForRow:i+row inSection:0]];
            }
            [_cellInfos insertObjects:cellInfo.subCells atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, cellInfo.subCells.count)]];
            [tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [tableView endUpdates];
        
        cellInfo.isUnFold = !cellInfo.isUnFold;
        currentCell.highLight = cellInfo.isUnFold;
        self.selectedCell = currentCell;
        if (cellInfo.isUnFold) {
            self.addNewCellInfos = cellInfo.subCells;
        } else {
            self.addNewCellInfos = nil;
        }
        return;
    }

    if (cellInfo.type == CellInfoTypeEntry) {
        UIViewController *controller = [cellInfo createEntryController];
        if (controller) {
            if (![controller isKindOfClass:NSClassFromString(@"MoviePlayerViewController")]) {
                [self _hideSuperPlayer];
            }
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (cellInfo.type == CellInfoTypeAction) {
        [cellInfo performAction];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellInfo* cellInfo = _cellInfos[indexPath.row];
    if (cellInfo.subCells != nil) {
        return 65;
    }
    return 51;
}

- (void)_hideSuperPlayer {}


- (void)handleLongPress:(UILongPressGestureRecognizer *)pressRecognizer
{
    if (pressRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long Press");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *logDoc = [NSString stringWithFormat:@"%@%@", paths[0], @"/log"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray* fileArray = [fileManager contentsOfDirectoryAtPath:logDoc error:nil];
        fileArray = [fileArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString* file1 = (NSString*)obj1;
            NSString* file2 = (NSString*)obj2;
            return [file1 compare:file2] == NSOrderedDescending;
        }];
        self.logFilesArray = [NSMutableArray new];
        for (NSString* logName in fileArray) {
            if ([logName hasSuffix:@"xlog"]) {
                [self.logFilesArray addObject:logName];
            }
        }
        
        _logUploadView.alpha = 0.1;
        UIView *logUploadView = _logUploadView;
        [UIView animateWithDuration:0.5 animations:^{
            logUploadView.hidden = NO;
            logUploadView.alpha = 1;
        }];
        [_logPickerView reloadAllComponents];
    }
}

- (void)handleTap:(UITapGestureRecognizer*)tapRecognizer
{
    if (!_logUploadView.hidden) {
        _logUploadView.hidden = YES;
    }
}

- (void)onSharedUploadLog:(UIButton*)sender
{
    NSInteger row = [_logPickerView selectedRowInComponent:0];
    if (row < self.logFilesArray.count) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *logDoc = [NSString stringWithFormat:@"%@%@", paths[0], @"/log"];
        NSString* logPath = [logDoc stringByAppendingPathComponent:self.logFilesArray[row]];
        NSURL *shareobj = [NSURL fileURLWithPath:logPath];
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[shareobj] applicationActivities:nil];
        UIView *logUploadView = _logUploadView;
        [self presentViewController:activityView animated:YES completion:^{
            logUploadView.hidden = YES;
        }];
    }
}
#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.logFilesArray.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row < self.logFilesArray.count) {
        return (NSString*)self.logFilesArray[row];
    }
    
    return nil;
}

@end
