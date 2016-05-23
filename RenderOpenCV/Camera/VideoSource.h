//
//  VideoSource.h
//  RenderOpenCV
//
//  Created by Anastasia Tarasova on 23/05/16.
//  Copyright © 2016 Anastasia Tarasova. All rights reserved.
//

#import <opencv2/videoio/cap_ios.h>

@protocol VideoSourceDelegate;

@interface VideoSource : NSObject{

     BOOL isRunning;
    UIView* parentView;
    AVCaptureVideoPreviewLayer * previewLayer;
}

@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, weak) id  delegate;
@property (nonatomic) AVCaptureVideoOrientation cameraOrientation;
@property (nonatomic) AVCaptureDevicePosition devicePosition;

@property(nonatomic,strong) AVCaptureVideoPreviewLayer * previewLayer;
@property(nonatomic,strong) UIView* parentView;

- (instancetype)initWithParentView:(UIView*)parentView;

- (void) startRunning;

- (void) stopRunning;

- (void) switchCamera;

- (void)loadCamera:(AVCaptureDevicePosition)position withOrientation:(AVCaptureVideoOrientation) orientation ;

- (void)layoutPreviewLayer;
- (void)updateOrientation;

//- (UIImage *)scaleAndRotateImage:(UIImage *) image;

@end

@protocol VideoSourceDelegate<NSObject>

@end

