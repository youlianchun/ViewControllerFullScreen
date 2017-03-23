//
//  UIBarButtonItem+Back.m
//  UIBarButtonItem_Back
//
//  Created by YLCHUN on 2017/3/10.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "UIBarButtonItem+Back.h"
static NSUInteger kBarBackButtonOffset = 11;

@interface BarBackButton : UIButton
@property (nonatomic, weak) UINavigationController *nvc;
@end
@implementation BarBackButton

+ (instancetype)buttonWithImage:(UIImage*)image title:(NSString *)title target:(id)target action:(SEL)action {
    UIFont *font = [UIFont systemFontOfSize:17];
    CGFloat titleWidth;
    if (title.length>0) {
        titleWidth = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
        titleWidth = ceil(titleWidth);
    }else{
        titleWidth = 30;
    }
    CGFloat width = kBarBackButtonOffset + titleWidth;
    BarBackButton *button = [self buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, width, 30);
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    return button;
}

- (void)pop {
    [self.nvc popViewControllerAnimated:YES];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat w = self.frame.size.width-kBarBackButtonOffset;
    self.imageView.frame = CGRectMake(-8, 5.667, 13, 21);
    self.titleLabel.frame = CGRectMake(11, 4.333, w, 21.333);
}


-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    UIColor *tintColor = [UINavigationBar appearance].tintColor;
    if (!tintColor) {
        tintColor = self.superview.tintColor;
    }
    self.tintColor = tintColor;
    
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            self.nvc = (UINavigationController*)nextResponder;
            break;
        }
    }
}

@end

@implementation UIBarButtonItem(Back)

-(UIBarButtonItem*)initBackItemWithTitle:(NSString *)title {
    BarBackButton *backButton = [BarBackButton buttonWithImage:[self backImage] title:title target:self action:@selector(back:)];
    self = [self initWithCustomView:backButton];
    return self;
}

- (void)back:(BarBackButton*)sender {
    [sender pop];
}

-(UIBarButtonItem*)initBackItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    BarBackButton *backButton = [BarBackButton buttonWithImage:[self backImage] title:title target:target action:action];
    self = [self initWithCustomView:backButton];
    return self;
}

-(UIImage*)backImage {//"<" 返回箭头图片
    CAShapeLayer *lineLayer = [[CAShapeLayer alloc]init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 12, 1);
    CGPathAddLineToPoint(path, nil, 2.5, 10.5);
    CGPathAddLineToPoint(path, nil, 12, 20);
    lineLayer.path = path;
    lineLayer.lineWidth = 3.1;
    CGPathRelease(path);
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(13, 21), NO, 0);
    [lineLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end



