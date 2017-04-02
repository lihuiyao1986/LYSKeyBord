//
//  ViewController.m
//  LYSKeyBord
//
//  Created by jk on 2017/3/20.
//  Copyright © 2017年 Goldcard. All rights reserved.
//

#import "ViewController.h"
#import "LYSNumPad.h"

@interface ViewController()<UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LYSNumPad *_keyborder = [[LYSNumPad alloc]initWithStyle:DECIMAL];
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
    _txt.placeholder = @"请输入金额";
    //_txt.delegate = self;
    [self.view addSubview:_txt];
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
