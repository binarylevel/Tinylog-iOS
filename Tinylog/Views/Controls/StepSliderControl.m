//
//  StepSliderControl.m
//
//  Created by Kireto.
//  Copyright (c) 2014 Kireto. All rights reserved.
//

#import "StepSliderControl.h"

#define SEPARATOR_BASE_TAG 101010101

@interface StepSliderControl ()

@property (nonatomic,assign) NSUInteger numberOfSteps;

@end

@implementation StepSliderControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark - setup view
- (void)setupView {
    
    UIImage *clearImage = [[UIImage alloc] init];
    [self setMinimumTrackImage:clearImage forState:UIControlStateNormal];
    [self setMaximumTrackImage:clearImage forState:UIControlStateNormal];
    
    UIView *middleLine = [self separatorWithFrame:CGRectMake(11.0, (self.frame.size.height - 1.0)/2, self.frame.size.width - 22.0, 1.0)];
    [self addSubview:middleLine];
    
    UIView *startSeparator = [self separatorWithOrigin:CGPointMake(11.0, (self.frame.size.height - 7.0)/2)];
    [self addSubview:startSeparator];
    
    UIView *endSeparator = [self separatorWithOrigin:CGPointMake(self.frame.size.width - 12.0, (self.frame.size.height - 7.0)/2)];
    [self addSubview:endSeparator];
    
    [self addTarget:self action:@selector(sliderUpdated:) forControlEvents:UIControlEventValueChanged];
}

- (UIView*)separatorWithOrigin:(CGPoint)origin {
    return [self separatorWithFrame:CGRectMake(origin.x, origin.y, 1.0, 7.0)];
}

- (UIView*)separatorWithFrame:(CGRect)frame {
    UIView *retView = [[UIView alloc] initWithFrame:frame];
    retView.backgroundColor = [UIColor colorWithRed:181.0/255.0 green:182.0/255.0 blue:183.0/255.0 alpha:1.0];
    return retView;
}

#pragma mark - setup for numberOfSteps
- (void)customizeForNumberOfSteps:(NSUInteger)numberOfSteps {
    
    [self clearOldSeparators];
    self.numberOfSteps = numberOfSteps;
    if (self.numberOfSteps > 1) {
        CGFloat stepWidth = (self.frame.size.width - 23.0)/self.numberOfSteps;
        for (int i = 1; i < self.numberOfSteps; i++) {
            UIView *separator = [self separatorWithOrigin:CGPointMake(11.0 + i*stepWidth, (self.frame.size.height - 7.0)/2)];
            separator.tag = SEPARATOR_BASE_TAG + i;
            [self addSubview:separator];
        }
    }
}

- (void)clearOldSeparators {
    
    if (self.numberOfSteps > 1) {
        for (int i = 1; i < self.numberOfSteps; i++) {
            [[self viewWithTag:(SEPARATOR_BASE_TAG + 1)] removeFromSuperview];
        }
    }
}

- (void)sliderUpdated:(id)sender {
    self.value = roundf(self.value/self.maximumValue*self.numberOfSteps)*self.maximumValue/self.numberOfSteps;
}

@end
