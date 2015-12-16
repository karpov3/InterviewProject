//
//  AKAuthViewController.m
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import "AKAuthViewController.h"
#import "AKMapViewController.h"
#import "FlickrKit.h"
#import "AKAuthManager.h"


#define CALLBACK_URL_STRING @"FlickrPhotosNearby://auth"

@interface AKAuthViewController ()

@property (nonatomic, retain) FKDUNetworkOperation *authOp;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AKAuthViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self beginAuthentication];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [self.authOp cancel];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    
    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            [self.page closeAuthViewControllerWithCallback:url];
            
            return NO;
        }
    }
    return YES;
    
}

#pragma mark - Authentication process

- (void) beginAuthentication {
    
    NSString *callbackURLString = CALLBACK_URL_STRING;
    
    // Begin the authentication process
    self.authOp = [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:[NSURL URLWithString:callbackURLString] permission:FKPermissionRead completion:^(NSURL *flickrLoginPageURL, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:flickrLoginPageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
                [self.webView loadRequest:urlRequest];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        });
    }];
    
}




@end
