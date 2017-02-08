//
//  MedicalProjectDetail_VC.h
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/10/24.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CollectChangeBlock)(BOOL);
@interface MedicalProjectDetail_VC : AppsBaseViewController
@property (nonatomic, strong) NSString *project_id;
@property (weak, nonatomic) IBOutlet UILabel *workTimeLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *homePageBtn;
@property (nonatomic, strong) CollectChangeBlock collectChangeBlock;
- (IBAction)imgOrTextConsultBtnClik:(UIButton *)sender;

- (IBAction)phoneConsultBtnClick:(UIButton *)sender;

@end
