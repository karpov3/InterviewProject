//
//  AppDelegate.m
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrKit.h"

#define FLICKR_API_KEY @"81448f1415a110c22c921143cdaac378"
#define FLICKR_API_SECRET @"09b925e30f9be535"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Insert apiKet and secret code here https://www.flickr.com/services/apps/create/apply/
    
    NSString *apiKey = FLICKR_API_KEY;
    NSString *secret = FLICKR_API_SECRET;
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:apiKey sharedSecret:secret];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
