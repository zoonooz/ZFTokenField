//
//  ZFTokenField.h
//  ZFTokenField
//
//  Created by Amornchai Kanokpullwad on 10/11/2014.
//  Copyright (c) 2014 Amornchai Kanokpullwad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFTokenField;

@interface ZFTokenTextField : UITextField
@end

@protocol ZFTokenFieldDataSource <NSObject>
@required
- (CGFloat)lineHeightForTokenInField:(ZFTokenField *)tokenField;
- (NSUInteger)numberOfTokenInField:(ZFTokenField *)tokenField;
- (UIView *)tokenField:(ZFTokenField *)tokenField viewForTokenAtIndex:(NSUInteger)index;

@optional
- (NSString *)tokenFieldPrefixTitle:(ZFTokenField *)tokenField;

@end

@protocol ZFTokenFieldDelegate <NSObject>
@optional
- (CGFloat)tokenMarginInTokenInField:(ZFTokenField *)tokenField;
- (void)tokenField:(ZFTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index;
- (void)tokenField:(ZFTokenField *)tokenField didReturnWithText:(NSString *)text;
- (void)tokenField:(ZFTokenField *)tokenField didTextChanged:(NSString *)text;
- (void)tokenField:(ZFTokenField*)tokenField didResizeHeight:(CGFloat)height;
- (void)tokenFieldDidBeginEditing:(ZFTokenField *)tokenField;
- (BOOL)tokenFieldShouldEndEditing:(ZFTokenField *)textField;
- (void)tokenFieldDidEndEditing:(ZFTokenField *)tokenField;
@end

@interface ZFTokenField : UIControl

@property (nonatomic, weak) IBOutlet id<ZFTokenFieldDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<ZFTokenFieldDelegate> delegate;

@property (nonatomic, strong, readonly) ZFTokenTextField *textField;

@property (nonatomic, assign) NSInteger maxLine;

- (void)reloadData;
- (NSUInteger)numberOfToken;
- (NSUInteger)indexOfTokenView:(UIView *)view;

@end