//
//  HealthSelfTest_VC.h
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/11/30.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HealthSelfTest_VC : AppsBaseViewController
@property (nonatomic ,strong) NSString *optionId;       //选择哪一项
@property (nonatomic ,assign) BOOL isAutoSkipToNext;  //是否自动跳转下个页面

@property (nonatomic, strong) NSDictionary *dicdic;
@property (nonatomic ,assign) NSInteger types;;
@end
