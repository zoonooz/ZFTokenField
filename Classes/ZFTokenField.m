//
//  ZFTokenField.m
//  ZFTokenField
//
//  Created by Amornchai Kanokpullwad on 10/11/2014.
//  Copyright (c) 2014 Amornchai Kanokpullwad. All rights reserved.
//

#import "ZFTokenField.h"

@interface ZFTokenTextField ()
- (NSString *)rawText;
@end

@implementation ZFTokenTextField

- (void)setText:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        if (((ZFTokenField *)self.superview).numberOfToken > 0) {
            text = @"\u200B";
        }
    }
    [super setText:text];
}

- (NSString *)text
{
    return [super.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
}

- (NSString *)rawText
{
    return super.text;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent zooming
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}

@end

@interface ZFTokenField () <UITextFieldDelegate>
@property (nonatomic, strong) ZFTokenTextField *textField;
@property (nonatomic, strong) NSMutableArray *tokenViews;

@property (nonatomic, strong) NSString *tempTextFieldText;
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

- (BOOL)focusOnTextField
{
    [self.textField becomeFirstResponder];
    return YES;
}

#pragma mark -

- (void)setup
{
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(focusOnTextField) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField = [[ZFTokenTextField alloc] init];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.delegate = self;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self reloadData];
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
    
    CGFloat margin = [self.delegate tokenMarginInTokenInField:self];
    totalRect.size.height += margin * 2;
    return totalRect.size;
}

#pragma mark - Public

- (void)reloadData
{
    // clear
    for (UIView *view in self.tokenViews) {
        [view removeFromSuperview];
    }
    self.tokenViews = [NSMutableArray array];
    
    if (self.dataSource) {
        NSUInteger count = [self.dataSource numberOfTokenInField:self];
        for (int i = 0 ; i < count ; i++) {
            UIView *tokenView = [self.dataSource tokenField:self viewForTokenAtIndex:i];
            tokenView.autoresizingMask = UIViewAutoresizingNone;
            [self addSubview:tokenView];
            [self.tokenViews addObject:tokenView];
        }
    }
    
    [self.tokenViews addObject:self.textField];
    [self addSubview:self.textField];
    self.textField.frame = (CGRect) {0,0,0,[self.dataSource lineHeightForTokenInField:self]};
    
    [self invalidateIntrinsicContentSize];
    [self.textField setText:@""];
}

- (NSUInteger)numberOfToken
{
    return self.tokenViews.count - 1;
}

- (NSUInteger)indexOfTokenView:(UIView *)view
{
    return [self.tokenViews indexOfObject:view];
}

#pragma mark - Private

- (void)enumerateItemRectsUsingBlock:(void (^)(CGRect itemRect))block
{
    NSUInteger rowCount = 0;
    CGFloat x = 0, y = 0;
    CGFloat margin = 0;
    CGFloat lineHeight = [self.dataSource lineHeightForTokenInField:self];
    
    if ([self.delegate respondsToSelector:@selector(tokenMarginInTokenInField:)]) {
        x = y = margin = [self.delegate tokenMarginInTokenInField:self];
    }
    
    CGFloat maxWidth = CGRectGetWidth(self.bounds) - 2 * margin;
    
    for (UIView *token in self.tokenViews) {
        CGFloat width = MAX(maxWidth, CGRectGetWidth(token.frame));
        CGFloat tokenWidth = MIN(maxWidth, CGRectGetWidth(token.frame));
        if (x - margin + tokenWidth > width) {
            y += lineHeight + margin;
            x = margin;
            rowCount = 0;
        }
        
        if ([token isKindOfClass:[ZFTokenTextField class]]) {
            UITextField *textField = (UITextField *)token;
            UIScrollView /* UIFieldEditor */ *editor = nil;
            UILabel /* UITextFieldLabel */ *label = nil;
            for (UIView *v in textField.subviews) {
                if ([NSStringFromClass(v.class) isEqualToString:@"UIFieldEditor"]) {
                    editor = (UIScrollView *)v;
                } else if ([NSStringFromClass(v.class) isEqualToString:@"UITextFieldLabel"]) {
                    label = (UILabel *)v;
                }
            }
            CGSize size = { MAX(editor.contentSize.width, [label sizeThatFits:CGRectInfinite.size].width + margin), lineHeight};
            if (size.width > maxWidth) {
                size.width = maxWidth;
            }
            token.frame = (CGRect){{x, y}, size};
        }
        block((CGRect){x, y, tokenWidth, lineHeight});
        x += tokenWidth + margin;
        rowCount++;
    }
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(ZFTokenTextField *)textField
{
    self.tempTextFieldText = [textField rawText];
    
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]) {
        [self.delegate tokenFieldDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(ZFTokenTextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenFieldShouldEndEditing:)]) {
        return [self.delegate tokenFieldShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(ZFTokenTextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)]) {
        [self.delegate tokenFieldDidEndEditing:self];
    }
}

- (void)textFieldDidChange:(ZFTokenTextField *)textField
{
    if ([[textField rawText] isEqualToString:@""]) {
        textField.text = @"\u200B";
        
        if ([self.tempTextFieldText isEqualToString:@"\u200B"]) {
            if (self.tokenViews.count > 1) {
                NSUInteger removeIndex = self.tokenViews.count - 2;
                [self.tokenViews[removeIndex] removeFromSuperview];
                [self.tokenViews removeObjectAtIndex:removeIndex];
                
                [self.textField setText:@""];
                
                if ([self.delegate respondsToSelector:@selector(tokenField:didRemoveTokenAtIndex:)]) {
                    [self.delegate tokenField:self didRemoveTokenAtIndex:removeIndex];
                }
            }
        }
    }
    
    self.tempTextFieldText = [textField rawText];
    [self invalidateIntrinsicContentSize];
    
    if ([self.delegate respondsToSelector:@selector(tokenField:didTextChanged:)]) {
        [self.delegate tokenField:self didTextChanged:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenField:didReturnWithText:)]) {
        [self.delegate tokenField:self didReturnWithText:textField.text];
    }
    return YES;
}

@end