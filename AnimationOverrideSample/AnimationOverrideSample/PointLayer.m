//
//  PointLayer.m
//  AnimationOverrideSample
//
//  Created by Kobayashi Shinji on 12/03/31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PointLayer.h"

@implementation PointLayer

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.45f green:0.45f blue:0.85f alpha:1.0f].CGColor);
    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextDrawPath(ctx, kCGPathFill);
}

@end
