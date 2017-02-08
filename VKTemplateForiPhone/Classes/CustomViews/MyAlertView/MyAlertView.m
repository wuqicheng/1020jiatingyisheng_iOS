//
//  MyAlertView.m
//  aixiche
//
//  Created by vescky.luo on 14-10-5.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "MyAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyAlertView
@synthesize labelAlert,delegate,labelTitle,tvContent,stepCounter;

#pragma mark - Public
- (instancetype)initWithTitle:(NSString*)alertTitle alertContent:(NSString*)alertContent style:(MyAlertViewStyle)aStyle {
    self = [self initWithFrame:[AppKeyWindow bounds]];
    if (self) {
        [self setUpViewWithTitle:alertTitle alertContent:alertContent style:aStyle buttons:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString*)alertTitle alertContent:(NSString*)alertContent defaultStyleWithButtons:(NSArray*)buttons {
    self = [self initWithFrame:[AppKeyWindow bounds]];
    if (self) {
        [self setUpViewWithTitle:alertTitle alertContent:alertContent style:MyAlertViewStyleDefault buttons:buttons];
    }
    return self;
}

- (void)show {
    [AppKeyWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - Private
- (void)setUpViewWithTitle:(NSString*)alertTitle alertContent:(NSString*)alertContent style:(MyAlertViewStyle)aStyle buttons:(NSArray*)buttons {
    self.backgroundColor = [UIColor clearColor];
    
    //make a mask-view
    UIView *viewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    viewMask.backgroundColor = [UIColor blackColor];
    viewMask.alpha = 0.4;
    [self addSubview:viewMask];
    
    //make up background responder
    UIButton *btnBackground = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBackground.backgroundColor = [UIColor clearColor];
    btnBackground.frame = CGRectMake(0, 0, viewMask.frame.size.width, viewMask.frame.size.height);
    btnBackground.tag = MyAlertViewEventBackgroud;
    [btnBackground addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btnBackground.userInteractionEnabled = NO;//default no respond
    [viewMask addSubview:btnBackground];
    
    //make up container-view
    float hMargin = 20.0f;
    float vMargin = 44.0f;
    UIView *viewContainer = [[UIView alloc] initWithFrame:CGRectMake(hMargin, 0, self.frame.size.width - 2*hMargin, 100)];
    viewContainer.clipsToBounds = YES;
    viewContainer.backgroundColor = GetColorWithRGB(240, 240, 240);
    viewContainer.layer.cornerRadius = 2.0;
    [self addSubview:viewContainer];
    
    //make some views for different styles
    if (aStyle == MyAlertViewStyleDefault) {
        //默认样式  暂时只做1和2个按钮
        float tmpMargin = 10.f;
        
        //header
        UIView *vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewContainer.frame.size.width, 49.f)];
        vHeader.backgroundColor = GetColorWithRGB(61, 152, 221);
        [viewContainer addSubview:vHeader];
        
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.0f, vHeader.frame.size.width, 25.0f)];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.text = alertTitle;
        labelTitle.textAlignment = NSTextAlignmentCenter;
        labelTitle.center = CGPointMake(vHeader.frame.size.width/2.f, vHeader.frame.size.height/2.f);
        [vHeader addSubview:labelTitle];
        
        //Middle
        labelAlert = [[UILabel alloc] initWithFrame:CGRectMake(hMargin, vHeader.frame.origin.y+vHeader.frame.size.height + tmpMargin, viewContainer.frame.size.width - 2*hMargin, 20)];
        labelAlert.font = [UIFont systemFontOfSize:14.0];
        labelAlert.textColor = [UIColor blackColor];
        labelAlert.text = alertContent;
        labelAlert.backgroundColor = [UIColor clearColor];
        fitLabelHeight(labelAlert,alertContent);
        [viewContainer addSubview:labelAlert];
        
        //buttom
        if (isValidArray(buttons)) {
            UIView *viewButtom = [[UIView alloc] initWithFrame:CGRectMake(0, labelAlert.frame.origin.y+labelAlert.frame.size.height + tmpMargin, viewContainer.frame.size.width, 60.0f)];
            viewButtom.clipsToBounds = YES;
            [viewContainer addSubview:viewButtom];
            
            if (buttons.count == 2) {
               
                setViewFrameSizeHeight(viewButtom, 56.f);
                viewButtom.clipsToBounds = YES;
                [viewContainer addSubview:viewButtom];
                
                UIButton *btnCancel= [UIButton buttonWithType:UIButtonTypeCustom];
                btnCancel.frame = CGRectMake(20.f, 10.f, 109.f, 36.f);
                btnCancel.tag = MyAlertViewEventBtnLeft;
                [btnCancel setTitle:[buttons firstObject] forState:UIControlStateNormal];
                [btnCancel setBackgroundImage:[UIImage imageNamed:@"button_red_short.png"] forState:UIControlStateNormal];
                [btnCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
                [viewButtom addSubview:btnCancel];
                
                UIButton *btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
                btnSure.frame = CGRectMake(viewButtom.frame.size.width-20.f-109.f, 10.f, 109.f, 36.f);
                btnSure.tag = MyAlertViewEventBtnRight;
                [btnSure setTitle:[buttons lastObject] forState:UIControlStateNormal];
                [btnSure setBackgroundImage:[UIImage imageNamed:@"button_gray_short.png"] forState:UIControlStateNormal];
                [btnSure addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
                [viewButtom addSubview:btnSure];
            }
            else {
                //button
                
                UIButton *btnCenter = [UIButton buttonWithType:UIButtonTypeCustom];
                btnCenter.frame = CGRectMake((viewButtom.frame.size.width - 225.f)/2.f, (viewButtom.frame.size.height - 36.f)/2.f, 225.f, 36.f);
                btnCenter.tag = MyAlertViewEventBtnLeft;
                [btnCenter setTitle:[buttons firstObject] forState:UIControlStateNormal];
                [btnCenter setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
                [btnCenter addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
                [viewButtom addSubview:btnCenter];
            }
            
            [viewContainer addSubview:viewButtom];
            setViewFrameSizeHeight(viewContainer, viewButtom.frame.origin.y+viewButtom.frame.size.height);
        }
    }
    else if (aStyle == MyAlertViewStyleTitleClose) {
        //特殊样式1--洗车
        //title
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.0f, viewContainer.frame.size.width, 25.0f)];
        [viewContainer addSubview:labelTitle];
        
        //make up close button
        float btnWidth = 44.0;
        UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClose.frame = CGRectMake(viewContainer.frame.size.width - btnWidth, 0, btnWidth, btnWidth);
        [btnClose setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        btnClose.tag = MyAlertViewEventBtnClosed;
        [btnClose addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnClose];
        
        labelAlert = [[UILabel alloc] initWithFrame:CGRectMake(hMargin, vMargin, viewContainer.frame.size.width - 2*hMargin, 20)];
        labelAlert.font = [UIFont systemFontOfSize:16.0];
        labelAlert.textColor = [UIColor blackColor];
        labelAlert.text = alertContent;
        labelAlert.backgroundColor = [UIColor clearColor];
        fitLabelHeight(labelAlert,alertContent);
        [viewContainer addSubview:labelAlert];
        
        //adjust content-view
        if (labelAlert.frame.origin.y + labelAlert.frame.size.height + vMargin > viewContainer.frame.size.height ) {
            setViewFrameSizeHeight(viewContainer, labelAlert.frame.origin.y + labelAlert.frame.size.height + vMargin);
            setViewFrameOriginY(viewContainer, (self.frame.size.height - viewContainer.frame.size.height) / 2.0);
        }
        
    }
    else if (aStyle == MyAlertViewStyleInput) {
        //带输入框的样式
        //title
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.0f, viewContainer.frame.size.width, 25.0f)];
        [viewContainer addSubview:labelTitle];
        
        //buttom
        UIView *viewButtom = [[UIView alloc] initWithFrame:CGRectMake(0, viewContainer.frame.size.height - 40.0, viewContainer.frame.size.width, 40.0f)];
        viewButtom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        viewButtom.clipsToBounds = YES;
        [viewContainer addSubview:viewButtom];
        
        UIButton *btnCancel= [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel.frame = CGRectMake(0, 0, viewButtom.frame.size.width/2.0, viewButtom.frame.size.height);
        btnCancel.tag = MyAlertViewEventBtnLeft;
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewButtom addSubview:btnCancel];
        
        UIButton *btnSure = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSure.frame = CGRectMake(viewButtom.frame.size.width/2.0, 0, viewButtom.frame.size.width/2.0, viewButtom.frame.size.height);
        btnSure.tag = MyAlertViewEventBtnRight;
        [btnSure setTitle:@"确定" forState:UIControlStateNormal];
        [btnSure addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewButtom addSubview:btnSure];
        
        //make up close button
        float btnWidth = 44.0;
        UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClose.frame = CGRectMake(viewContainer.frame.size.width - btnWidth, 0, btnWidth, btnWidth);
        [btnClose setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        btnClose.tag = MyAlertViewEventBtnClosed;
        [btnClose addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnClose];
        
        tvContent = [[UITextView alloc] initWithFrame:CGRectMake(10, labelTitle.frame.origin.y + labelTitle.frame.size.height + 10.0, viewContainer.frame.size.width - 2*10.0f, 50.0f)];
        [viewContainer addSubview:tvContent];
        
    }
    else if (aStyle == MyAlertViewStyleStepper) {
        stepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        
    }
    else if (aStyle == MyAlertViewStyleI_Know) {
        ///样式----我知道了
        float tmpMargin = 10.f;
        //header
        UIView *vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewContainer.frame.size.width, 49.f)];
        vHeader.backgroundColor = GetColorWithRGB(61, 152, 221);
        [viewContainer addSubview:vHeader];
        
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10.0f, vHeader.frame.size.width, 25.0f)];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.text = alertTitle;
        labelTitle.textAlignment = NSTextAlignmentCenter;
        labelTitle.center = CGPointMake(vHeader.frame.size.width/2.f, vHeader.frame.size.height/2.f);
        [vHeader addSubview:labelTitle];
        
        //Middle
        labelAlert = [[UILabel alloc] initWithFrame:CGRectMake(hMargin, vHeader.frame.origin.y+vHeader.frame.size.height + tmpMargin, viewContainer.frame.size.width - 2*hMargin, 20)];
        labelAlert.font = [UIFont systemFontOfSize:14.0];
        labelAlert.textColor = [UIColor blackColor];
        labelAlert.text = alertContent;
        labelAlert.backgroundColor = [UIColor clearColor];
        fitLabelHeight(labelAlert,alertContent);
        [viewContainer addSubview:labelAlert];
        
        //buttom
        UIView *viewButtom = [[UIView alloc] initWithFrame:CGRectMake(0, labelAlert.frame.origin.y+labelAlert.frame.size.height + tmpMargin, viewContainer.frame.size.width, 60.0f)];
        viewButtom.clipsToBounds = YES;
        [viewContainer addSubview:viewButtom];
        
        UIButton *btnCenter = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCenter.frame = CGRectMake((viewButtom.frame.size.width - 225.f)/2.f, (viewButtom.frame.size.height - 36.f)/2.f, 225.f, 36.f);
        btnCenter.tag = MyAlertViewEventBtnLeft;
        [btnCenter setTitle:@"我知道了" forState:UIControlStateNormal];
        [btnCenter setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
        [btnCenter addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewButtom addSubview:btnCenter];
        
        setViewFrameSizeHeight(viewContainer, viewButtom.frame.origin.y+viewButtom.frame.size.height);
    }
    else if (aStyle == MyAlertViewStylePayment) {
        ///样式---支付
        
    }
    //to be continue...
    
    //调节位置
    viewContainer.center = CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
}

- (IBAction)btnAction:(UIButton*)sender {
    [self dismiss];
    if (![delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        return;
    }
    
    if (sender.tag == MyAlertViewEventBtnClosed) {
        NSLog(@"closed button clicked");
        [delegate alertView:self clickedButtonAtIndex:0];
    }
    else if (sender.tag == MyAlertViewEventBtnLeft) {
        NSLog(@"left button clicked");
        [delegate alertView:self clickedButtonAtIndex:0];
    }
    else if (sender.tag == MyAlertViewEventBtnRight) {
        NSLog(@"right button clicked");
        [delegate alertView:self clickedButtonAtIndex:1];
    }
    else if (sender.tag == MyAlertViewEventBackgroud) {
        NSLog(@"background button clicked");
    }

}

@end
