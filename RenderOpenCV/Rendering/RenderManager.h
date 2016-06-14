//
//  RenderManager.h
//  RenderOpenCV
//
//  Created by Anastasia Tarasova on 24/05/16.
//  Copyright © 2016 Anastasia Tarasova. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GeometryTypes.hpp"
#import "CameraCalibration.hpp"

@interface RenderManager : NSObject{
    
    std::vector<Transformation> m_transformations;
    CameraCalibration m_calibration;
    GLuint width;
    GLuint height;
}

-(instancetype)initWithCalibration:(CameraCalibration)calibration;
- (void)drawFrame:(cv::Mat&)frame withTransformations:(const std::vector<Transformation>&)transformations;

@end
