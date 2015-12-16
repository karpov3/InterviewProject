//
//  MKMapView+AKZoomLevel.m
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import "MKMapView+AKZoomLevel.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395


@implementation MKMapView (AKZoomLevel)

#pragma mark -
#pragma mark Map conversion methods

+ (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

#pragma mark -
#pragma mark Public methods

- (NSUInteger) zoomLevel {
    MKCoordinateRegion region = self.region;
    
    double centerPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude];
    double topLeftPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude - region.span.longitudeDelta / 2];
    
    double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2;
    CGSize mapSizeInPixels = self.bounds.size;
    double zoomScale = scaledMapWidth / mapSizeInPixels.width;
    double zoomExponent = log(zoomScale) / log(2);
    double zoomLevel = 20 - zoomExponent;
    
    return zoomLevel;
}


@end
