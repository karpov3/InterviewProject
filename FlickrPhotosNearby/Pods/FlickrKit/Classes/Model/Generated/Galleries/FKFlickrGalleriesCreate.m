//
//  FKFlickrGalleriesCreate.m
//  FlickrKit
//
//  Generated by FKAPIBuilder on 19 Sep, 2014 at 10:49.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrGalleriesCreate.h" 

@implementation FKFlickrGalleriesCreate


@synthesize description = _description;

- (BOOL) needsLogin {
    return YES;
}

- (BOOL) needsSigning {
    return YES;
}

- (FKPermission) requiredPerms {
    return 1;
}

- (NSString *) name {
    return @"flickr.galleries.create";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];
	if(!self.title) {
		valid = NO;
		[errorDescription appendString:@"'title', "];
	}
	if(!self.description) {
		valid = NO;
		[errorDescription appendString:@"'description', "];
	}

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.title) {
		[args setValue:self.title forKey:@"title"];
	}
	if(self.description) {
		[args setValue:self.description forKey:@"description"];
	}
	if(self.primary_photo_id) {
		[args setValue:self.primary_photo_id forKey:@"primary_photo_id"];
	}
	if(self.full_result) {
		[args setValue:self.full_result forKey:@"full_result"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrGalleriesCreateError_RequiredParameterMissing:
			return @"Required parameter missing";
		case FKFlickrGalleriesCreateError_InvalidTitleOrDescription:
			return @"Invalid title or description";
		case FKFlickrGalleriesCreateError_FailedToAddGallery:
			return @"Failed to add gallery";
		case FKFlickrGalleriesCreateError_SSLIsRequired:
			return @"SSL is required";
		case FKFlickrGalleriesCreateError_InvalidSignature:
			return @"Invalid signature";
		case FKFlickrGalleriesCreateError_MissingSignature:
			return @"Missing signature";
		case FKFlickrGalleriesCreateError_LoginFailedOrInvalidAuthToken:
			return @"Login failed / Invalid auth token";
		case FKFlickrGalleriesCreateError_UserNotLoggedInOrInsufficientPermissions:
			return @"User not logged in / Insufficient permissions";
		case FKFlickrGalleriesCreateError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrGalleriesCreateError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrGalleriesCreateError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrGalleriesCreateError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrGalleriesCreateError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrGalleriesCreateError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrGalleriesCreateError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrGalleriesCreateError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end