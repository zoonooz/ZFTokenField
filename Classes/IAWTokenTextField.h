//
//  ZFTokenField.h
//  ZFTokenField
//
//  Created by Amornchai Kanokpullwad on 10/11/2014.
//  Copyright (c) 2014 Amornchai Kanokpullwad. All rights reserved.
//


#import <UIKit/UIKit.h>

@class IAWCustomTokenField;

@interface IAWTokenTextField : UITextField
@end

@protocol IAWTokenFieldDataSource <NSObject>
@required
- (CGFloat)lineHeightForTokenInField:(IAWCustomTokenField*)tokenField;
- (NSUInteger)numberOfTokenInField:(IAWCustomTokenField*)tokenField;
- (UIView*)tokenField:(IAWCustomTokenField*)tokenField viewForTokenAtIndex:(NSUInteger)index;
@end

@protocol IAWTokenFieldDelegate <NSObject>
@optional
- (CGFloat)tokenMarginInTokenInField:(IAWCustomTokenField*)tokenField;
- (void)tokenField:(IAWCustomTokenField*)tokenField didRemoveTokenAtIndex:(NSUInteger)index;
- (void)tokenField:(IAWCustomTokenField*)tokenField didReturnWithText:(NSString*)text;
- (void)tokenField:(IAWCustomTokenField*)tokenField didTextChanged:(NSString*)text;
- (void)tokenField:(IAWCustomTokenField*)tokenField didResizeHeight:(CGFloat)height;
- (void)tokenFieldDidBeginEditing:(IAWCustomTokenField*)tokenField;
- (BOOL)tokenFieldShouldEndEditing:(IAWCustomTokenField*)textField;
- (void)tokenFieldDidEndEditing:(IAWCustomTokenField*)tokenField;
@end

@interface IAWCustomTokenField : UIControl

@property (nonatomic, weak) IBOutlet id<IAWTokenFieldDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<IAWTokenFieldDelegate> delegate;
@property (nonatomic, assign) NSInteger maxLine;

@property (nonatomic, strong, readonly) IAWTokenTextField* textField;

- (void)      reloadData;
- (NSUInteger)numberOfToken;
- (NSUInteger)indexOfTokenView:(UIView*)view;

@end