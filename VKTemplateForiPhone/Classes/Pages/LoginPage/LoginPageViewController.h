//
//  LoginPageViewController.h
//  aixiche
//
//  Created by vescky.luo on 14-10-5.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginPageViewController : AppsBaseViewController {
    IBOutlet UITextField *tfPhone,*tfPassword;
    IBOutlet UIView *viewForPhone,*viewForPassword;
    IBOutlet UIButton *btnLogin,*btnCheckBox;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
