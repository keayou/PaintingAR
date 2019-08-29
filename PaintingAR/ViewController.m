//
//  ViewController.m
//  PaintingAR
//
//  Created by fk on 2019/6/24.
//  Copyright © 2019 fk. All rights reserved.
//

#import "ViewController.h"
#import "Utilities.h"
#include "transform_calc.h"
#import "UIView+Additions.h"

#import "RectangleDetector.h"
#import "OCRResultModel.h"
#import "SketchFilter.h"

#import "SGUtilsConstantsMacro.h"

typedef NS_ENUM(NSUInteger, ARTrackingType) {
    ARTrackingType_image = 120,
    ARTrackingType_horizontalPlane,
    ARTrackingType_verticalPlane
};

@interface ViewController () <ARSCNViewDelegate,ARSessionDelegate,RectangleDetectorDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

@property (nonatomic, strong) RectangleDetector *detetor;

@property (nonatomic, strong) ARReferenceImage *refeImage;

@property (nonatomic, strong) UIView *anchorView;
@property (nonatomic, strong) UIImageView *imageView;


@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) ARTrackingType trakingType;

@property (nonatomic, strong) UIImage *paintingImage;
@property (nonatomic, assign) CGSize   paintingSize;
@property (nonatomic, assign) BOOL   esitesd;
@property (nonatomic, strong) SCNNode *imgPlaneNode;

@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self handlePaintingImage:[UIImage imageNamed:@"timg"]];
    
    [self loadUI];
    
    _trakingType = ARTrackingType_image;
    
    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    self.sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    self.sceneView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startWordTrackingWithTrackImage:nil];
    self.detetor.arSession = self.sceneView.session;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)handlePaintingImage:(UIImage *)image {
    
    CIImage * inputImage = [[CIImage alloc] initWithImage:image];
    CIContext * context = [CIContext contextWithOptions:nil];
    SketchFilter * filter = [SketchFilter new];
    filter.inputImage = inputImage;
    CGImageRef cgImage = [context createCGImage:filter.outputImage fromRect:[inputImage extent]];
    UIImage *outImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    _paintingImage = [Utilities imageToTransparent:outImage];// outImage;
    
    _paintingSize = CGSizeMake(_paintingImage.size.width, _paintingImage.size.height);
    
}

- (void)loadUI {
    
    _anchorView = [[UIView alloc] initWithFrame:self.view.bounds];
    _anchorView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
    _anchorView.hidden = YES;
    [self.view addSubview:_anchorView];

    _imageView = [[UIImageView alloc] initWithFrame:_anchorView.bounds];
    _imageView.image = _paintingImage;
    [_imageView sizeToFit];
    [_anchorView addSubview:_imageView];
    
    NSArray *array = [NSArray arrayWithObjects:@"矩形",@"地板",@"墙面", nil];
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:array];
    segment.frame = CGRectMake(10, StatusBarHeightReal, self.view.frame.size.width-20, 30);
    [segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    segment.selectedSegmentIndex = 0;
    [self.view addSubview:segment];
}

- (void)startWordTrackingWithTrackImage:(ARReferenceImage *)refeImg {

    if (refeImg) {
        ARImageTrackingConfiguration *configuration = [ARImageTrackingConfiguration new];
        configuration.autoFocusEnabled = YES;
        configuration.trackingImages = [NSSet setWithObjects:refeImg, nil];
        configuration.maximumNumberOfTrackedImages = 1;
        self.sceneView.session.delegate = self;
        [self.sceneView.session runWithConfiguration:configuration options: ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
        
    } else {
        _imgPlaneNode = nil;
        _refeImage = nil;
        ARPlaneDetection planeDetection = ARPlaneDetectionNone;
        switch (_trakingType) {
            case ARTrackingType_image:
                planeDetection = ARPlaneDetectionNone;
                break;
            case ARTrackingType_horizontalPlane:
                planeDetection = ARPlaneDetectionHorizontal;
                break;
            case ARTrackingType_verticalPlane:
                planeDetection = ARPlaneDetectionVertical;
                break;
        }
        
        ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
           configuration.planeDetection = planeDetection;
        self.sceneView.session.delegate = self;
        [self.sceneView.session runWithConfiguration:configuration options: ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
    }
}

- (void)createImageNode:(CGSize)size {
    
    SCNPlane *plane = [SCNPlane planeWithWidth:size.width height:size.height];
    plane.firstMaterial.diffuse.contents = _paintingImage;
//    plane.firstMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
    
    SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
    planeNode.eulerAngles = SCNVector3Make(-M_PI / 2, 0, 0);// eulerAngles.x = -.pi / 2
    planeNode.name = @"sgNode";
    
    _imgPlaneNode = planeNode;
}

#pragma mark - RectangleDetectorDelegate
- (void)didDetecteRectangle:(NSArray <NSValue *>*)pointList trackingImage:(CIImage *)trackingImage {
    
    //        if (self.esitesd) {
    //            return ;
    //        }
    
    if (trackingImage && _imgPlaneNode == nil && self.trakingType == ARTrackingType_image) {

        CVPixelBufferRef pixelBuff = [Utilities getPixelBuffer:trackingImage];

        ARReferenceImage *refImage = [[ARReferenceImage alloc] initWithPixelBuffer:pixelBuff orientation:kCGImagePropertyOrientationLeft physicalWidth:0.5];
        [self createImageNode:refImage.physicalSize];
        _refeImage = refImage;

        [self startWordTrackingWithTrackImage:refImage];
    }
    
    
    
//    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
//    [bezierPath moveToPoint:[pointList[0] CGPointValue]];
//    [bezierPath addLineToPoint:[pointList[1] CGPointValue]];
//    [bezierPath addLineToPoint:[pointList[2] CGPointValue]];
//    [bezierPath addLineToPoint:[pointList[3] CGPointValue]];
//    [bezierPath closePath];
//    [bezierPath fill];
//
//    if (_shapeLayer == nil) {
//        _shapeLayer = [CAShapeLayer layer];
//        _shapeLayer.fillColor = [UIColor colorWithWhite:0.6 alpha:0.5].CGColor;
//        [self.view.layer addSublayer:_shapeLayer];
//    }
//    _shapeLayer.path = bezierPath.CGPath;
//
    
    
//    self.anchorView.hidden = NO;
//    OCRResultModel *model = [[OCRResultModel alloc] initWithDict:pointList];
//
//    float xRadio =  1; //self.detetor.ratio.size.width;
//    float xOffset = 0;//self.detetor.ratio.origin.x;
//    float yRadio = 1;//self.detetor.ratio.size.height;
//    float yOffset = 0;//self.detetor.ratio.origin.y;
//    CGRect frame = CGRectZero;
//    frame.origin.x = (0 + model.externalFrame.origin.x/xRadio);
//    frame.origin.y = (yOffset + model.externalFrame.origin.y/yRadio);
//    frame.size = CGSizeMake(model.externalFrame.size.width/xRadio, model.externalFrame.size.height/yRadio);
//
//    RectPoint *insidePonint = model.rectPoint;
//    RectPoint *insideRect = [RectPoint new];
//    insideRect.topLeft = CGPointMake(xOffset + insidePonint.topLeft.x/xRadio, yOffset + insidePonint.topLeft.y/yRadio);
//    insideRect.topRight = CGPointMake(xOffset + insidePonint.topRight.x/xRadio, yOffset + insidePonint.topRight.y/yRadio);
//    insideRect.bottomRight = CGPointMake(xOffset + insidePonint.bottomRight.x/xRadio, yOffset + insidePonint.bottomRight.y/yRadio);
//    insideRect.bottomLeft = CGPointMake(xOffset + insidePonint.bottomLeft.x/xRadio, yOffset + insidePonint.bottomLeft.y/yRadio);
    
    
    //        CGPoint center = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2) ;
    //        NSArray <ARHitTestResult *>*results = [self.sceneView hitTest:center types:(ARHitTestResultTypeEstimatedHorizontalPlane)];
    //        if (results.count > 0) {
    //
    //            if (self.imgPlaneNode) {
    ////                ARHitTestResult *result = results.firstObject;
    ////
    ////                simd_float3 sd = simd_make_float3(result.worldTransform.columns[3].x, result.worldTransform.columns[3].y, result.worldTransform.columns[3].z);
    ////                self.imgPlaneNode.simdPosition = sd;
    ////                self.imgPlaneNode.eulerAngles = SCNVector3Make(-M_PI / 2, 0, 0);// eulerAngles.x = -.pi / 2
    //
    //            } else  {
    //                ARHitTestResult *result = results.firstObject;
    //                CGFloat distance = result.distance;
    //
    //                ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:result.worldTransform];
    //                [self.sceneView.session addAnchor:anchor];
    //            }
    //        }
    
//    CATransform3D transform = CATransform3DIdentity;
//    if (get_trans_mat(CGPointZero,
//                      CGPointMake(0, frame.size.height),
//                      CGPointMake(frame.size.width, frame.size.height),
//                      CGPointMake(frame.size.width, 0),
//                      insideRect.topLeft,
//                      insideRect.bottomLeft,
//                      insideRect.bottomRight,
//                      insideRect.topRight,
//                      &transform))
//    {
//        [self.anchorView setFrame:frame];
//
//        if (frame.size.width > frame.size.height) {
//
//            self.imageView.height = frame.size.height;
//            self.imageView.width = self.paintingSize.width * frame.size.height / self.paintingSize.height;
//            self.imageView.centerX = self.anchorView.width / 2;
//            self.imageView.centerY = self.anchorView.height / 2;
//        } else {
//            self.imageView.width = frame.size.width;
//            self.imageView.height = self.paintingSize.height * frame.size.width / self.paintingSize.width;
//            self.imageView.centerX = self.anchorView.width / 2;
//            self.imageView.centerY = self.anchorView.height / 2;
//        }
//
//        self.anchorView.layer.transform = transform;
//        self.anchorView.layer.anchorPoint = CGPointMake(0,0);
//    }
}

#pragma mark - ARSessionDelegate
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    
    if (_trakingType == ARTrackingType_image) {
        CVPixelBufferRef pixelBuff = frame.capturedImage;
        [self.detetor searchRectangleInPixelBuffer:pixelBuff];
        _anchorView.hidden = YES;

    } else if (_trakingType == ARTrackingType_verticalPlane ||_trakingType == ARTrackingType_horizontalPlane ) {
        _anchorView.hidden = YES;
    }
}

/*
 ARKit 自动添加 anchors。例如，ARKit 检测到了一个平面，ARKit 会为该平面创建一个 ARPlaneAnchor 并添加到 ARSession 中。
 */
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors {

    NSLog(@"%s",__func__);
}

- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors {
    NSLog(@"%s",__func__);
    
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors {
    NSLog(@"%s",__func__);
    
}

#pragma mark - ARSCNViewDelegate
//// Override to create and configure nodes for anchors added to the view's session.
//- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
//    SCNNode *node = [SCNNode new];
//
//    // Add geometry to the node...
//
//    return node;
//}

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
    if (_trakingType == ARTrackingType_image) {
        
//
//        if let imageAnchor = anchor as? ARImageAnchor, imageAnchor.referenceImage == referenceImage {
//            self.anchor = imageAnchor
//
//            // Start the image tracking timeout.
//            resetImageTrackingTimeout()
//
//            // Add the node that displays the altered image to the node graph.
//            node.addChildNode(visualizationNode)
//
//            // If altering the first image completed before the
//            //  anchor was added, display that image now.
//            if let createdImage = modelOutputImage {
//                visualizationNode.display(createdImage)
//            }
//        }
        ARImageAnchor *imageAnchor = (ARImageAnchor *)anchor;
        if ([imageAnchor isKindOfClass:[ARImageAnchor class]] && imageAnchor.referenceImage == _refeImage) {
            
            [node addChildNode:_imgPlaneNode];
            
        }
        
//        SCNMaterial *material = [SCNMaterial material];
//        UIImage *img = _paintingImage;// [UIImage imageNamed:@"sogoLogo"];
//        material.diffuse.contents = img;
//        material.lightingModelName = SCNLightingModelPhysicallyBased;
//
//        SCNPlane *imgPlane = [SCNPlane planeWithWidth:img.size.width * .001 height:img.size.height * .001];
//        imgPlane.materials = @[material];
//        SCNNode *imgPlaneNode = [SCNNode nodeWithGeometry:imgPlane];
//
//        simd_float3 sd = simd_make_float3(anchor.transform.columns[3].x, anchor.transform.columns[3].y, anchor.transform.columns[3].z);
//        imgPlaneNode.simdPosition = sd;
//        imgPlaneNode.eulerAngles = SCNVector3Make(-M_PI / 2, 0, 0);// eulerAngles.x = -.pi / 2
//        imgPlaneNode.name = @"sgNode";
//        self.imgPlaneNode = imgPlaneNode;
//        [node addChildNode:imgPlaneNode];
//        self.esitesd = YES;

//        ARSCNPlaneGeometry *geo = [ARSCNPlaneGeometry planeGeometryWithDevice:self.sceneView.device];
//        [geo updateFromPlaneGeometry:anchor.geometry];
//        SCNNode *meshNode = [SCNNode nodeWithGeometry:geo];
//        meshNode.opacity = 0.3;
//        meshNode.geometry.firstMaterial.diffuse.contents = [UIColor redColor];
//        [node addChildNode:meshNode];


        return;
    }
    
    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    if (![planeAnchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }

//    ARSCNPlaneGeometry *geo = [ARSCNPlaneGeometry planeGeometryWithDevice:self.sceneView.device];
//    [geo updateFromPlaneGeometry:planeAnchor.geometry];
//    SCNNode *meshNode = [SCNNode nodeWithGeometry:geo];
//    meshNode.opacity = 0.3;
//    meshNode.geometry.firstMaterial.diffuse.contents = [UIColor redColor];
//    [node addChildNode:meshNode];

//    SCNPlane *plane = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
//    SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
//    planeNode.simdPosition = planeAnchor.center;
//    planeNode.eulerAngles = SCNVector3Make(-M_PI / 2, 0, 0);// eulerAngles.x = -.pi / 2
//    planeNode.opacity = 0.4;
//    planeNode.geometry.firstMaterial.diffuse.contents = [UIColor redColor];
//    planeNode.name = @"sgNode";
//    [node addChildNode:planeNode];


    SCNMaterial *material = [SCNMaterial material];
    UIImage *img = _paintingImage;
    material.diffuse.contents = img;
    material.lightingModelName = SCNLightingModelPhysicallyBased;
    
    SCNPlane *imgPlane = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
    imgPlane.materials = @[material];
    SCNNode *imgPlaneNode = [SCNNode nodeWithGeometry:imgPlane];
    imgPlaneNode.simdPosition = planeAnchor.center;
    imgPlaneNode.eulerAngles = SCNVector3Make(-M_PI / 2, 0, 0);// eulerAngles.x = -.pi / 2
    imgPlaneNode.name = @"sgNode";
    [node addChildNode:imgPlaneNode];
    
//    //2.创建一个3D物体模型    （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个长方形，并且是否对平地做了一个缩放效果）
//    //参数分别是长宽高和圆角
//    SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x height:0 length:planeAnchor.extent.z chamferRadius:0];
//    //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
//    plane.firstMaterial.diffuse.contents = [UIColor redColor];
//    //4.创建一个基于3D物体模型的节点
//    SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
//    //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
//    planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
//
//    [node addChildNode:planeNode];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {

}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    return;
    if (_trakingType == ARTrackingType_image) {
        SCNNode *planeNode = node.childNodes.firstObject;
        if (![planeNode.name isEqualToString:@"sgNode"]) {
            return;
        }
        
        if ([planeNode.geometry isKindOfClass:[SCNPlane class]]) {
            NSLog(@"%@ -- %s -- %d",NSStringFromClass([self class]),__func__,__LINE__);
//            SCNPlane *plane = (SCNPlane *)planeNode.geometry;
//            plane.width = planeAnchor.extent.x * .001;
//            plane.height =  planeAnchor.extent.z * .001;
            
            simd_float3 sd = simd_make_float3(anchor.transform.columns[3].x, anchor.transform.columns[3].y, anchor.transform.columns[3].z);
            planeNode.simdPosition = sd;
//            planeNode.simdPosition = planeAnchor.center;
        }
        return;
    }
    
    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    if (![planeAnchor isKindOfClass:[planeAnchor class]]) {
        return;
    }
    
    SCNNode *planeNode = node.childNodes.firstObject;
    if (![planeNode.name isEqualToString:@"sgNode"]) {
        return;
    }
    
    if ([planeNode.geometry isKindOfClass:[SCNPlane class]]) {
        NSLog(@"%@ -- %s -- %d",NSStringFromClass([self class]),__func__,__LINE__);
        SCNPlane *plane = (SCNPlane *)planeNode.geometry;
        plane.width = planeAnchor.extent.x * .001;
        plane.height =  planeAnchor.extent.z * .001;
        planeNode.simdPosition = planeAnchor.center;
    }

}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (node == _imgPlaneNode) {
        _imgPlaneNode = nil;
    }
    [node.childNodes enumerateObjectsUsingBlock:^(SCNNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (node == self.imgPlaneNode) {
             self.imgPlaneNode = nil;
            *stop = YES;
        }
    }];
}

#pragma mark - ARSessionObserver
- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    _imgPlaneNode = nil;
    if (error.code == ARErrorCodeInvalidReferenceImage) {
        NSLog(@"Error: The detected rectangle cannot be tracked.");
        [self startWordTrackingWithTrackImage:nil];
        return;
    }
    
    NSString *str = [NSString stringWithFormat:@"%@ -- %@ -- %@",error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion];
    NSLog(@"%@ -- %@",NSStringFromClass([self class]),str);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Restart" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self startWordTrackingWithTrackImage:nil];
        }];
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:(UIAlertControllerStyleAlert)];
        [alertVc addAction:action];
        [self presentViewController:alertVc animated:YES completion:nil];
    });
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

#pragma mark - Events
- (void)segmentChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        
        if (_trakingType == ARTrackingType_image) return;
        _trakingType = ARTrackingType_image;
    } else if (sender.selectedSegmentIndex == 1) {
        
        if (_trakingType == ARTrackingType_horizontalPlane) return;
        _trakingType = ARTrackingType_horizontalPlane;
    } else if (sender.selectedSegmentIndex == 2) {
        
        if (_trakingType == ARTrackingType_verticalPlane) return;
        _trakingType = ARTrackingType_verticalPlane;
    }
    [self startWordTrackingWithTrackImage:nil];
}
- (IBAction)photoAlbmClicked:(id)sender {
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imgPicker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //    NSData *imgData = UIImagePNGRepresentation(image2);
    
    [self handlePaintingImage:image];
    _imageView.image = _paintingImage;
    [_imageView sizeToFit];
    
    [self startWordTrackingWithTrackImage:nil];
}

#pragma mark - Lazy init
- (RectangleDetector *)detetor {
    
    if (_detetor) {
        return _detetor;
    }
    _detetor = [[RectangleDetector alloc] initWithImage:nil];
    _detetor.previewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _detetor.delegate = self;
    _detetor.arSession = self.sceneView.session;

    return _detetor;
}



@end
