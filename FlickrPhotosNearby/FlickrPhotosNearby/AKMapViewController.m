//
//  AKMapViewController.m
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import "AKMapViewController.h"
#import "FlickrKit.h"
#import "AKAuthViewController.h"
#import "AKPhotoInfo.h"
#import <MapKit/MapKit.h>
#import "AKPhotoViewController.h"
#import "MKMapView+AKZoomLevel.h"
#import "AKAuthManager.h"


#define MARGIN_MAPVIEW 20
#define DELTA_MAPVIEW 20
#define DEFAULT_FLICKR_MIN_LONG 160
#define DEFAULT_FLICKR_MAX_LONG 179

@interface AKMapViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logInOutButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray *addedPin;
@property (nonatomic, strong) NSMutableArray *zoneRect;
@property (atomic, assign) CLLocationCoordinate2D currentCenterMap;
@property (assign, nonatomic) BOOL secondAppearMap;
@property (assign, nonatomic) NSInteger currentZoomLevel;

#pragma mark Private Methods
- (IBAction)loginButtonAction:(id)sender;

@end

@implementation AKMapViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addedPin = [[NSMutableArray alloc] init];// save annotations that should be added
    self.zoneRect = [[NSMutableArray alloc] init];// save map rect already used
    
    // Check if User authorized the app already
    [[AKAuthManager authManager] getUserNameWithCompletion:^(NSString *userName) {
        [self navigationBarTitle:userName];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.secondAppearMap == YES) {
        [self showPinsOnMap];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    if (![FlickrKit sharedFlickrKit].isAuthorized) {
        [self deleteAllAnnotation];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"PhotoViewControllerID"]) {
        
        AKPhotoInfo *photo = [sender annotation];
        
        AKPhotoViewController *controller=(AKPhotoViewController *)segue.destinationViewController;
        controller.photo = photo;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation bar text

- (void) navigationBarTitle:(NSString*) userName {
    if (userName) {
        self.logInOutButton.title = @"Logout";
        self.title = [NSString stringWithFormat:@"Welcome,  %@!", userName];
    } else {
        self.logInOutButton.title = @"Login";
        self.title = @"Please, login!";
        
    }
}

#pragma mark - Action Methods

- (IBAction)loginButtonAction:(id)sender {
    
    if ([FlickrKit sharedFlickrKit].isAuthorized) {
        [[FlickrKit sharedFlickrKit] logout];
        [self navigationBarTitle:nil];
    } else {
        [self openAuthPage];
    }
}



- (void) closeAuthViewControllerWithCallback:(NSURL*) url {
    //[self titleForNavigation];
    
    [[AKAuthManager authManager] userAuthenticateCallback:url withCompletionBlock:^(NSString *userName) {
        [self navigationBarTitle:userName];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
}


#pragma mark - Auth Method

- (void) openAuthPage {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AKAuthViewController *authView = [storyboard instantiateViewControllerWithIdentifier:@"AuthViewControllerID"];
    authView.page = self;
    [self.navigationController pushViewController:authView animated:YES];
    
    //set title for cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:nil
                                                                    action:nil];
    [self.navigationItem setBackBarButtonItem:cancelButton];
}

#pragma mark - Get Data From Flick API

- (void) getPhotosFromFlickr {
    
    FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
    
    search.bbox = [self getBoundingBoxForFlickr];
    //search.per_page = @"20";
    
    self.addedPin = [NSMutableArray array];
    
    [[FlickrKit sharedFlickrKit] call:search completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response) {
                
                NSArray *photoDictionaries = [response valueForKeyPath:@"photos.photo"];
                
                for (NSDictionary *photoDictionary in photoDictionaries) {
                    
                    AKPhotoInfo *photo = [[AKPhotoInfo alloc] initWithDictionary:photoDictionary];
                    
                    [photo getInfoWithCompletion:^(NSError *error) {
                        
                        if (!error) {
                            [self addPinOnMap:photo];
                            [self.addedPin addObject:photo];
                        }
                    }];
                }
            } else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        });
    }];
    
    
}
#pragma mark - MKMapViewDelegate


// this method add in array zones (MKMapRect) with inserted annotations

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    
    if (self.secondAppearMap == NO && fullyRendered) {
        [self showPinsOnMap];
        self.secondAppearMap = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (self.secondAppearMap == YES) {
        [self showPinsOnMap];
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"Annotation";
    MKAnnotationView *pin = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!pin) {
        pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        pin.canShowCallout = YES;
        pin.draggable = NO;
        pin.image = [UIImage imageNamed:@"pin.png"];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.rightCalloutAccessoryView = btn;
        
    } else {
        pin.annotation = annotation;
    }
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self performSegueWithIdentifier:@"PhotoViewControllerID" sender:view];
}

#pragma mark - MKMapView Actions

- (void) showPinsOnMap {
    
    if ([self authorizeLoadData]) {
        
        [self zoomLevelChanged];
        [self getPhotosFromFlickr];
        [self createAnnotationWithRect];
    }
}

- (void) addPinOnMap:(AKPhotoInfo*) photo {
    
    CLLocationCoordinate2D coordiante = photo.coordinate;
    
    if (![self checkRegionForAnnotation:coordiante] && [FlickrKit sharedFlickrKit].isAuthorized) {
        
        id annotation = (MKAnnotationView*)photo;
        [self.mapView addAnnotation:annotation];
        
    }
}

- (void) deleteAllAnnotation {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.zoneRect removeAllObjects];
    self.currentCenterMap = CLLocationCoordinate2DMake(0, 0);
}

- (void) zoomLevelChanged {
    
    NSInteger newZoomLevel = [self.mapView zoomLevel];
    
    if (self.currentZoomLevel) {
        
        if (self.currentZoomLevel < newZoomLevel) {
            
            [self.zoneRect removeAllObjects];
            
        } else if (self.currentZoomLevel > newZoomLevel) {
            [self deleteAllAnnotation];
        }
    }
    
    self.currentZoomLevel = newZoomLevel;
    
}

//new annotations
- (void) createAnnotationWithRect {
    
    MKMapRect visibleMapRect = [self visibleMapRect];
    NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:visibleMapRect];
    
    MKMapRect rectWithAnnotaions = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in visibleAnnotations) {
        
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        
        static double delta = DELTA_MAPVIEW;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        rectWithAnnotaions = MKMapRectUnion(rectWithAnnotaions, rect);
        
    }
    
    NSValue *value = [NSValue valueWithBytes:&rectWithAnnotaions objCType:@encode(MKMapRect)];
    [self.zoneRect addObject:value];
}

#pragma mark Check Methods

- (BOOL) checkRegionForAnnotation:(CLLocationCoordinate2D) location {
    
    MKMapPoint center = MKMapPointForCoordinate(location);
    
    for (NSValue *value in self.zoneRect) {
        
        MKMapRect structValue;
        [value getValue:&structValue];
        
        BOOL contains = MKMapRectContainsPoint(structValue, center);
        
        if (contains) {
            return YES;
        }
        
    }
    return NO;
}

- (BOOL) authorizeLoadData {
    
    if ([FlickrKit sharedFlickrKit].isAuthorized && [self checkPositionCenterMapViewChanged]) {
        
        return YES;
    }
    
    return NO;
}

- (BOOL) checkPositionCenterMapViewChanged {
    
    CLLocationCoordinate2D currentCenter = [self.mapView centerCoordinate];
    CLLocationCoordinate2D savedCenter = self.currentCenterMap;
    
    if (currentCenter.longitude != savedCenter.longitude || currentCenter.latitude != savedCenter.latitude) {
        self.currentCenterMap = currentCenter;
        return YES;
    }
    return NO;
}



#pragma mark Other methods

- (MKMapRect) visibleMapRect {
    
    NSInteger margin = MARGIN_MAPVIEW;
    
    CGPoint minPoint = CGPointMake(0+margin, self.navigationController.navigationBar.frame.size.height+margin);
    CGPoint maxPoint = CGPointMake(self.mapView.frame.size.width-margin, self.mapView.frame.size.height-margin);
    
    CLLocationCoordinate2D min = [self.mapView convertPoint:minPoint toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D max = [self.mapView convertPoint:maxPoint toCoordinateFromView:self.mapView];
    
    MKMapPoint p1 = MKMapPointForCoordinate (min);
    MKMapPoint p2 = MKMapPointForCoordinate (max);
    
    // and make a MKMapRect using mins and spans
    MKMapRect mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));
    
    return mapRect;
}


- (NSString*) getBoundingBoxForFlickr {
    
    //    The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude.
    
    NSInteger margin = MARGIN_MAPVIEW;
    
    CGPoint bottomLeftCorner = CGPointMake(0+margin, self.mapView.frame.size.height-margin);
    CGPoint topRightCorner = CGPointMake(self.mapView.frame.size.width-margin, self.navigationController.navigationBar.frame.size.height+margin);
    
    CLLocationCoordinate2D min = [self.mapView convertPoint:bottomLeftCorner toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D max = [self.mapView convertPoint:topRightCorner toCoordinateFromView:self.mapView];
    
    CGFloat minLongitude = min.longitude;
    CGFloat minLatitude = min.latitude;
    CGFloat maxLongitude = max.longitude;
    CGFloat maxLatitude = max.latitude;
    
    if (minLongitude > maxLongitude) {
        minLongitude = DEFAULT_FLICKR_MIN_LONG;
        maxLongitude = DEFAULT_FLICKR_MAX_LONG;
    }
    
    NSString *getBbox = [NSString stringWithFormat:
                         @"%f,%f,%f,%f", minLongitude, minLatitude, maxLongitude, maxLatitude];
    
    return getBbox;
}


@end
