//
//  CamCalib.cpp
//  RenderOpenCV
//
//  Created by Anastasia Tarasova on 14/06/16.
//  Copyright © 2016 Anastasia Tarasova. All rights reserved.
//

#include "CamCalib.hpp"


#pragma mark - Public functions

// Open chessboard images and extract corner points
int CamCalib::addChessboardPoints(
                                          vector<cv::Mat> &images,
                                          cv::Size & boardSize) {
    // the points on the chessboard
    vector<cv::Point2f> imageCorners;
    vector<cv::Point3f> objectCorners;
    
    int successes = 0;
    // for all viewpoints
    for (int i=0; i<images.size(); i++) {
        
        int res = findBoardPoints(images[i], boardSize, imageCorners, objectCorners);
        if (res > 0){
            // Add image and scene points from one view
            addPoints(imageCorners, objectCorners);
            successes++;
        }
    }
    
    return successes;
}


/**
 Once a sufficient number of chessboard images have been processed (and consequently a large number of 3D scene point/2D image point correspondences are available), we can initiate the computation of the calibration parameters
 */
double CamCalib::calibrate(cv::Size &imageSize) {
    
    cout << "Start calibration" << endl;
    
    mustInitUndistort = true;
    vector<cv::Mat> rvecs,
    tvects;
    return cv::calibrateCamera(objectPoints, // the 3D points
                               imagePoints, // the image points
                               imageSize, // image size
                               cameraMatrix, // output camera matrix
                               distCoeffs, // output distortion matrix
                               rvecs, tvects, // Rs, Ts
                               flag); // set options
}

/// remove distortion in an image (after calibration)
void CamCalib::remap(cv::Mat &image) {
    cv::Mat undistorted;
    if (mustInitUndistort) { // called once per calibration
        cv::initUndistortRectifyMap(
                                    cameraMatrix,  // computed camera matrix
                                    distCoeffs,    // computed distortion matrix
                                    cv::Mat(),     // optional rectification (none)
                                    cv::Mat(),     // camera matrix to generate undistorted
                                    image.size(),  // size of undistorted
                                    CV_32FC1,      // type of output map
                                    map1, map2);   // the x and y mapping functions
        mustInitUndistort= false;
    }
    // Apply mapping functions
    cv::remap(image, undistorted, map1, map2,
              cv::INTER_LINEAR); // interpolation type
    //return undistorted;
    image = undistorted.clone();
}

void CamCalib::getCameraMatrixAndDistCoeffMatrix(cv::Mat &outputCameraMatrix, cv::Mat &outputDistCoeffMatrix) {
    outputCameraMatrix = cameraMatrix;
    outputDistCoeffMatrix = distCoeffs;
}

void CamCalib::drawBoardCorners(cv::Mat &image, cv::Size &boardSize){
    
    // the points on the chessboard
    vector<cv::Point2f> imageCorners;
    vector<cv::Point3f> objectCorners;
    
    cv::Mat grayImage; // grayscale image
    cv::cvtColor(image, grayImage, CV_BGRA2GRAY);
    
    bool patternFound = false ;//=  findBoardPoints(grayImage, boardSize, imageCorners, objectCorners);
    
    for (int i=0; i<boardSize.height; i++) {
        for (int j=0; j<boardSize.width; j++) {
            objectCorners.push_back(cv::Point3f(i, j, 0.0f));
        }
    }
    
    int cornerFlag = CV_CALIB_CB_ADAPTIVE_THRESH | CV_CALIB_CB_NORMALIZE_IMAGE | CV_CALIB_CB_FILTER_QUADS;
    
    patternFound = findChessboardCorners( grayImage, boardSize, imageCorners, cv::CALIB_CB_FAST_CHECK);
    
    if (patternFound == true)
    {
        
        // Get subpixel accuracy on the corners
        //cout << "finding corners subpix" << endl;
        cv::cornerSubPix(grayImage, imageCorners,
                         cv::Size(5,5),
                         cv::Size(-1,-1),
                         cv::TermCriteria(cv::TermCriteria::MAX_ITER +
                                          cv::TermCriteria::EPS,
                                          30,      // max number of iterations
                                          0.1));  // min accuracy
        
       
        //If we have a good board, add it to our data
        if (imageCorners.size() == boardSize.area()) {
            // Add image and scene points from one view
            //success = true;
        }
    }
    
    if (patternFound)
    {
        //cout << "draw chessboard corners" << endl;
        cv::drawChessboardCorners(image, boardSize, imageCorners, patternFound);
    }
    //cout << image.channels();
    
    
}

#pragma mark - Private functions

bool CamCalib::findBoardPoints(cv::Mat &image,
                                       cv::Size & boardSize,vector<cv::Point2f> &imageCorners,
                                       vector<cv::Point3f> &objectCorners )
{
    bool success = false;
    // 3D Scene Points:
    // Initialize the chessboard corners
    // in the chessboard reference frame
    // The corners are at 3D location (X,Y,Z)= (i,j,0)
    for (int i=0; i<boardSize.height; i++) {
        for (int j=0; j<boardSize.width; j++) {
            objectCorners.push_back(cv::Point3f(i, j, 0.0f));
        }
    }
    // 2D Image points:
    

   
    
    // Get the chessboard corners
    cout << "finding chessboard corners" << endl;
    cout<<image.channels();
    
    int cornerFlag = CV_CALIB_CB_ADAPTIVE_THRESH | CV_CALIB_CB_NORMALIZE_IMAGE | CV_CALIB_CB_FILTER_QUADS;
    bool res;
    res = findChessboardCorners( image, boardSize, imageCorners, cornerFlag);

    if (res == true)
    {
        
        // Get subpixel accuracy on the corners
        cout << "finding corners subpix" << endl;
        cv::cornerSubPix(image, imageCorners,
                         cv::Size(5,5),
                         cv::Size(-1,-1),
                         cv::TermCriteria(cv::TermCriteria::MAX_ITER +
                                          cv::TermCriteria::EPS,
                                          30,      // max number of iterations
                                          0.1));  // min accuracy
        //If we have a good board, add it to our data
        if (imageCorners.size() == boardSize.area()) {
            // Add image and scene points from one view
            success = true;
        }
    }
    
    return success;
}

/// add recognized image and vector points to vectors
void CamCalib::addPoints(const vector<cv::Point2f> &imageCorners, const vector<cv::Point3f> &objectCorners) {
    imagePoints.push_back(imageCorners);
    objectPoints.push_back(objectCorners);
}
