//
//  AKPhotoViewController.m
//  FlickrPhotosNearby
//
//  Created by Александр Карпов on 27.06.15.
//  Copyright (c) 2015 AK. All rights reserved.
//

#import "AKPhotoViewController.h"
#import "AKPhotoInfo.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"


#define TRY_AN_ANIMATED_GIF 0

@interface AKPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *photoTitle;

@end

@implementation AKPhotoViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *oneTouch=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                            action:@selector(bigButtonTapped:)];
    [oneTouch setNumberOfTouchesRequired:1];
    [self.imageView addGestureRecognizer:oneTouch];
    self.imageView.userInteractionEnabled = YES;
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:self.photo.urlPhoto];
    UIImage *tmpImage = [[UIImage alloc] initWithData:data];
    self.imageView.image = tmpImage;
    self.imageView.layer.cornerRadius = self.imageView.bounds.size.width/2.0f;
    self.imageView.clipsToBounds = YES;
    
    self.photoTitle.text = self.photo.titlePhoto;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JTSImageViewController@bulusoy methods

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)bigButtonTapped:(id)sender {
    // Create image info
    
    NSURL *url = self.photo.urlPhoto;
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.imageURL = url;
    imageInfo.referenceRect = self.imageView.frame;
    imageInfo.referenceView = self.imageView.superview;
    imageInfo.referenceContentMode = self.imageView.contentMode;
    imageInfo.referenceCornerRadius = self.imageView.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}



@end
