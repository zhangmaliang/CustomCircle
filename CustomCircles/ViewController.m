//
//  ViewController.m
//  CustomCircles
//
//  Created by Apple on 16/9/5.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "BYEditCirclesView.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)editCircleBtnClicked {
    
    NSArray *circles = @[@"1",@"2",@"3"];
    
    [BYEditCirclesView showWithExistCircles:circles completionBlock:^(NSArray *eidtCircles) {
       
        NSLog(@"%@",eidtCircles);
    }];
}

@end
