//
//  PayModeSelect_View.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/10/25.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "PayModeSelect_View.h"
#import "BackgroudView.h"
@interface PayModeSelect_View ()
- (IBAction)closeBtnClick:(UIButton *)sender;
- (IBAction)payModeBtnClick:(UIButton *)sender;
- (IBAction)confirmBtnClick:(UIButton *)sender;
@property (nonatomic, assign) NSInteger payMode;
@end

@implementation PayModeSelect_View

- (IBAction)closeBtnClick:(UIButton *)sender {
    [[BackgroudView shareInstance] hide];
}

- (IBAction)payModeBtnClick:(UIButton *)sender {
    ((UIButton *)[self viewWithTag:_payMode]).selected = NO;
    sender.selected = YES;
    _payMode = sender.tag;
}

- (IBAction)confirmBtnClick:(UIButton *)sender {
    if (_confirmBtnClickBlock) {
        _confirmBtnClickBlock(_payMode);
    }
}
@end
