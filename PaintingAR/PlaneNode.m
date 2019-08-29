//
//  PlaneNode.m
//  PaintingAR
//
//  Created by fk on 2019/7/2.
//  Copyright © 2019 fk. All rights reserved.
//

#import "PlaneNode.h"
#import <ARKit/ARKit.h>

@implementation PlaneNode

- (instancetype)initWithPlaneAnchor:(ARPlaneAnchor *)planeAnchor inSceneView:(ARSCNView *)sceneView {
    
    
//    self = (PlaneNode *)[[super class] nodeWithGeometry:geometry];
//
//    if (self) {
//
//    }
    return self;
    
}

+ (PlaneNode *)isNodePartOfARObject:(SCNNode *)node {
    
    if ([node isKindOfClass:[PlaneNode class]]) {
        return (PlaneNode *)node;
    }
    
    if (node.parentNode != nil) {
        return [[self class] isNodePartOfARObject:node.parentNode];
    }
    return nil;
}


@end
