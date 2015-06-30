//
//  ViewController.m
//  ComplexFilters
//
//  Created by 胡金友 on 15/5/27.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (retain, nonatomic) UIImage *originalImage;

@property (retain, nonatomic) CIContext *context;

@property (retain, nonatomic) CIFilter *filter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.originalImage = [UIImage imageNamed:@"image"];
    self.context = [CIContext contextWithOptions:nil];
    
    self.imageView.layer.shadowOpacity = 0.8;
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
    
    self.slider.maximumValue = (CGFloat)M_PI;
    self.slider.minimumValue = (CGFloat)(-M_PI);
    _slider.value = 0;
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.originalImage];
    self.filter = [CIFilter filterWithName:@"CIHueAdjust"];
    [self.filter setValue:inputImage forKey:kCIInputImageKey];
    [self.slider sendActionsForControlEvents:UIControlEventValueChanged];
    
//    [self showFiltersInConsole];
    
}

- (IBAction)valueChanged:(UISlider *)sender
{
    [_filter setValue:@(sender.value) forKey:kCIInputAngleKey];
    CIImage *outputImage = _filter.outputImage;
    CGImageRef cgimage = [_context createCGImage:outputImage fromRect:outputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgimage];
}

- (IBAction)oldFilmEffect:(id)sender
{
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.originalImage];
    
    /**
     *  1、创建CISepiaTone滤镜
     */
    CIFilter *sepiaToneFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [sepiaToneFilter setValue:inputImage forKey:kCIInputImageKey];
    [sepiaToneFilter setValue:@(1) forKey:kCIInputIntensityKey];
    
    /**
     *  2、创建白斑图滤镜
     */
    CIFilter *whiteSpecksFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [whiteSpecksFilter setValue:[[CIFilter filterWithName:@"CIRandomGenerator"].outputImage imageByCroppingToRect:inputImage.extent] forKey:kCIInputImageKey];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputRVector"];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputGVector"];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputBVector"];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBiasVector"];
    
    /**
     *  3、把CISepiaTone滤镜和白斑滤镜以源覆盖（source over）的方式组合起来
     */
    CIFilter *sourceOverCompositingFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverCompositingFilter setValue:whiteSpecksFilter.outputImage forKey:kCIInputBackgroundImageKey];
    [sourceOverCompositingFilter setValue:sepiaToneFilter.outputImage forKey:kCIInputImageKey];
    
    // ------------ 上面算是完成了一半
    
    /**
     *  4、用CIAffineTransform滤镜先对随机噪点图进行处理
     */
    CIFilter *affineTransformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [affineTransformFilter setValue:[[CIFilter filterWithName:@"CIRandomGenerator"].outputImage imageByCroppingToRect:inputImage.extent] forKey:kCIInputImageKey];
    [affineTransformFilter setValue:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(1.5, 25)] forKey:kCIInputTransformKey];
    
    /**
     *  5、创建蓝绿色磨砂图滤镜
     */
    CIFilter *darkScratchesFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:4 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputGVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputAVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:1 Z:1 W:1] forKey:@"inputBiasVector"];
    
    /**
     *  6、用CIMinimumComponent滤镜把蓝绿色磨砂图滤镜处理成黑色磨砂图滤镜
     */
    CIFilter *minimumComponentFilter = [CIFilter filterWithName:@"CIMinimumComponent"];
    [minimumComponentFilter setValue:darkScratchesFilter.outputImage forKey:kCIInputImageKey];
    
    /**
     *  7、最终组合在一起
     */
    CIFilter *multiplyCompositingFilter = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [multiplyCompositingFilter setValue:minimumComponentFilter.outputImage forKey:kCIInputBackgroundImageKey];
    [multiplyCompositingFilter setValue:sourceOverCompositingFilter.outputImage forKey:kCIInputImageKey];
    
    /**
     *  8、最终输出
     */
    CIImage *outputImage = multiplyCompositingFilter.outputImage;
    CGImageRef gImage = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:gImage];
}

- (IBAction)showOriginalImage:(id)sender
{
    self.imageView.image = [self originalImage];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
