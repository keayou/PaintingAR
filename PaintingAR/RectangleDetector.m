//
//  RectangleDetector.m
//  PaintingAR
//
//  Created by fk on 2019/6/25.
//  Copyright © 2019 fk. All rights reserved.
//

#import "RectangleDetector.h"
#import <Vision/Vision.h>

#import "Utilities.h"

@interface RectangleDetector ()

@property (nonatomic, assign) BOOL isBusy;

@property (nonatomic, strong) VNDetectRectanglesRequest *rectRequest;

@property (nonatomic, assign) CGImageRef cgImage;

@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;
@end

@implementation RectangleDetector

- (instancetype)initWithImage:(UIImage *)uiImage {
    
    self = [super init];
    if (self) {
        [self seachRectangleInImage:uiImage];
//        __weak typeof(self) weakSelf = self;
//
//        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            if (!weakSelf.arSession) {
//                return;
//            }
//            CVPixelBufferRef pixelBuff = weakSelf.arSession.currentFrame.capturedImage;
//            if (pixelBuff) {
//                [weakSelf searchRectangleInPixelBuffer:pixelBuff];
//            }
//        }];
        
    }
    return self;
}

- (void)seachRectangleInImage:(UIImage *)uiImage {
    
    if (!uiImage) return;

    if (_isBusy) return;
    
    _isBusy = YES;
    
    CGImagePropertyOrientation ori = [Utilities imagePropertyOrientation:uiImage.imageOrientation];
    CGImageRef img = uiImage.CGImage;
    _cgImage = img;

    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:img orientation:ori options:@{}];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        @try {
            [handler performRequests:@[self.rectRequest] error:&error];
        } @catch (NSException *exception) {
            NSLog(@"%@ -- %@ -- %s",error,NSStringFromClass([self class]),__func__);
        } @finally {
        }
    });
}

- (void)searchRectangleInPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (_isBusy) return;

    _isBusy = YES;
    
    _pixelBuffer = pixelBuffer;
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer orientation:(kCGImagePropertyOrientationUp) options:@{}];
    __weak typeof(self) weakSelf = self;
    VNDetectRectanglesRequest *rectRequest = [[VNDetectRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        [weakSelf processRectangleRequest:(VNDetectRectanglesRequest *)request error:error];
    }];
    rectRequest.maximumObservations = 1;
    rectRequest.minimumSize = 0.3;
    rectRequest.minimumConfidence = 0.85;
    rectRequest.minimumAspectRatio = 0.3;
    rectRequest.quadratureTolerance = 20;
    rectRequest.usesCPUOnly = NO;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        @try {
            [handler performRequests:@[rectRequest] error:&error];
        } @catch (NSException *exception) {
            NSLog(@"%@ -- %@ -- %s",error,NSStringFromClass([self class]),__func__);
        } @finally {
        }
    });
}

- (void)processRectangleRequest:(VNDetectRectanglesRequest *)vnRequest error:(NSError *)error {
    
    if (![vnRequest isKindOfClass:[VNDetectRectanglesRequest class]]) {
        _isBusy = NO;
        return;
    }
    if (error) {
        NSLog(@"%@ -- %@ -- %s",error,NSStringFromClass([self class]),__func__);
        _isBusy = NO;
        return;
    }
    
    VNRectangleObservation *rectangle = vnRequest.results.firstObject;
    
    if (![rectangle isKindOfClass:[VNRectangleObservation class]]) {
        NSLog(@"Error: Rectangle detection failed - Vision request returned an error");
        _isBusy = NO;
        return;
    }
    
//    CGFloat imageWidth = CVPixelBufferGetWidth(_pixelBuffer);
//    CGFloat imageHeight = CVPixelBufferGetHeight(_pixelBuffer);
//    _imageSize = CGSizeMake(imageWidth, imageHeight);

//    if (1) {
//        //UI坐标系
//        CGFloat width = [UIScreen mainScreen].bounds.size.width;// CGImageGetWidth(_cgImage);
//        CGFloat height = [UIScreen mainScreen].bounds.size.height;//CGImageGetHeight(_cgImage);
//
//        CGPoint topLeft = CGPointMake(rectangle.topLeft.x * width, height - rectangle.topLeft.y * height);
//        CGPoint topRight = CGPointMake(rectangle.topRight.x * width, height - rectangle.topRight.y * height);
//        CGPoint bottomLeft = CGPointMake(rectangle.bottomLeft.x * width, height - rectangle.bottomLeft.y * height);
//        CGPoint bottomRight = CGPointMake(rectangle.bottomRight.x * width, height - rectangle.bottomRight.y * height);
//
////        if (_delegate && [_delegate respondsToSelector:@selector(didDetecteRectangle:)]) {
////            NSArray *list = @[[NSValue valueWithCGPoint:topLeft],
////                              [NSValue valueWithCGPoint:topRight],
////                              [NSValue valueWithCGPoint:bottomRight],
////                              [NSValue valueWithCGPoint:bottomLeft]
////                              ];
////            [_delegate didDetecteRectangle:list];
////        }
//        NSArray *list = @[[NSValue valueWithCGPoint:topLeft],
//                          [NSValue valueWithCGPoint:topRight],
//                          [NSValue valueWithCGPoint:bottomRight],
//                          [NSValue valueWithCGPoint:bottomLeft]
//                          ];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([self.delegate respondsToSelector:@selector(didDetecteRectangle:trackingImage:)]) {
//                [self.delegate didDetecteRectangle:list trackingImage:nil];
//            }
//            NSLog(@"%@ -- %s -- %d",NSStringFromClass([self class]),__func__,__LINE__);
//        });
//    } else {
//        // CI坐标系
////        CGPoint topLeft = CGPointMake(rectangle.topLeft.x * width, rectangle.topLeft.y * height);
////        CGPoint topRight = CGPointMake(rectangle.topRight.x * width, rectangle.topRight.y * height);
////        CGPoint bottomLeft = CGPointMake(rectangle.bottomLeft.x * width, rectangle.bottomLeft.y * height);
////        CGPoint bottomRight = CGPointMake(rectangle.bottomRight.x * width, rectangle.bottomRight.y * height);
//    }
    
    // 获取UI坐标系四个角点
    CGFloat previewWidth = [UIScreen mainScreen].bounds.size.width;//_previewSize.width;
    CGFloat previewHeight = [UIScreen mainScreen].bounds.size.height;//_previewSize.height;

    CGPoint previewTopLeft  = CGPointMake(rectangle.topRight.y * previewWidth, previewHeight - rectangle.topRight.x * previewHeight );
    CGPoint previewTopRight = CGPointMake(rectangle.bottomRight.y * previewWidth , previewHeight - rectangle.bottomRight.x * previewHeight);
    CGPoint previewBottomRight = CGPointMake(rectangle.bottomLeft.y * previewWidth, previewHeight - rectangle.bottomLeft.x * previewHeight);
    CGPoint previewBottomLeft = CGPointMake(rectangle.topLeft.y * previewWidth, previewHeight - rectangle.topLeft.x * previewHeight);

//    CGPoint previewTopLeft = CGPointMake(rectangle.topLeft.x * previewWidth , previewHeight - rectangle.topLeft.y * previewHeight);
//    CGPoint previewTopRight = CGPointMake(rectangle.topRight.x * previewWidth , previewHeight - rectangle.topRight.y * previewHeight);
//    CGPoint previewBottomLeft = CGPointMake(rectangle.bottomLeft.x * previewWidth, previewHeight - rectangle.bottomLeft.y * previewHeight);
//    CGPoint previewBottomRight = CGPointMake(rectangle.bottomRight.x * previewWidth , previewHeight - rectangle.bottomRight.y * previewHeight);

    
    NSArray *list = @[[NSValue valueWithCGPoint:previewTopLeft],
                      [NSValue valueWithCGPoint:previewTopRight],
                      [NSValue valueWithCGPoint:previewBottomRight],
                      [NSValue valueWithCGPoint:previewBottomLeft]
                      ];


    // 获取矫正后的矩形区域
    CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveCorrection"];

    CGFloat width = CVPixelBufferGetWidth(_pixelBuffer);
    CGFloat height = CVPixelBufferGetHeight(_pixelBuffer);

    CGPoint topLeft = CGPointMake([self subtractOffset:70 originStart:rectangle.topLeft.x * width],
                                  [self additionOffset:70 originStart:rectangle.topLeft.y * height max:height]);

    CGPoint topRight = CGPointMake([self additionOffset:70 originStart:rectangle.topRight.x * width max:width],
                                   [self additionOffset:70 originStart:rectangle.topRight.y * height max:height]);

    CGPoint bottomLeft = CGPointMake([self subtractOffset:70 originStart:rectangle.bottomLeft.x * width],
                                     [self subtractOffset:70 originStart:rectangle.bottomLeft.y * height]);

    CGPoint bottomRight = CGPointMake([self additionOffset:70 originStart:rectangle.bottomRight.x * width max:width],
                                      [self subtractOffset:70 originStart:rectangle.bottomRight.y * height]);

//    CGPoint topLeft1 = CGPointMake(rectangle.topLeft.x * width - 70, rectangle.topLeft.y * height + 70);
//    CGPoint topRight1 = CGPointMake(rectangle.topRight.x * width + 70, rectangle.topRight.y * height + 70);
//    CGPoint bottomLeft1 = CGPointMake(rectangle.bottomLeft.x * width - 70, rectangle.bottomLeft.y * height - 70);
//    CGPoint bottomRight1 = CGPointMake(rectangle.bottomRight.x * width + 70, rectangle.bottomRight.y * height - 70);

    [filter setValue:[CIVector vectorWithCGPoint:topLeft] forKey:@"inputTopLeft"];
    [filter setValue:[CIVector vectorWithCGPoint:topRight] forKey:@"inputTopRight"];
    [filter setValue:[CIVector vectorWithCGPoint:bottomLeft] forKey:@"inputBottomLeft"];
    [filter setValue:[CIVector vectorWithCGPoint:bottomRight] forKey:@"inputBottomRight"];

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:_pixelBuffer];
    ciImage = [ciImage imageByApplyingCGOrientation:kCGImagePropertyOrientationUp];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    CIImage *perspectiveImage = [filter valueForKey:kCIOutputImageKey];

    if (perspectiveImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didDetecteRectangle:trackingImage:)]) {
                [self.delegate didDetecteRectangle:list trackingImage:perspectiveImage];
            }
            NSLog(@"%@ -- %s -- %d",NSStringFromClass([self class]),__func__,__LINE__);
        });
    }
    _isBusy = NO;
}

- (CGFloat)additionOffset:(CGFloat)offset originStart:(CGFloat)start max:(CGFloat)max {
    CGFloat an = start + offset;
    return an > max ? max : an;
}

- (CGFloat)subtractOffset:(CGFloat)offset originStart:(CGFloat)start {
    CGFloat an = start - offset;
    return an < 0 ? 0 : an;
}

#pragma mark - Lazy Init
- (VNDetectRectanglesRequest *)rectRequest {
    
    if (_rectRequest) return _rectRequest;
    __weak typeof(self) weakSelf = self;
    _rectRequest = [[VNDetectRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        [weakSelf processRectangleRequest:(VNDetectRectanglesRequest *)request error:error];
    }];
    _rectRequest.maximumObservations = 1;
    _rectRequest.minimumSize = 0.25;
    _rectRequest.minimumConfidence = 0.90;
    _rectRequest.minimumAspectRatio = 0.3;
    _rectRequest.quadratureTolerance = 20;
    _rectRequest.usesCPUOnly = NO;
    
    return _rectRequest;
}

- (CGRect)ratio {
    
    float xRatio = 0.0;
    float yRatio = 0.0;
    float xOffset = 0.0;
    float yOffset = 0.0;
    
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height;
    
    float defaultRatio = viewWidth / viewHeight;
    
    float imageRatio = _imageSize.width/_imageSize.height;
    
    if (imageRatio >= defaultRatio) {
        xRatio = _imageSize.width/viewWidth;
        yRatio = xRatio;
        yOffset = (viewWidth/defaultRatio - _imageSize.height/yRatio)/2;
    } else if (imageRatio < defaultRatio){
        yRatio = _imageSize.height/viewHeight;
        xRatio = yRatio;
        xOffset = (viewWidth - _imageSize.width/xRatio)/2;
    }
    CGRect ra = CGRectMake(xOffset, yOffset, xRatio, yRatio);
    
    return ra;
}


@end
