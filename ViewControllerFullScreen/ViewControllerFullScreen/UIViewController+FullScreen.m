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

-(BOOL)backPanFull {
    id backPanFull = objc_getAssociatedObject(self, @selector(backPanFull));
    if (backPanFull) {
        return [backPanFull boolValue];
    }else{
        return NO;
    }
}

-(void)setBackPanFull:(BOOL)backPanFull {
    objc_setAssociatedObject(self, @selector(backPanFull), @(backPanFull), OBJC_ASSOCIATION_RETAIN);
}
@end

#pragma mark - _DelegateInterceptor

@interface _DelegateInterceptor : NSObject
@property (nonatomic, readwrite, weak) id receiver;
@property (nonatomic, readwrite, weak) UINavigationController* navigationController;
@end
@implementation _DelegateInterceptor

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return self;
    }
    if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString*selName=NSStringFromSelector(aSelector);
    if ([selName hasPrefix:@"keyboardInput"] || [selName isEqualToString:@"customOverlayContainer"]) {
        return NO;
    }
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    UIViewController *viewController = self.navigationController.topViewController;
    BOOL backPanFull = viewController.backPanFull;
    if (!viewController.backPanEnabled || (point.x > 50 && !backPanFull)) {
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
@property (nonatomic, retain) UIPanGestureRecognizer *fs_popGestureRecognizer;
@property (nonatomic, retain) _DelegateInterceptor *fs_delegateInterceptor;
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
    self.fs_delegateInterceptor = [[_DelegateInterceptor alloc] init];
    self.fs_delegateInterceptor.receiver = self.interactivePopGestureRecognizer.delegate;
    self.fs_delegateInterceptor.navigationController = self;
    self.fs_popGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self.fs_delegateInterceptor;        self.interactivePopGestureRecognizer.enabled = NO;
    [self fs_viewDidLoad];
}

-(UIPanGestureRecognizer *)fs_popGestureRecognizer {
    UIPanGestureRecognizer * _fs_popGestureRecognizer = objc_getAssociatedObject(self, @selector(fs_popGestureRecognizer));
    if (!_fs_popGestureRecognizer) {
        _fs_popGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
//        _fs_popGestureRecognizer.edges = UIRectEdgeLeft;
        id internalTarget = self.interactivePopGestureRecognizer.delegate;
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        [_fs_popGestureRecognizer addTarget:internalTarget action:internalAction];
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:_fs_popGestureRecognizer];
        self.fs_popGestureRecognizer = _fs_popGestureRecognizer;
    }
    return _fs_popGestureRecognizer;
}

-(void)setFs_popGestureRecognizer:(UIPanGestureRecognizer *)fs_popGestureRecognizer {
    objc_setAssociatedObject(self, @selector(fs_popGestureRecognizer), fs_popGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}

-(_DelegateInterceptor *)fs_delegateInterceptor {
    return objc_getAssociatedObject(self, @selector(fs_delegateInterceptor));
}

-(void)setFs_delegateInterceptor:(_DelegateInterceptor *)fs_delegateInterceptor {
    objc_setAssociatedObject(self, @selector(fs_delegateInterceptor), fs_delegateInterceptor, OBJC_ASSOCIATION_RETAIN);
}
@end

