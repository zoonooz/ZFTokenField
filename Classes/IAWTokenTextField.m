//
//  ZFTokenField.m
//  ZFTokenField
//
//  Created by Amornchai Kanokpullwad on 10/11/2014.
//  Copyright (c) 2014 Amornchai Kanokpullwad. All rights reserved.
//

#import "IAWCustomTokenField.h"

@interface IAWTokenTextField ()
- (NSString*)rawText;
@end

@implementation IAWTokenTextField

- (void)setText:(NSString*)text {
    if ([text isEqualToString:@""]) {
        if (((IAWCustomTokenField*)self.superview.superview).numberOfToken > 0) {
            text = @"\u200B";
        }
    }
    [super setText:text];
}

- (NSString*)text {
    return [super.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
}

- (NSString*)rawText {
    return super.text;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer {
    //Prevent zooming
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}

@end

@interface IAWCustomTokenField () <UITextFieldDelegate>
{
    UITapGestureRecognizer* tapGesture;
}
@property (nonatomic, strong) IAWTokenTextField* textField;
@property (nonatomic, strong) NSMutableArray* tokenViews;
@property (nonatomic, strong) UIScrollView* scrollView;

@property (nonatomic, strong) NSString* tempTextFieldText;
@end

@implementation IAWCustomTokenField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [self removeGestureRecognizer:tapGesture];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (BOOL)focusOnTextField {
    [self.textField becomeFirstResponder];
    return YES;
}

#pragma mark -

- (void)setup {
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(focusOnTextField) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField                    = [[IAWTokenTextField alloc] init];
    self.textField.borderStyle        = UITextBorderStyleNone;
    self.textField.backgroundColor    = [UIColor clearColor];
    self.textField.delegate           = self;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.returnKeyType      = UIReturnKeyDone;
    
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.scrollView                        = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor        = [UIColor clearColor];
    self.scrollView.directionalLockEnabled = YES;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self addGestureRecognizer:tapGesture];
    self.tokenViews = [NSMutableArray array];
    
    [self reloadData];
}

- (void)tapView:(UITapGestureRecognizer*)gesture {
    [self focusOnTextField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self invalidateIntrinsicContentSize];
    
    NSEnumerator* tokenEnumerator = [self.tokenViews objectEnumerator];
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        UIView* token = [tokenEnumerator nextObject];
        [token setFrame:itemRect];
    }];
}

- (CGSize)intrinsicContentSize {
    if (!self.tokenViews) {
        return CGSizeZero;
    }
    
    __block CGRect totalRect = CGRectNull;
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        totalRect = CGRectUnion(itemRect, totalRect);
    }];
    
    CGFloat maxHeight    = self.maxLine* [self.dataSource lineHeightForTokenInField:self];
    CGFloat scrollHeight = totalRect.size.height >= maxHeight ? maxHeight : totalRect.size.height;
    
    self.scrollView.contentSize = totalRect.size;
    [self.scrollView setFrame:CGRectMake(0, 0, self.frameSizeWidth, scrollHeight)];
    
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(tokenField:didResizeHeight:)]) {
        [self.delegate tokenField:self didResizeHeight:scrollHeight];
    }
    
    return totalRect.size;
}

#pragma mark - Public

- (void)reloadData {
    // clear
    for (UIView* view in self.tokenViews) {
        [view removeFromSuperview];
    }
    [self.tokenViews removeAllObjects];
    [self.scrollView removeFromSuperview];
    
    UILabel* label = [[UILabel alloc] init];
    [label setText:LocalizedString(@"add:")];
    label.backgroundColor = [UIColor clearColor];
    label.textColor       = [UIColor colorWithRed:149. / 255. green:149. / 255. blue:149. / 255. alpha:1.];
    
    [self.scrollView addSubview:label];
    [self.tokenViews addObject:label];
    
    if (self.dataSource) {
        NSUInteger count = [self.dataSource numberOfTokenInField:self];
        for (int i = 0; i < count; i++) {
            UIView* tokenView = [self.dataSource tokenField:self viewForTokenAtIndex:i];
            tokenView.autoresizingMask = UIViewAutoresizingNone;
            [self.scrollView addSubview:tokenView];
            [self.tokenViews addObject:tokenView];
        }
    }
    
    [self.tokenViews addObject:self.textField];
    [self.scrollView addSubview:self.textField];
    self.textField.frame = (CGRect){0, 0, 100, [self.dataSource lineHeightForTokenInField:self]};
    
    [self invalidateIntrinsicContentSize];
    [self.textField setText:@""];
    
    [self addSubview:self.scrollView];
}

- (NSUInteger)numberOfToken {
    return self.tokenViews.count - 2;
}

- (NSUInteger)indexOfTokenView:(UIView*)view {
    return [self.tokenViews indexOfObject:view];
}

#pragma mark - Private

- (void)enumerateItemRectsUsingBlock:(void (^)(CGRect itemRect))block {
    NSUInteger rowCount = 0;
    CGFloat x           = 0, y = 0;
    CGFloat margin      = 0;
    CGFloat lineHeight  = [self.dataSource lineHeightForTokenInField:self];
    
    if ([self.delegate respondsToSelector:@selector(tokenMarginInTokenInField:)]) {
        margin = [self.delegate tokenMarginInTokenInField:self];
    }
    
    for (UIView* token in self.tokenViews) {
        CGFloat width      = MAX(CGRectGetWidth(self.bounds), CGRectGetWidth(token.frame));
        CGFloat tokenWidth = MIN(CGRectGetWidth(self.bounds), CGRectGetWidth(token.frame));
        if (x > width - tokenWidth) {
            y       += lineHeight + margin;
            x        = 0;
            rowCount = 0;
        }
        
        if ([token isKindOfClass:[IAWTokenTextField class]]) {
            UITextField* textField = (UITextField*)token;
            CGSize size            = [textField sizeThatFits:(CGSize){CGRectGetWidth(self.bounds), lineHeight}];
            size.height = lineHeight;
            if (size.width > CGRectGetWidth(self.bounds)) {
                size.width = CGRectGetWidth(self.bounds);
            }
            token.frame = (CGRect){{x, y}, size};
        }
        
        if ([token isKindOfClass:[UILabel class]]) {
            x = x + 10;
            UILabel* label = (UILabel*)token;
            CGSize size    = [label sizeThatFits:(CGSize){CGRectGetWidth(self.bounds), lineHeight}];
            label.frame = (CGRect){{x, (lineHeight - size.height) / 2}, size};
        }
        
        block((CGRect){x, y, tokenWidth, token.frame.size.height});
        x += tokenWidth + margin;
        rowCount++;
    }
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(IAWTokenTextField*)textField {
    if (textField.text.length == 0) {
        textField.text = @"";
    }
    self.tempTextFieldText = [textField rawText];
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]) {
        [self.delegate tokenFieldDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(IAWTokenTextField*)textField {
    if ([self.delegate respondsToSelector:@selector(tokenFieldShouldEndEditing:)]) {
        return [self.delegate tokenFieldShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(IAWTokenTextField*)textField {
    if (textField.text.length == 0 || [textField.text isEqualToString:@""]) {
        textField.text = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)]) {
        [self.delegate tokenFieldDidEndEditing:self];
    }
}

- (void)textFieldDidChange:(IAWTokenTextField*)textField {
    if ([[textField rawText] isEqualToString:@""]) {
        textField.text = @"\u200B";
        
        if ([self.tempTextFieldText isEqualToString:@"\u200B"]) {
            if (self.tokenViews.count > 2) {
                NSUInteger removeIndex = self.tokenViews.count - 2;
                [self.tokenViews[removeIndex] removeFromSuperview];
                [self.tokenViews removeObjectAtIndex:removeIndex];
                
                [self.textField setText:@""];
                
                if ([self.delegate respondsToSelector:@selector(tokenField:didRemoveTokenAtIndex:)]) {
                    [self.delegate tokenField:self didRemoveTokenAtIndex:removeIndex - 1];
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

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(tokenField:didReturnWithText:)]) {
        [self.delegate tokenField:self didReturnWithText:textField.text];
    }
    return YES;
}

@end