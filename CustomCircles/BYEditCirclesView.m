//
//  BYEditCirclesView.m
//  藏家
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "BYEditCirclesView.h"

@interface BYEditCirclesView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHConstraint;

@property (weak, nonatomic) IBOutlet UILabel *switchCircleLabel;
@property (weak, nonatomic) IBOutlet UIButton *editOrFinishButton;
@property (weak, nonatomic) IBOutlet UILabel *moreCircleLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *upCirclesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *upCirclesLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upCirclesHConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *downCirclesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *downCirclesLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downCirclesHConstraint;

@property (nonatomic, strong) NSMutableArray<NSString *> *upCricles;
@property (nonatomic, strong) NSMutableArray<NSString *> *downCircles;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGr;

@property (nonatomic, copy) void (^completionBlock)();

@end

@implementation BYEditCirclesView

static NSString *const identifier = @"BYEditCirclesCollectionView";

+ (void)showWithExistCircles:(NSArray<NSString *> *)existCircles completionBlock:(void (^)(NSArray *))block{

    BYEditCirclesView *circleView = [[[NSBundle mainBundle] loadNibNamed:@"BYEditCirclesView" owner:self options:nil] lastObject];
    circleView.upCricles = existCircles.mutableCopy;
    circleView.completionBlock = block;
    [circleView updateCollectionViewFrame];
    
    UIWindow *win = [self currentWindow];
    circleView.frame = win.bounds;
    [win addSubview:circleView];
    
    circleView.transform = CGAffineTransformMakeTranslation(0, - win.bounds.size.height);

    [UIView animateWithDuration:0.25 animations:^{
        circleView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib{
    
    [self setupCollectionView];
    
    [self loadGroupListData];
}

- (void)setupCollectionView{
    
    NSInteger screenH = [[UIScreen mainScreen] bounds].size.height;
    NSInteger screenW = [[UIScreen mainScreen] bounds].size.width;
    
    if (screenH == 568 || screenH == 480) {
        self.switchCircleLabel.font = [UIFont systemFontOfSize:13];
        self.moreCircleLabel.font = self.switchCircleLabel.font;
    }
    
    self.upCirclesCollectionView.backgroundColor = [UIColor clearColor];
    self.downCirclesCollectionView.backgroundColor = [UIColor clearColor];
    
    self.upCirclesCollectionView.clipsToBounds = NO;
    self.downCirclesCollectionView.clipsToBounds = NO;
    
    [self.upCirclesCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    [self.downCirclesCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    
    CGFloat marginX = 7;
    NSInteger row = (screenH == 568 || screenH == 480) ? 3 : 4;
    CGFloat itemW = (screenW - 34 - (row - 1) * marginX) / row;
    CGFloat itemH = 35;
    
    self.upCirclesLayout.itemSize = CGSizeMake(itemW, itemH);
    self.downCirclesLayout.itemSize = CGSizeMake(itemW, itemH);
    self.upCirclesLayout.minimumInteritemSpacing = 0;
    self.downCirclesLayout.minimumInteritemSpacing = 0;
}

- (void)updateCollectionViewFrame{
    
    if (self.downCircles.count == 0 || self.upCricles.count == 0) return;
    
    NSInteger screenH = [[UIScreen mainScreen] bounds].size.height;
    
    NSInteger row = (screenH == 568 || screenH == 480) ? 3 : 4;
    
    NSInteger upAddNum = self.upCricles.count % row == 0 ? 0 : 1;
    NSInteger downAddNum = self.downCircles.count % row == 0 ? 0 : 1;
    
    NSInteger upRowNum = self.upCricles.count / row + upAddNum;
    NSInteger downRowNum = self.downCircles.count / row + downAddNum;
    
    self.upCirclesHConstraint.constant = upRowNum * 35 + (upRowNum - 1) * 10;
    self.downCirclesHConstraint.constant = downRowNum * 35 + (downRowNum - 1) * 10;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.contentViewHConstraint.constant = CGRectGetMaxY(self.downCirclesCollectionView.frame) + 20;
    });
}


/**
 *  加载圈子列表
 */
- (void)loadGroupListData{
    
    // 网络请求加载所有圈子数据，然后剔除掉传入的圈子数，剩余的为下方显示的圈子数
    
    // 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSArray *allCircles = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11"];
        
        for (NSString *circle in allCircles) {
            if ([self.upCricles containsObject:circle]) continue;
            [self.downCircles addObject:circle] ;
        }
        
        [self updateCollectionViewFrame];
        
        [self.upCirclesCollectionView reloadData];
        [self.downCirclesCollectionView reloadData];
    });
}

#pragma mark - 交互方法

// 编辑或者完成按钮被点击
- (IBAction)editOrFinishButtonClicked:(UIButton *)sender {
    
    sender.selected = !sender.isSelected;
    
    if (sender.selected) {
        [self switchToEditState];
    }else{
        [self switchToDefaultState];
    }
}

// 点击编辑按钮，切换到编辑状态
- (void)switchToEditState{
    
    self.downCirclesCollectionView.hidden = YES;
    self.moreCircleLabel.hidden = YES;
    self.switchCircleLabel.text = @"点击取消关注圈子，拖动可进行圈子排序";
    [self.editOrFinishButton setImage:[UIImage imageNamed:@"icon_edit_complete"] forState:UIControlStateNormal];
    
    self.upCirclesCollectionView.tag = 999;
    [self.upCirclesCollectionView reloadData];
    
    [self.upCirclesCollectionView addGestureRecognizer:self.longPressGr];
}

// 点击完成按钮，切换到默认状态
- (void)switchToDefaultState{
    
    self.downCirclesCollectionView.hidden = NO;
    self.moreCircleLabel.hidden = NO;
    self.switchCircleLabel.text = @"点击切换圈子";
    [self.editOrFinishButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
    
    self.upCirclesCollectionView.tag = 0;
    [self.upCirclesCollectionView reloadData];
    
    [self.upCirclesCollectionView removeGestureRecognizer:self.longPressGr];
}

//  退出按钮被点击
- (IBAction)exitButtonClicked {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, - self.bounds.size.height);
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    !self.completionBlock ?: self.completionBlock(self.upCricles);
}

#pragma mark - 长按手势相关

- (UILongPressGestureRecognizer *)longPressGr{
    if (_longPressGr == nil) {
        _longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        _longPressGr.minimumPressDuration = 0.5;
        _longPressGr.delaysTouchesBegan = YES;
    }
    return _longPressGr;
}

// 长按手势动作
-(void)longPressToDo:(UILongPressGestureRecognizer *)gestureRecognizer{
    
    static NSIndexPath *startIndexPath = nil;

    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan: // 长按手势刚开始
        {
            CGPoint startP = [gestureRecognizer locationInView:self.upCirclesCollectionView];
            
            startIndexPath = [self.upCirclesCollectionView indexPathForItemAtPoint:startP];
            
            if (startIndexPath == nil) return;
            
            UICollectionViewCell* startCell = [self.upCirclesCollectionView cellForItemAtIndexPath:startIndexPath];
            
            startCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
            
            [self.upCirclesCollectionView bringSubviewToFront:startCell];
        }
            break;
            
        case UIGestureRecognizerStateChanged: // 长按手势移动过程中
        {
            CGPoint changeP = [gestureRecognizer locationInView:self.upCirclesCollectionView];
            
            UICollectionViewCell *moveCell = [self.upCirclesCollectionView cellForItemAtIndexPath:startIndexPath];

            moveCell.center = changeP;
            
            NSIndexPath *changeIndexPath = [self.upCirclesCollectionView indexPathForItemAtPoint:changeP];
            
            if (changeIndexPath == nil || changeIndexPath.item == startIndexPath.item) return;
            
//            [self.upCricles exchangeObjectAtIndex:startIndexPath.item withObjectAtIndex:changeIndexPath.item];
            
            // 注意，这里不能用上面方法，上面只会交换两个数据，而不是整个顺序
            NSString *startModel = self.upCricles[startIndexPath.item];
            [self.upCricles removeObject:startModel];
            [self.upCricles insertObject:startModel atIndex:changeIndexPath.item];
            
            [self.upCirclesCollectionView moveItemAtIndexPath:startIndexPath toIndexPath:changeIndexPath];

            startIndexPath = changeIndexPath;
        }
            break;
            
        case UIGestureRecognizerStateEnded: // 长按手势结束
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.upCirclesCollectionView reloadData];
            });
        }
            break;

        default:
            break;
    }
}

#pragma mark - UICollectionView代理方法

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (collectionView == self.upCirclesCollectionView) {
        return self.upCricles.count;
    }
    return self.downCircles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString *model;
    if (collectionView == self.upCirclesCollectionView) {
        model = self.upCricles[indexPath.item];
    }else{
        model = self.downCircles[indexPath.item];
    }
    
    // 上面的圈子，且是处于可编辑状态
    BOOL edited = collectionView == self.upCirclesCollectionView && self.upCollectionViewIsEdited;
    
    cell.backgroundView = [self circleCellWithCircleModel:model edited:edited];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.upCirclesCollectionView) {// 上面圈子item被点击
        
        NSString *model = self.upCricles[indexPath.item];

        if (self.upCollectionViewIsEdited) {// 处于编辑状态，点击删除，圈子移动到下面去
            
            [self.upCricles removeObject:model];
            [self.downCircles addObject:model];
            
            [self updateCollectionViewFrame];
            
            [self.downCirclesCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.downCircles.count - 1 inSection:0]]];
            [self.upCirclesCollectionView deleteItemsAtIndexPaths:@[indexPath]];

        }else{// 处于普通状态，点击跳到首页相对应的圈子
            
            [self removeFromSuperview];
            
            !self.completionBlock ?: self.completionBlock(self.upCricles);
        }
        
    }else{
        
        // 下面圈子item被点击，圈子移动到上面去
        NSString *model = self.downCircles[indexPath.item];
        [self.downCircles removeObject:model];
        [self.upCricles addObject:model];
        
        [self updateCollectionViewFrame];

        [self.upCirclesCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.upCricles.count - 1 inSection:0]]];
        [self.downCirclesCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

// 创建圈子item
- (UIView *)circleCellWithCircleModel:(NSString *)model edited:(BOOL)edited{
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:model forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn setBackgroundImage:[UIImage imageNamed:@"icon_release_circle_n"] forState:UIControlStateNormal];
    
    if (edited) {
        UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_edit_cancel_attention"]];
        [btn addSubview:imageV];
        CGRect frame = imageV.bounds;
        frame.origin = CGPointMake(-3, -3);
        imageV.frame = frame;
    }
    return btn;
}

/**
 *  获取当前窗口视图
 */
+ (UIWindow *)currentWindow{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        for (id win in [UIApplication sharedApplication].windows) {
            if ([win isKindOfClass:[UIWindow class]]) {
                window = win;
                break;
            }
        }
    }
    return window;
}


// 上面圈子是否处于可编辑状态
- (BOOL)upCollectionViewIsEdited{
    
    return self.upCirclesCollectionView.tag == 999;
}

#pragma mark - 懒加载

- (NSMutableArray<NSString *> *)upCricles{
    if (_upCricles == nil) {
        _upCricles = @[].mutableCopy;
    }
    return _upCricles;
}
- (NSMutableArray<NSString *> *)downCircles{
    if (_downCircles == nil) {
        _downCircles = @[].mutableCopy;
    }
    return _downCircles;
}

@end
