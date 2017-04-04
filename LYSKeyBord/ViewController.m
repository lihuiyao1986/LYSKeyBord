//
//  ViewController.m
//  LYSKeyBord
//
//  Created by jk on 2017/3/20.
//  Copyright © 2017年 Goldcard. All rights reserved.
//

#import "ViewController.h"
#import "LYSNumPad.h"
#import "LYSAlphaKeyBord.h"

@interface ViewController()<UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LYSNumPad *_keyborder = [[LYSNumPad alloc]initWithStyle:IDCARD];
    _keyborder.resignBlock = ^(){
        NSLog(@"resignBlock");
    };
    _keyborder.sureBlock = ^(){
        NSLog(@"sureBlock");
    };
    _keyborder.deleteBlock = ^(){
        NSLog(@"deleteBlock");
    };
    _keyborder.valueChange = ^(NSString *value){
        NSLog(@"value = %@",value);
    };
    UITextField *_txt = [[UITextField alloc]initWithFrame:CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 40)];
    _txt.inputView = _keyborder;
    _txt.placeholder = @"身份证键盘";
    //_txt.delegate = self;
    [self.view addSubview:_txt];
    
    LYSNumPad *_keyborder1 = [[LYSNumPad alloc]initWithStyle:DECIMAL];
    _keyborder1.resignBlock = ^(){
        NSLog(@"resignBlock");
    };
    _keyborder1.sureBlock = ^(){
        NSLog(@"sureBlock");
    };
    _keyborder1.deleteBlock = ^(){
        NSLog(@"deleteBlock");
    };
    _keyborder1.valueChange = ^(NSString *value){
        NSLog(@"value = %@",value);
    };
    UITextField *_txt1 = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_txt.frame) + 10, CGRectGetWidth(self.view.frame) - 40, 40)];
    _txt1.inputView = _keyborder1;
    _txt1.placeholder = @"小数键盘";
    //_txt.delegate = self;
    [self.view addSubview:_txt1];
    
    
    LYSNumPad *_keyborder2 = [[LYSNumPad alloc]initWithStyle:DEFAULT];
    _keyborder2.resignBlock = ^(){
        NSLog(@"resignBlock");
    };
    _keyborder2.sureBlock = ^(){
        NSLog(@"sureBlock");
    };
    _keyborder2.deleteBlock = ^(){
        NSLog(@"deleteBlock");
    };
    _keyborder2.valueChange = ^(NSString *value){
        NSLog(@"value = %@",value);
    };
    UITextField *_txt2 = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_txt1.frame) + 10, CGRectGetWidth(self.view.frame) - 40, 40)];
    _txt2.inputView = _keyborder2;
    _txt2.placeholder = @"默认键盘";
    //_txt.delegate = self;
    [self.view addSubview:_txt2];
    
    LYSAlphaKeyBord *_keyborder3 = [[LYSAlphaKeyBord alloc]init];
    _keyborder3.sureBlock = ^(){
        NSLog(@"LYSAlphaKeyBord sureBlock");
    };
    _keyborder3.deleteBlock = ^(){
        NSLog(@"LYSAlphaKeyBord deleteBlock");
    };
    _keyborder3.valueChange = ^(NSString * value){
        NSLog(@"LYSAlphaKeyBord %@",value);
    };
    UITextField *_txt3 = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_txt2.frame) + 10, CGRectGetWidth(self.view.frame) - 40, 40)];
    _txt3.inputView = _keyborder3;
    _txt3.placeholder = @"字母键盘";
    //_txt.delegate = self;
    [self.view addSubview:_txt3];
    // Do any additiona l setup after loading the view, typically from a nib.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
