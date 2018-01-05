//
//  ViewController.m
//  YYPraiseEmitterButton
//
//  Created by 赵天旭 on 2018/1/2.
//  Copyright © 2018年 ZTX. All rights reserved.
//

#import "ViewController.h"
#import "YYPraiseEmitterButton.h"
@interface ViewController ()
@property (nonatomic, strong)YYPraiseEmitterButton *praiseEmitterButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.praiseEmitterButton = [YYPraiseEmitterButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.praiseEmitterButton];
    self.praiseEmitterButton.frame = CGRectMake(0, 0, 50, 50);
    self.praiseEmitterButton.center = self.view.center;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
