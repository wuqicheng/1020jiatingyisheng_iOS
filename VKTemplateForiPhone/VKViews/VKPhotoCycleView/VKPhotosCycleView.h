//
//  VKPhotosCycleView.h
//  test
//
//  Created by vescky.luo on 14-9-9.
//  Copyright (c) 2014年 vescky.luo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPhotosCycleViewItem.h"

@class VKPhotosCycleView;

@protocol VKPhotosCycleViewDelegate <NSObject>

- (void)photosCycleView:(VKPhotosCycleView*)photoCycleView didSelectedItem:(VKPhotosCycleViewItem*)photoItem;

@end

@interface VKPhotosCycleView : UIView<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate> {
    
}

@property (nonatomic,strong) NSMutableArray *dataSource;//array filled with VKPhotosCycleViewItems
@property (nonatomic,assign) id <VKPhotosCycleViewDelegate> delegate;

@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,strong) UITableView *tbView;
@property (nonatomic,strong) UIPageControl *pageControl;

- (id)initWithFrame:(CGRect)frame data:(NSMutableArray*)data target:(id)target buttomMaskColor:(UIColor*)mColor;
- (void)setData:(NSMutableArray*)data target:(id)target buttomMaskColor:(UIColor*)mColor;

@end
