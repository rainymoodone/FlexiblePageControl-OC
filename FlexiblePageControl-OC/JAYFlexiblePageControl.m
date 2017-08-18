//
//  JAYFlexiblePageControl.m
//  JAYFlexiblePageControl-OC
//
//  Created by jack on 2017/8/6.
//  Copyright © 2017年 jieWang. All rights reserved.
//

#import "JAYFlexiblePageControl.h"

typedef NS_ENUM(NSInteger, JAYFlexiblePageControlDirection) {
    JAYFlexiblePageControlDirectionLeft,
    JAYFlexiblePageControlDirectionRight,
    JAYFlexiblePageControlDirectionStay,
};

static CGFloat JAYItemViewMediumSizeRatio = 0.7;
static CGFloat JAYItemViewSmallSizeRatio  = 0.5;
static NSInteger JAYFlexiblePageControlDisplayCount  = 7;

@interface JAYFlexiblePageControl ()

@property (nonatomic, assign) CGFloat itemSize;
@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<JAYItemView *> *items;

@end

@implementation JAYFlexiblePageControl

#pragma mark - public

- (void)setProgressWithContentOffsetX:(CGFloat)contentOffsetX pageWidth:(CGFloat)pageWidth {
    NSInteger currentPage = (NSInteger)round(contentOffsetX/pageWidth);
    if (currentPage == self.currentPage) {
        return;
    }
    self.currentPage = currentPage;
}

- (void)updateViewSize {
    self.bounds = CGRectMake(0, 0, self.intrinsicContentSize.width, self.intrinsicContentSize.height);
}

#pragma mark - util

- (void)updateDotColorWithCurrentPage:(NSInteger)currentPage{
    for (int index = 0; index < self.items.count; index++) {
        NSInteger pageIndex = self.items[index].index;
        self.items[index].dotColor = (pageIndex == self.currentPage) ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
    }
}

- (void)updateDotPositionWithCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    NSTimeInterval duration = animated ? self.animateDuration : 0;
    CGFloat x = 0;
    if (currentPage == 0) {
        x = -self.scrollView.contentInset.left;
        [self moveScrollViewViewWithX:x duration:duration];
    }
    else if (currentPage == self.numberOfPages - 1) {
        x = self.scrollView.contentSize.width - self.scrollView.bounds.size.width + self.scrollView.contentInset.right;
        [self moveScrollViewViewWithX:x duration:duration];
    }
    else if (self.currentPage * self.itemSize <= (self.scrollView.contentOffset.x + self.itemSize)) {
        x = self.scrollView.contentOffset.x - self.itemSize;
        [self moveScrollViewViewWithX:x duration:duration];
    }
    else if ((self.currentPage * self.itemSize + self.itemSize) >= (self.scrollView.contentOffset.x + self.scrollView.bounds.size.width - self.itemSize)) {
        x = self.scrollView.contentOffset.x + self.itemSize;
        [self moveScrollViewViewWithX:x duration:duration];
    }
}

- (void)updateDotSizeWithCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    NSTimeInterval duration = animated ? self.animateDuration : 0;
    for (int index = 0; index < self.items.count; index++) {
        JAYItemView *item = self.items[index];
        item.animateDuration = duration;
        if (item.index == currentPage) {
            item.state = JAYItemViewStateNormal;
        }
        // outside of left
        else if (item.index < 0) {
            item.state = JAYItemViewStateNone;
        }
        // outside of right
        else if (item.index > self.numberOfPages - 1) {
            item.state = JAYItemViewStateNone;
        }
        // first dot from left
        else if (CGRectGetMinX(item.frame) <= self.scrollView.contentOffset.x) {
            item.state = JAYItemViewStateSmall;
        }
        // first dot from right
        else if (CGRectGetMaxX(item.frame) >= (self.scrollView.contentOffset.x + self.scrollView.bounds.size.width)) {
            item.state = JAYItemViewStateSmall;
        }
        // second dot from left
        else if (CGRectGetMinX(item.frame) <= (self.scrollView.contentOffset.x + self.itemSize)) {
            item.state = JAYItemViewStateMedium;
        }
        // second dot from right
        else if (CGRectGetMaxX(item.frame) >= (self.scrollView.contentOffset.x + self.scrollView.bounds.size.width - self.itemSize)) {
            item.state = JAYItemViewStateMedium;
        }
        else {
            item.state = JAYItemViewStateNormal;
        }
    }
}

- (void)moveScrollViewViewWithX:(CGFloat)x duration:(NSTimeInterval)duration {
    JAYFlexiblePageControlDirection direction = [self behaviorDirectionWithX:x];
    [self reusedViewWithDirection:direction];
    [UIView animateWithDuration:duration animations:^{
        self.scrollView.contentOffset = CGPointMake(x, self.scrollView.contentOffset.y);
    }];
}

- (JAYFlexiblePageControlDirection)behaviorDirectionWithX:(CGFloat)x {
    if (x > self.scrollView.contentOffset.x) {
        return JAYFlexiblePageControlDirectionRight;
    } else if (x < self.scrollView.contentOffset.x) {
        return JAYFlexiblePageControlDirectionLeft;
    } else {
        return JAYFlexiblePageControlDirectionStay;
    }
}

- (void)reusedViewWithDirection:(JAYFlexiblePageControlDirection)direction {
    JAYItemView *firstItem = self.items.firstObject;
    JAYItemView *lastItem = self.items.lastObject;
    if (!firstItem || !lastItem) {
        return;
    }
    switch (direction) {
        case JAYFlexiblePageControlDirectionLeft:
            lastItem.index = firstItem.index - 1;
            lastItem.frame = CGRectMake(lastItem.index * self.itemSize, 0, self.itemSize, self.itemSize);
            [self.items insertObject:lastItem atIndex:0];
            [self.items removeLastObject];
            break;
            
        case JAYFlexiblePageControlDirectionRight:
            firstItem.index = lastItem.index + 1;
            firstItem.frame = CGRectMake(firstItem.index * self.itemSize, 0, self.itemSize, self.itemSize);
            [self.items insertObject:firstItem atIndex:self.items.count];
            [self.items removeObjectAtIndex:0];
            break;
            
        case JAYFlexiblePageControlDirectionStay:
            break;
            
        default:
            break;
    }
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    [self updateDotColorWithCurrentPage:currentPage];
    if (self.canScroll) {
        [self updateDotPositionWithCurrentPage:currentPage animated:animated];
        [self updateDotSizeWithCurrentPage:currentPage animated:animated];
    }
}

- (void)update {
    if (self.displayCount + 4 < self.items.count) {
        while (self.displayCount + 4 < self.items.count) {
            JAYItemView *item = self.items.lastObject;
            [item removeFromSuperview];
            [self.items removeLastObject];
        }
    }
    for (int index = 0; index < MAX((self.displayCount + 4), self.items.count) ; index++) {
        JAYItemView *item = nil;
        if (index < self.items.count) {
            item = self.items[index];
            item.index = index - 2;
            item.state = JAYItemViewStateNormal;
            item.frame = CGRectMake((index - 2) * self.itemSize, item.frame.origin.y, item.frame.size.width, item.frame.size.height);
        } else {
            JAYItemView *item = [[JAYItemView alloc] initWithItemSize:self.itemSize dotSize:self.dotSize index:index - 2];
            [self.items addObject:item];
            [self.scrollView addSubview:item];
        }
    }
    self.scrollView.contentSize = CGSizeMake(self.itemSize * self.numberOfPages, self.itemSize);
    
    CGRect frame = CGRectMake(0, 0, self.itemSize * self.displayCount, self.itemSize);
    self.scrollView.frame = frame;
    
    if (self.displayCount < self.numberOfPages) {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, self.itemSize * 2, 0, self.itemSize * 2);
    } else {
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }
    [self setCurrentPage:self.currentPage animated:NO];
}

#pragma mark - setter

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    if (_pageIndicatorTintColor == pageIndicatorTintColor) {
        return;
    }
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self updateDotColorWithCurrentPage:self.currentPage];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    if (_currentPageIndicatorTintColor == currentPageIndicatorTintColor) {
        return;
    }
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self updateDotColorWithCurrentPage:self.currentPage];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage) {
        return;
    }
    _currentPage = currentPage;
    [self.scrollView.layer removeAllAnimations];
    [self setCurrentPage:self.currentPage animated:YES];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages == numberOfPages) {
        return;
    }
    _numberOfPages = numberOfPages;
    self.canScroll = (self.numberOfPages > self.displayCount);
    self.scrollView.hidden = (self.numberOfPages <= 1 && self.hidesForSinglePage);
    _displayCount = JAYFlexiblePageControlDisplayCount;
    _displayCount = MIN(self.displayCount, self.numberOfPages);
    self.canScroll = (self.numberOfPages > self.displayCount);
    [self update];
    self.currentPage = 0;
    [self updateViewSize];
}

- (void)setDisplayCount:(NSInteger)displayCount {
    if (_displayCount == displayCount) {
        return;
    }
    JAYFlexiblePageControlDisplayCount = displayCount;
    _displayCount = displayCount;
    self.canScroll = (self.numberOfPages > self.displayCount);
    [self update];
    [self updateViewSize];
}

- (void)setDotSize:(CGFloat)dotSize {
    if (_dotSize == dotSize) {
        return;
    }
    _dotSize = dotSize;
    [self update];
}

- (void)setDotSpace:(CGFloat)dotSpace {
    if (_dotSpace == dotSpace) {
        return;
    }
    _dotSpace = dotSpace;
    [self update];
}

- (void)setSmallDotSizeRatio:(CGFloat)smallDotSizeRatio {
    if (_smallDotSizeRatio == smallDotSizeRatio) {
        return;
    }
    _smallDotSizeRatio = smallDotSizeRatio;
    JAYItemViewSmallSizeRatio = smallDotSizeRatio;
}

- (void)setMediumDotSizeRatio:(CGFloat)mediumDotSizeRatio {
    if (_mediumDotSizeRatio == mediumDotSizeRatio) {
        return;
    }
    _mediumDotSizeRatio = mediumDotSizeRatio;
    JAYItemViewMediumSizeRatio = mediumDotSizeRatio;
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage == hidesForSinglePage) {
        return;
    }
    _hidesForSinglePage = hidesForSinglePage;
    self.scrollView.hidden = (self.numberOfPages <= 1 && self.hidesForSinglePage);
}

#pragma mark - getter

- (CGFloat)itemSize {
    return self.dotSize + self.dotSpace;
}

- (NSMutableArray<JAYItemView *> *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

#pragma mark - setup

- (void)variableInit {
    _pageIndicatorTintColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.00];
    _currentPageIndicatorTintColor = [UIColor colorWithRed:0.32 green:0.59 blue:0.91 alpha:1.00];;
    _dotSize = 6;
    _dotSpace = 4;
    self.smallDotSizeRatio = 0.5;
    self.mediumDotSizeRatio = 0.7;
    self.animateDuration = 0.3;
    self.currentPage = 0;
    self.numberOfPages = 0;
    self.displayCount = 7;
}

- (void)setup {
    self.scrollView = [[UIScrollView alloc] init];
    [self addSubview:self.scrollView];
    self.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.userInteractionEnabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self variableInit];
}

#pragma mark - override

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self updateViewSize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
        [self updateViewSize];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.center = CGPointMake(self.bounds.size.width * .5f, self.bounds.size.height * .5f);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.itemSize * self.displayCount, self.itemSize);
}

@end


@interface JAYItemView ()

@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, assign) CGFloat itemSize;
@property (nonatomic, assign) CGFloat dotSize;

@end

@implementation JAYItemView

#pragma mark - util

- (void)updateDotSizeWithState:(JAYItemViewState)state {
    CGSize size = CGSizeZero;
    switch (state) {
        case JAYItemViewStateNone:
            size = CGSizeZero;
            break;
            
        case JAYItemViewStateSmall:
            size = CGSizeMake(self.dotSize * JAYItemViewSmallSizeRatio, self.dotSize * JAYItemViewSmallSizeRatio);
            break;
            
        case JAYItemViewStateMedium:
            size = CGSizeMake(self.dotSize * JAYItemViewMediumSizeRatio, self.dotSize * JAYItemViewMediumSizeRatio);
            break;
            
        case JAYItemViewStateNormal:
            size = CGSizeMake(self.dotSize, self.dotSize);
            break;
        default:
            break;
    }
    self.dotView.layer.cornerRadius = size.height * .5f;
    [UIView animateWithDuration:self.animateDuration animations:^{
        self.dotView.layer.bounds = CGRectMake(self.dotView.layer.bounds.origin.x, self.dotView.layer.bounds.origin.y, size.width, size.height);
    }];
}

#pragma mark - setter

- (void)setDotColor:(UIColor *)dotColor {
    if (_dotColor == dotColor) {
        return;
    }
    _dotColor = dotColor;
    self.dotView.backgroundColor = dotColor;
}

- (void)setState:(JAYItemViewState)state {
    _state = state;
    [self updateDotSizeWithState:state];
}

#pragma mark - setup

- (void)variableInit {
    self.dotColor = [UIColor lightGrayColor];
    self.animateDuration = .3f;
}

#pragma mark - override

- (instancetype)initWithItemSize:(CGFloat)itemSize dotSize:(CGFloat)dotSize index:(NSInteger)index {
    CGFloat x = itemSize * index;
    CGRect frame = CGRectMake(x, 0, itemSize, itemSize);
    
    self = [super initWithFrame:frame];
    if (self) {
        [self variableInit];
        self.itemSize = itemSize;
        self.dotSize = dotSize;
        self.index = index;
        
        self.backgroundColor = [UIColor clearColor];
        self.dotView = [[UIView alloc] init];
        self.dotView.frame = CGRectMake(0, 0, dotSize, dotSize);
        self.dotView.center = CGPointMake(itemSize * .5f, itemSize * .5f);
        self.dotView.backgroundColor = self.dotColor;
        self.dotView.layer.cornerRadius = dotSize * .5f;
        self.dotView.layer.masksToBounds = YES;
        [self addSubview:self.dotView];
    }
    return self;
}

@end
