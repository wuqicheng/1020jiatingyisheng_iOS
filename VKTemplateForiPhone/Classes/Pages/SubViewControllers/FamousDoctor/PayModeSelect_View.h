//
//  PayModeSelect_View.h
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/10/25.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ConfirmBtnClickBlock)(NSInteger);
@interface PayModeSelect_View : UIView

@property (nonatomic, strong) ConfirmBtnClickBlock confirmBtnClickBlock;

@end
