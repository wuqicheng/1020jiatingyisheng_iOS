//
//  SearchDoctorViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/17.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface SearchDoctorViewController : AppsBaseTableViewController {
    IBOutlet UITextField *tfSearch;
    IBOutlet UIView *noRecordView;
}

- (IBAction)searchAction:(UIButton*)sender;

@end
