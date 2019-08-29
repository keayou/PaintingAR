//
//  transform_calc.m
//  imagerotateTest
//
//  Created by macbook on 2017/7/13.
//  Copyright © 2017年 macbook. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "transform_calc.h"
#include "stdlib.h"

bool gauss_elimination(float* mat, int n, int batch, float* out, int* idx_buf) {
    /* mat should be n * (n + batch) */
    /* out should be batch * n */
    /* buf should be n */
    int col, i, j;
    int max_row_id = -1;
    float max_abs = 0.0f;
    for (col = 0; col < n; col++) {
        max_row_id = -1;
        max_abs = 0.0f;
        for (i = 0; i < n; i++) {
            float abs_value = mat[i * (n + batch) + col];
            if (abs_value < 0) abs_value = -abs_value;
            if (abs_value > max_abs) {
                max_abs = abs_value;
                max_row_id = i;
            }
        }
        if (max_row_id == -1) return false;
        idx_buf[col] = max_row_id;
        for (i = 0; i < n; i++) {
            float c = mat[i * (n + batch) + col] / mat[max_row_id * (n + batch) + col];
            for (j = col; j < n + batch; j++) {
                if (i != max_row_id) {
                    mat[i * (n + batch) + j] -= c * mat[max_row_id * (n + batch) + j];
                }
            }
        }
        float max_row_col = mat[max_row_id * (n + batch) + col];
        for (j = col; j < n + batch; j++)
            mat[max_row_id * (n + batch) + j] /= max_row_col;
    }
    for (i = 0; i < n; i++) {
        for (j = 0; j < batch; j++) {
            out[j * batch + i] = mat[(idx_buf[i]) * (n + batch) + n + j];
        }
    }
    return true;
}

float* the_mat_at(float* mat, int i, int j) {
    return mat + i * 9 + j;
}

bool get_trans_mat(CGPoint from_lt, CGPoint from_lb, CGPoint from_rb, CGPoint from_rt,
                   CGPoint to_lt, CGPoint to_lb, CGPoint to_rb, CGPoint to_rt,
                   CATransform3D* transform) {
    void* buf = malloc(sizeof(float) * 8 * 9 + sizeof(float) * 8 + sizeof(int) * 8);
    float* mat = (float*) buf;
    float* result = mat + 8 * 9;
    int* idx_buf = (int*)(result + 8);
    
    CGPoint* from_point, *to_point;
    for (int i = 0; i < 4; i++) {
        if (i == 0) {
            from_point = & from_lt;
            to_point = & to_lt;
        } else if (i == 1) {
            from_point = & from_lb;
            to_point = & to_lb;
        } else if (i == 2) {
            from_point = & from_rb;
            to_point = & to_rb;
        } else {
            from_point = & from_rt;
            to_point = & to_rt;
        }
        *the_mat_at(mat, i * 2, 0) = from_point->x;
        *the_mat_at(mat, i * 2, 1) = 0;
        *the_mat_at(mat, i * 2, 2) = -from_point->x * to_point->x;
        *the_mat_at(mat, i * 2, 3) = from_point->y;
        *the_mat_at(mat, i * 2, 4) = 0;
        *the_mat_at(mat, i * 2, 5) = -from_point->x * to_point->y;
        *the_mat_at(mat, i * 2, 6) = 1;
        *the_mat_at(mat, i * 2, 7) = 0;
        *the_mat_at(mat, i * 2, 8) = to_point->x;
        
        *the_mat_at(mat, i * 2 + 1, 1) = from_point->x;
        *the_mat_at(mat, i * 2 + 1, 0) = 0;
        *the_mat_at(mat, i * 2 + 1, 2) = -from_point->y * to_point->x;
        *the_mat_at(mat, i * 2 + 1, 4) = from_point->y;
        *the_mat_at(mat, i * 2 + 1, 3) = 0;
        *the_mat_at(mat, i * 2 + 1, 5) = -from_point->y * to_point->y;
        *the_mat_at(mat, i * 2 + 1, 7) = 1;
        *the_mat_at(mat, i * 2 + 1, 6) = 0;
        *the_mat_at(mat, i * 2 + 1, 8) = to_point->y;
    }
    if (gauss_elimination(mat, 8, 1, result, idx_buf) == false) {
        free(buf);
        return false;
    }
    transform->m11 = result[0];
    transform->m12 = result[1];
    transform->m13 = 0;
    transform->m14 = result[2];
    transform->m21 = result[3];
    transform->m22 = result[4];
    transform->m23 = 0;
    transform->m24 = result[5];
    transform->m31 = 0;
    transform->m32 = 0;
    transform->m33 = 0;
    transform->m34 = 0;
    transform->m41 = result[6];
    transform->m42 = result[7];
    transform->m43 = 0;
    transform->m44 = 1;
    
    free(buf);
    return true;
}
