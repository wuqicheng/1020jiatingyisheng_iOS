//
//  AutodiagnosisCell.m
//  jiankangshouhuzhuanjia
//
//  Created by 三牛犇科技 on 16/8/24.
//  Copyright © 2016年 Vescky. All rights reserved.
//

#import "AutodiagnosisCell.h"

@implementation AutodiagnosisCell

-(id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        NSArray *arrCell = [[NSBundle mainBundle]loadNibNamed:@"AutodiagnosisCell" owner:self options:nil];
        if (arrCell.count<1)
        {
            return nil;
        }
        if (![[arrCell objectAtIndex:0]isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        self = [arrCell objectAtIndex:0];
    }
    
    return self;
}

@end