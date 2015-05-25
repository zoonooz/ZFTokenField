//
//  ZFTokenField.h
//  ZFTokenField
//
//  Created by Amornchai Kanokpullwad on 10/11/2014.
//  Copyright (c) 2014 Amornchai Kanokpullwad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFTokenField;

@protocol ZFTokenFieldDataSource <NSObject>
@required
- (CGFloat)lineHeightForTokenField:(ZFTokenField *)tokenField;
- (CGFloat)tokenMarginForTokenField:(ZFTokenField *)tokenField;
- (NSInteger)numberOfTokensInTokenField:(ZFTokenField *)tokenField;
- (UIView *)tokenField:(ZFTokenField *)tokenField viewForTokenAtIndex:(NSInteger)index;
@end

@protocol ZFTokenFieldDelegate <UITextFieldDelegate>
@optional
- (void)tokenField:(ZFTokenField *)tokenField didRemoveTokenAtIndex:(NSInteger)index;
- (void)tokenField:(ZFTokenField *)tokenField didReturnWithText:(NSString *)text;
- (void)tokenFieldDidReloadData:(ZFTokenField *)tokenField;
@end

@interface ZFTokenField : UIControl <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet id<ZFTokenFieldDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<ZFTokenFieldDelegate> delegate;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL shouldAutomaticallyRemoveToken;
@property (nonatomic, strong, readonly) UITextField *textField;
- (void)reloadData;
- (NSInteger)numberOfToken;
- (NSInteger)indexOfTokenView:(UIView *)view;
@end

@interface _ZFTokenFieldTextField : UITextField
@property (nonatomic, weak) ZFTokenField *tokenField;
@end
