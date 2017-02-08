//
//  HeathyProjectChartViewController.m
//  VKTemplateForiPhone
//
//  Created by vescky.luo on 15/5/22.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "HeathyProjectChartViewController.h"
#import "UserSessionCenter.h"

#define Chart_Line_Width 1.f
#define Chart_Unit_Height 25.f
#define Chart_Unit_Width 22.f

@interface HeathyProjectChartViewController () {
    NSMutableArray *dataSource;
}

@end

@implementation HeathyProjectChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"计划完成统计";
    [self customBackButton];
    scView.contentSize = CGSizeMake(scView.frame.size.width, 480.f);
    
    //表格横线
    for (int i = 0; i < 10; i++) {
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, i*Chart_Unit_Height, coordinatesView.frame.size.width, 1.f)];
        lineView.backgroundColor = GetColorWithRGB(240, 240, 240);
        [coordinatesView addSubview:lineView];
    }
    [coordinatesView bringSubviewToFront:coordinatesDataView];
    
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [SVProgressHUD showWithStatus:String_Loading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[UserSessionCenter shareSession] getUserId],@"user_id",@1,@"status", nil];
    [[AppsNetWorkEngine shareEngine] submitRequest:@"getHealthPlanCurveListByAdmin.action" param:params onCompletion:^(id jsonResponse) {
        [SVProgressHUD dismiss];
        
        labelDate.text = [NSString stringWithFormat:@"%@/%@",getDateStringByCuttingTime([jsonResponse objectForKey:@"start_time"]),getDateStringByCuttingTime([jsonResponse objectForKey:@"end_time"])];
        
        [self updateCahrtViewWithData:[self parseData:jsonResponse]];
        
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
    } defaultErrorAlert:YES isCacheNeeded:NO method:nil];
}

- (NSArray*)parseData:(NSDictionary*)info {
    NSArray *arr1 = [info objectForKey:@"yiliao"];
    NSArray *arr2 = [info objectForKey:@"yingyang"];
    NSArray *arr3 = [info objectForKey:@"yundong"];
    NSArray *arr4 = [info objectForKey:@"kangfu"];
    
    if (!arr1 || !arr2 || !arr3 || !arr4) {
        return nil;
    }
    
    NSArray *data = @[arr1,arr2,arr3,arr4];
    
    return data;
}

- (void)updateCahrtViewWithData:(NSArray*)datas {
//    //test data
//    NSMutableArray *datas = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 4; i++) {
//        NSMutableArray *gArr = [[NSMutableArray alloc] init];
//        for (int j = 0; j < 52; j++) {
//            NSInteger r = ((arc4random() % 10) + 0)*10;
//            [gArr addObject:@(r)];
//        }
//        
//        [datas addObject:gArr];
//    }
//    
    NSInteger colCount = [[datas firstObject] count];

    //resize chartView.contentSize
    coordinatesDataView.contentSize = CGSizeMake(colCount*Chart_Unit_Width, coordinatesDataView.frame.size.height);
    
    UIColor *textColor = GetColorWithRGB(150, 150, 150);
    
    //加入横线-Y轴
    for (int i = 0; i < 10; i++) {
        //Y轴
        UILabel *labelY =[[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, 25.f, 20.f)];
        labelY.center = CGPointMake(labelY.center.x, i*Chart_Unit_Height+38.f);
        labelY.textAlignment = NSTextAlignmentRight;
        labelY.font = [UIFont systemFontOfSize:12.f];
        labelY.textColor = textColor;
        labelY.text = [NSString stringWithFormat:@"%d",(10-i)*10];
        [chartView addSubview:labelY];
    }
    
    //加入X轴
    for (int i = 0; i < colCount; i++) {
        UILabel *labelX = [[UILabel alloc] initWithFrame:CGRectMake(i*Chart_Unit_Width, coordinatesDataView.frame.size.height-Chart_Unit_Width, Chart_Unit_Width, Chart_Unit_Width)];
        labelX.text = [NSString stringWithFormat:@"%@",@(i+1)];
        labelX.font = [UIFont systemFontOfSize:12.f];
        labelX.textColor = textColor;
        [coordinatesDataView addSubview:labelX];
    }
    
    //划线
    NSArray *colors = @[GetColorWithRGB(255, 82, 75),GetColorWithRGB(117, 228, 103),GetColorWithRGB(255, 153, 0),GetColorWithRGB(50, 208, 221)];
    NSArray *pointImgs = @[[UIImage imageNamed:@"project_chart_point_red.png"],[UIImage imageNamed:@"project_chart_point_green.png"],[UIImage imageNamed:@"project_chart_point_orange.png"],[UIImage imageNamed:@"project_chart_point_blue.png"]];
    for (int i = 0; i < datas.count; i++) {
        NSArray *itemData = [datas objectAtIndex:i];
        [self drawLineWithData:itemData lineColor:[colors objectAtIndex:i] pointImage:[pointImgs objectAtIndex:i]];
    }
}


- (void)drawLineWithData:(NSArray*)data lineColor:(UIColor*)lineColor pointImage:(UIImage*)pointImg {
    
    UIGraphicsBeginImageContext(coordinatesDataView.contentSize);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = 1.f;
    
    CAShapeLayer *layer = [self _layerWithPath:path];
    
    layer.strokeColor = [lineColor CGColor];
    
    [coordinatesDataView.layer addSublayer:layer];
    
    NSInteger idx = 0;
    for (id item in data) {
        NSLog(@"== %@ ==",item);
        CGFloat x = idx*Chart_Unit_Width+2;
        CGFloat y = (100-[item  integerValue])*(Chart_Unit_Height/10.f);
        CGPoint point = CGPointMake(x, y);
        
        if (idx != 0) [path addLineToPoint:point];
        [path moveToPoint:point];
        
        idx++;
        
        //point image
        UIImageView *imgvPoint = [[UIImageView alloc] initWithImage:pointImg];
        imgvPoint.center = point;
        [coordinatesDataView addSubview:imgvPoint];
    }
    
    layer.path = path.CGPath;
    
    UIGraphicsEndImageContext();
}

- (CAShapeLayer *)_layerWithPath:(UIBezierPath *)path {
    CAShapeLayer *item = [CAShapeLayer layer];
    item.fillColor = [[UIColor blackColor] CGColor];
    item.lineCap = kCALineCapRound;
    item.lineJoin  = kCALineJoinRound;
    item.lineWidth = Chart_Line_Width;
    //    item.strokeColor = [self.foregroundColor CGColor];
    item.strokeColor = [[UIColor redColor] CGColor];
    item.strokeEnd = 1;
    return item;
}



@end
