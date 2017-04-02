//
//  LYSNumPad.h
//  LYSKeyBord
//
//  Created by jk on 2017/3/20.
//  Copyright © 2017年 Goldcard. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LYSNumPadStyle){
    DECIMAL,
    IDCARD
};

typedef void(^DeleteBlock)();

typedef void(^SureBlock)();

typedef void(^ResignBlock)();

typedef void(^ValueChanged)(NSString *value);

@interface LYSNumPad : UIView

@property(nonatomic,copy)DeleteBlock deleteBlock;

@property(nonatomic,copy)SureBlock sureBlock;

@property(nonatomic,copy)ResignBlock resignBlock;

@property(nonatomic,copy)ValueChanged valueChange;

- (instancetype)initWithStyle:(LYSNumPadStyle)style;

@end
