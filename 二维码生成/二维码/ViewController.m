//
//  ViewController.m
//  二维码生成
//
//  Created by rimi on 15/7/14.
//  Copyright (c) 2015年 DXY. All rights reserved.
//

#import "ViewController.h"
#import "QRCTools.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.imageView.image =[QRCTools QRCWithString:@"hell" size:200 color:[UIColor orangeColor]];
    return;
    //self.imageView = [self setImageShadow:self.imageView]; //只是可以自定义二维码的阴影啊，这里改变的是二维码整个view 的layer
}
/**
 *  自定义改变二维码的layer
 *
 *  @param sender 二维码view。记住，是view不是image
 *
 *  @return 二维码view
 */
- (UIImageView *)setImageShadow :(UIImageView *)sender{
    sender.layer.shadowOffset = CGSizeMake(0, 3);  // 设置阴影的偏移量
    sender.layer.shadowRadius = 1;  // 设置阴影的半径
    sender.layer.shadowColor = [UIColor redColor].CGColor; // 设置阴影的颜色为黑色
    sender.layer.shadowOpacity = 0.3; // 设置阴影的不透明度
    return sender;
}
@end
