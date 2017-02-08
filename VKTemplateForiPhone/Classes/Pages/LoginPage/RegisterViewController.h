//
//  RegisterViewController.h
//  aixiche
//
//  Created by Vescky on 14-10-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : AppsBaseViewController {
    IBOutlet UITextField *tfPhone,*tfSMSCode,*tfPassword,*tfComfirmPassword;
    IBOutlet UIButton *btnSMSCode,*btnCheckbox;
    IBOutlet UIScrollView *scView;
}

- (IBAction)btnAction:(UIButton*)sender;

@end
