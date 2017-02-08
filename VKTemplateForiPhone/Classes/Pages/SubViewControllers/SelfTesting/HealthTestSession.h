//
//  HealthTestSession.h
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/11/30.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthTestSession : NSObject
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSString *project_id;
@property (nonatomic, strong) NSString *project_title;
@property (nonatomic, strong) NSString *next_quest_id;
@property (nonatomic, strong) NSString *bgimage;

@property (nonatomic, strong) NSMutableArray *quest;
@property (nonatomic, strong) NSMutableArray *questOption;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *selected;
@property (nonatomic, strong) NSMutableArray *nextQuestionIdArry;
+ (HealthTestSession *)shareInstance;


- (void)selectQuestOptionWithId:(NSString *)option_id;

- (void)rollBack;
- (NSDictionary *)next;
- (void)clear;
@end
