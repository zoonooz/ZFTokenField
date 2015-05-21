//
//  ZFTokenField.m
//  ZFTokenField
//
//  Created by Amornchai Kanokpullwad on 10/11/2014.
//  Copyright (c) 2014 Amornchai Kanokpullwad. All rights reserved.
//

#import "ZFTokenField.h"

@interface ZFTokenField ()

- (void)textFieldWillDeleteBackward:(_ZFTokenFieldTextField *)textField;

@end

@implementation _ZFTokenFieldTextField

- (void)deleteBackward {
    if (self.tokenField) {
        [self.tokenField textFieldWillDeleteBackward:self];
    }
    [super deleteBackward];
}

@end

@interface ZFTokenField ()
@property (nonatomic, strong) _ZFTokenFieldTextField *textField;
@property (nonatomic, strong) NSMutableArray *tokenViews;
@end

@implementation ZFTokenField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark -

- (void)setup
{
    self.clipsToBounds = YES;
    self.shouldAutomaticallyRemoveToken = YES;
    self.textField = [[_ZFTokenFieldTextField alloc] init];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.delegate = self;
    ((_ZFTokenFieldTextField *)self.textField).tokenField = self;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    [self reloadData];
}

- (BOOL)editable {
    return self.textField.enabled;
}

- (void)setEditable:(BOOL)editable {
    self.textField.enabled = editable;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self invalidateIntrinsicContentSize];
    
    NSEnumerator *tokenEnumerator = [self.tokenViews objectEnumerator];
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        UIView *token = [tokenEnumerator nextObject];
        [token setFrame:itemRect];
    }];
    
}

- (CGSize)intrinsicContentSize
{
    if (!self.tokenViews) {
        return CGSizeZero;
    }
    
    __block CGRect totalRect = CGRectNull;
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        totalRect = CGRectUnion(itemRect, totalRect);
    }];
    
    CGFloat margin = [self.dataSource tokenMarginForTokenField:self];
    totalRect.size.height += margin * 2;
    return totalRect.size;
}

#pragma mark - Public

- (void)reloadData
{
    // clear
    for (UIView *view in self.tokenViews) {
        if (view != self.textField) {
            [view removeFromSuperview];
        }
    }
    self.tokenViews = [NSMutableArray array];
    
    if (self.dataSource) {
        NSInteger count = [self.dataSource numberOfTokensInTokenField:self];
        for (int i = 0 ; i < count ; i++) {
            UIView *tokenView = [self.dataSource tokenField:self viewForTokenAtIndex:i];
            tokenView.autoresizingMask = UIViewAutoresizingNone;
            [self addSubview:tokenView];
            [self.tokenViews addObject:tokenView];
        }
    }
    
    [self.tokenViews addObject:self.textField];
    [self addSubview:self.textField];
    self.textField.frame = (CGRect){0, 0, 0, [self.dataSource lineHeightForTokenField:self]};
    
    [self invalidateIntrinsicContentSize];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tokenFieldDidReloadData:)]) {
        [self.delegate tokenFieldDidReloadData:self];
    }
}

- (NSInteger)numberOfToken
{
    return self.tokenViews.count - 1;
}

- (NSInteger)indexOfTokenView:(UIView *)view
{
    return [self.tokenViews indexOfObject:view];
}

#pragma mark - Private

- (void)enumerateItemRectsUsingBlock:(void (^)(CGRect itemRect))block
{
    CGFloat x = 0, y = 0;
    CGFloat _margin = 0;
    if ([self.dataSource respondsToSelector:@selector(tokenMarginForTokenField:)]) {
        x = y = _margin = [self.dataSource tokenMarginForTokenField:self];
    }
    const CGFloat margin = _margin;
    const CGFloat width = CGRectGetWidth(self.bounds);
    const CGFloat lineHeight = [self.dataSource lineHeightForTokenField:self];
    
    for (UIView *token in self.tokenViews) {
        CGRect rect = CGRectMake(x, y, MIN(CGRectGetWidth(token.frame), width - 2 * margin), CGRectGetHeight(token.frame));
        if (token == self.textField) {
            if (self.editable) {
                rect = CGRectMake(x, y, width - x - margin, lineHeight);
            } else {
                rect = CGRectMake(x, y, 0, 0);
            }
        }
        if (CGRectGetMaxX(rect) > width - margin && CGRectGetMinX(rect) > margin) {
            x = margin;
            y += lineHeight + margin;
            rect.origin = (CGPoint){x, y};
        }
        x += CGRectGetWidth(rect) + margin;
        block(rect);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.delegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [self.delegate textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        return [self.delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL value = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        value = [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return value;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL value = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        value = [self.delegate textFieldShouldReturn:textField];
    }
    if (value) {
        NSString *text = textField.text;
        textField.text = @"";
        [self.delegate tokenField:self didReturnWithText:text];
    }
    return value;
}

- (void)textFieldWillDeleteBackward:(_ZFTokenFieldTextField *)textField {
    if (self.shouldAutomaticallyRemoveToken && textField.text.length == 0 && self.tokenViews.count > 1) {
        UIView *view = (UIView *)self.tokenViews[self.tokenViews.count - 2];
        [view removeFromSuperview];
        [self.tokenViews removeObject:view];
        if (self.delegate && [self.delegate respondsToSelector:@selector(tokenField:didRemoveTokenAtIndex:)]) {
            [self.delegate tokenField:self didRemoveTokenAtIndex:self.tokenViews.count - 1];
        }
        [self reloadData];
    }
}

@end
