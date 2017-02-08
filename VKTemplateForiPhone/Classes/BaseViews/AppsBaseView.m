//
//  AppsBaseView.m
//  NanShaZhiChuang
//
//  Created by vescky.luo on 14-9-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "AppsBaseView.h"

@implementation AppsBaseView

//快速获取一些值
- (float)viewOriginX {
    return self.frame.origin.x;
}
- (float)viewOriginY {
    return self.frame.origin.y;
}
- (float)viewHeight {
    return self.frame.size.height;
}
- (float)viewWidth {
    return self.frame.size.width;
}


@end
