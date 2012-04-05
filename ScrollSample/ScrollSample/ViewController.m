//
//  ViewController.m
//  ScrollSample
//
//  Created by Kobayashi Shinji on 12/04/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView* scrollViewL;
@property (nonatomic, weak) IBOutlet UIScrollView* scrollViewR;

- (void)setScrollViewTop:(UIScrollView*)scrollView;

@end

@implementation ViewController

@synthesize scrollViewL = _scrollViewL;
@synthesize scrollViewR = _scrollViewR;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _scrollViewL.contentSize = [[[_scrollViewL subviews] objectAtIndex:0] bounds].size;    
    _scrollViewR.contentSize = [[[_scrollViewR subviews] objectAtIndex:0] bounds].size;
    
    [self setScrollViewTop:_scrollViewL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self setScrollViewTop:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    [self setScrollViewTop:scrollView];
    return [scrollView.subviews objectAtIndex:0];
}

- (void)scrollViewDidZoom:(UIScrollView*)scrollView {
    UIView* cnView = [[scrollView subviews] objectAtIndex:0];
    CGRect rc = cnView.frame;
    rc.origin = CGPointZero;
    if (rc.size.width < scrollView.bounds.size.width)
        rc.origin.x = (scrollView.bounds.size.width - rc.size.width) / 2.0f;
    if (rc.size.height + scrollView.contentInset.top < scrollView.bounds.size.height)
        rc.origin.y = (scrollView.bounds.size.height - rc.size.height - scrollView.contentInset.top) / 2.0f;

    [[[scrollView subviews] objectAtIndex:0] setFrame:rc];
}

#pragma mark - Private Method

- (void)setScrollViewTop:(UIScrollView *)scrollView {
    scrollView.scrollsToTop = YES;
    if (scrollView == _scrollViewL)
        _scrollViewR.scrollsToTop = !scrollView.scrollsToTop;
    else
        _scrollViewL.scrollsToTop = !scrollView.scrollsToTop;
}

@end
