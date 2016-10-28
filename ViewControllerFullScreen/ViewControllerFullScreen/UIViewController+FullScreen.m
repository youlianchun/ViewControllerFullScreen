//
//  UIViewController+FullScreen.m
//  ViewControllerFullScreen
//
//  Created by YLCHUN on 16/10/28.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "UIViewController+FullScreen.h"
#import <objc/runtime.h>


BOOL swizzledClassMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod;
    Method swizzledMethod;
    BOOL success;
    originalMethod = class_getInstanceMethod(class, originalSelector);
    swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return success;
}

@implementation UIViewController (FullScreen)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector;
        SEL swizzledSelector;
        
        originalSelector = @selector(viewWillAppear:);
        swizzledSelector = @selector(fs_viewWillAppear:);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
    });
}

-(void)fs_viewWillAppear:(BOOL)animated {
    [self fs_viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:animated];
}

-(BOOL)navigationBarHidden {
    return [objc_getAssociatedObject(self, @selector(navigationBarHidden)) boolValue];
}

-(void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    objc_setAssociatedObject(self, @selector(navigationBarHidden), @(navigationBarHidden), OBJC_ASSOCIATION_RETAIN);
}

@end


@interface UINavigationController ()
@property (nonatomic) UIScreenEdgePanGestureRecognizer *popGestureRecognizer;
@end

@implementation UINavigationController (FullScreen)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector;
        SEL swizzledSelector;
        
        originalSelector = @selector(init);
        swizzledSelector = @selector(fs_init);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
        originalSelector = @selector(initWithCoder:);
        swizzledSelector = @selector(fs_initWithCoder:);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
        originalSelector = @selector(initWithNibName:bundle:);
        swizzledSelector = @selector(fs_initWithNibName:bundle:);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
        originalSelector = @selector(initWithNavigationBarClass:toolbarClass:);
        swizzledSelector = @selector(fs_initWithNavigationBarClass:toolbarClass:);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
    });
}

-(instancetype)fs_init {
    UINavigationController *nvc = [self fs_init];
    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
    return nvc;
}

-(instancetype)fs_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UINavigationController *nvc = [self fs_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
    return nvc;
}

-(instancetype)fs_initWithCoder:(NSCoder *)aDecoder {
    UINavigationController *nvc = [self fs_initWithCoder:aDecoder];
    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
    return nvc;
}

- (instancetype)fs_initWithRootViewController:(UIViewController *)rootViewController; {
    UINavigationController* nvc = [self fs_initWithRootViewController:rootViewController];
    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
    return nvc;
}

-(instancetype)fs_initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    UINavigationController* nvc = [self fs_initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
    return nvc;
}

-(void)initNewPopGestureRecognizer {
    if (!self.popGestureRecognizer) {
        self.popGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] init];
        self.popGestureRecognizer.edges = UIRectEdgeLeft;
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        [self.popGestureRecognizer addTarget:internalTarget action:internalAction];
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.popGestureRecognizer];
        self.interactivePopGestureRecognizer.enabled = false;
    }
}

-(UIScreenEdgePanGestureRecognizer *)popGestureRecognizer {
    return objc_getAssociatedObject(self, @selector(popGestureRecognizer));
}

-(void)setPopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)popGestureRecognizer {
    objc_setAssociatedObject(self, @selector(popGestureRecognizer), popGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}


@end
