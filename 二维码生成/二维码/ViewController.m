//
//  ViewController.m
//  二维码生成
//
//  Created by rimi on 15/7/14.
//  Copyright (c) 2015年 DXY. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h> //框架
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLael;

@end

@implementation ViewController

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [_tipLael sizeToFit];
    //1.实例化滤镜
    CIFilter *filder = [CIFilter filterWithName:@"CIQRCodeGenerator"];//名字不能错
    
    //2.恢复滤镜默认属性（有可能会保存上一次的属性）
    [filder setDefaults];
    
    //3.将我们的字符串转换成DSData
    //  在此处输入你需要转化的字符串，例如我这里使用的字符串是：https://itunes.apple.com/cn/app/tian-cai-zi-xun/id920367098?mt=8
    NSData *data = [@"https://itunes.apple.com/cn/app/tian-cai-zi-xun/id920367098?mt=8" dataUsingEncoding:NSUTF8StringEncoding];
    
    //4.通过KVO设置滤镜，传入data，将来滤镜就知道要传入的数据生成二维码
    [filder setValue:data forKey:@"inputMessage"];//名字不能错，固定
    
    //5.生成二维码
    CIImage *outputImage = [filder outputImage];
    
    //下边的size是你需要的二维码大小
    UIImage *tempImage =  [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:100.0];
    
    // RGB 范围 0~255
    UIImage *image = [self imageBlackToTransparent:tempImage withRed:110 andGreen:120 andBlue:30];
    
    //6.设置生成好的二维码到imageView上
    self.imageView.image = image;
    
    //self.imageView = [self setImageShadow:self.imageView]; //只是可以自定义二维码的阴影啊，这里改变的是二维码整个view 的layer
}


/**
 *  调整二维码大小
 *
 *  @param image 滤镜生成的CIImage
 *  @param size  你需要的尺寸
 *
 *  @return UIimage
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
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

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
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
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
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

//http://blog.sina.com.cn/s/blog_693de6100102vtjk.html    二维码相关博客








@end
