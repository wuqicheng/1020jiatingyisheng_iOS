//
//  PickDateTimeActionSheetView.m
//  aixiche
//
//  Created by Vescky on 14/11/24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "PickDateTimeActionSheetView.h"

#define PickDateTimeActionSheetView_Background_Tag 9999
#define PickDateTimeActionSheetView_Button_Yes 9998
#define PickDateTimeActionSheetView_Button_No 9997

@implementation PickDateTimeActionSheetView
@synthesize delegate,selectedDate,picker;

- (instancetype)initWithTitle:(NSString*)pTitle pickerType:(PickDateTimeActionSheetViewType)pickerType {
    self = [self initWithFrame:[AppKeyWindow bounds]];
    if (self) {
        [self setUpViewWithTitle:pTitle pickerType:pickerType];
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
- (void)setUpViewWithTitle:(NSString*)pTitle pickerType:(PickDateTimeActionSheetViewType)pickerType  {
    
    self.backgroundColor = [UIColor clearColor];
    
    //make a mask-view
    UIView *viewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    viewMask.backgroundColor = [UIColor blackColor];
    viewMask.alpha = 0.6;
    [self addSubview:viewMask];
    
    //make up background responder
    UIButton *btnBackground = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBackground.backgroundColor = [UIColor clearColor];
    btnBackground.frame = CGRectMake(0, 0, viewMask.frame.size.width, viewMask.frame.size.height);
    btnBackground.tag = PickDateTimeActionSheetView_Background_Tag;
    [btnBackground addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewMask addSubview:btnBackground];
    
    //make up container
    float topbarHeight = 49.0f;
    float pickerHeight = 216.0f;
    float containerHeight = pickerHeight + topbarHeight;
    UIView *viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, viewMask.frame.size.height - containerHeight, viewMask.frame.size.width, containerHeight)];
    viewContainer.backgroundColor = GetColorWithRGB(197.0, 197.0, 197.0);
    [self addSubview:viewContainer];
    
    //make up top-bar
    UIView *viewTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewContainer.frame.size.width, topbarHeight)];
    viewContainer.backgroundColor = [UIColor whiteColor];
    [viewContainer addSubview:viewTopBar];
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 0, 60.0, viewTopBar.frame.size.height)];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnCancel addTarget:selectedDate action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.tag = PickDateTimeActionSheetView_Button_No;
    [viewTopBar addSubview:btnCancel];
    
    UIButton *btnYes = [[UIButton alloc] initWithFrame:CGRectMake(viewTopBar.frame.size.width - 10.0 - 60.0, 0, 60.0, viewTopBar.frame.size.height)];
    [btnYes setTitle:@"确定" forState:UIControlStateNormal];
    [btnYes setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnYes addTarget:selectedDate action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btnYes.tag = PickDateTimeActionSheetView_Button_Yes;
    [viewTopBar addSubview:btnYes];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(btnCancel.frame.origin.x+btnCancel.frame.size.width+10.0, 0, viewTopBar.frame.size.width - btnYes.frame.size.width - btnCancel.frame.size.width - 2*10.0, viewTopBar.frame.size.height)];
    [labelTitle setFont:[UIFont systemFontOfSize:20.0]];
    [labelTitle setTextColor:[UIColor blackColor]];
    [labelTitle setTextAlignment:NSTextAlignmentCenter];
    [labelTitle setText:pTitle];
    [viewTopBar addSubview:labelTitle];
    
    //make up picker
    picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, topbarHeight, viewContainer.frame.size.width, pickerHeight)];
    [picker setTimeZone:[NSTimeZone defaultTimeZone]];
    [picker setDate:(selectedDate ? selectedDate : [NSDate date]) animated:NO];
    if (pickerType == PickDateTimeActionSheetViewTypeDefault) {
        [picker setDatePickerMode:UIDatePickerModeDateAndTime];
    }
    else if (pickerType == PickDateTimeActionSheetViewTypePickDateOnly) {
        [picker setDatePickerMode:UIDatePickerModeDate];
    }
    else if (pickerType == PickDateTimeActionSheetViewTypePickTimeOnly) {
        [picker setDatePickerMode:UIDatePickerModeTime];
    }
    [viewContainer addSubview:picker];
}

- (IBAction)btnAction:(UIButton*)sender {
    [self dismiss];
    if (sender.tag == PickDateTimeActionSheetView_Button_Yes) {
        if ([delegate respondsToSelector:@selector(pickDateTimeActionSheetView:didSelectedDateTime:)]) {
            selectedDate = picker.date;
            [delegate pickDateTimeActionSheetView:self didSelectedDateTime:selectedDate];
        }
    }
}


@end
