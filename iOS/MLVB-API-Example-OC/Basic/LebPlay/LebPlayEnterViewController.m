//  Copyright © 2022 Tencent. All rights reserved.

#import "LebPlayEnterViewController.h"
#import "LebPlayViewController.h"


@interface LebPlayEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *lebPlayButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation LebPlayEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.title = localize(@"MLVB-API-Example.LebPlay.title");
    self.streamIdLabel.text = localize(@"MLVB-API-Example.LivePlay.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:localize(@"MLVB-API-Example.LebPlay.descripView") attributes:@{
        (id)NSForegroundColorAttributeName : [UIColor whiteColor],
        (id)NSFontAttributeName : [UIFont systemFontOfSize:14],
    }];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:localize(@"MLVB-API-Example.LebPlay.descripRecommend") attributes:@{
        (id)NSForegroundColorAttributeName : [UIColor redColor],
        (id)NSFontAttributeName : [UIFont systemFontOfSize:14],
    }]];
    self.descriptionTextView.attributedText = text;
    
    
    [self.lebPlayButton setTitle:localize(@"MLVB-API-Example.LebPlay.lebPlay") forState:UIControlStateNormal];
    [self.lebPlayButton setBackgroundColor:[UIColor themeBlueColor]];
    self.lebPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;

    self.streamIdTextField.text = [NSString generateRandomStreamId];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}


#pragma mark - Actions


- (IBAction)onLebPlayButtonClick:(UIButton*)button {
    LebPlayViewController *playVC = [[LebPlayViewController alloc] initWithStreamId:self.streamIdTextField.text];
    [self.navigationController pushViewController:playVC animated:YES];


}

@end
