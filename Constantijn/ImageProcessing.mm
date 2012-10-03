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

#include <algorithm>
#include <math.h>

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
    // parameters (could be made configuarable)
    int grabMaxArea = 20000; // will scale image patch to be under this area, the smaller - the faster (but less accurate)
    int roiMargin = 10; // after scaling image patch is selection rect plus this margin (for bg detection)
    int denoise = 1; // small subcontours filter - before grab cut
    int simplicity = 2; // contour simplification - after grab cut

    // We want to crop a portion around rect
    int area = rect.size.width * rect.size.height;
    double scale = 1.0;
    if (grabMaxArea < area) {
        scale = std::sqrt((double)grabMaxArea / (double)area);
    }
    int margin = std::max(2, (int)((double)roiMargin / scale));
    CGRect cropRect = CGRectIntersection(CGRectInset(rect, -margin , -margin ),
                                         CGRectMake(0, 0, img.size.width, img.size.height));
    NSLog( @"Crop\n  Rect: %.0f,%.0f,%.0f,%.0f\n  Area: %d\n  Scale: %.2f\n  Margin: %d\n  cropRect: %.0f,%.0f,%.0f,%.0f\n",
          rect.origin.x, rect.origin.y, rect.size.width, rect.size.height,
          area,
          scale,
          margin,
          cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.height );

    // we rely on OpenCV to allocate / deallocate memory for the cropped image...
    cv::Mat scaled( cropRect.size.height * scale, cropRect.size.width * scale, CV_8UC4 ); // RGBA

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context =
        CGBitmapContextCreate(scaled.data, scaled.cols, scaled.rows,
                              8, 4 * scaled.cols, colorSpace,
                              kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);

    CGColorSpaceRelease(colorSpace);

    // crop, scale and convert to RGB
    CGImageRef imageRef = img.CGImage;
    CGImageRef cropPortion = CGImageCreateWithImageInRect(imageRef, cropRect);
    CGContextDrawImage(context, CGRectMake(0, 0, scaled.cols, scaled.rows), cropPortion);
    CGContextRelease(context);
    CGImageRelease(cropPortion);

    // convert RGBA->RGB
    cv::cvtColor(scaled, scaled, CV_RGBA2RGB);

    // now we need a cv::Rect corresponding to 'rect' in cropped, scaled image
    cv::Rect grabInScaled(scale * (rect.origin.x - cropRect.origin.x),
                          scale * (rect.origin.y - cropRect.origin.y),
                          scale * rect.size.width,
                          scale * rect.size.height);
    NSLog( @"GrabCut input\n  Image size: %d,%d\n  Scaled rect: %d,%d,%d,%d\n",
          scaled.cols, scaled.rows,
          grabInScaled.x, grabInScaled.y, grabInScaled.width, grabInScaled.height);

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
    cv::findContours( mask, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_TC89_L1 );
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

    NSMutableArray *vertices = [NSMutableArray array];

    ShapeRecord *result = [[ShapeRecord alloc] init];
    for (int i = 0; i < contour.size(); ++i) {
        [vertices addObject:
         [NSArray arrayWithObjects:
          [NSNumber numberWithInt:contour[i].x / scale + cropRect.origin.x],
          [NSNumber numberWithInt:contour[i].y / scale + cropRect.origin.y],
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
    NSMutableArray *result = [NSMutableArray array];
    /* do your thing */
    std::vector<double> W(12);
    for(int i=0; i<12; i++)
        W[i] = [[weights objectAtIndex: i] doubleValue];

    for(int i=0; i<7; i++) {
        double v = [[shape.huMoments objectAtIndex: i] doubleValue];
        [result addObject:[NSNumber numberWithDouble: W[i] * v]];
    }
    for(int i=0; i<3; i++) {
        double v = [[shape.color objectAtIndex: i] doubleValue];
        [result addObject:[NSNumber numberWithDouble: W[i+7] * v]];
    }
    [result addObject:[NSNumber numberWithDouble: W[10] * log((double)[shape.vertices count] - 2.0)]];
    [result addObject:[NSNumber numberWithDouble: W[11] * log((double) shape.defectsCount + 1.0)]];


    /* add the objects to the mutable array*/
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
    return sqrt(result);
}

@end
