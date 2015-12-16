//
//  AKPhotoInfo.m
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import "AKPhotoInfo.h"
#import "FlickrKit.h"


@implementation AKPhotoInfo

- (instancetype)initWithDictionary:(NSDictionary*) dictionary
{
    self = [super init];
    if (self) {
        [self parseDataFrom:dictionary];
    }
    return self;
}


- (void) parseDataFrom:(NSDictionary*) dict {
    
    if([dict objectForKey:@"id"]) {
        self.idPhoto = [dict objectForKey:@"id"];
    }
    
    if([dict objectForKey:@"title"]) {
        self.titlePhoto = [dict objectForKey:@"title"];
    }
    
    self.urlPhoto = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmall320 fromPhotoDictionary:dict];
    self.title = @"Some place";
    self.subtitle = self.titlePhoto;
    
    
}

- (void)getInfoWithCompletion:(AKCompletionBlockWithError)completion {
    
    FKFlickrPhotosGeoGetLocation *location = [[FKFlickrPhotosGeoGetLocation alloc] init];
    
    location.photo_id = self.idPhoto;
    
    [[FlickrKit sharedFlickrKit] call:location completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response) {
                
                NSDictionary *location = [response valueForKeyPath:@"photo.location"];
                CGFloat latitude = (CGFloat)[[location objectForKey:@"latitude"] floatValue];
                CGFloat longitude = (CGFloat)[[location objectForKey:@"longitude"] floatValue];
                self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                
                NSDictionary *county = [location valueForKeyPath:@"county"];
                NSString * countyName = [county objectForKey:@"_content"];
                
                if (countyName) {
                    self.title = countyName;
                }
                
                if (completion)
                {
                    completion(nil);
                }
                
            } else {
                
                if (completion)
                {
                    completion(error);
                }
            }
        });
    }];
    
    
}



@end
