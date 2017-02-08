//
//  MedicalReportPhotoCell.h
//  jiankangshouhuzhuanjia
//
//  Created by vescky.luo on 15/5/24.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MedicalReportPhotoCellDelegate;
@interface MedicalReportPhotoCell : UICollectionViewCell {
    IBOutlet UIImageView *imgvDelete;
    IBOutlet UIButton *btnDelete;
}

@property (nonatomic,weak) IBOutlet UIImageView *imgvMain;
@property (nonatomic,strong) UIImage *mainImage;
@property (nonatomic,strong) NSString *mainImageLink;
@property (nonatomic,assign) id <MedicalReportPhotoCellDelegate> delegate;

- (IBAction)btnAction:(UIButton*)sender;

- (void)setupWithImage:(UIImage*)img;

@end


@protocol MedicalReportPhotoCellDelegate <NSObject>

- (void)medicalReportPhotoCellDidDeleteImage:(MedicalReportPhotoCell*)mCell;

@end