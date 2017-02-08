//
//  RelationShipCell.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/25.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppsBaseTableViewCell.h"

@protocol RelationShipCellDelegate;
@interface RelationShipCell : AppsBaseTableViewCell {
    IBOutlet UIImageView *imgvAvatar;
    IBOutlet UILabel *labelName;
    IBOutlet UIButton *btn;
}

@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,assign) id <RelationShipCellDelegate> delegate;

- (IBAction)btnAction:(UIButton*)sender;

@end


@protocol RelationShipCellDelegate <NSObject>

//- (void)relationShipCell:(RelationShipCell*)cell buttonDidClick:(UIButton*)sender;
- (void)relationShipCell:(RelationShipCell*)cell buttonDidClickAtIndexPath:(NSIndexPath*)indexPath;

@end