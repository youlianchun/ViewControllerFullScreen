//
//  UIViewController+FullScreen.m
//  ViewControllerFullScreen
//
//  Created by YLCHUN on 16/10/28.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "UIViewController+FullScreen.h"
#import <objc/runtime.h>

#pragma mark - swizzleClassMethod
static inline BOOL fs_swizzleClassMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return success;
}


#pragma mark - UIViewController
@implementation UIViewController (FullScreen)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(fs_viewWillAppear:);
        fs_swizzleClassMethod(class, originalSelector, swizzledSelector);
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

#pragma mark - UINavigationController
@interface UINavigationController ()
@property (nonatomic, retain) UIScreenEdgePanGestureRecognizer *fs_popGestureRecognizer;
@end

@implementation UINavigationController (FullScreen)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector;
        SEL swizzledSelector;
        originalSelector = @selector(viewDidLoad);
        swizzledSelector = @selector(fs_viewDidLoad);
        fs_swizzleClassMethod(class, originalSelector, swizzledSelector);
    });
}

-(void)fs_viewDidLoad {
    [self fs_popGestureRecognizer];
    [self fs_viewDidLoad];
}

-(UIScreenEdgePanGestureRecognizer *)fs_popGestureRecognizer {
    UIScreenEdgePanGestureRecognizer * _fs_popGestureRecognizer = objc_getAssociatedObject(self, @selector(fs_popGestureRecognizer));
    if (!_fs_popGestureRecognizer) {
        _fs_popGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] init];
        _fs_popGestureRecognizer.edges = UIRectEdgeLeft;
        self.fs_popGestureRecognizer = _fs_popGestureRecognizer;
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        [_fs_popGestureRecognizer addTarget:internalTarget action:internalAction];
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:_fs_popGestureRecognizer];
        _fs_popGestureRecognizer.delegate = self.interactivePopGestureRecognizer.delegate;
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return _fs_popGestureRecognizer;
}

-(void)setFs_popGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)fs_popGestureRecognizer {
    objc_setAssociatedObject(self, @selector(fs_popGestureRecognizer), fs_popGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}


@end
