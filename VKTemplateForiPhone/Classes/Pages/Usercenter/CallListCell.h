//
//  CallListCell.h
//  VKTemplateForiPhone
//
//  Created by NPHD on 15/7/27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"
#import "StarsRatingView.h"
@protocol CallListDelegate;

@interface CallListCell : AppsBaseTableViewCell
{
    IBOutlet UILabel *menuLabel,*starTime,*apointmentTime,*endTime,*nickName,*commentLable,*payTimeLabel;
    IBOutlet UIImageView *imageAvtar;
    IBOutlet UIButton *statusBtn,*phoneCallBtn,*chatBtn,*commentBtn;
    IBOutlet StarsRatingView *ratingView1,*ratingView2;
    IBOutlet UIView *commentView,*starView,*lineView,*underLineView,*phoneView,*chatAndCommentView;
}

typedef NS_ENUM(NSInteger, btnClickType) {
    phoneCallBtnClick = 101,//电话咨询
    chatBtnClick = 102,//图文咨询
    commentBtnClick = 103//评论
};

@property(nonatomic,assign) id<CallListDelegate> delegate;
@property(nonatomic,strong) NSString *phoneCallId,*converstationId;
- (IBAction)btnAction:(UIButton*)sender;
- (CGFloat)getCellHeight:(NSDictionary*)cInfo;
@end

@protocol CallListDelegate <NSObject>


-(void)setPhoneCallId:(NSString*)phoneId btnClickType:(btnClickType)clickTye;

@end