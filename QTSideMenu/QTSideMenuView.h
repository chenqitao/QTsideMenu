//
//  QTSideMenuView.h
//  QTSideMenu
//
//  Created by mac chen on 15/10/10.
//  Copyright © 2015年 陈齐涛. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TapBtnBlock)();
@interface QTSideMenuView : UIView
@property (nonatomic, assign) TapBtnBlock tapbtnBlock;   /**< 定义事件回调*/
/**
 *  激活动画
 */
-(void)trigger;
@end
