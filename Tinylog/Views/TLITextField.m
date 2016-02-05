//
//  TLITextField.m
//  Tinylog
//
//  Created by Spiros Gerokostas on 12/15/13.
//  Copyright (c) 2013 Spiros Gerokostas. All rights reserved.
//

#import "TLITextField.h"
#import "TLIDrawingUtils.h"

@interface TLITextField ()
- (void)_setup;
@end

@implementation TLITextField

#pragma mark - Accessors

@synthesize textEdgeInsets = _textEdgeInsets;
@synthesize clearButtonEdgeInsets = _clearButtonEdgeInsets;
@synthesize placeholderTextColor = _placeholderTextColor;

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self _setup];
    }
    return self;
}

#pragma mark - UITextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], _textEdgeInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect rect = [super clearButtonRectForBounds:bounds];
    rect = CGRectSetY(rect, rect.origin.y + _clearButtonEdgeInsets.top);
    return CGRectSetX(rect, rect.origin.x + _clearButtonEdgeInsets.right);
}


#pragma mark - Private

- (void)_setup {
    _textEdgeInsets = UIEdgeInsetsZero;
    _clearButtonEdgeInsets = UIEdgeInsetsZero;
}

@end
