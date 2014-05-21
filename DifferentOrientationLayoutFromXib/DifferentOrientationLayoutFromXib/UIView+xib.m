//
//  UIView+xib.m
//  UnitTest
//
//  Created by anerevol on 5/21/14.
//  Copyright (c) 2014 zhang xiao. All rights reserved.
//

#import "UIView+xib.h"
#import <objc/runtime.h>

@interface UIView ()

@property(retain, nonatomic)NSDictionary* portraitPropertyDic;
@property(retain, nonatomic)NSDictionary* landscapePropertyDic;


@end

static const char* portraitViewKey = "portraitView";
static const char* landscapeViewKey = "landscapeView";


@implementation UIView (xib)

- (void)setPortraitPropertyDic:(NSDictionary *)portraitPropertyDic
{
    objc_setAssociatedObject(self, portraitViewKey, portraitPropertyDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary*)portraitPropertyDic
{
    return objc_getAssociatedObject(self, portraitViewKey);
}

- (void)setLandscapePropertyDic:(NSDictionary *)landscapePropertyDic
{
    objc_setAssociatedObject(self, landscapeViewKey, landscapePropertyDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary*)landscapePropertyDic
{
    return objc_getAssociatedObject(self, landscapeViewKey);
}

- (instancetype)initWithNibName:(NSString*)name
{
    UINib* nib =  [UINib nibWithNibName:name bundle:nil];
    self = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    if (nib == nil)
    {
        return nil;
    }
    NSArray* viewArray = [nib instantiateWithOwner:self options:nil];
    if (viewArray.count > 0)
    {
        self.portraitPropertyDic = [self propertyDicFromView: viewArray[0]];
    }
    if (viewArray.count == 2)
    {
        self.landscapePropertyDic = [self propertyDicFromView: viewArray[1]];
    }
    
    [self changeOrientation];
        
    return self;
}
            
- (NSArray*)supportedProperty
{
    return @[@"frame"];
}

- (NSDictionary*)propertyDicFromView:(UIView*)view
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    for (NSString* key in [self supportedProperty])
    {
        id property = [view valueForKey:key];
        if (property != nil)
        {
            dic[key] = property;
        }
    }
    NSMutableArray* subviewProperties = [NSMutableArray array];
    dic[@"subviews"] = subviewProperties;
    for (UIView* subView in view.subviews)
    {
        [subviewProperties addObject:[self propertyDicFromView:subView]];
    }
    
    return dic;
}

- (BOOL)isLandscape
{
    return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight;
}


- (void)changeOrientation
{
    NSDictionary* dic;
    if ([self isLandscape])
    {
        dic = self.landscapePropertyDic;
    }
    else
    {
        dic = self.portraitPropertyDic;
    }
    
    if (dic != nil)
    {
        [self setViewProperty:dic];
    }
}

- (void)setViewProperty:(NSDictionary*)dic
{
    if (![self shouldDescendIntoSubviews])
    {
        return;
    }
    
    for (NSString* key in [self supportedProperty])
    {
        [self setValue:dic[key] forKey:key];
    }
    NSArray* subViewProperties = dic[@"subviews"];
    if (subViewProperties.count != self.subviews.count)
    {
        NSLog(@"setViewProperty：view 层次体系不一致！！！");
        return;
    }
    for (int i = 0; i < self.subviews.count; i++)
    {
        UIView* subView = self.subviews[i];
        NSDictionary* properties = subViewProperties[i];
        [subView setViewProperty:properties];
    }
}

- (BOOL)shouldDescendIntoSubviews
{
    if ( [self isKindOfClass:[UISlider class]] ||
        [self isKindOfClass:[UISwitch class]] ||
        [self isKindOfClass:[UITextField class]] ||
        [self isKindOfClass:[UIWebView class]] ||
        [self isKindOfClass:[UITableView class]] ||
        [self isKindOfClass:[UIPickerView class]] ||
        [self isKindOfClass:[UIDatePicker class]] ||
        [self isKindOfClass:[UITextView class]] ||
        [self isKindOfClass:[UIProgressView class]] ||
        [self isKindOfClass:[UISegmentedControl class]] ) return NO;
    return YES;
}

@end
