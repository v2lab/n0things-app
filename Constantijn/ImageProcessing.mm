 //
//  ImageProcessing.m
//  Constantijn
//
//  Created by Jan Misker on 13-08-12.
//  Copyright (c) 2012 V2_. All rights reserved.
//

#import "ImageProcessing.h"

#undef MIN
#include <opencv2/opencv.hpp>


@interface ImageProcessing ()


@end

template <typename T>
std::vector<T>& operator<<(std::vector<T>& vector, const T& value)
{
    vector.push_back(value);
    return vector;
}


@implementation ImageProcessing

+ (ShapeRecord *)detectContourForImage:(UIImage *)img selection:(CGRect)rect {
    /* parameters (could be made configuarable) */
    double grabMaxArea = 35000.0; // will scale image patch to be under this area, the smaller - the faster (but less accurate)
    double roiMargin = 5.0; // after scaling image patch is selection rect plus this margin (for bg detection)
    int denoise = 2; // small subcontours filter - before grab cut
    int simplicity = 3; // contour simplification - after grab cut
    
    /* wrap UIImage for opencv */
    CGImageRef imageRef = img.CGImage;
    
    const int srcWidth        = CGImageGetWidth(imageRef);
    const int srcHeight       = CGImageGetHeight(imageRef);
    const int stride          = CGImageGetBytesPerRow(imageRef);
    const int bitPerPixel     = CGImageGetBitsPerPixel(imageRef);
    const int bitPerComponent = CGImageGetBitsPerComponent(imageRef);
    const int numComponents   = bitPerPixel / bitPerComponent;
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef rawData = CGDataProviderCopyData(dataProvider);
    
    const UInt8 * dataPtr = CFDataGetBytePtr(rawData);

    assert(bitPerComponent == 8);
    assert(numComponents == 3 || numComponents == 4);
    cv::Mat cv_image(srcHeight, srcWidth, CV_8UC(numComponents), (void*)dataPtr, stride);
    
    if (numComponents == 4) {
        // where is alpha?
        CGImageAlphaInfo ainfo = CGImageGetAlphaInfo( imageRef );
        bool afirst = ((ainfo == kCGImageAlphaPremultipliedFirst)
                       || (ainfo == kCGImageAlphaFirst)
                       || (ainfo == kCGImageAlphaNoneSkipFirst));
        
        // split the alpha off
        cv::Mat rgb( cv_image.rows, cv_image.cols, CV_8UC3 );
        cv::Mat alpha( cv_image.rows, cv_image.cols, CV_8UC1 );        
        cv::Mat outs[] = { rgb, alpha };

        std::vector<int> from_to;
        // = { 0,2, 1,1, 2,0, 3,3 };
        if (afirst) {
            from_to << 0<<3 << 1<<0 << 2<<1 << 3<<2;
        } else {
            from_to << 0<<0 << 1<<1 << 2<<2 << 3<<3;
        }
        mixChannels( &cv_image, 1, outs, 2, from_to.data(), 4 );
        cv_image = rgb;
    }
    
    /* convert selection rectangle to opencv */
    cv::Rect grab( CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect) );
    
    // how large should the grab rect become?
    // 40x40=1600, to get 1000: scale is sqrt(1600/1000) =
    double area = grab.width*grab.height;
    double scale = 1.0;
    if (area > grabMaxArea) {
        scale = std::sqrt(grabMaxArea / area);
    }
    
    // find roi so that it will have roiMargin around grab after scaling
    int margin = roiMargin * scale;
    cv::Rect roi(grab);
    roi -= cv::Point(margin, margin);
    roi += cv::Size(margin*2, margin*2);
    roi &= cv::Rect( cv::Point(0,0), cv_image.size() );
    
    // now scale region of interest if necessary
    cv::Mat selection( cv_image, roi );
    cv::Mat scaled = selection;
    if (area > grabMaxArea) {
        cv::resize( selection, scaled, cv::Size(), scale, scale );
    }
    
    // adjust the grab rectangle
    cv::Rect grabInScaled(grab);
    grabInScaled -= roi.tl();
    grabInScaled.x *= scale;
    grabInScaled.y *= scale;
    grabInScaled.width *= scale;
    grabInScaled.height *= scale;
    
    // perform grabcut
    cv::Mat mask, bgd, fgd;
    cv::grabCut( scaled, mask, grabInScaled, bgd, fgd, 1, cv::GC_INIT_WITH_RECT );
    mask = (mask == cv::GC_FGD) + (mask == cv::GC_PR_FGD);
    if (denoise)
        cv::morphologyEx( mask, mask, cv::MORPH_OPEN, cv::Mat(), cv::Point(-1,-1),
                         denoise, cv::BORDER_CONSTANT, cv::Scalar(0) );
    // FIXME average color?
    cv::Scalar color = cv::mean( scaled, mask );
    
    std::vector< std::vector< cv::Point > > contours;
    cv::findContours( mask, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_TC89_L1, roi.tl() );
    if (contours.size() < 1)
        return nil; // no contours found
    
    // find the largest contour
    double max_area=0;
    int max_index=-1;
    for(int i=0; i<contours.size(); i++) {
        double area = cv::contourArea(contours[i]);
        if (contours[i].size() > 2 && area > max_area) {
            max_area = area;
            max_index = i;
        }
    }
    if (max_index < 0)
        return nil; // no contour contains more than 2 vertices
    
    std::vector<cv::Point> contour = contours[max_index];
    
    if (simplicity && contour.size() > 10)
        cv::approxPolyDP(contour, contour, simplicity, true);
    
    // find defects (just to know the count)
    std::vector< int > hull_idx;
    cv::convexHull( contour, hull_idx, false, true );
    std::vector< cv::Vec4i > defects;
    if ( contour.size() > 3 )
        cv::convexityDefects( contour, hull_idx, defects );
    
    // find hu moments
    cv::Moments mom = cv::moments( contour );
    std::vector<double> hu; // 7 doubles
    cv::HuMoments( mom, hu );
        
    CFRelease(rawData);
    
    NSMutableArray *vertices = [NSMutableArray array];
        
    ShapeRecord *result = [[ShapeRecord alloc] init];
    for (int i = 0; i < contour.size(); ++i) {
        [vertices addObject:
         [NSArray arrayWithObjects:
          [NSNumber numberWithDouble:contour[i].x],
          [NSNumber numberWithDouble:contour[i].y], 
          nil]];
    }
    result.vertices = [NSArray arrayWithArray:vertices];
    result.color = [NSArray arrayWithObjects:
                    [NSNumber numberWithInt:color[0]], 
                    [NSNumber numberWithInt:color[1]], 
                    [NSNumber numberWithInt:color[2]], 
                    nil];
    result.huMoments = [NSArray arrayWithObjects:
                        [NSNumber numberWithDouble:hu[0]], 
                        [NSNumber numberWithDouble:hu[1]], 
                        [NSNumber numberWithDouble:hu[2]], 
                        [NSNumber numberWithDouble:hu[3]], 
                        [NSNumber numberWithDouble:hu[4]], 
                        [NSNumber numberWithDouble:hu[5]], 
                        [NSNumber numberWithDouble:hu[6]], 
                        nil];
    result.defectsCount = defects.size();

    return result;
}

+ (NSArray *)mapShapeRecord:(ShapeRecord *)shape withWeights:(NSArray *)weights {
    //double weight1 = [[weights objectAtIndex:0] doubleValue];
    
    NSMutableArray *result = [NSMutableArray array];
    /* do your thing */
    
    /* add the objects to the mutable array*/
    [result addObject:[NSNumber numberWithDouble:2.]];
    return [NSArray arrayWithArray:result];
}

+ (double)distanceBetweenPointA:(NSArray *)pointA andPointB:(NSArray *)pointB {
    if (pointA.count != pointB.count) {
        return DBL_MAX;
    }
    double result = 0;
    for (int i = 0; i < pointA.count; ++i) {
        double a = [(NSNumber *)[pointA objectAtIndex:i] doubleValue];
        double b = [(NSNumber *)[pointB objectAtIndex:i] doubleValue];
        result += (a-b)*(a-b);
    }
    return result;
}

@end
