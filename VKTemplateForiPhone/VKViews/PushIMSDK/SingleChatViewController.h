//
//  SingleChatViewController.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewController.h"
#import "StarsRatingView.h"

@interface SingleChatViewController : AppsBaseTableViewController {
    IBOutlet UITextView *tvContent;
    IBOutlet UIView *toolBar,*evaluateBar;
    IBOutlet UIButton *btnMore;
    IBOutlet StarsRatingView *ratingView1,*ratingView2;
    IBOutlet UILabel *labelEvaluate;
}

@property (nonatomic,strong) NSDictionary *conversationInfo;
@property (nonatomic,strong) NSString *conversationId;
@property (nonatomic,assign) bool isConversationOver,isCommented,isThirdMan;

- (IBAction)toolBarAction:(UIButton*)sender;

@end
