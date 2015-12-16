//
//  AKAuthManager.h
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AKCompletionBlockUserName)(NSString *userName);

@interface AKAuthManager : NSObject

+ (AKAuthManager *) authManager;
- (void) userAuthenticateCallback:(NSURL *)callbackURL withCompletionBlock:(AKCompletionBlockUserName)completion;
- (void)getUserNameWithCompletion:(AKCompletionBlockUserName)completion;

@end
