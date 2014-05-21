//
//  ViewController.m
//  DifferentOrientationLayoutFromXib
//
//  Created by anerevol on 5/21/14.
//  Copyright (c) 2014 zhang xiao. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"
#import "UIView+xib.h"

@interface ViewController ()
{
    TestView* testView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    testView = [[TestView alloc] initWithNibName:@"TestView"];
    NSLog(@"%@", testView);
    [self.view addSubview:testView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [testView changeOrientation];
}
@end
