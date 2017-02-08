//
//  HealthTestSession.m
//  jiankangshouhuzhuanjia
//
//  Created by xuzeyu on 15/11/30.
//  Copyright © 2015年 Vescky. All rights reserved.
//

#import "HealthTestSession.h"
@interface HealthTestSession ()

@end

@implementation HealthTestSession
+ (HealthTestSession *)shareInstance {
    static HealthTestSession *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HealthTestSession alloc] init];
        instance.quest = [NSMutableArray array];
        instance.questOption = [NSMutableArray array];
        instance.selected = [NSMutableArray array];
        instance.nextQuestionIdArry = [NSMutableArray array];
        
    });
    return instance;
}

- (void)selectQuestOptionWithId:(NSString *)option_id {
    for (NSDictionary *dic in self.questOption) {
        if ([dic[@"question_id"] isEqualToString:self.next_quest_id] && [dic[@"option_id"] isEqualToString:option_id]) {
            [self.selected addObject:@{@"question_id":self.next_quest_id, @"option_id":option_id}];
            self.next_quest_id = dic[@"next_question_id"];
        }
    }
}

- (void)rollBack {
    NSDictionary *dic = self.selected.lastObject;
    if (dic) {
        self.next_quest_id = dic[@"question_id"];
        [self.selected removeLastObject];
    }
}

- (NSDictionary *)next {
    if (!self.next_quest_id) {
        return nil;
    }
    NSMutableArray *quest = [NSMutableArray array];
    NSMutableArray *option = [NSMutableArray array];
    for (NSMutableDictionary *dic in self.quest) {
        if ([dic[@"question_id"] isEqualToString:self.next_quest_id]) {
            [quest addObject:dic];
        }
    }
    
    for (NSMutableDictionary *dic in self.questOption) {
        if ([dic[@"question_id"] isEqualToString:self.next_quest_id]) {
            [option addObject:dic];
        }
    }
    
    //排序选项
    NSArray *arr;
    arr = [option sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (obj1[@"sort"] > obj2[@"sort"]) {
            return -1;
        }
        return 0;
    }];
    [option removeAllObjects];
    [option addObjectsFromArray:arr];
    return @{@"quest":quest, @"option":option};
}

- (void)clear {
    [self.quest removeAllObjects];
    [self.questOption removeAllObjects];
    [self.selected removeAllObjects];
    self.project_title = @"";
    self.project_id = @"";
    self.next_quest_id = @"";
    self.index = 0;
}

- (BOOL)isReady {
    if (self.quest.count > 0 && self.questOption.count >0) {
        return YES;
    }
    return NO;
}
@end
