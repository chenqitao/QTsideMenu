//
//  ViewController.m
//  QTSideMenu
//
//  Created by mac chen on 15/10/10.
//  Copyright © 2015年 陈齐涛. All rights reserved.
//

#import "ViewController.h"
#import "QTSideMenuView.h"
#define KeyWindow [[UIApplication sharedApplication]keyWindow]   /**< 当前活跃窗口*/

@interface ViewController ()
{
    QTSideMenuView  *menu;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TextMenu";
    self.view.backgroundColor = [UIColor whiteColor];
    [self creatUI];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)creatUI {
    menu = [[QTSideMenuView alloc]init];
    menu.tapbtnBlock = ^(){
        NSLog(@"点击了侧边按钮");
    
    };
    
    
    UIButton *showMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    showMenu.frame = CGRectMake(KeyWindow.frame.size.width - 120, KeyWindow.frame.size.height-50, 100, 30);
    [showMenu setTitle:@"show" forState:UIControlStateNormal];
    showMenu.backgroundColor = [UIColor yellowColor];
    [showMenu addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showMenu];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show {
    [menu trigger];
}

@end
