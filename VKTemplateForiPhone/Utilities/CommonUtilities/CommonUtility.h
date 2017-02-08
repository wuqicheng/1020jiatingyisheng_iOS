//
//  CommonUtility.h
//  SandBayCinema
//
//  Created by Rayco on 12-11-1.
//  Copyright (c) 2012年 Apps123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"

#pragma mark - base
CG_INLINE NSString *toUTF8String(NSString* str) {
    NSData *responseData = [NSData dataWithBytes:[str UTF8String] length:str.length];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *resultStr = [[NSString alloc] initWithData:responseData encoding:enc];
    return resultStr;
}


//CG_INLINE BOOL isValueSet(id obj) {
//    if (!obj) {
//        return NO;
//    }
//    if ([obj isKindOfClass:NSClassFromString(@"NSArray")] || [obj isKindOfClass:NSClassFromString(@"NSMutableArray")]) {
//        if ([obj count] > 0) {
//            return YES;
//        }
//    }
//    else if ([obj isKindOfClass:NSClassFromString(@"NSDictionary")] || [obj isKindOfClass:NSClassFromString(@"NSMutableDictionary")]) {
//        if ([obj count] > 0) {
//            return YES;
//        }
//    }
//    else if ([obj isKindOfClass:NSClassFromString(@"NSString")]) {
//        if ([obj length] > 0) {
//            return YES;
//        }
//    }
//    return NO;
//}

//判断是否为整形：
CG_INLINE BOOL isInt(NSString *string) {
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：
CG_INLINE BOOL isFloat(NSString *string) {
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}


CG_INLINE BOOL isValidString(id obj) {
    if (!obj) {
        return NO;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSString")]) {
        if ([obj length] > 0) {
            return YES;
        }
    }
    return NO;
}

CG_INLINE BOOL isValidArray(id obj) {
    if (!obj) {
        return NO;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSArray")] || [obj isKindOfClass:NSClassFromString(@"NSMutableArray")]) {
        if ([obj count] > 0) {
            return YES;
        }
    }
    return NO;
}

CG_INLINE BOOL isValidDictionary(id obj) {
    if (!obj) {
        return NO;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSDictionary")] || [obj isKindOfClass:NSClassFromString(@"NSMutableDictionary")]) {
        if ([obj count] > 0) {
            return YES;
        }
    }
    return NO;
}

CG_INLINE NSString *getString(id obj) {
    return [NSString stringWithFormat:@"%@",obj];
}

CG_INLINE NSString *md5Encode(NSString *input)
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return [ret lowercaseString];
}



CG_INLINE NSString* getRandomStrings(int length) {
    if (length <= 0) {
        return @"0";
    }
    NSString *str = @"";
    for (int i = 0; i < length; i++) {
        int r = arc4random() % 10; //随机生成0-9 的数字
        str = [str stringByAppendingFormat:@"%d",r];
    }
    return str;
}

CG_INLINE NSString *getCachePath() {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

#pragma mark - image
//纠正图片的方向
CG_INLINE UIImage* adjustPhotoOrientation(UIImage  *aImage) {
    
    if (aImage == nil)
    {
        return nil;
    }
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = aImage.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
        {
            transform = CGAffineTransformIdentity;
            break;
        }
        case UIImageOrientationUpMirrored: //EXIF = 2
        {
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        }
        case UIImageOrientationDown: //EXIF = 3
        {
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        }
        case UIImageOrientationDownMirrored: //EXIF = 4
        {
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        }
        case UIImageOrientationLeftMirrored: //EXIF = 5
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        }
        case UIImageOrientationLeft: //EXIF = 6
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        }
        case UIImageOrientationRightMirrored: //EXIF = 7
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        }
        case UIImageOrientationRight: //EXIF = 8
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        }
        default:
        {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            break;
        }
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}


//保存压缩后的图像，更适合网络传输.返回Document路径
CG_INLINE NSString* saveAndResizeImage(UIImage *_image,NSString *_sName,float with) {
    with = with > _image.size.width ? _image.size.width : with;
    CGSize newSize = CGSizeMake(with, with * _image.size.height / _image.size.width);
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* tmpImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
    UIImage *newImage = tmpImage;//adjustPhotoOrientation(tmpImage);
    
    //保存新图片到Document
    NSData *data;
//    if (UIImagePNGRepresentation(newImage) == nil) {
//        data = UIImageJPEGRepresentation(newImage, 0.6);
//    } else {
//        data = UIImagePNGRepresentation(newImage);
//    }
    data = UIImageJPEGRepresentation(newImage, 0.8);
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString* imgSavePath = [getCachePath() stringByAppendingPathComponent:_sName];
    if ([fm fileExistsAtPath:imgSavePath]) {
        [fm removeItemAtPath:imgSavePath error:nil];
    }
    [fm createFileAtPath:imgSavePath contents:data attributes:nil];
    return imgSavePath;
}

CG_INLINE NSString *getTransformImageLink(NSString *originalLink,int percentage) {
    if (isValidString(originalLink)) {
        NSString *oldExt = [originalLink pathExtension];
        NSString *pString = @"";
        if (percentage == 25) {
            pString = @"025_025";
        }
        else if (percentage == 50) {
            pString = @"05_05";
        }
        else if (percentage == 75) {
            pString = @"075_075";
        }
        else if (percentage == 100) {
            return originalLink;
        }
        else {
            return nil;
        }
        NSString *newExt = [NSString stringWithFormat:@"%@.%@",pString,oldExt];
        NSString *newLink = [originalLink stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",oldExt] withString:newExt];
        return newLink;
    }
    
    return nil;
}

#pragma mark - others
/**
 * 计算两组经纬度坐标 之间的距离
 * params ：lat1 纬度1； lng1 经度1； lat2 纬度2； lng2 经度2； len_type （1:m or 2:km);
 * return m or km
 */
CG_INLINE double getDistance(double lat1, double lng1, double lat2, double lng2, double len_type)
{
    double EARTH_RADIUS=6378.137;
    double PI=3.1415926;
    double radLat1 = lat1 * PI / 180.0;
    double radLat2 = lat2 * PI / 180.0;
    double a = radLat1 - radLat2;
    double b = (lng1 * PI / 180.0) - (lng2 * PI / 180.0);
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    s = round(s * 1000);
    if (len_type > 1)
    {
        s /= 1000;
    }
    return round(s);
}

//string:lon,lat
CG_INLINE CLLocation* getGfLocation(NSString* location) {
    NSArray *arr = [location componentsSeparatedByString:@","];
    if ([arr count] >= 2) {
        double lon = [[arr objectAtIndex:0] doubleValue];
        double lat = [[arr objectAtIndex:1] doubleValue];
        return [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    return nil;
}


CG_INLINE NSString* getFormatedDistance(double dist) {
    NSString *resultString = @"";
    if (dist <= 100) {
        resultString = @"100米以内";
    }
    else if (dist <= 200) {
        resultString = @"200米以内";
    }
    else if (dist <= 500) {
        resultString = @"500米以内";
    }
    else if (dist <= 1000) {
        resultString = @"1000米以内";
    }
    else if (dist <= 2000) {
        resultString = @"2000米以内";
    }
    else if (dist <= 5000) {
        resultString = @"5000米以内";
    }
    else if (dist <= 10000) {
        resultString = @"10km以内";
    }
    else {
        resultString = @"大于10km";
    }
    
    return resultString;
}

CG_INLINE NSString *removeHtmlTags(NSString *html) {
    @try {
        html = [html stringByReplacingOccurrencesOfRegex:@"<.+?>" withString:@""];
        html = [html stringByReplacingOccurrencesOfRegex:@"(?<=>)" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@" " withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        NSError *error = nil;
        NSMutableString *dest = [NSMutableString stringWithCapacity:0];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<.+?>(.+?)</.+?>" options:NSRegularExpressionCaseInsensitive error:&error]; //<.+?>(.+?)</.+?>
        NSRegularExpression *regex2 = [[NSRegularExpression alloc] initWithPattern:@"(?<=>).*?(?=</.+?>)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:html options:0 range:NSMakeRange(0, [html length])];
        
        if (numberOfMatches != 0) {
            [dest appendString:html];
            [regex enumerateMatchesInString:html options:0 range:NSMakeRange(0, [html length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *resultString = [html substringWithRange:[result range]];
                NSString *link = [resultString substringWithRange:[[regex2 firstMatchInString:resultString options:0 range:NSMakeRange(0, [resultString length])] range]];
                [dest replaceCharactersInRange:[result range] withString:link];
            }
             ];
            
            return [dest stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        }
        else {
            return [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return html;
}

CG_INLINE UIColor *GetColorWithRGB(float r,float g,float b) {
    return [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1.0];
}

//CG_INLINE UIColor *getHexColor(NSString *hexColor) {
//    if(!hexColor || [hexColor isEqualToString:@""] || [hexColor length] < 7){
//        if (hexColor.length != 4) {
//            return [UIColor whiteColor];
//        }
//    }
//    
//    if (hexColor.length == 4) {
//        hexColor = [NSString stringWithFormat:@"#%c%c%c%c%c%c",[hexColor characterAtIndex:1],[hexColor characterAtIndex:1],[hexColor characterAtIndex:2],[hexColor characterAtIndex:2],[hexColor characterAtIndex:3],[hexColor characterAtIndex:3]];
//    }
//    
//    unsigned int red,green,blue;
//    NSRange range;
//    range.length = 2;
//    
//    range.location = 1;
//    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
//    
//    range.location = 3;
//    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
//    
//    range.location = 5;
//    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
//    
//    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
//}

CG_INLINE UIColor *getHexColor(NSString *hex) {
    
    /*
     source: http://stackoverflow.com/questions/3805177/how-to-convert-hex-rgb-color-codes-to-uicolor
     */
    
    NSString *cleanString = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


CG_INLINE BOOL isMobileNumber(NSString *mobileNum)
{
    
    NSString * MOBILE_ALL = @"^1\\d{10}$";
    NSPredicate *regextestmobileAll = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE_ALL];
    return [regextestmobileAll evaluateWithObject:mobileNum];
}


CG_INLINE NSString* URLEncodedString(NSString *urlString)
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)urlString,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            NULL,
                                            kCFStringEncodingUTF8));
    return encodedString;
}

CG_INLINE NSString* getShortDateTimeForShow(NSString *dateTimeString) {
    if (isValidString(dateTimeString) && dateTimeString.length > 3) {
        return [dateTimeString substringToIndex:dateTimeString.length-3];
    }
    
    return dateTimeString;
}

CG_INLINE NSString* getDateStringByCuttingTime(NSString* dString) {
    if (!isValidString(dString)) {
        return nil;
    }
    NSArray *arr = [dString componentsSeparatedByString:@" "];
    return [arr firstObject];
}

#pragma mark - About System
CG_INLINE BOOL iPhone5() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.height > 960 : NO);
}

///用此方法代替iPhone5()
CG_INLINE BOOL isBigScreen() {
    return ([[UIScreen mainScreen] bounds].size.height > 480);
}

CG_INLINE BOOL ios7OrLater() {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? YES : NO;
}

CG_INLINE BOOL ios8OrLater() {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) ? YES : NO;
}

CG_INLINE NSString *GetDocumentPath() {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

CG_INLINE NSString *getTmpPath() {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

CG_INLINE NSString *GetMainBundlePath() {
    return [[NSBundle mainBundle] bundlePath];
}

CG_INLINE AppDelegate* app_delegate() {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

///是否允许远程推送
CG_INLINE bool isRemoteNotificationOn() {
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone;
}

#pragma mark - About Frame
/*
 *   About Size
 */
///获取内容的size，
CG_INLINE CGSize getTextSizeForLabel(NSString *textString,UILabel *label,CGFloat maxWidth,CGFloat maxHeight) {
    CGSize cSize;
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:label.font,NSFontAttributeName, nil];
    cSize = [textString boundingRectWithSize:CGSizeMake(maxWidth, maxHeight) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    cSize.height = (int)(cSize.height / label.frame.size.height + 1) * label.frame.size.height;
    return cSize;
}

CG_INLINE CGFloat fitLabelHeight(UILabel *label,NSString *contentString) {
    label.numberOfLines = 0;
//    CGSize size = [label sizeThatFits:CGSizeMake(label.frame.size.width, 0)];
//    CGSize size = [contentString sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, MAXFLOAT) lineBreakMode:1];
    CGRect rct = label.frame;
    rct.size.height = getTextSizeForLabel(contentString,label,rct.size.width,MAXFLOAT).height;
    label.frame = rct;
    
    return label.frame.size.height;
}

CG_INLINE CGFloat fitLabelWidth(UILabel *label,NSString *contentString) {
    label.numberOfLines = 0;
    CGRect rct = label.frame;
    rct.size.height = getTextSizeForLabel(contentString,label,MAXFLOAT,rct.size.height).width;
    label.frame = rct;
    
    return label.frame.size.width;
}

CG_INLINE CGSize fitLabelSize(UILabel *label,NSString *contentString,CGSize maxSize) {
    label.numberOfLines = 0;
    CGRect rct = label.frame;
    rct.size = getTextSizeForLabel(contentString,label,maxSize.width,rct.size.height);
    label.frame = rct;
    
    return label.frame.size;
}

CG_INLINE void setViewFrameOriginX(UIView *v ,float x) {
    CGRect frame = v.frame;
    frame.origin.x = x;
    v.frame = frame;
}

CG_INLINE void setViewFrameOriginY(UIView *v ,float y) {
    CGRect frame = v.frame;
    frame.origin.y = y;
    v.frame = frame;
}

CG_INLINE void setViewFrameSizeWidth(UIView *v ,float w) {
    CGRect frame = v.frame;
    frame.size.width = w;
    v.frame = frame;
}

CG_INLINE void setViewFrameSizeHeight(UIView *v ,float h) {
    CGRect frame = v.frame;
    frame.size.height = h;
    v.frame = frame;
}


CG_INLINE UIView* getStarRateBar(NSInteger rate) {
    CGFloat margin = 5.f,starWH = 15.f;
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (starWH + margin)*5, starWH+2*margin)];
    barView.backgroundColor = [UIColor clearColor];
    
    for (NSInteger i = 0; i < 5; i++) {
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake((i+1)*margin+i*starWH, margin, starWH, starWH)];
        [imgv setClipsToBounds:YES];
        [imgv setImage:[UIImage imageNamed:(i<=rate ? @"star-on.png" : @"star-off.png")]];
        [barView addSubview:imgv];
    }
    
    
    return barView;
}


CG_INLINE void removeAllSubViews(UIView *v) {
    for (NSInteger i = 0; i < v.subviews.count; i++) {
        UIView *viewTmp = [v.subviews objectAtIndex:i];
        [viewTmp removeFromSuperview];
    }
}

//判断字符串高度或者长度
CG_INLINE CGFloat getTextHeight(NSString *text, UIFont *font, CGFloat width)
{
    //判断判断，如果大于7.0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
        return ceilf(rect.size.height);
    }
    else
    {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 10000)];
        return ceilf(size.height);
    }

}

CG_INLINE CGFloat getTextWidth(NSString *text, UIFont *font) {
    //判断判断，如果大于7.0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(10000, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
        return ceilf(rect.size.width);
    }
    else
    {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(10000, 10000)];
        return ceilf(size.width);
    }
}

