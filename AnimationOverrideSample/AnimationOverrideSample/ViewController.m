//
//  ViewController.m
//  AnimationOverrideSample
//
//  Created by Kobayashi Shinji on 12/03/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "PointLayer.h"

#define PI 3.14159265

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton* scaleButton;
@property (nonatomic, weak) IBOutlet UIView* affineView;
@property (nonatomic, weak) IBOutlet UIView* rotateView;
@property (nonatomic, weak) IBOutlet UILabel* affineLabel;
@property (nonatomic, strong) CALayer* pointLayer;

- (IBAction)pushScaleButton:(id)sender;
- (IBAction)releaseScaleButton:(id)sender;

- (IBAction)pushAffineButton:(id)sender;
- (IBAction)releaseAffineButton:(id)sender;

- (IBAction)pushLayerButton:(id)sender;
- (IBAction)releaseLayerButton:(id)sender;

- (IBAction)pushLayerButton2:(id)sender;
- (IBAction)releaseLayerButton2:(id)sender;

@end

@implementation ViewController

@synthesize scaleButton = _scaleButton;
@synthesize affineView = _affineView;
@synthesize rotateView = _rotateView;
@synthesize affineLabel = _affineLabel;
@synthesize pointLayer = _pointLayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _pointLayer = [PointLayer layer];
    _pointLayer.needsDisplayOnBoundsChange = YES;
    _pointLayer.bounds = CGRectMake(0, 0, 10.0f, 10.0f);
    _pointLayer.position = CGPointMake(160.0f, 440.0f);
    [self.view.layer addSublayer:_pointLayer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _pointLayer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Action

- (IBAction)pushScaleButton:(id)sender {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveLinear animations:^{
        CGRect f = _scaleButton.frame;
        NSLog(@"push (%d, %d)", (int)f.size.width, (int)f.size.height);
        
        f.size = CGSizeMake(200, 150);
        f.origin.x += (_scaleButton.frame.size.width - f.size.width) / 2.0f;
        f.origin.y += (_scaleButton.frame.size.height - f.size.height) / 2.0f;
        _scaleButton.frame = f;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)releaseScaleButton:(id)sender {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveLinear animations:^{
        CGRect f = _scaleButton.frame;
        NSLog(@"release (%d, %d)", (int)f.size.width, (int)f.size.height);
        
        f.size = CGSizeMake(60, 50);
        f.origin.x += (_scaleButton.frame.size.width - f.size.width) / 2.0f;
        f.origin.y += (_scaleButton.frame.size.height - f.size.height) / 2.0f;
        _scaleButton.frame = f;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)pushAffineButton:(id)sender {
    _affineLabel.hidden = NO;
    CGAffineTransform trans = CGAffineTransformMakeTranslation(-100.0f, 0.0f);
    _rotateView.transform = trans;
    _affineLabel.transform = CGAffineTransformIdentity;
    _affineView.transform = CGAffineTransformIdentity;

    [UIView animateWithDuration:1 
                          delay:0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^
    {
        _affineView.transform = CGAffineTransformRotate(_affineView.transform, PI - 0.01f);
        
        [UIView animateWithDuration:1.0f / 2.5f 
                              delay:0 
                            options:UIViewAnimationOptionOverrideInheritedDuration 
                         animations:^
        {
            [UIView setAnimationRepeatCount:2.5f];
            _rotateView.transform = CGAffineTransformRotate(trans, PI);
            _affineLabel.transform = CGAffineTransformMakeRotation(PI);
        } completion:^(BOOL finished) 
        {
            if (finished)
                _affineLabel.transform = CGAffineTransformIdentity;
        }];
    } completion:^(BOOL finished) {}];
}

- (IBAction)releaseAffineButton:(id)sender {
    CGAffineTransform trans = CGAffineTransformMakeTranslation(-100.0f, 0.0f);
    _rotateView.transform = CGAffineTransformRotate(trans, PI);
    _affineLabel.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:1 
                          delay:0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations: ^
    {
        _affineView.transform = CGAffineTransformMakeRotation(-0.01f);
        
        [UIView animateWithDuration:1.0f / 2.5f
                              delay:0 
                            options:UIViewAnimationOptionOverrideInheritedDuration 
                         animations:^
        {
            [UIView setAnimationRepeatCount:2.5f];
            _rotateView.transform = CGAffineTransformRotate(trans, 0.01f);
            _affineLabel.transform = CGAffineTransformMakeRotation(PI);
        } completion:^(BOOL finished) 
        {
            if (finished)
                _affineLabel.transform = CGAffineTransformIdentity;
        }];
    } completion:^(BOOL finished) 
    {
        if (finished)
            _affineLabel.hidden = YES;
    }];    
}

- (IBAction)pushLayerButton:(id)sender {
    NSMutableArray* anims = [NSMutableArray array];
    
    CABasicAnimation* anim;
    
    anim = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5f, 0.5f)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(-12.5f, 0.5f)];
    [anims addObject:anim];
    
    CATransform3D trans = CATransform3DMakeTranslation(0, -160, 0);
    trans = CATransform3DRotate(trans, PI, 0.0f, 1.0f, 0.0f);
    trans = CATransform3DTranslate(trans, -50.0f, 0.0f, 0.0f);
    anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)];
    anim.toValue = [NSValue valueWithCATransform3D:trans];
    [anims addObject:anim];
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.duration=1.5;
    group.repeatCount=3;
    group.animations = anims;
    [_pointLayer addAnimation:group forKey:@"nil"];
}

- (IBAction)releaseLayerButton:(id)sender {
    NSMutableArray* anims = [NSMutableArray array];
    
    CABasicAnimation* anim;
    
    anim = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5f, 0.5f)];
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(-12.5f, 0.5f)];
    [anims addObject:anim];
    
    CATransform3D trans = CATransform3DMakeTranslation(0, -160, 0);
    trans = CATransform3DRotate(trans, PI, 0.0f, 1.0f, 0.0f);
    trans = CATransform3DTranslate(trans, -50.0f, 0.0f, 0.0f);
    anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)];
    anim.fromValue = [NSValue valueWithCATransform3D:trans];
    [anims addObject:anim];
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.duration=1.5;
    group.repeatCount=3;
    group.animations = anims;
    [_pointLayer addAnimation:group forKey:@"nil"];
}

- (IBAction)pushLayerButton2:(id)sender {
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.5f];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]]; 

    _pointLayer.anchorPoint = CGPointMake(-8.0f, 0.5f);
    CATransform3D trans = CATransform3DMakeTranslation(0, -160, 0);
    trans = CATransform3DRotate(trans, PI, 0.0f, 1.0f, 0.0f);
    trans = CATransform3DTranslate(trans, -50.0f, 0.0f, 0.0f);
    _pointLayer.transform = trans;
    
    [CATransaction commit];
}

- (IBAction)releaseLayerButton2:(id)sender {
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.5f];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]]; 
    
    _pointLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    _pointLayer.transform = CATransform3DIdentity;
    
    [CATransaction commit];
}

@end
