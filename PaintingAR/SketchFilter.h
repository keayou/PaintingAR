//
//  SketchFilter.h
//  PaintingAR
//
//  Created by fk on 2019/7/8.
//  Copyright © 2019 fk. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface SketchFilter : CIFilter

@property (nonatomic, strong) CIImage *inputImage;


@end

NS_ASSUME_NONNULL_END
