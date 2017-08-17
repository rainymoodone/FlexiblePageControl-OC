//
//  JAYFlexiblePageControl.h
//  JAYFlexiblePageControl-OC
//
//  Created by jack on 2017/8/6.
//  Copyright © 2017年 jieWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAYFlexiblePageControl : UIView

@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger displayCount;

@property (nonatomic, assign) CGFloat dotSize;
@property (nonatomic, assign) CGFloat dotSpace;
@property (nonatomic, assign) CGFloat smallDotSizeRatio;
@property (nonatomic, assign) CGFloat mediumDotSizeRatio;
@property (nonatomic, assign) NSTimeInterval animateDuration;
@property (nonatomic, assign) BOOL hidesForSinglePage;

- (void)setProgressWithContentOffsetX:(CGFloat)contentOffsetX pageWidth:(CGFloat)pageWidth;
- (void)updateViewSize;

@end


typedef NS_ENUM(NSInteger, JAYItemViewState) {
    JAYItemViewStateNone,
    JAYItemViewStateSmall,
    JAYItemViewStateMedium,
    JAYItemViewStateNormal,
};

@interface JAYItemView : UIView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, assign) JAYItemViewState state;
@property (nonatomic, assign) NSTimeInterval animateDuration;
@property (nonatomic, assign) CGFloat mediumSizeRatio;

- (instancetype)initWithItemSize:(CGFloat)itemSize dotSize:(CGFloat)dotSize index:(NSInteger)index;

@end
