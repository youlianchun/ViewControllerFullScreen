//
//  UIViewController+FullScreen.h
//  ViewControllerFullScreen
//
//  Created by YLCHUN on 16/10/28.
//  Copyright © 2016年 ylchun. All rights reserved.
//
#define FullScreen_enabled 1

#if FullScreen_enabled
#import <UIKit/UIKit.h>

@interface UIViewController (FullScreen)
@property (nonatomic, assign) BOOL navigationBarHidden;
@end
#endif
