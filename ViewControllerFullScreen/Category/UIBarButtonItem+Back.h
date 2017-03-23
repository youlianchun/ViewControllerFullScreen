//
//  UIBarButtonItem+Back.h
//  UIBarButtonItem_Back
//
//  Created by YLCHUN on 2017/3/10.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem ()

/**
 初始化导航栏返回按钮，返回箭头+文字
 
 @param title 返回
 @return UIBarButtonItem
 */
-(instancetype)initBackItemWithTitle:(NSString *)title;

/**
 初始化导航栏返回按钮，返回箭头+文字
 
 @param title 返回标题
 @param target 目标
 @param action 事件
 @return UIBarButtonItem
 */
-(instancetype)initBackItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

/**
 初始化导航栏返回按钮

 @param image 返回图片
 @param title 返回标题
 @param target 目标
 @param action 事件
 @return UIBarButtonItem
 */
-(instancetype)initBackItemWithImage:(UIImage*)image title:(NSString *)title target:(id)target action:(SEL)action;

@end
