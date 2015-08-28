//
//  QRCTools.m
//  二维码
//
//  Created by sam on 15/8/28.
//  Copyright (c) 2015年 DXY. All rights reserved.
//

#import "QRCTools.h"

@implementation QRCTools

+ (UIImage *)QRCWithString:(NSString *)str {
	CGFloat tempSize = 100.f;
	UIColor *tempColor = [UIColor blackColor];
	NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
	return [self QRCWithData:data size:tempSize color:tempColor];
}

+ (UIImage *)QRCWithData:(NSData *)data {
	CGFloat tempSize = 100.f;
	UIColor *tempColor = [UIColor blackColor];
	return [self QRCWithData:data size:tempSize color:tempColor];
}

+ (UIImage *)QRCWithString:(NSString *)str size:(CGFloat)size color:(UIColor *)color {
	CGFloat tempSize = 10.f;
	UIColor *tempColor = nil;

	if (size > 10) {
		tempSize = size;
	}
	if (color != nil) {
		tempColor = color;
	}
	else {
		tempColor = [UIColor blackColor];
	}

	NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
	return [self QRCWithData:data size:tempSize color:tempColor];
}

+ (UIImage *)QRCWithData:(NSData *)data size:(CGFloat)size color:(UIColor *)color {
	if (!data) {
		return nil;
	}
	CGFloat tempSize = 10.f;
	UIColor *tempColor = nil;

	if (size > 10) {
		tempSize = size;
	}
	if (color != nil) {
		tempColor = color;
	}
	else {
		tempColor = [UIColor blackColor];
	}

	//1.实例化滤镜
	CIFilter *filder = [CIFilter filterWithName:@"CIQRCodeGenerator"];//名字不能错

	//2.恢复滤镜默认属性（有可能会保存上一次的属性）
	[filder setDefaults];

	//4.通过KVO设置滤镜，传入data，将来滤镜就知道要传入的数据生成二维码
	[filder setValue:data forKey:@"inputMessage"];//名字不能错，固定

	//5.生成二维码
	CIImage *outputImage = [filder outputImage];

	//下边的size是你需要的二维码大小
	UIImage *tempImage =  [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:tempSize];

	const CGFloat *components = CGColorGetComponents(tempColor.CGColor);
	UIImage *image = [self imageBlackToTransparent:tempImage withRed:components[0] * 255.f andGreen:components[1] * 255.f andBlue:components[2] * 255.f];

	//6.设置生成好的二维码到imageView上
	return image;
}

void ProviderReleaseData(void *info, const void *data, size_t size) {
	free((void *)data);
}

/**
 *  调整二维码大小
 *
 *  @param image 滤镜生成的CIImage
 *  @param size  你需要的尺寸
 *
 *  @return UIimage
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
	CGRect extent = CGRectIntegral(image.extent);
	CGFloat scale = MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));
	// 创建bitmap;
	size_t width = CGRectGetWidth(extent) * scale;
	size_t height = CGRectGetHeight(extent) * scale;
	CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();

	CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
	CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
	CGContextScaleCTM(bitmapRef, scale, scale);
	CGContextDrawImage(bitmapRef, extent, bitmapImage);
	// 保存bitmap到图片
	CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
	CGContextRelease(bitmapRef);
	CGImageRelease(bitmapImage);
	return [UIImage imageWithCGImage:scaledImage];
}

/**
 *   自定义二维码的颜色
 *
 *  @param image 转换过只存的image
 *  @param red   0-255  没什么说的
 *  @param green 0-255  没什么说的
 *  @param blue  0-255  没什么说的
 *
 *  @return 自定义颜色的二维码image
 */
+ (UIImage *)imageBlackToTransparent:(UIImage *)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue {
	const int imageWidth = image.size.width;
	const int imageHeight = image.size.height;
	size_t bytesPerRow = imageWidth * 4;
	uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
	                                             kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
	// 遍历像素
	int pixelNum = imageWidth * imageHeight;
	uint32_t *pCurPtr = rgbImageBuf;
	for (int i = 0; i < pixelNum; i++, pCurPtr++) {
		if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {  // 将白色变成透明
			// 改成下面的代码，会将图片转成想要的颜色
			uint8_t *ptr = (uint8_t *)pCurPtr;
			ptr[3] = red; //0~255
			ptr[2] = green;
			ptr[1] = blue;
		}
		else {
			uint8_t *ptr = (uint8_t *)pCurPtr;
			ptr[0] = 0;
		}
	}
	// 输出图片
	CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
	CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
	                                    kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
	                                    NULL, true, kCGRenderingIntentDefault);
	CGDataProviderRelease(dataProvider);
	UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
	// 清理空间
	CGImageRelease(imageRef);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	return resultUIImage;
}

@end
