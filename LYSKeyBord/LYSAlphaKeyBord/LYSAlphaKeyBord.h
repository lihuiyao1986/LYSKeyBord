//
//  LYSAlphaKeyBord.h
//  LYSKeyBord
//
//  Created by jk on 2017/4/2.
//  Copyright © 2017年 Goldcard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYSAlphaKeyBord : UIView

@property(nonatomic,copy)void(^deleteBlock)();

@property(nonatomic,copy)void(^sureBlock)();

@property(nonatomic,copy)void(^valueChange)(NSString *value);

@end
