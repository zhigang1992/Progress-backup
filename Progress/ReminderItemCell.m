//
//  ReminderItemCell.m
//  Progress
//
//  Created by Kyle Fang on 2/26/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import "ReminderItemCell.h"

#define kDefaultEdageXOffset 80

@interface ReminderItemCell() <UIGestureRecognizerDelegate>
@property (nonatomic) CGPoint originalCenter;
@end

@implementation ReminderItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.numberOfLines = 2;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer respondsToSelector:@selector(translationInView:)]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:[self superview]];
        return fabsf(translation.x) > fabsf(translation.y);
    } else {
        return YES;
    }
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture{
    
    CGRect checkMarkOriginFrame = CGRectMake(20, 20, 40, 40);
    CGRect deleteMarkOriginFrame = CGRectMake(self.frame.size.width-20-40, 20, 40, 40);
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.originalCenter = self.center;
        UIImageView *checkMarkView = [[UIImageView alloc] initWithFrame:checkMarkOriginFrame];
        checkMarkView.backgroundColor = [UIColor greenColor];
        checkMarkView.highlightedImage = nil;
        checkMarkView.tag = 1;
        UIImageView *deleteMarkView = [[UIImageView alloc] initWithFrame:deleteMarkOriginFrame];
        deleteMarkView.backgroundColor = [UIColor redColor];
        deleteMarkView.highlightedImage = nil;
        deleteMarkView.tag = 2;
        [self insertSubview:checkMarkView atIndex:0];
        [self insertSubview:deleteMarkView atIndex:0];
    } else {
        CGPoint translation = [gesture translationInView:self];
        CGFloat xOffset = translation.x;
        UIView *checkMarkView = [self viewWithTag:1];
        UIView *deleteMarkView = [self viewWithTag:2];
        if (gesture.state == UIGestureRecognizerStateChanged) {
            self.center = CGPointMake(self.originalCenter.x+xOffset, self.originalCenter.y);
            if (xOffset>-kDefaultEdageXOffset && xOffset<kDefaultEdageXOffset) {
                checkMarkView.frame = CGRectOffset(checkMarkOriginFrame, -xOffset, 0);
                deleteMarkView.frame = CGRectOffset(deleteMarkOriginFrame, -xOffset, 0);
            }
        } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [checkMarkView removeFromSuperview];
            [deleteMarkView removeFromSuperview];
            if (xOffset>kDefaultEdageXOffset) {
                NSLog(@">kDefaultEdageXOffset");
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = CGRectOffset(self.frame, -self.frame.origin.x, 0);
                } completion:^(BOOL finished) {
                    [self.delegate completedByTheUser:self];
                }];
            } else if (xOffset<-kDefaultEdageXOffset) {
                NSLog(@"<-kDefaultEdageXOffset");
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = CGRectOffset(self.frame, self.frame.origin.x-self.frame.size.width, 0);
                    self.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.delegate deletedByTheUser:self];
                }];
                
            } else {
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = CGRectOffset(self.frame, -self.frame.origin.x, 0);
                }];
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
