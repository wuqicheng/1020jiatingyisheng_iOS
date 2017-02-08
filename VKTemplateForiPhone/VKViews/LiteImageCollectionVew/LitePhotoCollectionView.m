//
//  LitePhotoCollectionView.m
//  GolfFriend
//
//  Created by Vescky on 13-12-4.
//  Copyright (c) 2013年 vescky.org. All rights reserved.
//

#import "LitePhotoCollectionView.h"
#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface LitePhotoCollectionView ()<MJPhotoBrowserDelegate>

@end

@implementation LitePhotoCollectionView
@synthesize photoCollection,coverCollection,delegate,margin,scaleHDW,viewWidth,colCount,bgColor;
@synthesize onlyResponsToDelegateMenthod,identifyString,marginToBounce;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView {
    [self cleanAllSubviews];
    [self initData];
    [self initView];
}

- (void)initData {
    if (!photoCollection || [photoCollection count] < 1) {
        return;
    }
    if (!margin) {
        margin = 10;
    }
    if (!viewWidth) {
        viewWidth = 320.0;
    }
    if (!colCount) {
        colCount = 3;
    }
    
    if (scaleHDW <= 0) {
        scaleHDW = 1.0;
    }
    
    if (!bgColor) {
        bgColor = [UIColor clearColor];
    }
}

- (void)initView {
    
    [self.view setClipsToBounds:YES];
    
    float contentWidth = viewWidth - 2 * margin;
    
    int photosCount = [photoCollection count];//图片的数量
    int rowCount = photosCount / colCount;//数量 / 列数 = 行数
    float imgUnitWith = (contentWidth - (colCount + 1) * marginToBounce) / colCount * 1.0; //(总宽度 - 所有列margin宽总和) / 列数 = 单个图片的宽
    float imgUnitHeight = imgUnitWith * scaleHDW;//宽与高相等
    CGFloat startX = marginToBounce;//(self.view.frame.size.width - 3 * imgUnitWith - 2 * margin) * 0.5;
    CGFloat startY = marginToBounce;
    
    CGRect rect = self.view.frame;
    rect.size.width = contentWidth;
    rect.size.height = imgUnitHeight * colCount + (colCount + 1) * margin;
    [self.view setFrame:rect];
    [self.view setBackgroundColor:bgColor];
  
    UIImage *placeholder = Defualt_Loading_Image;
    for (int i = 0; i < photosCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        
        // 计算位置
        int row = i/colCount;
        int column = i%colCount;
        CGFloat x = startX + column * (imgUnitWith + margin);
        CGFloat y = startY + row * (imgUnitHeight + margin);
        imageView.frame = CGRectMake(x, y, imgUnitWith, imgUnitHeight);
        
        // 下载图片
        NSString *skImageName = [photoCollection objectAtIndex:i];
        if (!isValidString(skImageName)) {
            continue;
        }
        skImageName = getTransformImageLink(skImageName, 25);
        if ([skImageName stringByMatching:@"http://"]) {
            [imageView setImageURLStr:skImageName placeholder:placeholder];
        }
        else if([skImageName stringByMatching:@"assets-library:"]) {
            //本地图片
            ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
            NSURL *url=[NSURL URLWithString:skImageName];
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
                UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
                [imageView setImage:image];
            }failureBlock:^(NSError *error) {
                NSLog(@"error=%@",error);
            }
             ];
        }
        else {
            [imageView setImageURLStr:skImageName placeholder:placeholder];
        }
        
        // 事件监听
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        
        // 内容模式
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    }/**/
    
}

- (void)cleanAllSubviews {
    self.view = nil;
    self.view = [[UIView alloc] init];
}


- (void)tapImage:(UITapGestureRecognizer *)tap
{
    if ([delegate respondsToSelector:@selector(imageDidTapped:)]) {
        [delegate imageDidTapped:tap.view.tag];
        if (onlyResponsToDelegateMenthod) {
            //只响应delegate方法
            return;
        }
    }
    if ([delegate respondsToSelector:@selector(imageDidTapped:identifyString:)]) {
        [delegate imageDidTapped:tap.view.tag identifyString:identifyString];
        if (onlyResponsToDelegateMenthod) {
            //只响应delegate方法
            return;
        }
    }
    int count = photoCollection.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [photoCollection[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        photo.srcImageView = self.view.subviews[i]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    browser.delegate = self;
    [browser show];
}

- (float)getViewHeight {
    int pCount = [photoCollection count] - 1;
    int rowCount = pCount / colCount + 1;
    float imgUnitHeight = (viewWidth + 2 * margin - (colCount + 1) * margin) / colCount * 1.0;
    return rowCount * imgUnitHeight + (rowCount+1)*margin;
}


@end
