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


@interface UIGestureRecognizer (FullScreen)
@property (nonatomic, copy) NSString*tag;
@end
@implementation UIGestureRecognizer (FullScreen)
-(NSString *)tag {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setTag:(NSString *)tag {
    objc_setAssociatedObject(self, @selector(tag), tag, OBJC_ASSOCIATION_COPY);
}
@end

static NSString *kPopGestureRecognizer = @"kPopGestureRecognizer";

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
        
//        originalSelector = @selector(init);
//        swizzledSelector = @selector(fs_init);
//        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
        originalSelector = @selector(initWithCoder:);
        swizzledSelector = @selector(fs_initWithCoder:);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
        originalSelector = @selector(initWithNibName:bundle:);
        swizzledSelector = @selector(fs_initWithNibName:bundle:);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
//        originalSelector = @selector(initWithNavigationBarClass:toolbarClass:);
//        swizzledSelector = @selector(fs_initWithNavigationBarClass:toolbarClass:);
//        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
    });
}

//-(instancetype)fs_init {
//    UINavigationController *nvc = [self fs_init];
//    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
//    return nvc;
//}

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

//- (instancetype)fs_initWithRootViewController:(UIViewController *)rootViewController; {
//    UINavigationController* nvc = [self fs_initWithRootViewController:rootViewController];
//    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
//    return nvc;
//}
//
//-(instancetype)fs_initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
//    UINavigationController* nvc = [self fs_initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
//    [nvc performSelector:@selector(initNewPopGestureRecognizer) withObject:nil afterDelay:0.2];
//    return nvc;
//}

-(void)initNewPopGestureRecognizer {
    if (!self.popGestureRecognizer) {
        self.popGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] init];
        self.popGestureRecognizer.tag = kPopGestureRecognizer;
        self.popGestureRecognizer.edges = UIRectEdgeLeft;
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        [self.popGestureRecognizer addTarget:internalTarget action:internalAction];
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.popGestureRecognizer];
        self.popGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self;
        self.interactivePopGestureRecognizer.enabled = false;
    }
}

-(UIScreenEdgePanGestureRecognizer *)popGestureRecognizer {
    return objc_getAssociatedObject(self, @selector(popGestureRecognizer));
}

-(void)setPopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)popGestureRecognizer {
    objc_setAssociatedObject(self, @selector(popGestureRecognizer), popGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.viewControllers.count != 1;
}

@end


@interface FS_DelegateInterceptor<ReceiverDelegateType> : NSObject
@property (nonatomic, readwrite, weak) ReceiverDelegateType receiver;
@property (nonatomic, readwrite, weak) id middleMan;
@end

@implementation FS_DelegateInterceptor
- (id) forwardingTargetForSelector:(SEL)aSelector {
    if (self.middleMan && [self.middleMan respondsToSelector:aSelector]) {
        return self.middleMan;
    }
    if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    return	[super forwardingTargetForSelector:aSelector];
}

- (BOOL) respondsToSelector:(SEL)aSelector {
//    NSString *aSelectorName = NSStringFromSelector(aSelector);
//    if (![aSelectorName hasPrefix:@"keyboardInput"] ) {//键盘输入代理过滤
        if (self.middleMan && [self.middleMan respondsToSelector:aSelector]) {
            return YES;
        }
        if (self.receiver && [self.receiver respondsToSelector:aSelector]) {
            return YES;
        }
//    }
    return [super respondsToSelector:aSelector];
}

@end


@interface ScrollViewPanGRDelegate : NSObject
@property (nonatomic) FS_DelegateInterceptor *di;
@end

@implementation ScrollViewPanGRDelegate

-(instancetype)initWithScrllView:(UIScrollView*)scrollView {
    self = [super init];
    if (self) {
        self.di = [[FS_DelegateInterceptor alloc]init];
        self.di.middleMan = self;
        self.di.receiver = scrollView;
        [scrollView.panGestureRecognizer setValue:self.di forKey:@"_scrollView"];
        scrollView.panGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self.di;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.tag isEqualToString:kPopGestureRecognizer]) {
        return true;
    }
    if ([self.di.receiver respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        BOOL b = [self.di.receiver gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
        return b;
    }
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.tag isEqualToString:kPopGestureRecognizer]) {
        CGPoint p = [otherGestureRecognizer locationInView:otherGestureRecognizer.view];
        if (p.x <= 50 ) {
            return true;
        }
        return false;
    }
    if ([self.di.receiver respondsToSelector:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:)]) {
        BOOL b = [self.di.receiver gestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
        return b;
    }
    return false;
}
@end


@interface UIScrollView (FullScreen)
@property (nonatomic) ScrollViewPanGRDelegate *panGRDelegate;
@end

@implementation UIScrollView (FullScreen)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector;
        SEL swizzledSelector;
        
        originalSelector = @selector(didMoveToSuperview);
        swizzledSelector = @selector(fs_didMoveToSuperview);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
        originalSelector = @selector(initWithNibName:bundle:);
        swizzledSelector = @selector(fs_initWithNibName:bundle:);
        swizzledClassMethod(class, originalSelector, swizzledSelector);
        
        
    });
}
-(void)fs_didMoveToSuperview {
    [self fs_didMoveToSuperview];
    [self panGRDelegate];
}

-(ScrollViewPanGRDelegate *)panGRDelegate {
    ScrollViewPanGRDelegate *panGRDelegate = objc_getAssociatedObject(self, @selector(panGRDelegate));
    if (!panGRDelegate) {
        panGRDelegate = [[ScrollViewPanGRDelegate alloc]initWithScrllView:self];
        [self setPanGRDelegate:panGRDelegate];
    }
    return panGRDelegate;
}

-(void)setPanGRDelegate:(ScrollViewPanGRDelegate *)panGRDelegate {
    objc_setAssociatedObject(self, @selector(panGRDelegate), panGRDelegate, OBJC_ASSOCIATION_RETAIN);
}

@end

