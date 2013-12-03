//
//  UIImage+Resize.h
//  ImageScrollApp
//
//  Created by Corey-san on 11/25/13.
//  Copyright (c) 2013 CoreyZanotti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomImageView : UIView
@property (nonatomic, retain) UIImageView *imageView;

-(id)initWithImageURL:(NSURL *)imageURL atPosition:(NSUInteger)position;
@end
