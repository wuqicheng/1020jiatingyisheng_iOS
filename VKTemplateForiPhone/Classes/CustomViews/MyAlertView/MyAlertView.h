//
//  MyAlertView.h
//  aixiche
//
//  Created by vescky.luo on 14-10-5.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"
@protocol MyAlertViewDelegate;

@interface MyAlertView : AppsBaseView {
    UIStepper *stepper;
}

typedef int MyAlertViewStyle;
enum MyAlertViewStyle {
    MyAlertViewStyleDefault,
    MyAlertViewStyleTitleClose,
    MyAlertViewStyleInput,
    MyAlertViewStyleStepper,
    MyAlertViewStyleI_Know,
    MyAlertViewStylePayment
    //to be continue...
};

typedef int MyAlertViewEventTag;
enum MyAlertViewEventTag {
    MyAlertViewEventBtnClosed,
    MyAlertViewEventBtnLeft,
    MyAlertViewEventBtnRight,
    MyAlertViewEventBackgroud
};

@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,strong) UILabel *labelAlert;
@property (nonatomic,strong) UITextView *tvContent;
@property (nonatomic) NSInteger stepCounter;
@property (nonatomic,assign) id <MyAlertViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString*)alertTitle alertContent:(NSString*)alertContent style:(MyAlertViewStyle)aStyle;
- (instancetype)initWithTitle:(NSString*)alertTitle alertContent:(NSString*)alertContent defaultStyleWithButtons:(NSArray*)buttons;
- (void)show;
- (void)dismiss;

@end


@protocol MyAlertViewDelegate <NSObject>

- (void)btnDidClick:(MyAlertViewEventTag)eventTag;

- (void)alertView:(MyAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end