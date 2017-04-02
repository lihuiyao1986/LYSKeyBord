//
//  LYSNumPad.m
//  LYSKeyBord
//
//  Created by jk on 2017/3/20.
//  Copyright © 2017年 Goldcard. All rights reserved.
//


#import "LYSNumPad.h"

// 获取设备宽度
#define DeviceW [UIScreen mainScreen].bounds.size.width

// 获取设备高度
#define DeviceH [UIScreen mainScreen].bounds.size.height

// 每行显示的列数
#define COLUMN  4

// 行数
#define ROW 4

// 键盘的高度
#define KEYBORDER_HEIGHT 216.f


@interface LYSNumPad (){
    UIButton *_confirmBtn;//确认按钮
    UIButton *_deleteBtn;//删除按钮
    UIView *_leftView;//左边视图
    CGFloat _spacing;// 间隔
    UIFont *_keyborderFont;// 键盘字体大小
    UIResponder<UITextInput> *_textInput;//输入框
    LYSNumPadStyle _style;//类型
    struct {
        unsigned int textInputSupportsShouldChangeTextInRange:1;
        unsigned int delegateSupportsTextFieldShouldChangeCharactersInRange:1;
        unsigned int delegateSupportsTextViewShouldChangeTextInRange:1;
    } _delegateFlags;
}

@property(nonatomic,copy)NSArray *items;

@end

@implementation LYSNumPad


#pragma mark - 自定义私有的init方法
- (instancetype)initWithStyle:(LYSNumPadStyle)style{
    
    self = [super initWithFrame:CGRectMake(0, 0, DeviceW, KEYBORDER_HEIGHT)];
    
    if (self) {
        _style = style;
        [self setupUI];
    }
    
    return self;
}


#pragma mark - 创建UI
-(void)setupUI{
    
    // 间隔
    _spacing = 0.5;
    
    // 键盘字体大小
    _keyborderFont = [UIFont systemFontOfSize:18];
    
    // 设置背景颜色
    self.backgroundColor = [self colorWithHexString:@"D2D2D2" alpha:1.0];
    
    // 左边视图
    _leftView = [[UIView alloc]init];
    [self addSubview:_leftView];
    
    // 添加item按钮
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.titleLabel.font = _keyborderFont;
        [_btn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"ffffff" alpha:1.0]] forState:UIControlStateNormal];
        [_btn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"e2e3e5" alpha:1.0]] forState:UIControlStateHighlighted];
        _btn.tag = idx;
        if ([obj isEqualToString:@"resign"]) {
            [_btn setImage:[UIImage imageNamed:@"LYSNumPad.bundle/resign.png"] forState:UIControlStateNormal];
        }else{
            [_btn setTitle:obj forState:UIControlStateNormal];
            [_btn setTitle:obj forState:UIControlStateHighlighted];
        }
        [_btn setTitleColor:[self colorWithHexString:@"1686D5" alpha:1.0] forState:UIControlStateHighlighted];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_leftView addSubview:_btn];
    }];
    
    // 设置删除按钮
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setImage:[UIImage imageNamed:@"LYSNumPad.bundle/delete.png"] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"ffffff" alpha:1.0]] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"e2e3e5" alpha:1.0]] forState:UIControlStateHighlighted];
    [_deleteBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn.titleLabel.font = _keyborderFont;
    _deleteBtn.backgroundColor = [UIColor whiteColor];
    [self addSubview:_deleteBtn];
    
    // 设置确认按钮
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmBtn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"1686D5" alpha:1.0]] forState:UIControlStateNormal];
    [_confirmBtn setBackgroundImage:[self createImageWithColor:[self colorWithHexString:@"1686D5" alpha:0.9]] forState:UIControlStateNormal];
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn.titleLabel.font = _keyborderFont;
    [self addSubview:_confirmBtn];
    
    // 通知
    [self addNotificationsObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


#pragma mark - 按钮被点击
-(void)btnClicked:(UIButton*)sender{
    
    if (!_textInput) {
        return;
    }
    
    if( sender != _confirmBtn && sender != _deleteBtn){
        
        if (sender.tag == 11) {
            
            [_textInput resignFirstResponder];
            if (self.resignBlock) {
                self.resignBlock();
            }
            
        }else{
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
            
            if (self.valueChange) {
                self.valueChange(text);
            }
        }
        
    }else if(sender == _deleteBtn){
        
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
        
        if(self.deleteBlock){
            
            self.deleteBlock();
            
        }
        
    }else if(_confirmBtn == sender){
        
        [_textInput resignFirstResponder];
        
        if(self.sureBlock){
            
            self.sureBlock();
            
        }
    }
}

#pragma mark - 重写layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    // 计算出每个键盘item的高度和宽度
    CGFloat itemW = CGRectGetWidth(self.frame) / COLUMN;
    CGFloat itemH = CGRectGetHeight(self.frame) / ROW;
    _leftView.frame = CGRectMake(0, 0, itemW * (COLUMN - 1), itemH * ROW);
    [_leftView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake((idx % (ROW - 1)) * itemW , (idx / (COLUMN -1)) * itemH + _spacing, itemW - _spacing, itemH - _spacing);
    }];
    _deleteBtn.frame = CGRectMake(CGRectGetMaxX(_leftView.frame), _spacing, itemW , CGRectGetHeight(self.frame) / 2 - _spacing);
    _confirmBtn.frame = CGRectMake(CGRectGetMaxX(_leftView.frame), CGRectGetMaxY(_deleteBtn.frame),itemW , CGRectGetHeight(self.frame) / 2);
}


#pragma mark - Additions

+ (NSRange)selectedRange:(id<UITextInput>)textInput {
    
    UITextRange *textRange = [textInput selectedTextRange];
    
    NSInteger startOffset = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRange.start];
    NSInteger endOffset = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRange.end];
    
    return NSMakeRange(startOffset, endOffset - startOffset);
}

#pragma mark - 数据源
-(NSArray*)items{
    switch (_style) {
        case DECIMAL:
            return @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@".",@"9",@"resign"];
        case IDCARD:
            return @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"x",@"9",@"resign"];
        case DEFAULT:
            return @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"",@"9",@"resign"];
    }
}

@end
