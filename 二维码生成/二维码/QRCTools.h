//
//  QRCTools.h
//  二维码
//
//  Created by sam on 15/8/28.
//  Copyright (c) 2015年 DXY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface QRCTools : NSObject
/**
 *  创建二维码
 *
 *  @param str 二维码内容字符串
 *
 *  @return
 */
+ (UIImage *)QRCWithString:(NSString *)str;
/**
 *  创建二维码
 *
 *  @param data data类型
 *
 *  @return 
 */
+ (UIImage *)QRCWithData:(NSData *)data;
+ (UIImage *)QRCWithString:(NSString *)str size:(CGFloat)size color:(UIColor *)color;
+ (UIImage *)QRCWithData:(NSData *)data size:(CGFloat)size color:(UIColor *)color;

@end
