//
//  RectangleDetector.h
//  PaintingAR
//
//  Created by fk on 2019/6/25.
//  Copyright © 2019 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RectangleDetectorDelegate <NSObject>

- (void)didDetecteRectangle:(NSArray <NSValue *>*)pointList trackingImage:(CIImage *)trackingImage;


@end

@interface RectangleDetector : NSObject

@property (nonatomic, weak) id<RectangleDetectorDelegate>delegate;

@property (nonatomic, weak) ARSession *arSession;

@property (nonatomic, assign, readonly) CGRect ratio;

@property (nonatomic, assign) CGSize previewSize;

- (instancetype)initWithImage:(UIImage *)uiImage;
- (void)searchRectangleInPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

NS_ASSUME_NONNULL_END
