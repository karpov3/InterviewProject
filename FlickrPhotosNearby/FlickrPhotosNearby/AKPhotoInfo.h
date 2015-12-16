//
//  AKPhotoInfo.h
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

typedef void(^AKCompletionBlockWithError)(NSError *error);

@interface AKPhotoInfo : NSObject<MKAnnotation>

@property (strong, nonatomic) NSURL *urlPhoto;
@property (strong, nonatomic) NSString *titlePhoto;
@property (strong, nonatomic) NSString *idPhoto;

- (id)initWithDictionary:(NSDictionary*) dictionary;
- (void)getInfoWithCompletion:(AKCompletionBlockWithError)completion;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
