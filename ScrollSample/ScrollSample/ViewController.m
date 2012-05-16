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
    
    _scrollViewL.panGestureRecognizer.minimumNumberOfTouches = 2;
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    CGRect rc =  view.frame;
    rc.origin = CGPointZero;
    CGSize scrollSize = CGSizeMake(scrollView.bounds.size.width - scrollView.contentInset.left - scrollView.contentInset.right
                                   , scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom);
    
    if (rc.size.width < scrollSize.width)
        rc.origin.x = (scrollSize.width - rc.size.width) / 2.0f;
    if (rc.size.height < scrollSize.height)
        rc.origin.y = (scrollSize.height - rc.size.height) / 2.0f;

    [view setFrame:rc];
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
