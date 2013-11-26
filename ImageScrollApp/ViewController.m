//
//  ViewController.m
//  ImageScrollApp
//
//  Created by Corey-san on 11/24/13.
//  Copyright (c) 2013 CoreyZanotti. All rights reserved.
//

#import "ViewController.h"
#import "CustomImageView.h"

@interface ViewController ()

@end

/*
    Algorithm: 
 *  Grab Image URL's from Flickr
 *  Create Custom Image Views for x number of images
 *  Place Those image views into scrollview
 *  Place those images in the cache
 *  When Adding new place in scrollview, create new imageview for next image url we have
 */
@implementation ViewController
{
    NSMutableArray *photoURLs;
    NSMutableArray *photos;
    NSUInteger photoIndex;
    NSCache *imageCache;
}
- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Setup UI
    
    photos = [[NSMutableArray alloc]init];
    photoURLs = [[NSMutableArray alloc]init];
    imageCache = [[NSCache alloc]init];
    
    [self setupScrollView];
    [self pilageFlickr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createImageForScrollView:) name:@"FLICKR_IMAGES_RECEIVED" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupScrollView
{
    //create initial bounds and content size of scrollview
    [_scrollView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, _scrollView.frame.size.height)];
    [_scrollView setUserInteractionEnabled:YES];
    [_scrollView setScrollEnabled:YES];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setDelegate:self];
}
-(void)pilageFlickr
{
    FlickrKit *fk = [FlickrKit sharedFlickrKit];
    [fk initializeWithAPIKey:@"838e2ea33c0485e2375366eefd6245bb" sharedSecret:@"3fc5e8ea8f7968c1"];
    [fk call:@"flickr.photos.getRecent" args:@{@"per_page": @"10"} maxCacheAge:FKDUMaxAgeNeverCache completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            for (NSDictionary *photoData in [response valueForKeyPath:@"photos.photo"]) {
                NSURL *url = [fk photoURLForSize:FKPhotoSizeMedium640 fromPhotoDictionary:photoData];
                [photoURLs addObject:url];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FLICKR_IMAGES_RECEIVED" object:nil];
        }
    }];
}

-(void)getImages
{
    FlickrKit *fk = [FlickrKit sharedFlickrKit];
    [fk call:@"flickr.photos.getRecent" args:@{@"per_page": @"10"} maxCacheAge:FKDUMaxAgeNeverCache completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            for (NSDictionary *photoData in [response valueForKeyPath:@"photos.photo"]) {
                NSURL *url = [fk photoURLForSize:FKPhotoSizeMedium640 fromPhotoDictionary:photoData];
                [photoURLs addObject:url];
            }
        }
    }];
}
/*
-(IBAction)nextImage:(id)sender
{
    photoIndex ++;
    [self loadImage];
}
-(IBAction)previousImage:(id)sender
{
    if (photoIndex != 0)
    {
        photoIndex --;
        [self loadImage];
    }
}
-(void)loadImage
{
    if ([photoURLs count] <= photoIndex + 1)
    {
        [self getImages];
    } else
    {
        //grab url
        NSURL *imageURL = (NSURL *)[photoURLs objectAtIndex:photoIndex];
        //check cache
        UIImage *nextImage = [imageCache objectForKey:[imageURL path]];
        if (nextImage)
        {
            [_imageView setImage:nextImage];
        }
        //grab image from url
        else
        {
            nextImage = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:imageURL]];
            //make a call to resize class
            [imageCache setObject:nextImage forKey:[imageURL path]];
            [_imageView setImage:nextImage];
        }
    }
}
*/
-(void)createImageForScrollView:(NSNotification *)note
{
    //When we receive more images from flickr we need to populate the scroll view with 3 image views
    if ([photoURLs count]==0)
        return;
    //When we grab more images from flickr, what is the proper return 
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < 5; i++)
        {
            NSURL *imagePath = (NSURL *)[photoURLs objectAtIndex:i];
            CustomImageView *newImageView = [[CustomImageView alloc]initWithImageURL:imagePath atPosition:i];
            [_scrollView addSubview:newImageView];
            [imageCache setObject:newImageView forKey:[imagePath path]];
            photoIndex++;
        }
        
    });
    /*
        dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *imagePath = (NSURL *)[photoURLs objectAtIndex:0];
        UIImage *newImage = [imageCache objectForKey:[imagePath path]];
        [_imageView setImage:newImage];
    });*/
}
-(void)appendImageViewToScrollView
{
    //Grab image url
    //create image
    //add image to scrollview
    //if we only have 5 image urls left, grab more from flickr
    if (photoIndex + 5 >= [photoURLs count])
    {
        [self getImages];
    }
    NSURL *imagePath = (NSURL *)[photoURLs objectAtIndex:photoIndex];
    CustomImageView *newImageView = [[CustomImageView alloc]initWithImageURL:imagePath atPosition:photoIndex];
    [_scrollView addSubview:newImageView];
    [imageCache setObject:newImageView forKey:[imagePath path]];
    photoIndex++;
}
#pragma mark - Scroll View Delegate methods
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //test content offset
    //make width larger if content offset is greater than content size - 2*bounds.width
    NSInteger contentOffset = [scrollView contentOffset].x;
    //append  - 2*[scrollView bounds].size.width to keep the loading occuring two into the future
    if (contentOffset >= [scrollView contentSize].width - 3 * [scrollView bounds].size.width)
    {
        NSUInteger newWidth = [scrollView contentSize].width + [UIScreen mainScreen].bounds.size.width;
        [scrollView setContentSize:CGSizeMake(newWidth, [scrollView contentSize].height)];
        //here we need to create one new image to add to the scroll view
        [self appendImageViewToScrollView];
    }
}
@end
