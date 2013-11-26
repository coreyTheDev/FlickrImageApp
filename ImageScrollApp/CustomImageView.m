//
//  UIImage+Resize.m
//  ImageScrollApp
//
//  Created by Corey-san on 11/25/13.
//  Copyright (c) 2013 CoreyZanotti. All rights reserved.
//

#import "CustomImageView.h"
/*
 *  Class needs to take an image as input and reformat the image 
 *  to fit comfortably within the screen bounds, with accompanying 
 *  blackspace
 */

@implementation CustomImageView
{
    dispatch_queue_t loadQueue;
    UIActivityIndicatorView *activityView;
}

-(id)initWithImageURL:(NSURL *)imageURL atPosition:(NSUInteger)position
{
    self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * position, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self setBackgroundColor:[UIColor blackColor]];
    if (self)
    {
        activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 25, [UIScreen mainScreen].bounds.size.height/2 - 25, 50, 50)];
        [activityView startAnimating];
        [self addSubview:activityView];
        loadQueue = dispatch_queue_create("corey.imageGrab", NULL);
        dispatch_async(loadQueue, ^{
            UIImage *newImage = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:imageURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageView = [[UIImageView alloc]initWithImage:newImage];
                [self addSubview:_imageView];
                [activityView removeFromSuperview];
                [self resizeImageViewForImage:newImage];
            });
        });
    }
    return self;
}
-(void)resizeImageViewForImage:(UIImage *)image
{
    CGFloat imageRatio = image.size.width/image.size.height;
    if (imageRatio >= .75)
    {
        //width greater than height, hardcode width
        NSUInteger newWidth = [UIScreen mainScreen].bounds.size.width;
        NSUInteger newHeight = newWidth/imageRatio;
        NSInteger verticalEdgeInset = ([UIScreen mainScreen].bounds.size.height - newHeight)/2;
        [_imageView setFrame:CGRectMake(0, verticalEdgeInset, newWidth, newHeight)];
    } else
    {
        NSUInteger newHeight = [UIScreen mainScreen].bounds.size.height;
        NSUInteger newWidth = newHeight * imageRatio;
        //2 cases
        //width is larger than bounds
        NSInteger horizontalInset = ([UIScreen mainScreen].bounds.size.width - newWidth)/2;
        if (horizontalInset < 0)
            NSLog(@"negative inset");
        
        [_imageView setFrame:CGRectMake(horizontalInset, 0, newWidth, newHeight)];
    }
}

@end
