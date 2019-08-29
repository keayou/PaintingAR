//
//  OCRResultModel.h
//  ImageTest
//
//  Created by fk on 2017/6/27.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RectPoint : NSObject


@property (nonatomic, assign) CGPoint topLeft;
@property (nonatomic, assign) CGPoint topRight;
@property (nonatomic, assign) CGPoint bottomRight;
@property (nonatomic, assign) CGPoint bottomLeft;


@end


@interface OCRResultModel : NSObject


@property (nonatomic, assign, readonly) BOOL isOnLineResult;  //OCR结果是否来自线上服务（因线上和本地返回结果类型不一致，所有需做区分）


#pragma mark - 共有属性
//@property (nonatomic, strong) NSString *content;
//@property (nonatomic, strong) UIColor *textColor;
//
//
//@property (nonatomic, strong) NSString *translatedStr;


@property (nonatomic, strong) RectPoint *rectPoint;  //透视区域相对外框的4个点位置
@property (nonatomic, assign) CGRect externalFrame;  //外框frame



#pragma mark - 在线服务
@property (nonatomic, strong) NSString *background;
- (instancetype)initWithDict:(NSArray <NSValue *>*)list;


@end
