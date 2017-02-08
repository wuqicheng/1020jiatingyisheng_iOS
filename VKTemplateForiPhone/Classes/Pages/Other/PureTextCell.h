//
//  PureTextCell.h
//  aixiche
//
//  Created by Vescky on 14/11/14.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"
@interface PureTextCell : AppsBaseTableViewCell {
    IBOutlet UILabel *labelTitle;
    IBOutlet UIView *viewLine;
    
}

@property (nonatomic,strong) UILabel *labelTitle;

- (float)heigthForCell:(NSDictionary*)dic;

@end
