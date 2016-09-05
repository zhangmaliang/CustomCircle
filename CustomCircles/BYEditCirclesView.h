//
//  BYEditCirclesView.h
//  藏家
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BYEditCirclesView : UIView

// existCircles: 最初存在的圈子
// block： 编辑圈子完成回调
+ (void)showWithExistCircles:(NSArray<NSString *> *)existCircles completionBlock:(void (^)(NSArray *eidtCircles))block;

@end
