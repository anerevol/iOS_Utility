//
//  UIView+xib.h
//  UnitTest
//
//  Created by anerevol on 5/21/14.
//  Copyright (c) 2014 zhang xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

// 不支持 auto layout
@interface UIView (xib)

- (instancetype)initWithNibName:(NSString*)name;

- (void)changeOrientation;
@end
