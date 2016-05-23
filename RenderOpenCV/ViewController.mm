//
//  ViewController.m
//  RenderOpenCV
//
//  Created by Anastasia Tarasova on 23/05/16.
//  Copyright © 2016 Anastasia Tarasova. All rights reserved.
//

#import "ViewController.h"
#import "VideoSource.h"
#import "CalibrationWrapper.h"

@interface ViewController ()<CvVideoCameraDelegate>{

    BOOL addedObservers;
    CalibrationWrapper * cameraCalibrator;
    VideoSource * videoManager;
}

@property (nonatomic,strong) VideoSource * videoManager;
@property (nonatomic,strong) CalibrationWrapper * cameraCalibrator;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cameraCalibrator = [[CalibrationWrapper alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustOrientation)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:[UIApplication sharedApplication]];
    
    addedObservers = YES;
    
    // Keep track of changes to the device orientation so we can update the capture pipeline
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    
    videoManager = [[VideoSource alloc] initWithParentView:self.view];
    videoManager.videoCamera.delegate = self;
    [videoManager startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustOrientation {
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [videoManager layoutPreviewLayer];
    [videoManager updateOrientation];
    //[videoManager layoutPreviewLayer];
    
}


-(void)processImage:(cv::Mat &)image{

    //[cameraCalibrator drawCheccBoardCornersOnFrame:image];
    cv::cvtColor(image, image, CV_BGRA2GRAY);
    
}
@end

