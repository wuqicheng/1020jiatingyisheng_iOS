//
//  MyActionSheetView.h
//  aixiche
//
//  Created by Vescky on 14-11-8.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"

@protocol MyActionSheetViewDelegate;

@interface MyActionSheetView : AppsBaseView {
    
}

@property (nonatomic,assign) id <MyActionSheetViewDelegate> delegate;

- (instancetype)initWithTitles:(NSArray*)titlesArray cancelButtonTitle:(NSString*)cancelButtonTitle;
- (instancetype)initWithPhotoSelectorStyle;
- (void)show;
- (void)dismiss;

@end

@protocol MyActionSheetViewDelegate <NSObject>

- (void)btnDidClick:(int)buttonIndex;

@end