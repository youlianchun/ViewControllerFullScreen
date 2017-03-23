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
 允许侧滑返回，默认YES, kFullScreen_popEnabled = YES 有效
 */
@property (nonatomic, assign) IBInspectable BOOL backPanEnabled;


@end


static BOOL kFullScreen_popEnabled  = YES; //开启新手势
@interface UINavigationController (FullScreen)

/**
 新手势，替代 interactivePopGestureRecognizer, kFullScreen_popEnabled = YES 有效
 */
@property (nonatomic, readonly, getter=fs_popGestureRecognizer) UIPanGestureRecognizer *popGestureRecognizer;

@end
