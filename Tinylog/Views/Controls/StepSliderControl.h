//
//  StepSliderControl.h
//
//  Created by Kireto.
//  Copyright (c) 2014 Kireto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepSliderControl : UISlider

- (void)setupView;
- (void)customizeForNumberOfSteps:(NSUInteger)numberOfSteps;

@end
