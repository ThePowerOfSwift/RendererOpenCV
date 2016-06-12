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
#import "MarkerDetector.hpp"
#include "CameraCalibration.hpp"
#import "RenderManager.h"

@interface ViewController ()<CvVideoCameraDelegate>{

    BOOL addedObservers;
    CalibrationWrapper * cameraCalibrator;
    VideoSource * videoManager;
    MarkerDetector * markerDetector;
    CameraCalibration cameraParams;
    RenderManager * renderer;
    int mode;
    
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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    videoManager = [[VideoSource alloc] initWithParentView:self.view];
    videoManager.videoCamera.delegate = self;
    [videoManager startRunning];
    
    
    
    cameraParams = CameraCalibration(6.24860291e+02 * (640./352.), 6.24860291e+02 * (480./288.), 640 * 0.5f, 480 * 0.5f);
    
    markerDetector = new MarkerDetector(cameraParams);
    renderer = [[RenderManager alloc]initWithCalibration:cameraParams];
    //markerDetector = new MarkerDetector(cameraParams);
    mode = 4;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustOrientation {
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
}


-(void)processImage:(cv::Mat &)image{

    //[renderer CVMat2GLTexture:image];
    //
    dispatch_sync(dispatch_get_main_queue(), ^{
    
        markerDetector->processFrame(image);
        
        
        [renderer drawFrame:image withTransformations:markerDetector->getTransformations()];
    }) ;
    //markerDetector->processFrame(image);
    
       
    //[renderer drawFrame:image withTransformations:markerDetector->getTransformations()];
    /*switch (mode) {
        case 0:
            self.markerDetector->Step_grayscale(image);
            break;
        case 1:
            self.markerDetector->Step_threshold(image);
            break;
        case 2:
            self.markerDetector->Step_contours(image);
            break;
        case 3:
            self.markerDetector->Step_candidates(image);
            break;
        case 4:
            self.markerDetector->processFrame(image);
            break;
        default:
            break;
    }*/
    
   
}
@end

