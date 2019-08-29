//
//  SketchFilter.m
//  PaintingAR
//
//  Created by fk on 2019/7/8.
//  Copyright © 2019 fk. All rights reserved.
//

#import "SketchFilter.h"
#import "Utilities.h"

@implementation SketchFilter

- (CIImage *)outputImage {
    
    // 1、去色；
    // 2、复制去色图层，并且反色；
    // 3、对反色图像进行高斯模糊；
    // 4、模糊后的图像叠加模式选择颜色减淡效果。
    
    CIFilter * monoFilter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    
    [monoFilter setValue:_inputImage forKey:kCIInputImageKey];
    
    // 1
    CIImage * outImage = [monoFilter valueForKey:kCIOutputImageKey];
    
    // 2
    CIImage * invertImage = [outImage copy];
    
    CIFilter * invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
    [invertFilter setValue:invertImage forKey:kCIInputImageKey];
    invertImage = [invertFilter valueForKey:kCIOutputImageKey];
    
    // 3
    CIFilter * blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:@5 forKey:kCIInputRadiusKey];
    [blurFilter setValue:invertImage forKey:kCIInputImageKey];
    
    invertImage = [blurFilter valueForKey:kCIOutputImageKey];
    
    // 4
    CIFilter * blendFilter = [CIFilter filterWithName:@"CIColorDodgeBlendMode"];
    
    [blendFilter setValue:invertImage forKey:kCIInputImageKey];
    [blendFilter setValue:outImage forKey:kCIInputBackgroundImageKey];
    CIImage * sketchImage = [blendFilter outputImage];
    
    return sketchImage;
}

@end
