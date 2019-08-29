//
//  transform_calc.h
//  imagerotateTest
//
//  Created by macbook on 2017/7/13.
//  Copyright © 2017年 macbook. All rights reserved.
//

#ifndef transform_calc_h
#define transform_calc_h

#import <UIKit/UIKit.h>


bool get_trans_mat(CGPoint from_lt,
                   CGPoint from_lb,
                   CGPoint from_rb,
                   CGPoint from_rt,
                   CGPoint to_lt,
                   CGPoint to_lb,
                   CGPoint to_rb,
                   CGPoint to_rt,
                   CATransform3D* transform);


#endif /* transform_calc_h */
