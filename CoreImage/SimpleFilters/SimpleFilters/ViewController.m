//
//  ViewController.m
//  SimpleFilters
//
//  Created by 胡金友 on 15/5/27.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (retain, nonatomic) CIContext *context;

@property (retain, nonatomic) UIImage *originalImage;

@property (retain, nonatomic) CIFilter *filter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.context = [CIContext contextWithOptions:nil];
    self.originalImage = [UIImage imageNamed:@"image"];
    
    self.imageView.layer.shadowOpacity = 0.8;
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    
    self.imageView.image = [self originalImage];
    
    [self showFiltersInConsole];
    
}

- (IBAction)showOriginalImage:(id)sender
{
    self.imageView.image = [self originalImage];
}

- (IBAction)autoAdjust:(id)sender
{
    /**
     CIImage:这是一个模型对象，他保存能构建图像的数据，可以是图像的Data，可以是一个文件，也可以是CIFilter输出的对象。
     */
    CIImage *inputImage = [[CIImage alloc] initWithImage:[self originalImage]];
    
    /**
     使用API渠道能使图像得到改善的滤镜数组
     */
    NSArray *filters = [inputImage autoAdjustmentFilters];
    /**
     CIFilter:滤镜，不同的CIFilter实例能表示不同的滤镜效果，不同的滤镜所能设置的参数也不尽相同，但他至少需要一个输入参数以及能生成一个输出对象。
     */
    for (CIFilter *filter in filters)
    {
        [filter setValue:inputImage forKey:kCIInputImageKey];
        
        /**
         调用outputImage方法时，此时Core Image并不会去渲染图像，而是通过计算各种参数，并把计算结果存储到CIImage对象中，只有当真正将要显示的时候，才会通过第三个对象CIContext去渲染。
         */
        inputImage = filter.outputImage;
        
//        NSLog(@"%@",filter.name);
//        NSLog(@"%@",filter.inputKeys);
//        NSLog(@"%@",filter.outputKeys);
//        NSLog(@"----------------");
        
        /**
         CoreImage自动改善的滤镜
         
         CIRedEyeCorrection：修复因相机的闪光灯导致的各种红眼
         CIFaceBalance：调整肤色
         CIVibrance：在不影响肤色的情况下，改善图像的饱和度
         CIToneCurve：改善图像的对比度
         CIHighlightShadowAdjust：改善阴影细节
         */
    }
    
    CGImageRef cgImage = [self.context createCGImage:inputImage fromRect:inputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgImage];
//    self.imageView.image = [UIImage imageWithCIImage:inputImage];
    
}


- (void)showFiltersInConsole
{
    NSArray *filterNames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@", @(filterNames.count));
    NSLog(@"%@",filterNames);
    for (NSString *filterName in filterNames)
    {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        NSLog(@"%@",filterName);
        NSLog(@"%@\n\n\n",filter.attributes);
    }
    
//    {
//        CIAttributeFilterCategories =     (
//                                           CICategoryColorEffect,
//                                           CICategoryVideo,
//                                           CICategoryInterlaced,
//                                           CICategoryNonSquarePixels,
//                                           CICategoryStillImage,
//                                           CICategoryBuiltIn,
//                                           CICategoryXMPSerializable
//                                           );
//        CIAttributeFilterDisplayName = "Photo Effect Mono";
//        CIAttributeFilterName = CIPhotoEffectMono;
//        inputImage =     {
//            CIAttributeClass = CIImage;
//            CIAttributeType = CIAttributeTypeImage;
//        };
//    }
}

/**
 *  怀旧
 */
- (IBAction)photoEffectInstant:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    [self outputImage];
}

/**
 *  黑白
 */
- (IBAction)photoEffectNoir:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
    [self outputImage];
}

/**
 *  色调
 */
- (IBAction)photoEffectTonal:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
    [self outputImage];
}

/**
 *  岁月
 */
- (IBAction)photoEffectTransfer:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
    [self outputImage];
}

/**
 *  单色
 */
- (IBAction)photoEffectMono:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [self outputImage];
}

/**
 *  褪色
 */
- (IBAction)photoEffectFade:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectFade"];
    [self outputImage];
}

/**
 *  冲印
 */
- (IBAction)photoEffectProcess:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
    [self outputImage];
}

/**
 *  铬黄
 */
- (IBAction)photoEffectChrome:(id)sender {
    _filter = [CIFilter filterWithName:@"CIPhotoEffectChrome"];
    [self outputImage];
}

- (void)outputImage
{
    NSLog(@"%@",self.filter);
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.originalImage];
    [self.filter setValue:inputImage forKey:kCIInputImageKey];
    CIImage *outputImage = _filter.outputImage;
    CGImageRef cgimage = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgimage];
}























- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
