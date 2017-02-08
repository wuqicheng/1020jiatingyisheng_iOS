//
//  UserHealthWarnResult_VC.h
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/12/2.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^BlockCancelCollect)(void);
@interface UserHealthWarnResult_VC : AppsBaseViewController
@property (nonatomic, strong) BlockCancelCollect blockCancelCollect;
@property (nonatomic, strong) NSDictionary *dic;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@end
