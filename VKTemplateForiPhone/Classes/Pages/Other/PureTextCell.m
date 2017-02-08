//
//  PureTextCell.m
//  aixiche
//
//  Created by Vescky on 14/11/14.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "PureTextCell.h"

@implementation PureTextCell
@synthesize labelTitle;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellDataInfo:(NSDictionary *)dataInfo {
    [super setCellDataInfo:dataInfo];
    
    if (isValidString([dataInfo objectForKey:@"title"])) {
        labelTitle.numberOfLines = 0;
        setViewFrameSizeHeight(labelTitle, 20.f);//恢复一下
        labelTitle.text = [dataInfo objectForKey:@"title"];
        fitLabelHeight(labelTitle,[dataInfo objectForKey:@"title"]);
        setViewFrameSizeHeight(self, labelTitle.frame.size.height + 2*labelTitle.frame.origin.y);
    }
    if ([[dataInfo objectForKey:@"textColor"] isKindOfClass:NSClassFromString(@"UIColor")]) {
        labelTitle.textColor = [dataInfo objectForKey:@"textColor"];
    }
    if ([[dataInfo objectForKey:@"font"] isKindOfClass:NSClassFromString(@"UIFont")]) {
        labelTitle.font = [dataInfo objectForKey:@"font"];
    }
    if ([dataInfo objectForKey:@"textAlignment"]) {
        labelTitle.textAlignment = [[dataInfo objectForKey:@"textAlignment"] integerValue];
    } 
    if ([[dataInfo objectForKey:@"separatorColor"] isKindOfClass:NSClassFromString(@"UIColor")]) {
        viewLine.backgroundColor = [dataInfo objectForKey:@"separatorColor"] ;
    }
    
    
}

- (float)heigthForCell:(NSDictionary*)dic {
    [self setCellDataInfo:dic];
    return self.frame.size.height;
}


@end
