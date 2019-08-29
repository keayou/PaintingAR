//
//  OCRModel.m
//  ImageTest
//
//  Created by fk on 2017/6/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "OCRResultModel.h"


@implementation RectPoint


@end

@implementation OCRResultModel

- (instancetype)initWithDict:(NSArray  <NSValue *>*)list {
    
    self = [super init];
    if (self) {
        

        RectPoint *point = [RectPoint new];
        point.topLeft = list[0].CGPointValue;
        point.topRight = list[1].CGPointValue;
        point.bottomRight = list[2].CGPointValue;
        point.bottomLeft = list[3].CGPointValue;
        
        NSArray *xArray = @[@(point.topLeft.x),@(point.topRight.x),@(point.bottomRight.x),@(point.bottomLeft.x)];
        NSNumber *minX = [xArray valueForKeyPath:@"@min.floatValue"];
        NSNumber *maxX = [xArray valueForKeyPath:@"@max.floatValue"];
        
        NSArray *yArray = @[@(point.topLeft.y),@(point.topRight.y),@(point.bottomRight.y),@(point.bottomLeft.y)];
        NSNumber *minY = [yArray valueForKeyPath:@"@min.floatValue"];
        NSNumber *maxY = [yArray valueForKeyPath:@"@max.floatValue"];
        
        CGFloat width = maxX.floatValue - minX.floatValue;
        CGFloat height = maxY.floatValue - minY.floatValue;
        _externalFrame = CGRectMake(minX.floatValue, minY.floatValue, width, height);
        
        
        RectPoint *rePoint = [RectPoint new];
        rePoint.topLeft = CGPointMake(fabs(point.topLeft.x - minX.floatValue), fabs(point.topLeft.y - minY.floatValue));
        rePoint.topRight = CGPointMake(fabs(point.topRight.x - minX.floatValue), fabs(point.topRight.y - minY.floatValue));
        rePoint.bottomRight = CGPointMake(fabs(point.bottomRight.x - minX.floatValue),  fabs(point.bottomRight.y - minY.floatValue));
        rePoint.bottomLeft = CGPointMake(fabs(point.bottomLeft.x - minX.floatValue), fabs(point.bottomLeft.y - minY.floatValue));
        _rectPoint = rePoint;
    }
    
    return self;
}

+ (CGPoint)getPointFromString:(NSString *)string {
    NSArray *arr = [string componentsSeparatedByString:@","];
    return CGPointMake([arr[0] intValue], [arr[1] intValue]);
}

@end
