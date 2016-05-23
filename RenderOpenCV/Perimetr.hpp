//
//  TinyLA.h
//  Filters_OpenCV
//
//  Created by Admin on 10.05.15.
//  Copyright (c) 2015 tarasova_aa. All rights reserved.
//



#include <vector>
#include <opencv2/opencv.hpp>

float perimeter(const std::vector<cv::Point2f> &a);

bool isInto(cv::Mat &contour, std::vector<cv::Point2f> &b);

