//
//  MedicalReportPhotoCell.m
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MedicalReportPhotoCell.h"

@implementation MedicalReportPhotoCell
@synthesize mainImage = _mainImage,mainImageLink,imgvMain;

- (void)setupWithImage:(UIImage*)img {
    if (img) {
        [imgvMain setImage:img];
        btnDelete.hidden = NO;
        imgvDelete.hidden = NO;
    }
    else {
        imgvDelete.hidden = YES;
        btnDelete.hidden = YES;
        [imgvMain setImage:[UIImage imageNamed:@"mr_icon_add.png"]];
    }
}

- (IBAction)btnAction:(UIButton*)sender {
    [self setupWithImage:nil];
    mainImageLink = nil;
    if ([self.delegate respondsToSelector:@selector(medicalReportPhotoCellDidDeleteImage:)]) {
        [self.delegate medicalReportPhotoCellDidDeleteImage:self];
    }
}

- (void)setMainImage:(UIImage *)mainImage {
    _mainImage = mainImage;
    [self setupWithImage:mainImage];
}

@end
