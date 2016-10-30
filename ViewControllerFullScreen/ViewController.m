//
//  ViewController.m
//  ViewControllerFullScreen
//
//  Created by YLCHUN on 16/10/28.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentInset = UIEdgeInsetsMake(-10, 10, 40, -40);
    
    CGAffineTransform f0 = CGAffineTransformIdentity;
    CGAffineTransform f1 = CGAffineTransformMakeRotation(M_PI/2);
    CGAffineTransform f2 = CGAffineTransformMakeRotation(-M_PI/2);
    CGAffineTransform f3 = CGAffineTransformMakeRotation(M_PI);
    self.scrollView.transform = f1;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
//@implementation UIScrollView (FullScreen)
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
////    if ([otherGestureRecognizer.tag isEqualToString:kPopGestureRecognizer]) {
////        return true;
////    }
//    return false;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
////    if ([otherGestureRecognizer.tag isEqualToString:kPopGestureRecognizer]) {
////        CGPoint p = [otherGestureRecognizer locationInView:otherGestureRecognizer.view];
////        if (p.x <= 50 ) {
////            return true;
////        }
////        return false;
////    }
//    return false;
//}
//
//@end
