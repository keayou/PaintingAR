//
//  Utilities.h
//  PaintingAR
//
//  Created by fk on 2019/6/25.
//  Copyright © 2019 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utilities : NSObject


+ (CGImagePropertyOrientation)imagePropertyOrientation:(UIImageOrientation)imageOrientation;

+ (UIImage *)imageToTransparent:(UIImage *)image;

+ (CVPixelBufferRef)getPixelBuffer:(CIImage *)ciImage;

@end

NS_ASSUME_NONNULL_END
