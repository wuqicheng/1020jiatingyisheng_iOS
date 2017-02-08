//
//  UserCollectionViewController.h
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"

@interface UserCollectionViewController : AppsBaseTableViewController {
    IBOutlet UILabel *labelNoData;
}
@property (weak, nonatomic) IBOutlet UIView *topView;

- (IBAction)btnAction:(UIButton*)sender;

@end
