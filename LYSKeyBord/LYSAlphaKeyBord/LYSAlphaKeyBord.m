//
//  LYSAlphaKeyBord.m
//  LYSKeyBord
//
//  Created by jk on 2017/4/2.
//  Copyright © 2017年 Goldcard. All rights reserved.
//

// 获取设备宽度
#define DeviceW [UIScreen mainScreen].bounds.size.width

// 获取设备高度
#define DeviceH [UIScreen mainScreen].bounds.size.height

// 键盘的高度
#define KEYBORDER_HEIGHT 216.f

// 每行显示的列数
#define COLUMN  8

#import "LYSAlphaKeyBord.h"

@interface LYSAlphaKeyBord (){
    UIFont *_keyborderFont;// 键盘字体大小
    CGFloat _spacing;// 间隔
    UIButton *_switchBtn;// 切换按钮
    UIButton *_delBtn;//删除按钮
    UIButton *_sureBtn;//确认按钮
    UIResponder<UITextInput> *_textInput;//输入框
    
    struct {
        unsigned int textInputSupportsShouldChangeTextInRange:1;
        unsigned int delegateSupportsTextFieldShouldChangeCharactersInRange:1;
        unsigned int delegateSupportsTextViewShouldChangeTextInRange:1;
    } _delegateFlags;
}

@property(nonatomic,copy)NSArray *items;

@end

@implementation LYSAlphaKeyBord

#pragma mark - 初始化
- (instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, DeviceW, KEYBORDER_HEIGHT)];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 创建ui
-(void)setupUI{
    
    __weak typeof (self) MyWeakSelf = self;
    
    _spacing = 10.f;
    
    // 键盘字体大小
    _keyborderFont = [UIFont systemFontOfSize:18];
    
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *itemBtn = [MyWeakSelf createBtn];
        [itemBtn setTitle:obj forState:UIControlStateNormal];
        [itemBtn setTitle:obj forState:UIControlStateHighlighted];
        itemBtn.tag = idx + 100;
        [MyWeakSelf addSubview:itemBtn];
    }];
    
    _switchBtn = [self createBtn];
    [_switchBtn setTitle:@"ABC" forState:UIControlStateNormal];
    [_switchBtn setTitle:@"ABC" forState:UIControlStateHighlighted];
    [self addSubview:_switchBtn];
    
    _delBtn = [self createBtn];
    [_delBtn setImage:[UIImage imageNamed:@"LYSNumPad.bundle/delete.png"] forState:UIControlStateNormal];
    [self addSubview:_delBtn];
    
    _sureBtn = [self createBtn];
    [_sureBtn setTitle:@"确认" forState:UIControlStateNormal];
    [_sureBtn setTitle:@"确认" forState:UIControlStateHighlighted];
    [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_sureBtn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"1686D5" alpha:1.0]] forState:UIControlStateNormal];
    [_sureBtn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"1686D5" alpha:0.9]] forState:UIControlStateHighlighted];

    [self addSubview:_sureBtn];
    
    [self addNotificationsObservers];

}


#pragma mark - Notifications

- (void)addNotificationsObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidBeginEditing:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidBeginEditing:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidEndEditing:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidEndEditing:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}


- (void)textDidEndEditing:(NSNotification *)notification {
    _textInput = nil;
}

- (void)textDidBeginEditing:(NSNotification *)notification {
    if (![notification.object conformsToProtocol:@protocol(UITextInput)]) {
        return;
    }
    
    UIResponder<UITextInput> *textInput = notification.object;
    
    if (textInput.inputView && self == textInput.inputView) {
        _textInput = textInput;
        
        _delegateFlags.textInputSupportsShouldChangeTextInRange = NO;
        _delegateFlags.delegateSupportsTextFieldShouldChangeCharactersInRange = NO;
        _delegateFlags.delegateSupportsTextViewShouldChangeTextInRange = NO;
        
        if ([_textInput respondsToSelector:@selector(shouldChangeTextInRange:replacementText:)]) {
            _delegateFlags.textInputSupportsShouldChangeTextInRange = YES;
        } else if ([_textInput isKindOfClass:[UITextField class]]) {
            id<UITextFieldDelegate> delegate = [(UITextField *)_textInput delegate];
            if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                _delegateFlags.delegateSupportsTextFieldShouldChangeCharactersInRange = YES;
            }
        } else if ([_textInput isKindOfClass:[UITextView class]]) {
            id<UITextViewDelegate> delegate = [(UITextView *)_textInput delegate];
            if ([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                _delegateFlags.delegateSupportsTextViewShouldChangeTextInRange = YES;
            }
        }
    }
}


#pragma mark - 创建按钮
-(UIButton*)createBtn{
    UIButton *_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.titleLabel.font = _keyborderFont;
    [_btn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"ffffff" alpha:1.0]] forState:UIControlStateNormal];
    [_btn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"e2e3e5" alpha:1.0]] forState:UIControlStateHighlighted];
    _btn.layer.cornerRadius = 4.f;
    _btn.layer.masksToBounds = YES;
    [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return _btn;
}

#pragma mark - 按钮被点击
-(void)btnClicked:(UIButton*)sender{
    
    if (!_textInput) {
        return;
    }
    
    if( sender != _delBtn && sender != _sureBtn && sender != _switchBtn){
        
        NSString *text = sender.currentTitle;
        
        if (_delegateFlags.textInputSupportsShouldChangeTextInRange) {
            
            if ([_textInput shouldChangeTextInRange:_textInput.selectedTextRange replacementText:text]) {
                
                [_textInput insertText:text];
                
            }
            
        } else if (_delegateFlags.delegateSupportsTextFieldShouldChangeCharactersInRange) {
            
            NSRange selectedRange = [[self class] selectedRange:_textInput];
            
            UITextField *textField = (UITextField *)_textInput;
            
            if ([textField.delegate textField:textField shouldChangeCharactersInRange:selectedRange replacementString:text]) {
                
                [_textInput insertText:text];
                
            }
        } else if (_delegateFlags.delegateSupportsTextViewShouldChangeTextInRange) {
            
            NSRange selectedRange = [[self class] selectedRange:_textInput];
            
            UITextView *textView = (UITextView *)_textInput;
            
            if ([textView.delegate textView:textView shouldChangeTextInRange:selectedRange replacementText:text]) {
                
                [_textInput insertText:text];
                
            }
            
        } else {
            
            [_textInput insertText:text];
            
        }
        
        if(self.valueChange){
            self.valueChange(text);
        }
        
    }else if(sender == _delBtn){
        
        if (_delegateFlags.textInputSupportsShouldChangeTextInRange) {
            
            UITextRange *textRange = _textInput.selectedTextRange;
            
            if ([textRange.start isEqual:textRange.end]) {
                
                UITextPosition *newStart = [_textInput positionFromPosition:textRange.start inDirection:UITextLayoutDirectionLeft offset:1];
                
                textRange = [_textInput textRangeFromPosition:newStart toPosition:textRange.end];
            }
            
            if ([_textInput shouldChangeTextInRange:textRange replacementText:@""]) {
                
                [_textInput deleteBackward];
            }
            
        } else if (_delegateFlags.delegateSupportsTextFieldShouldChangeCharactersInRange) {
            
            NSRange selectedRange = [[self class] selectedRange:_textInput];
            
            if (selectedRange.length == 0 && selectedRange.location > 0) {
                selectedRange.location--;
                selectedRange.length = 1;
            }
            
            UITextField *textField = (UITextField *)_textInput;
            
            if ([textField.delegate textField:textField shouldChangeCharactersInRange:selectedRange replacementString:@""]) {
                
                [_textInput deleteBackward];
                
            }
        } else if (_delegateFlags.delegateSupportsTextViewShouldChangeTextInRange) {
            
            NSRange selectedRange = [[self class] selectedRange:_textInput];
            
            if (selectedRange.length == 0 && selectedRange.location > 0) {
                selectedRange.location--;
                selectedRange.length = 1;
            }
            
            UITextView *textView = (UITextView *)_textInput;
            
            if ([textView.delegate textView:textView shouldChangeTextInRange:selectedRange replacementText:@""]) {
                
                [_textInput deleteBackward];
                
            }
            
        } else {
            
            [_textInput deleteBackward];
            
        }
        
        if (self.deleteBlock){
            self.deleteBlock();
        }
        
    }else if(_sureBtn == sender){
        
        [_textInput resignFirstResponder];
        
        if(self.sureBlock){
            self.sureBlock();
        }
        
    }else if(_switchBtn == sender){
        NSString *_switchStr = sender.currentTitle;
        if ([_switchStr isEqualToString:@"ABC"]) {
            [sender setTitle:@"abc" forState:UIControlStateNormal];
            [sender setTitle:@"abc" forState:UIControlStateHighlighted];
            [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIButton *btn = (UIButton*)[self viewWithTag:100 + idx];
                [btn setTitle:[btn.currentTitle uppercaseString] forState:UIControlStateNormal];
                [btn setTitle:[btn.currentTitle uppercaseString] forState:UIControlStateHighlighted];
            }];
        }else{
            [sender setTitle:@"ABC" forState:UIControlStateNormal];
            [sender setTitle:@"ABC" forState:UIControlStateHighlighted];
            [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIButton *btn = (UIButton*)[self viewWithTag:100 + idx];
                [btn setTitle:[btn.currentTitle lowercaseString] forState:UIControlStateNormal];
                [btn setTitle:[btn.currentTitle lowercaseString] forState:UIControlStateHighlighted];
            }];
        }
    }
    
}

#pragma mark - Additions

+ (NSRange)selectedRange:(id<UITextInput>)textInput {
    
    UITextRange *textRange = [textInput selectedTextRange];
    
    NSInteger startOffset = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRange.start];
    NSInteger endOffset = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRange.end];
    
    return NSMakeRange(startOffset, endOffset - startOffset);
}

#pragma mark - 重写layoutSubviews方法
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat itemW = (CGRectGetWidth(self.frame) - (COLUMN + 1) * _spacing) / COLUMN;
    NSInteger row = self.items.count / COLUMN + 1;
    CGFloat itemH = (CGRectGetHeight(self.frame) - (row + 1) * _spacing) / row;
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self viewWithTag:idx + 100].frame = CGRectMake((idx % (COLUMN)) * (itemW + _spacing) + _spacing , (idx / (COLUMN)) * (itemH + _spacing) + _spacing, itemW, itemH);
    }];
    _switchBtn.frame = CGRectMake(CGRectGetMaxX([self viewWithTag:(self.items.count - 1 + 100)].frame) + _spacing, CGRectGetMinY([self viewWithTag:(self.items.count - 1 + 100)].frame), 2* itemW + _spacing, itemH);
    _delBtn.frame = CGRectMake(CGRectGetMaxX(_switchBtn.frame) + _spacing, CGRectGetMinY(_switchBtn.frame), 2* itemW + _spacing, itemH);
    _sureBtn.frame = CGRectMake(CGRectGetMaxX(_delBtn.frame) + _spacing, CGRectGetMinY(_switchBtn.frame), 2* itemW + _spacing, itemH);
}

#pragma mark - 将颜色转换成图片
- (UIImage *)createImageWithColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

#pragma mark - 生成16进制颜色
-(UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha{
    
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}


-(NSArray*)items{
    return @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
}

@end
