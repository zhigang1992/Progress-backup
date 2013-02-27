//
//  UIScrollView+ZGPullDrag.m
//  ZGPullDragScrollView
//
//  Created by Kyle Fang on 2/26/13.
//  Copyright (c) 2013 Kyle Fang. All rights reserved.
//

#import "UIScrollView+ZGPullDrag.h"
#import <objc/runtime.h>

static char UIScrollViewZGPullDragViewDelegate;
static char UIScrollViewZGPullDragViewObserving;
static char UIScrollViewZGPullView;
static char UIScrollViewZGDragView;
static char UIScrollViewWasDragging;

@interface UIScrollView (ZGPullDragPropertyCategory)
@property (nonatomic) BOOL isObserving;
@property (nonatomic, assign) UIView *pullView;
@property (nonatomic, assign) UIView *dragView;
@property (nonatomic) BOOL wasDragging;
@end

@implementation UIScrollView (ZGPullDragPropertyCategory)

- (void)setIsObserving:(BOOL)isObserving {
    if (self.isObserving == YES && isObserving == NO) {
        @try {
            [self removeObserver:self forKeyPath:@"contentOffset"];
        }
        @catch (NSException *exception) {
            //It's not observing
        }
    } else if (self.isObserving == NO && isObserving == YES) {
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [self willChangeValueForKey:@"isObserving"];
    objc_setAssociatedObject(self, &UIScrollViewZGPullDragViewObserving,
                             [NSNumber numberWithBool:isObserving],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"isObserving"];
}

- (BOOL)isObserving {
    NSNumber *number = objc_getAssociatedObject(self, &UIScrollViewZGPullDragViewObserving);
    if (number == nil) {
        return NO;
    } else {
        return [number boolValue];
    }
}

- (void)setPullView:(UIView *)pullView{
    [self willChangeValueForKey:@"pullView"];
    objc_setAssociatedObject(self, &UIScrollViewZGPullView, pullView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"pullView"];
}

- (UIView *)pullView{
    return objc_getAssociatedObject(self, &UIScrollViewZGPullView);
}

- (void)setDragView:(UIView *)dragView{
    [self willChangeValueForKey:@"dragView"];
    objc_setAssociatedObject(self, &UIScrollViewZGDragView, dragView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"dragView"];
}

- (UIView *)dragView{
    return objc_getAssociatedObject(self, &UIScrollViewZGDragView);
}

- (void)setWasDragging:(BOOL)wasDragging{
    [self willChangeValueForKey:@"wasDragging"];
    objc_setAssociatedObject(self, &UIScrollViewWasDragging, [NSNumber numberWithBool:wasDragging], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"wasDragging"];
}

- (BOOL)wasDragging{
    NSNumber *number = objc_getAssociatedObject(self, &UIScrollViewWasDragging);
    if (number == nil) {
        return NO;
    } else {
        return [number isEqualToNumber:@YES];
    }
}

@end


@implementation UIScrollView (ZGPullDrag)
@dynamic pullDragDelegate;

- (void)setPullDragDelegate:(id<ZGPullDragViewDelegate>)pullDragDelegate{
    [self willChangeValueForKey:@"pullDragDelegate"];
    objc_setAssociatedObject(self, &UIScrollViewZGPullDragViewDelegate, pullDragDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"pullDragDelegate"];
}

- (id<ZGPullDragViewDelegate>)pullDragDelegate{
    return objc_getAssociatedObject(self, &UIScrollViewZGPullDragViewDelegate);
}

- (void)addZGPullView:(UIView *)pullView{
    if (self.pullView != pullView) {
        [self.pullView removeFromSuperview];
    }
    pullView.frame = CGRectOffset(pullView.frame, -pullView.frame.origin.x, -pullView.frame.origin.y-pullView.frame.size.height);
    [self addSubview:pullView];
    self.pullView = pullView;
    self.isObserving = YES;
}

- (void)addZGDragView:(UIView *)dragView{
    if (self.dragView != dragView) {
        [self.dragView removeFromSuperview];
        [self layoutIfNeeded];
        CGFloat originY = MAX(self.frame.size.height, self.contentSize.height);
        dragView.frame = CGRectOffset(dragView.frame, -dragView.frame.origin.x, -dragView.frame.origin.y+originY);
        [self addSubview:dragView];
        self.dragView = dragView;
        self.isObserving = YES;
    } else {
        CGFloat originY = MAX(self.frame.size.height, self.contentSize.height);
        dragView.frame = CGRectOffset(dragView.frame, -dragView.frame.origin.x, -dragView.frame.origin.y+originY);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        [self contentSizeDidUpdate:[[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue]];
    }
}

- (void)scrollViewDidScroll:(CGPoint )contentOffset {
    CGFloat yOffset = contentOffset.y;
    if (yOffset<0) {
        [self pullViewHandler:-yOffset];
    } else if (self.dragView.frame.origin.y == self.frame.size.height) {
        [self dragViewHandler:yOffset];
    } else if (self.dragView.frame.origin.y == self.contentSize.height && yOffset > self.dragView.frame.origin.y - self.frame.size.height) {
        [self dragViewHandler:yOffset-(self.dragView.frame.origin.y - self.frame.size.height)];
    }
    if (self.wasDragging && !self.isDragging) {
        if ([self.pullDragDelegate respondsToSelector:@selector(userPullOrDragStoppedWithPullView:dragView:)]) {
            [self.pullDragDelegate userPullOrDragStoppedWithPullView:self.pullView dragView:self.dragView];
        }
    }
    self.wasDragging = self.isDragging;
}


- (void)contentSizeDidUpdate:(CGSize )contenSize{
    if (self.dragView) {
        [self addZGDragView:self.dragView];
    }
}



- (void)pullViewHandler:(CGFloat )visiblePixels{
    if ([self.pullDragDelegate respondsToSelector:@selector(pullView:Show:ofTotal:)]) {
        [self.pullDragDelegate pullView:self.pullView Show:visiblePixels ofTotal:self.pullView.frame.size.height];
    }
    if (visiblePixels>self.pullView.frame.size.height && !self.isDragging && [self.pullDragDelegate respondsToSelector:@selector(pullView:hangForCompletionBlock:)]) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.contentInset = UIEdgeInsetsMake(self.pullView.frame.size.height, 0, 0, 0);
                         } completion:^(BOOL finished) {
                             [self.pullDragDelegate pullView:self.pullView hangForCompletionBlock:^{
                                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                     [UIView animateWithDuration:0.2 animations:^{
                                         self.contentInset = UIEdgeInsetsZero;
                                     }];
                                 }];
                             }];
                         }];
    }
}


- (void)dragViewHandler:(CGFloat )visiblePixels{
    if ([self.pullDragDelegate respondsToSelector:@selector(dragView:Show:ofTotal:)]) {
        [self.pullDragDelegate dragView:self.dragView Show:visiblePixels ofTotal:self.dragView.frame.size.height];
    }
    if (visiblePixels>self.dragView.frame.size.height && !self.isDragging && [self.pullDragDelegate respondsToSelector:@selector(dragView:hangForCompletionBlock:)]) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             if (self.dragView.frame.origin.y == self.frame.size.height) {
                                 self.contentInset = UIEdgeInsetsMake(0, 0, self.dragView.frame.size.height + self.frame.size.height - self.contentSize.height, 0);
                             } else {
                                 self.contentInset = UIEdgeInsetsMake(0, 0, self.dragView.frame.size.height, 0);
                             }
                         } completion:^(BOOL finished) {
                             
                             [self.pullDragDelegate dragView:self.dragView hangForCompletionBlock:^{
                                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                     [UIView animateWithDuration:0.2 animations:^{
                                         self.contentInset = UIEdgeInsetsZero;
                                     }];
                                 }];
                             }];
                         }];
    }
}

- (void)dealloc{
    if (self.isObserving) {
        self.isObserving = NO;
    }
}

@end
