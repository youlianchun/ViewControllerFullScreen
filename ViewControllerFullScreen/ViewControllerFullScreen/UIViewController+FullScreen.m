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


#pragma mark - _FullScreenPopGestureRecognizer
@interface _FullScreenPopGestureRecognizer : UIScreenEdgePanGestureRecognizer
@property (nonatomic, readwrite, weak) id<UIGestureRecognizerDelegate> receiver;
@property (nonatomic, readwrite, weak) UINavigationController* navigationController;
@end

@implementation _FullScreenPopGestureRecognizer
-(instancetype)init {
    self = [super init];
    if (self) {
        self.edges = UIRectEdgeLeft;
        self.delegate = nil;
    }
    return self;
}

-(void)setDelegate:(id<UIGestureRecognizerDelegate>)delegate {
    id<UIGestureRecognizerDelegate> delegateSelf = (id<UIGestureRecognizerDelegate>)self;
    if (delegateSelf != delegate) {
        self.receiver = delegate;
    }
    [super setDelegate:delegateSelf];
}

-(id<UIGestureRecognizerDelegate>)delegate {
    return self.receiver;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIViewController *viewController = self.navigationController.topViewController;
    if (!viewController.backPanEnabled) {
        return NO;
    }
    if ([self.receiver respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        BOOL b = [self.receiver gestureRecognizerShouldBegin:gestureRecognizer];
        return b;
    }
    return YES;
}

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
    if ([selName hasPrefix:@"keyboardInput"] || [selName isEqualToString:@"customOverlayContainer"]) {//键盘输入代理过滤
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
@end

#pragma mark - UINavigationController
@interface UINavigationController ()
@property (nonatomic, retain) _FullScreenPopGestureRecognizer *fs_popGestureRecognizer;
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
    self.fs_popGestureRecognizer = [[_FullScreenPopGestureRecognizer alloc] init];
    id <UIGestureRecognizerDelegate> delegate = self.interactivePopGestureRecognizer.delegate;
    self.fs_popGestureRecognizer.navigationController = self;
    self.fs_popGestureRecognizer.delegate = delegate;
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    [self.fs_popGestureRecognizer addTarget:delegate action:action];
    [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.fs_popGestureRecognizer];
    self.interactivePopGestureRecognizer.enabled = NO;
}

-(_FullScreenPopGestureRecognizer *)fs_popGestureRecognizer {
    return objc_getAssociatedObject(self, @selector(fs_popGestureRecognizer));
}

-(void)setFs_popGestureRecognizer:(_FullScreenPopGestureRecognizer *)fs_popGestureRecognizer {
    objc_setAssociatedObject(self, @selector(fs_popGestureRecognizer), fs_popGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}

@end

