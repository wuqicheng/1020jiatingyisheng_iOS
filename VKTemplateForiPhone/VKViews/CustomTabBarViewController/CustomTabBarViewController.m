//
//  CustomTabBarViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-4.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CustomTabBarViewController.h"


#define TabBarItemTag 88888
#define TabBarTextTag 99999

@implementation CustomTabBarViewController

@synthesize currentSelectedIndex;
@synthesize buttons;
@synthesize selectedImages,unselectedImages,titles;
@synthesize isBarHidden,customTabBarView,backgroundImage;

- (void)viewDidAppear:(BOOL)animated{
    [self hideRealTabBar];
    [self customTabBar];
}

- (void)hideRealTabBar{
    for(UIView *view in self.view.subviews){
        if([view isKindOfClass:[UITabBar class]]){
            view.hidden = YES;
            break;
        }
    }
}

- (void)customTabBar{
    //创建自定义的tabbar view
    customTabBarView = [[UIView alloc] initWithFrame:self.tabBar.frame];
    customTabBarView.backgroundColor = [UIColor whiteColor];
    customTabBarView.layer.borderColor = GetColorWithRGB(229.0f, 229.0f, 229.0f).CGColor;
    customTabBarView.layer.borderWidth = 1.0f;
    
    //创建按钮
    int viewCount = self.viewControllers.count > 5 ? 5 : self.viewControllers.count;
    self.buttons = [NSMutableArray arrayWithCapacity:viewCount];
    double _width = 320 / viewCount;
    double _height = self.tabBar.frame.size.height;
    for (int i = 0; i < viewCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (selectedImages && i < [selectedImages count]) {
            [btn setImage:[UIImage imageNamed:[selectedImages objectAtIndex:i]] forState:UIControlStateNormal];
        }
        if (unselectedImages && i < [unselectedImages count]) {
            [btn setImage:[UIImage imageNamed:[unselectedImages objectAtIndex:i]] forState:UIControlStateSelected];
        }
        btn.frame = CGRectMake(i*_width + 5, -5, _width, _height);
        [btn addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = TabBarItemTag + i;
        
        if (i < [titles count]) {
            NSString *vcTitle = [titles objectAtIndex:i];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*_width + 4, customTabBarView.frame.size.height - 18, _width, 20)];
            label.textAlignment = 1;
            label.text = vcTitle;
            label.textColor = GetColorWithRGB(255, 255, 255);
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:12.0];
            label.tag = TabBarTextTag + i;
            [customTabBarView addSubview:label];
        }
        
        [self.buttons addObject:btn];
        [customTabBarView addSubview:btn];
    }
    customTabBarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    if (backgroundImage) {
        UIImageView *imgvBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, customTabBarView.frame.size.width, customTabBarView.frame.size.height)];
        [imgvBackground setImage:backgroundImage];
        [customTabBarView addSubview:imgvBackground];
        [customTabBarView sendSubviewToBack:imgvBackground];
    }
    
    [self selectedTab:[self.buttons objectAtIndex:0]];
    [self.view addSubview:customTabBarView];
    //for test
//    customTabBarView.backgroundColor = [UIColor redColor];
//    self.view.backgroundColor = [UIColor greenColor];
}

- (void)selectedTab:(UIButton *)button{
    
    if (self.currentSelectedIndex == button.tag) {
        return;
    }
    
    int lastButtonSelectedIndex = self.currentSelectedIndex;
    int lastLabelSelectedIndex = lastButtonSelectedIndex + TabBarTextTag - TabBarItemTag;
    int currentButtonSelectedIndex = button.tag;
    int currentLabelSelectedIndex = currentButtonSelectedIndex + TabBarTextTag - TabBarItemTag;
    
    button.selected = YES;
    UIButton *lastButton = (UIButton*)[customTabBarView viewWithTag:lastButtonSelectedIndex];
    if ([lastButton isKindOfClass:[UIButton class]]) {
        lastButton.selected = NO;
    }
    
    UILabel *label = (UILabel*)[customTabBarView viewWithTag:currentLabelSelectedIndex];
    if ([label isKindOfClass:[UILabel class]]) {
        label.textColor = GetColorWithRGB(0, 0, 0);
    }
    
    UILabel *lastLabel = (UILabel*)[customTabBarView viewWithTag:lastLabelSelectedIndex];
    if ([lastLabel isKindOfClass:[UILabel class]]) {
        lastLabel.textColor = GetColorWithRGB(255, 255, 255);
    }
    
    self.currentSelectedIndex = currentButtonSelectedIndex;
    self.selectedIndex = currentButtonSelectedIndex - TabBarItemTag;
}


- (void)setCustomTabBarHidden:(bool)isHidden animated:(bool)animated {
    isBarHidden = isHidden;
    customTabBarView.hidden = isHidden;
}

@end