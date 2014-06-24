//
//  MyView.m
//  LayoutSubviewsTest
//
//  Created by Nikolay Mamaev on 6/23/14.
//  Copyright (c) 2014 Nikolay Mamaev. All rights reserved.
//

#import "MyView.h"


@interface MyView ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) NSTimer* timer;
@property (nonatomic) NSUInteger timerCounter;

- (void)timerFired:(NSTimer*)timer;

@end


@implementation MyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:5 animations:^{
            CGRect frame = self.label.frame;
            frame.origin.y = 527;
            self.label.frame = frame;
        }];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    });
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.timerCounter > 0) {
        CGRect frame = self.label.frame;
        frame.origin.y = arc4random() % 500;
        self.label.frame = frame;
        NSLog(@"layoutSubviews: y=%3.1f", frame.origin.y);
    }
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawRect: %@", NSStringFromCGRect(rect));
    [super drawRect:rect];
}

- (void)timerFired:(NSTimer *)timer
{
    [self setNeedsLayout];
    if (self.timerCounter++ < 6) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    }
}


@end
