//
//  QTSideMenuView.m
//  QTSideMenu
//
//  Created by mac chen on 15/10/10.
//  Copyright © 2015年 陈齐涛. All rights reserved.
//

#import "QTSideMenuView.h"
#import "AppDelegate.h"
#define KeyWindow [[UIApplication sharedApplication]keyWindow]   /**< 当前活跃窗口*/
#define EXTRAAREA 50    /**< 弹性的那段距离*/
#define menuColor [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1]  /**< 菜单的颜色*/
@implementation QTSideMenuView
{
    UIVisualEffectView *blurView;               /**< 菜单栏的背景*/
    UIView             *helperCenterView;       /**< 辅助视图（中心）*/
    UIView             *helperSideView;         /**< 辅助视图（最上）*/
    CGFloat            diffValue;               /**< 辅助视图之间的差值*/
    BOOL               triggered;               /**< 是否激活动画*/
    CADisplayLink      *displayLink;            /**< 相当于一个定时器*/
    NSInteger          animationCount;          /**< 动画的一个计数*/
    NSInteger          drawCount;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatUI];
    }
    return self;

}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self creatUI];
    }
    return self;
}


- (void)creatUI {
    blurView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = KeyWindow.frame;
    blurView.alpha = 0.0f;
    
    helperSideView = [[UIView alloc]initWithFrame:CGRectMake(-40, 0, 40, 40)];
    helperSideView.backgroundColor = [UIColor redColor];
    helperSideView.hidden = YES;       //这里辅助视图的作用是为了获取他们的差值
    [KeyWindow addSubview:helperSideView];
    
    helperCenterView = [[UIView alloc]initWithFrame:CGRectMake(-40, CGRectGetHeight(KeyWindow.frame)/2 - 20, 40, 40)];
    helperCenterView.backgroundColor = [UIColor yellowColor];
    helperCenterView.hidden = YES;
    [KeyWindow addSubview:helperCenterView];
    
    self.frame = CGRectMake(- KeyWindow.frame.size.width/2 - EXTRAAREA, 0, KeyWindow.frame.size.width/2+EXTRAAREA, KeyWindow.frame.size.height);  //一开始要让他处于最左侧
    self.backgroundColor = [UIColor clearColor];
    [KeyWindow insertSubview:self belowSubview:helperSideView];
    
    UIButton *tomBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tomBtn.frame = CGRectMake( 50, self.frame.size.height/2, 50, 50);
    tomBtn.layer.cornerRadius = 25;
    [tomBtn setTitle:@"tom" forState:UIControlStateNormal];
    tomBtn.backgroundColor = [UIColor yellowColor];
    [tomBtn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tomBtn];
    

}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // 创建一个贝塞尔曲线句柄
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 初始化该path到一个初始点
    [path moveToPoint:CGPointMake(0, 0)];
    // 添加一条直线，从初始点到该函数指定的坐标点
    [path addLineToPoint:CGPointMake(self.frame.size.width-EXTRAAREA, 0)];
    // 画二元曲线，一般和moveToPoint配合使用
    [path addQuadCurveToPoint:CGPointMake(self.frame.size.width-EXTRAAREA, self.frame.size.height) controlPoint:CGPointMake(KeyWindow.frame.size.width/2+diffValue, KeyWindow.frame.size.height/2)];
    // 添加一条直线，从初始点到该函数指定的坐标点
    [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
    // 关闭该path
    [path closePath];
    // 创建描边（Quartz）上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 将此path添加到Quartz上下文中
    CGContextAddPath(context, path.CGPath);
    // 设置本身颜色
    [menuColor set];
    // 设置填充的路径
    CGContextFillPath(context);
}

- (void)trigger {
    
    if (!triggered) {
        [KeyWindow insertSubview:blurView belowSubview:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = self.bounds;
        }];
        //打开CADisplayLink，类似于定时器，60帧

        [self beforeAnimation];
        [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:0.9f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            helperSideView.center = CGPointMake(KeyWindow.center.x, helperSideView.frame.size.height/2);
        } completion:^(BOOL finished) {
             //关闭CADisplayLink
            [self finishAnimation];
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            blurView.alpha = 1.0f;
        }];
        
        [self beforeAnimation];
        [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:2.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            helperCenterView.center = KeyWindow.center;
        } completion:^(BOOL finished) {
            if (finished) {
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToUntrigger)];
                [blurView addGestureRecognizer:tapGes];
                
                [self finishAnimation];
            }
        }];
        //[self animateButtons];
        triggered = YES;
    }else{
        [self tapToUntrigger];
    }


}

#pragma mark  --CADisplayLink生成(动画之前调用)
- (void)beforeAnimation {
    if (displayLink == nil) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    animationCount ++;
}

#pragma mark  --CADisplayLink销毁(动画完成调用)
- (void)finishAnimation {
    animationCount --;
    if (animationCount == 0) {
        [displayLink invalidate];   //和timer的方法一样
        displayLink = nil;
    }
}

#pragma mark --撤回menu,取消激活动画状态
- (void)tapToUntrigger {
    [UIView animateWithDuration:0.3 animations:^{
        
        self.frame = CGRectMake(-KeyWindow.frame.size.width/2-EXTRAAREA, 0, KeyWindow.frame.size.width/2+EXTRAAREA, KeyWindow.frame.size.height);
    }];
    
    
    [self beforeAnimation];
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.9f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        helperSideView.center = CGPointMake(-helperSideView.frame.size.height/2, helperSideView.frame.size.height/2);
        
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        blurView.alpha = 0.0f;
        
    }];
    
    [self beforeAnimation];
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:2.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        helperCenterView.center = CGPointMake(-helperSideView.frame.size.height/2, CGRectGetHeight(KeyWindow.frame)/2);
        
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    
    triggered = NO;
}

#pragma mark --动画
-(void)displayLinkAction:(CADisplayLink *)dis{
    
    CALayer *sideHelperPresentationLayer   =  (CALayer *)[helperSideView.layer presentationLayer];
    CALayer *centerHelperPresentationLayer =  (CALayer *)[helperCenterView.layer presentationLayer];
    
    CGRect centerRect = [[centerHelperPresentationLayer valueForKeyPath:@"frame"]CGRectValue];
    CGRect sideRect = [[sideHelperPresentationLayer valueForKeyPath:@"frame"]CGRectValue];
    
    diffValue = sideRect.origin.x - centerRect.origin.x;
    
    [self setNeedsDisplay];
    
}

- (void)tap:(UIButton *)sender {
    self.tapbtnBlock();
    [self tapToUntrigger];
}


@end
