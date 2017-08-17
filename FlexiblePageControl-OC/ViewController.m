//
//  ViewController.m
//  FlexiblePageControl-OC
//
//  Created by jack on 2017/8/6.
//  Copyright © 2017年 jieWang. All rights reserved.
//

#import "ViewController.h"
#import "JAYFlexiblePageControl.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) JAYFlexiblePageControl *pageControl;
@property (nonatomic, assign) CGFloat scrollSize;
@property (nonatomic, assign) NSInteger numberOfPage;

@end

@implementation ViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.pageControl setProgressWithContentOffsetX:scrollView.contentOffset.x pageWidth:scrollView.bounds.size.width];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollSize = 300;
    self.numberOfPage = 10;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.scrollSize, self.scrollSize)];
    scrollView.delegate = self;
    scrollView.center = self.view.center;
    scrollView.contentSize = CGSizeMake(self.scrollSize * self.numberOfPage, self.scrollSize);
    scrollView.pagingEnabled = YES;
 
    self.pageControl = [[JAYFlexiblePageControl alloc] init];
    self.pageControl.numberOfPages = self.numberOfPage;
    self.pageControl.numberOfPages = 2;
    self.pageControl.numberOfPages = 10;
    self.pageControl.numberOfPages = 8;

    self.pageControl.center = CGPointMake(scrollView.center.x, CGRectGetMaxY(scrollView.frame) + 16);
    
    for (int index = 0; index < self.numberOfPage; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * self.scrollSize, 0, self.scrollSize, self.scrollSize)];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%02d.jpg", index]];
        [scrollView addSubview:imageView];
    }
    [self.view addSubview:scrollView];
    [self.view addSubview:self.pageControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
