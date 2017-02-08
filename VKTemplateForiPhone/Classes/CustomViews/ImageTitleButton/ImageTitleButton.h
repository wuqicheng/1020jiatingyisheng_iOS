//
//  ImageTitleButton.h
//
//  目前只做一个样式的menu button，日后可以扩展
//  Created by vescky.luo on 14-9-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseView.h"

@interface ImageTitleButton : AppsBaseView {
    
}

//@property (nonatomic,strong) 

- (id)initWithFrame:(CGRect)frame Image:(UIImage*)image Title:(NSString*)sTitle;

- (void)addTarget:(id)_target action:(SEL)_action forControlEvents:(UIControlEvents)controlEvents;

@end
