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
@property (nonatomic, assign) BOOL navigationBarHidden;

/**
 允许侧滑返回，默认YES
 */
@property (nonatomic, assign) BOOL backPanEnabled;

@end
