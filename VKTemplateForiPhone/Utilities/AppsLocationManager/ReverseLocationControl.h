//
//  ReverseLocationControl.h
//
//  逆向地理编码
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@protocol ReverseLocationControlDelegate;

@interface ReverseLocationControl : NSObject<AMapSearchDelegate>{
    NSString *cityString;
    AMapSearchAPI *search;
}
@property (nonatomic,assign) id<ReverseLocationControlDelegate> delegate;
- (void)reverLocation;
@end

@protocol ReverseLocationControlDelegate <NSObject>

- (void)reverseLocationStringSuccess:(NSString *)location;

@end