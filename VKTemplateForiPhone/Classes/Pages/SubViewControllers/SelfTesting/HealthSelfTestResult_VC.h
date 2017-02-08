//
//  HealthSelfTestResult_VC.h
//  jiankangshouhuzhuanjia
//
//  Created by ADUU on 15/12/2.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HealthSelfTestResult_VC : AppsBaseViewController{
   

    UIViewController *parrentVc;
}
@property (nonatomic, strong) NSString *project_id;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic, strong) NSDictionary *dicdicdic;
@end
