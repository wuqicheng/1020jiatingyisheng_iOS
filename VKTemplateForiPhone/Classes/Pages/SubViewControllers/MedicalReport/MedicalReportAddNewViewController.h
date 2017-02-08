//
//  MedicalReportAddNewViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicalReportAddNewViewController : AppsBaseViewController {
    IBOutlet UIView *cursor1,*cursor2;
    IBOutlet UITextField *tfTitle;
    IBOutlet UITextView *tvContent;
    IBOutlet UILabel *labelPic,*labelPlaceHolder;
    IBOutlet UICollectionView *picCollectionView;
    IBOutlet UIScrollView *scView;
    IBOutlet UIButton *btn1,*btn2;
}

@property (nonatomic,assign) bool isActive;

- (IBAction)btnAction:(UIButton*)sender;

@end
