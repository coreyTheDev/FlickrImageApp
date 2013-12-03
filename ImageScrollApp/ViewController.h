//
//  ViewController.h
//  ImageScrollApp
//
//  Created by Corey-san on 11/24/13.
//  Copyright (c) 2013 CoreyZanotti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrKit.h"
#import "CustomImageView.h"

@interface ViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet CustomImageView *customImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end
