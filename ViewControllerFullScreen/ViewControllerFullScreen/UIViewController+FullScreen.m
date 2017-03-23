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
#define fs_swizzleMethod(originalSelector, swizzledSelector)  fs_swizzleClassMethod([self class], @selector(originalSelector), @selector(swizzledSelector))
BOOL fs_swizzleClassMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
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
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fs_swizzleMethod(viewWillAppear:, fs_viewWillAppear:);
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

-(BOOL)backPanEnabled {
    id backPanEnabled = objc_getAssociatedObject(self, @selector(backPanEnabled));
    if (backPanEnabled) {
        return [backPanEnabled boolValue];
    }else{
        return YES;
    }
}

-(void)setBackPanEnabled:(BOOL)backPanEnabled {
    objc_setAssociatedObject(self, @selector(backPanEnabled), @(backPanEnabled), OBJC_ASSOCIATION_RETAIN);
}

@end

#pragma mark - _DelegateInterceptor
@interface _DelegateInterceptor : NSObject
@property (nonatomic, readwrite, weak) id receiver;
@property (nonatomic, readwrite, weak) UINavigationController* navigationController;
@end
@implementation _DelegateInterceptor

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if(aSelector == @selector(gestureRecognizerShouldBegin:)){
        return self;
    }else{
        return self.receiver;
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if(aSelector == @selector(gestureRecognizerShouldBegin:)){
        return YES;
    }else{
        return [self.receiver respondsToSelector:aSelector];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIViewController *viewController = self.navigationController.topViewController;
    if (!viewController.backPanEnabled) {
        return NO;
    }
    if ([self.receiver respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        return [self.receiver gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
}
@end

#pragma mark - UINavigationController
@interface UINavigationController ()
@property (nonatomic, retain) UIScreenEdgePanGestureRecognizer *fs_popGestureRecognizer;
@property (nonatomic, retain) _DelegateInterceptor *fs_delegateInterceptor;
@end

@implementation UINavigationController (FullScreen)

+ (void)load {
    [super load];
    if (kFullScreen_popEnabled) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            fs_swizzleMethod(viewDidLoad, fs_viewDidLoad);
        });
    }
}

-(void)fs_viewDidLoad {
    [self createPopGestureRecognizer];
    [self fs_viewDidLoad];
}

-(void)createPopGestureRecognizer {
    self.fs_popGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] init];
    self.fs_popGestureRecognizer.edges = UIRectEdgeLeft;
    id internalTarget = self.interactivePopGestureRecognizer.delegate;
    SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
    [self.fs_popGestureRecognizer addTarget:internalTarget action:internalAction];
    [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.fs_popGestureRecognizer];
    
    self.fs_delegateInterceptor = [[_DelegateInterceptor alloc] init];
    self.fs_delegateInterceptor.receiver = self.interactivePopGestureRecognizer.delegate;
    self.fs_delegateInterceptor.navigationController = self;
    self.fs_popGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self.fs_delegateInterceptor;
    //    self.fs_popGestureRecognizer.delegate = self.interactivePopGestureRecognizer.delegate;
    
    self.interactivePopGestureRecognizer.enabled = NO;
}

-(UIScreenEdgePanGestureRecognizer *)fs_popGestureRecognizer {
    return objc_getAssociatedObject(self, @selector(fs_popGestureRecognizer));
}

-(void)setFs_popGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)fs_popGestureRecognizer {
    objc_setAssociatedObject(self, @selector(fs_popGestureRecognizer), fs_popGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}

-(_DelegateInterceptor *)fs_delegateInterceptor {
    return objc_getAssociatedObject(self, @selector(fs_delegateInterceptor));
}

-(void)setFs_delegateInterceptor:(_DelegateInterceptor *)fs_delegateInterceptor {
    objc_setAssociatedObject(self, @selector(fs_delegateInterceptor), fs_delegateInterceptor, OBJC_ASSOCIATION_RETAIN);
}
@end

