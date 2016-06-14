//
//  MarkerDetector.h
//  Filters_OpenCV
//
//  Created by Admin on 09.05.15.
//  Copyright (c) 2015 tarasova_aa. All rights reserved.
//




////////////////////////////////////////////////////////////////////
// Стандартные библиотеки:
#include <vector>
#include <opencv2/opencv.hpp>

////////////////////////////////////////////////////////////////////
// File includes:
#include "CameraCalibration.hpp"
using namespace cv;
using namespace std;

////////////////////////////////////////////////////////////////////
// Forward declaration:
class Marker;

/**
 * A top-level class that encapsulate marker detector algorithm
 */
class MarkerDetector
{
public:
    
    typedef std::vector<vector<cv::Point>> ContoursVector;
    
    
    MarkerDetector(CameraCalibration calibration);
    
    const std::vector<Transformation>& getTransformations();
    
    void DrawDetectedMarkers(Mat& frame,std::vector<Marker>& detectedMarkers,cv::Scalar colorScalar);
    
    //detection states
    void Step_grayscale(cv::Mat& frame);
    void Step_threshold(cv::Mat& frame);
    void Step_contours(cv::Mat& frame);
    void Step_candidates(cv::Mat& frame);
    void processFrame( Mat& frame);
    
    
    
protected:
    
    //! Main marker detection routine
    bool findMarkers(cv::Mat& frame, std::vector<Marker>& detectedMarkers);
    
    //! Converts image to grayscale
    void prepareImage(cv::Mat& frame, cv::Mat& grayscale) ;
    
    //! Performs binary threshold
    void performThreshold(cv::Mat& grayscale, cv::Mat& thresholdImg) ;
    
    //! Detects appropriate contours
    void findContours(cv::Mat& thresholdImg, ContoursVector& contours, int minContourPointsAllowed);
    
    //! Finds marker candidates among all contours
    void findCandidates(ContoursVector& contours, std::vector<Marker>& detectedMarkers);
    
    //! Tries to recognize markers by detecting marker code
    void recognizeMarkers(cv::Mat& grayscale, std::vector<Marker>& detectedMarkers);
    
    //! Calculates marker poses in 3D
    void estimatePosition(std::vector<Marker>& detectedMarkers);
    
private:
    float m_minContourLengthAllowed;
    
    cv::Size markerSize;
    cv::Mat camMatrix;
    cv::Mat distCoeff;
    std::vector<Transformation> m_transformations;
    
    cv::Mat m_grayscaleImage;
    cv::Mat m_thresholdImg;
    cv::Mat canonicalMarkerImage;
    
    ContoursVector           m_contours;
    std::vector<cv::Point3f> m_markerCorners3d;
    std::vector<cv::Point2f> m_markerCorners2d;
    
    
};


