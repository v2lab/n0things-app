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


@implementation ImageProcessing

+ (ShapeRecord *)detectContourForImage:(UIImage *)img selection:(CGRect)rect {
    
    /* or see: http://niw.at/articles/2009/03/14/using-opencv-on-iphone/en */

    /*
    CGImageRef imageRef = img.CGImage;
    
    const int srcWidth        = CGImageGetWidth(imageRef);
    const int srcHeight       = CGImageGetHeight(imageRef);
    const int stride          = CGImageGetBytesPerRow(imageRef);
    const int bitPerPixel     = CGImageGetBitsPerPixel(imageRef);
    const int bitPerComponent = CGImageGetBitsPerComponent(imageRef);
    const int numPixels       = bitPerPixel / bitPerComponent;
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef rawData = CGDataProviderCopyData(dataProvider);
    
    const UInt8 * dataPtr = CFDataGetBytePtr(rawData);
    
    UIImageOrientation orientation = img.imageOrientation;
    
    int dstWidth = srcWidth;
    int dstHeight = srcHeight;
    
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight)
    {
        std::swap(dstWidth, dstHeight); // swap width and height since we have to rotate image to 90 degrees.
    }
    
    if (numPixels == 4 && bitPerComponent == 8)
    {
        //bgra8_view_t sourceView = interleaved_view(srcWidth, srcHeight,(bgra8_pixel_t*)dataPtr, stride);
        //copy_with_regards_to_orientation(sourceView, view(result), orientation);
    }
    else if(numPixels == 3 && bitPerComponent == 8)
    {
        //bgr8_view_t sourceView = interleaved_view(srcWidth, srcHeight,(bgr8_pixel_t*)dataPtr, stride);
        //copy_with_regards_to_orientation(sourceView, view(result), orientation);
    }
    else if(numPixels == 1 && bitPerComponent == 8) // Assume gray pixel
    {
        // assume grayscale image
        //gray8_view_t sourceView = interleaved_view(srcWidth, srcHeight,(gray8_pixel_t*)dataPtr, stride);
        //copy_with_regards_to_orientation(sourceView, view(result), orientation);
    }
    else
    {
        NSLog(@"Unsupported format of the input UIImage (neither BGRA, BGR or GRAY)");
    }
    
    CFRelease(rawData);
    IplImage *cvImg;
    */
    
    int red = arc4random() % 256;
    int green = arc4random() % 256;
    int blue = arc4random() % 256;
    //UIColor *color = [UIColor colorWithRed:red/255. green:0. blue:0. alpha:1.];
    NSArray *color = [NSArray arrayWithObjects:[NSNumber numberWithInt:red], [NSNumber numberWithInt:green], [NSNumber numberWithInt:blue], nil];
    NSMutableArray *vertices = [NSMutableArray array];
    
    //data looks something like this ??
    double x[9];
    double y[9];
    int vertexCount = 9;
    for (int i = 0; i < vertexCount; ++i) {
        [vertices addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:x[i]],
                             [NSNumber numberWithDouble:y[i]], nil]];
    }
    /* something to create output*/
    [vertices removeAllObjects];
    [vertices addObject:[NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:rect.origin.x],
                         [NSNumber numberWithDouble:rect.origin.y], nil]];
    [vertices addObject:[NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:rect.origin.x + rect.size.width],
                         [NSNumber numberWithDouble:rect.origin.y], nil]];
    [vertices addObject:[NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:rect.origin.x + rect.size.width],
                         [NSNumber numberWithDouble:rect.origin.y + rect.size.height], nil]];
    [vertices addObject:[NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:rect.origin.x],
                         [NSNumber numberWithDouble:rect.origin.y + rect.size.height], nil]];
    [vertices addObject:[NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:rect.origin.x],
                         [NSNumber numberWithDouble:rect.origin.y], nil]];
    
    ShapeRecord *result = [[ShapeRecord alloc] init];
    result.vertices = [NSArray arrayWithArray:vertices];
    result.color = color;
    result.huMoments = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.2], [NSNumber numberWithDouble:0.2], [NSNumber numberWithDouble:0.2], nil];
    result.defectsCount = 1;

    sleep(1); //for testing purposes

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
