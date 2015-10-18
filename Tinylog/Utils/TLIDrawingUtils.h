//
//  TLIDrawingUtils.h
//  Tiny Log
//
//  Created by Spiros Gerokostas on 12/15/13.
//  Copyright (c) 2013 Spiros Gerokostas. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGGradientRef CreateGradientWithColors(NSArray *colors);
extern CGGradientRef CreateGradientWithColorsAndLocations(NSArray *colors, NSArray *locations);

extern void drawRoundedRect(CGContextRef context, CGRect rect, CGFloat cornerRadius);

extern CGRect CGRectSetX(CGRect rect, CGFloat x);
extern CGRect CGRectSetY(CGRect rect, CGFloat y);
