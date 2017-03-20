//
//  UIViewController+FullScreen.h
//  ViewControllerFullScreen
//
//  Created by YLCHUN on 16/10/28.
//  Copyright © 2016年 ylchun. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIViewController (FullScreen)

/**
 隐藏导航栏，默认NO
 */
@property (nonatomic, assign) IBInspectable BOOL navigationBarHidden;

/**
 允许侧滑返回，默认YES
 */
@property (nonatomic, assign) IBInspectable BOOL backPanEnabled;

/**
 全屏侧滑返回，默认NO
 */
@property (nonatomic, assign) IBInspectable BOOL backPanFull;

@end


@interface UINavigationController (FullScreen)

/**
 新手势，替代 interactivePopGestureRecognizer
 */
@property (nonatomic, readonly, getter=fs_popGestureRecognizer) UIPanGestureRecognizer *popGestureRecognizer;

@end
