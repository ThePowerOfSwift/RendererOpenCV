//
//  VideoSource.m
//  RenderOpenCV
//
//  Created by Anastasia Tarasova on 23/05/16.
//  Copyright © 2016 Anastasia Tarasova. All rights reserved.
//

#import "VideoSource.h"

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation VideoSource
@synthesize videoCamera;

-(instancetype)init {
    
    self = [super init];
    if(self){
        isRunning = false;
        [self setupCamera];
    }
    return self;
}

- (instancetype)initWithParentView:(UIView*)view{

    self = [super init];
    if(self){
        isRunning = false;
        videoCamera = [[CvVideoCamera alloc]initWithParentView:view];
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
        videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        videoCamera.defaultFPS = 30;
    }
    return self;
}

-(CvVideoCamera*)setupCamera {
    
    if(!videoCamera) {
        
    
        videoCamera = [[CvVideoCamera alloc] init];
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
        videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        videoCamera.defaultFPS = 30;
       
    
        return videoCamera;
        
    } else {
        
    }
    return nil;
}

- (void) startRunning
{
    [videoCamera start];
    isRunning = YES;
}

- (void) stopRunning
{
    [videoCamera stop];
    isRunning = NO;
}


#pragma mark - Orientation
- (void)updateOrientation
{
    previewLayer.bounds = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height);
    [self layoutPreviewLayer];
}

- (void)layoutPreviewLayer
{
    
    if (self.videoCamera.parentView != nil)
    {
        CALayer* layer = previewLayer;
        CGRect bounds = previewLayer.bounds;
        int rotation_angle = 0;
        
        switch (videoCamera.defaultAVCaptureVideoOrientation)
        {
            case AVCaptureVideoOrientationLandscapeRight:
                rotation_angle = 90;
                break;
            case AVCaptureVideoOrientationPortraitUpsideDown:
                rotation_angle = 180;
                break;
            case AVCaptureVideoOrientationPortrait:
                //rotation_angle = 90;
                break;
            case AVCaptureVideoOrientationLandscapeLeft:
                rotation_angle = -90;
                break;
            default:
                break;
        }
        
        layer.position = CGPointMake(self.parentView.frame.size.width/2., self.parentView.frame.size.height/2.);
        layer.affineTransform = CGAffineTransformMakeRotation( DEGREES_RADIANS(rotation_angle) );
        layer.bounds = bounds;
    }
}

#pragma mark - Settirs and Getters
-(AVCaptureVideoPreviewLayer*)previewLayer{

    return videoCamera.captureVideoPreviewLayer;
}

-(UIView*)parentView{

    return videoCamera.parentView;
}
-(void)setParentView:(UIView*)newView{
    
    videoCamera.parentView = newView;
}
-(void)delegate:(id)delegate{

    videoCamera.delegate = delegate;
}


@end
