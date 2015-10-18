//
//  TLITextField.h
//  Tiny Log
//
//  Created by Spiros Gerokostas on 12/15/13.
//  Copyright (c) 2013 Spiros Gerokostas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLITextField : UITextField

@property (nonatomic, strong) UIColor *placeholderTextColor;
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets clearButtonEdgeInsets;

@end
