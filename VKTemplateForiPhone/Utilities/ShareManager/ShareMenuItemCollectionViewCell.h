//
//  ShareMenuItemCollectionViewCell.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/6/26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareMenuItemCollectionViewCell : UICollectionViewCell {
    IBOutlet UIImageView *imgv;
    IBOutlet UILabel *labelTitle;
}

@property (nonatomic,strong) UIImage *img;
@property (nonatomic,strong) NSString *title;

@end
