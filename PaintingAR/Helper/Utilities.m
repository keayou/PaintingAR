//
//  Utilities.m
//  PaintingAR
//
//  Created by fk on 2019/6/25.
//  Copyright © 2019 fk. All rights reserved.
//

#import "Utilities.h"
#import <Metal/MTLDevice.h>

@implementation Utilities
///// Returns a pixel buffer of the image's current contents.
//func toPixelBuffer(pixelFormat: OSType) -> CVPixelBuffer? {
//    var buffer: CVPixelBuffer?
//    let options = [
//                   kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
//                   kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true)
//                   ]
//    let status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                     Int(extent.size.width),
//                                     Int(extent.size.height),
//                                     pixelFormat,
//                                     options as CFDictionary, &buffer)
//
//    if status == kCVReturnSuccess, let device = MTLCreateSystemDefaultDevice(), let pixelBuffer = buffer {
//        let ciContext = CIContext(mtlDevice: device)
//        ciContext.render(self, to: pixelBuffer)
//    } else {
//        print("Error: Converting CIImage to CVPixelBuffer failed.")
//    }
//    return buffer
//}

+ (CVPixelBufferRef)getPixelBuffer:(CIImage *)ciImage {
    
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault,
                                               NULL,
                                               NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef attributes = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                                  1,
                                                                  &kCFTypeDictionaryKeyCallBacks,
                                                                  &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attributes,kCVPixelBufferIOSurfacePropertiesKey,empty);
    
    CVPixelBufferRef resultBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          ciImage.extent.size.width,
                                          ciImage.extent.size.height,
                                          kCVPixelFormatType_32BGRA,
                                          attributes,
                                          &resultBuffer);
    if (result == kCVReturnSuccess && resultBuffer) {
        CIContext *context = [CIContext contextWithMTLDevice:MTLCreateSystemDefaultDevice()];
        [context render:ciImage toCVPixelBuffer:resultBuffer];
    }
    return resultBuffer;
}


+ (CGImagePropertyOrientation)imagePropertyOrientation:(UIImageOrientation)imageOrientation {
    switch (imageOrientation) {
        case UIImageOrientationUp:
            return kCGImagePropertyOrientationUp;
            break;
        case UIImageOrientationDown:
            return kCGImagePropertyOrientationDown;
            break;
        case UIImageOrientationLeft:
            return kCGImagePropertyOrientationLeft;
            break;
        case UIImageOrientationRight:
            return kCGImagePropertyOrientationRight;
            break;
        case UIImageOrientationUpMirrored:
            return kCGImagePropertyOrientationUpMirrored;
            break;
        case UIImageOrientationDownMirrored:
            return kCGImagePropertyOrientationDownMirrored;
            break;
        case UIImageOrientationLeftMirrored:
            return kCGImagePropertyOrientationLeftMirrored;
            break;
        case UIImageOrientationRightMirrored:
            return kCGImagePropertyOrientationRightMirrored;
            break;
    }
}


+ (UIImage *)imageToTransparent:(UIImage *)image {
    
    // 分配内存
    
    const int imageWidth = image.size.width;
    
    const int imageHeight = image.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    
    
    // 创建context
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素
    
    int pixelNum = imageWidth * imageHeight;
    
    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
        
    {
        
        //将像素点转成子节数组来表示---第一个表示透明度即ARGB这种表示方式。ptr[0]:透明度,ptr[1]:R,ptr[2]:G,ptr[3]:B
        
        //分别取出RGB值后。进行判断需不需要设成透明。
        
        uint8_t* ptr = (uint8_t*)pCurPtr;
        // NSLog(@"1是%d,2是%d,3是%d",ptr[1],ptr[2],ptr[3]);
        
        if(ptr[1] < 200 && ptr[2] < 200 && ptr[3] < 200){
            ptr[1] = 255;
            ptr[2] = 0;
            ptr[3] = 0;
        } else {
            ptr[0] = 0;
        }
        
//        if(ptr[1] >= 250 || ptr[2] >= 250 || ptr[3] >= 250){
//            ptr[0] = 0;
//        }
        
        
    }
    
    // 将内存转成image
    
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, nil);
    
    
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace,
                                        
                                        kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,
                                        
                                        NULL, true,kCGRenderingIntentDefault);
    
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    
    CGImageRelease(imageRef);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
    
}


@end
