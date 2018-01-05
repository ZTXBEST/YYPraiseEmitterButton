//
//  YYPraiseEmitterButton.m
//  YYPraiseEmitterButton
//
//  Created by 赵天旭 on 2018/1/2.
//  Copyright © 2018年 ZTX. All rights reserved.
//

#import "YYPraiseEmitterButton.h"

@interface YYPraiseEmitterButton()

/**
 cell的数组
 */
@property(nonatomic, strong)NSMutableArray *CAEmitterCellArr;


@property(nonatomic, strong)UILabel *countLabel;//赞的展示label

@property(nonatomic, assign)NSInteger count;//赞的个数

@property(nonatomic, strong)NSTimer *timer;

//喷射layer
@property(nonatomic, strong)CAEmitterLayer *emitterLayer;

@end

@implementation YYPraiseEmitterButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    //默认赞为1
    _count = 1;
    
    [self setImage:[UIImage imageNamed:@"feed_like"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"feed_like_press"] forState:UIControlStateSelected];
    
//    添加单点事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEven:)];
    [self addGestureRecognizer:tap];
    
//    添加长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
    
//    添加赞label
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(-50, -100, 200, 40)];
    _countLabel.hidden = YES;
    [self addSubview:_countLabel];
}

//单击事件
- (void)tapEven:(UIGestureRecognizer *)tap {
    UIButton *button = (UIButton *)tap.view;
    button.selected = !button.selected;
    
    
}

//长按事件
- (void)longPress:(UIGestureRecognizer *)longPress {
    UIButton *button = (UIButton *)longPress.view;
    button.selected = YES;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self beginAnimation];
    }
    else if (longPress.state == UIGestureRecognizerStateEnded) {
//        [self stopAnimation];
    }
}

- (void)stopAnimation {
    //让chareLayer每秒喷射的个数为0个
    for (NSString * imgStr in self.imagesArr) {
        NSString * keyPathStr = [NSString stringWithFormat:@"emitterCells.%@.birthRate",imgStr];
        [self.emitterLayer setValue:@0 forKeyPath:keyPathStr];
    }
    _countLabel.hidden = YES;
    [_timer invalidate];
    _timer = nil;
}

//长按动画
- (void)beginAnimation {
//    button动效
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    if (self.selected) {
        keyframeAnimation.values = @[@1.5,@0.8,@1.0,@1.2,@1.0];
        keyframeAnimation.duration = 0.5;
        [self startAnimation];
    }
    else {
        keyframeAnimation.values = @[@0.8, @1.0];
        keyframeAnimation.duration = 0.4;
    }
    
    keyframeAnimation.calculationMode = kCAAnimationCubic;
    [self.layer addAnimation:keyframeAnimation forKey:@"transform.scale"];
}

//开始喷射动画
- (void)startAnimation {
    
    for (int i = 1; i < 10; i++)
    {
        //78张图片 随机选
        int x = arc4random() % 77 + 1;
        NSString * imageStr = [NSString stringWithFormat:@"emoji_%d",x];
        [self.imagesArr addObject:imageStr];
    }
    
    //设置展示的cell
    for (NSString * imageStr in self.imagesArr) {
        CAEmitterCell * cell = [self emitterCell:[UIImage imageNamed:imageStr] Name:imageStr];
        [self.CAEmitterCellArr addObject:cell];
    }
    self.emitterLayer.emitterCells  = self.CAEmitterCellArr;
    
    self.countLabel.hidden = NO;
    //赞label的动画
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyframeAnimation.values = @[@0.8, @1.0];
    keyframeAnimation.duration = 4.0;
    [self.countLabel.layer addAnimation:keyframeAnimation forKey:@"transform.scale"];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(changeCountText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    self.emitterLayer.beginTime = CACurrentMediaTime();
    for (NSString * imgStr in self.imagesArr) {
        NSString * keyPathStr = [NSString stringWithFormat:@"emitterCells.%@.birthRate",imgStr];
        [self.emitterLayer setValue:@7 forKeyPath:keyPathStr];
    }
}

- (void)changeCountText {
    _count ++;
    self.countLabel.attributedText = [self getAttributedString:_count];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
}

/**
 富文本设置label的图片内容
 
 @param num 当前赞的个数
 @return 要显示的富文本
 */
- (NSMutableAttributedString *)getAttributedString:(NSInteger)num {
    
    //先把count拆分成个位，十位，百位
    NSInteger ge = num % 10;
    NSInteger shi = num % 100 / 10;
    NSInteger bai = num % 1000 / 100;
    
    if (num >= 1000) {
        return nil;
    }
    
    NSMutableAttributedString * mutStr = [[NSMutableAttributedString alloc]init];
    //创建百位显示的图片
    if (bai != 0) {
        NSTextAttachment *b_attachment = [[NSTextAttachment alloc] init];
        b_attachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"multi_digg_num_%ld",bai]];
        b_attachment.bounds = CGRectMake(0, 0, b_attachment.image.size.width, b_attachment.image.size.height);
        NSAttributedString *b_string = [NSAttributedString attributedStringWithAttachment:b_attachment];
        [mutStr appendAttributedString:b_string];
    }
    
    //创建十位显示的图片
    if (!(shi == 0 && bai == 0)) {
        NSTextAttachment *s_attachment = [[NSTextAttachment alloc] init];
        s_attachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"multi_digg_num_%ld",shi]];
        s_attachment.bounds = CGRectMake(0, 0, s_attachment.image.size.width, s_attachment.image.size.height);
        NSAttributedString *s_string = [NSAttributedString attributedStringWithAttachment:s_attachment];
        [mutStr appendAttributedString:s_string];
    }
    
    //创建个位显示的图片
    if (ge >= 0) {
        NSTextAttachment *g_attachment = [[NSTextAttachment alloc] init];
        g_attachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"multi_digg_num_%ld",ge]];
        g_attachment.bounds = CGRectMake(0, 0, g_attachment.image.size.width, g_attachment.image.size.height);
        NSAttributedString *g_string = [NSAttributedString attributedStringWithAttachment:g_attachment];
        [mutStr appendAttributedString:g_string];
    }
    
    if (num<=10) {
        //鼓励
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [UIImage imageNamed:@"multi_digg_word_level_1"];
        attch.bounds = CGRectMake(0, 0, attch.image.size.width, attch.image.size.height);
        NSAttributedString *z_string = [NSAttributedString attributedStringWithAttachment:attch];
        [mutStr appendAttributedString:z_string];
    }
    else if (num<=20) {
        //加油
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [UIImage imageNamed:@"multi_digg_word_level_2"];
        attch.bounds = CGRectMake(0, 0, attch.image.size.width, attch.image.size.height);
        NSAttributedString *z_string = [NSAttributedString attributedStringWithAttachment:attch];
        [mutStr appendAttributedString:z_string];
    }
    else {
        //太棒了
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [UIImage imageNamed:@"multi_digg_word_level_3"];
        attch.bounds = CGRectMake(0, 0, attch.image.size.width, attch.image.size.height);
        NSAttributedString *z_string = [NSAttributedString attributedStringWithAttachment:attch];
        [mutStr appendAttributedString:z_string];
    }
    return mutStr;
}

/**
  创建喷射的cell
 @param image 传入随机的图片
 @param name 图片名字
 @return cell
 */
- (CAEmitterCell *)emitterCell:(UIImage *)image Name:(NSString *)name {
    //随机喷射的cell
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    
    cell.birthRate = 0;//每秒出现多少粒子
    cell.lifetime = 2;//每个粒子存活的时间
    cell.lifetimeRange = 2;// 粒子生命周期的范围
    cell.scale = 0.35;//粒子的缩放比例
    
    cell.alphaRange = 1; //粒子颜色alpha能改变的范围
    cell.alphaSpeed = -1.0;//粒子alpha改变的速度
    cell.yAcceleration = 450;//下落的加速度
    
    //设置粒子包含的内容
    CGImageRef cgimage = image.CGImage;
    cell.contents = (__bridge id _Nullable)(cgimage);
    cell.name = name;//设置name是展示喷射动画和隐藏的
    
    cell.velocity = 450;//设置粒子的喷射速度
    cell.velocityRange = 30;//设置粒子的平均速度
    cell.emissionRange = M_PI_2;//设置弹射范围
    cell.spin = M_PI * 2; // 粒子的平均旋转速度
    cell.spinRange = M_PI * 2;// 粒子的旋转速度调整范围
    cell.emissionLongitude = 3 * M_PI / 2 ;
    
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.emitterLayer.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
}

#pragma mark - 懒加载
- (NSMutableArray *)imagesArr {
    if (!_imagesArr) {
        _imagesArr = [[NSMutableArray alloc] init];
    }
    return _imagesArr;
}

- (NSMutableArray *)CAEmitterCellArr {
    if (!_CAEmitterCellArr) {
        _CAEmitterCellArr = [[NSMutableArray alloc] init];
    }
    return _CAEmitterCellArr;
}

- (CAEmitterLayer *)emitterLayer{
    if (_emitterLayer == nil) {
        _emitterLayer = [CAEmitterLayer layer];
        //        发射源的形状
//        _emitterLayer.emitterShape = kCAEmitterLayerCircle;
//                发射模式
//        _emitterLayer.emitterMode = kCAEmitterLayerVolume;
//                渲染模式
        _emitterLayer.renderMode = kCAEmitterLayerAdditive;
//                发射源大小
        _emitterLayer.emitterSize = CGSizeMake(30, 30);
        _emitterLayer.masksToBounds = NO;
        [self.layer addSublayer:_emitterLayer];
    }
    return _emitterLayer;
}


@end
