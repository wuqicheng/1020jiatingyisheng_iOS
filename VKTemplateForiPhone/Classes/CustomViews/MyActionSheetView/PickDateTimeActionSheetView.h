//
//  PickDateTimeActionSheetView.h
//  aixiche
//
//  Created by Vescky on 14/11/24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"

@protocol PickDateTimeActionSheetViewDelegate;

@interface PickDateTimeActionSheetView : AppsBaseView {
    
}

typedef NS_ENUM(NSInteger, PickDateTimeActionSheetViewType) {
    PickDateTimeActionSheetViewTypeDefault = 0,//date and time
    PickDateTimeActionSheetViewTypePickDateOnly,//date only
    PickDateTimeActionSheetViewTypePickTimeOnly,//time only
};

@property (nonatomic,assign) id <PickDateTimeActionSheetViewDelegate> delegate;
@property (nonatomic,strong) NSDate *selectedDate;
@property (nonatomic,strong) UIDatePicker *picker;

- (instancetype)initWithTitle:(NSString*)pTitle pickerType:(PickDateTimeActionSheetViewType)pickerType;
- (void)show;
- (void)dismiss;

@end

@protocol PickDateTimeActionSheetViewDelegate <NSObject>

- (void)pickDateTimeActionSheetView:(PickDateTimeActionSheetView*)sheetView didSelectedDateTime:(NSDate*)sDate;

@end