//
//  SearchTextField.m
//  UGift
//
//  Created by xuzeyu on 15/8/13.
//  Copyright (c) 2015年 Joe.x. All rights reserved.
//

#import "SearchTextField.h"
#import "PopoverView.h"
@implementation SearchTextField

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        leftImgView.contentMode = UIViewContentModeScaleAspectFit;
        leftImgView.image = [UIImage imageNamed:@"title_search.png"];
        self.leftView = leftImgView;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.borderStyle = UITextBorderStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"Helvetica" size:15];
        self.textColor = _Color_(100, 100, 100, 1.0f);
    }
    return self;
}



-(CGRect) leftViewRectForBounds:(CGRect)bounds
{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 5;// 右偏10
    return iconRect;
}



- (CGRect)editingRectForBounds:(CGRect)bounds{
    CGRect editingRect = [super editingRectForBounds:bounds];
    editingRect.origin.x+= 5;// 右偏10
    return editingRect;
}



- (CGRect)textRectForBounds:(CGRect)bounds{
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x+=5;// 右偏10
    return textRect;
}

@end
