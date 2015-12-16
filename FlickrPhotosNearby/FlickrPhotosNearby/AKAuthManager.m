//
//  AKAuthManager.m
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import "AKAuthManager.h"
#import "FlickrKit.h"

@interface AKAuthManager ()

@property (nonatomic, strong) FKDUNetworkOperation *checkAuthOp;
@property (nonatomic, strong) FKDUNetworkOperation *completeAuthOp;
@property (nonatomic, strong) NSString *userID;

@end

@implementation AKAuthManager

+ (AKAuthManager *) authManager {
    static dispatch_once_t onceToken;
    static AKAuthManager *authManager = nil;
    
    dispatch_once(&onceToken, ^{
        authManager = [[self alloc] init];
    });
    
    return authManager;
}


- (void) userAuthenticateCallback:(NSURL *)callbackURL withCompletionBlock:(AKCompletionBlockUserName)completion {
    
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                
                if (completion) {
                    completion(userName);
                }
                
            } else {
                
                if (completion) {
                    completion(nil);
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        });
    }];
    
}

//check if user already logged in
- (void)getUserNameWithCompletion:(AKCompletionBlockUserName)completion {
    self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                
                if (completion) {
                    completion(userName);
                }
            }
            else {
                
                if (completion) {
                    completion(nil);
                }
                
            }
        });
    }];
}


@end
