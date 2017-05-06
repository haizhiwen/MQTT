//
//  ViewController.m
//  MQTT
//
//  Created by 王亚军 on 16/7/22.
//  Copyright © 2016年 王亚军. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+extension.h"
#import "MqttManager.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


//服务器地址
#define kMQTTServerHost @"192.168.0.68"
//主题：需要从后台拿到
#define CLIENT_ID @13075

#define USER_MOBILE @"-1"
#define USER_PASSWORD @"670b14728ad9902aecba32e22fa4f6bd"

@interface ViewController ()

@property (strong, nonatomic) UITextField *TextField;
@property (strong, nonatomic) UILabel *showMessage;
@property (nonatomic, strong) MqttManager *client;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [self configUI];
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginkeyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (MqttManager *)client{
    static MqttManager * client = nil;
    if (!client) {
        client = [MqttManager sharedMQTTClientManasger:CLIENT_ID];
    }
    return client;
}
#pragma mark UI
- (void)configUI{
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 60, SCREEN_WIDTH - 40, 50)];
    titleLabel.text = @"MQTT客户端";
    titleLabel.font = [UIFont systemFontOfSize:25];
    titleLabel.textAlignment = NSTextAlignmentCenter ;
    [self.view addSubview:titleLabel];
    
    UILabel * receiveLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 170, SCREEN_WIDTH - 40, 50)];
    receiveLabel.tag = 100;
    receiveLabel.backgroundColor = [UIColor grayColor];
    receiveLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:receiveLabel];
    self.showMessage = receiveLabel;
    
    UITextField * field = [[UITextField alloc]initWithFrame:CGRectMake(20 , 240, SCREEN_WIDTH - 40 , 40)];
    field.tag = 200;
    field.delegate = self;
    field.layer.borderColor = [UIColor grayColor].CGColor;
    field.layer.borderWidth = 1.0;
    field.placeholder = @"请输入内容";
    field.layer.cornerRadius = 5;
    [self.view addSubview:field];
    self.TextField = field;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(30, 320, SCREEN_WIDTH/2 - 40, 40);
    [btn setTitle:@"连接" forState:UIControlStateNormal];
    btn.tag = 1;
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = YES;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage createImageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(50 + btn.frame.size.width , btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
    [btn2 setTitle:@"断开连接" forState:UIControlStateNormal];
    btn2.tag = 3;
    btn2.layer.cornerRadius = 5;
    btn2.clipsToBounds = YES;
    [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIImage createImageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
    
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(30, 380, SCREEN_WIDTH - 60, 40);
    [btn1 setTitle:@"发送" forState:UIControlStateNormal];
    btn1.tag = 2;
    btn1.layer.cornerRadius = 5;
    btn1.clipsToBounds = YES;
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage createImageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
    [self.view addSubview:btn1];

}

- (void)btnClick:(UIButton *)sender{
    if (sender.tag == 1) {
        [self ConfigClient];
    }else if(sender.tag == 2){
        ///发送
        //    for (int i = 0; i < 1000; i ++) {
        //        [self.client publishString:[NSString stringWithFormat:@"{\"action\":1,\"key\":%d}",i] toTopic:@"test/topic" withQos:AtMostOnce retain:YES completionHandler:^(int mid) {
        //
        //        }];
        //    }
        NSLog(@"%@",self.TextField.text);
        //        [self.client publishString:self.TextField.text toTopic:PubkTopic withQos:ExactlyOnce retain:YES completionHandler:^(int mid) {
        //            NSLog(@"publishString : %d",mid);
        //
        //        }];
    }else if (sender.tag == 3){
        [self.client MQTTdisconnectWithBlock:^(NSUInteger code) {
            [self connectionLost:code];
        }];
    }else if (sender.tag == 5){
    }
}

#pragma mark client connect
- (void)ConfigClient{
    //1.在app登录后，后台返回 name＋password＋topic
    
    //2.name＋password用于连接主机
    
    //3.topic 用于订阅主题
    
    //连接服务器  连接后，会通过block将连接结果code返回，然后执行此段代码块
    
    __weak typeof(self) weakSelf = self;
    
    [self.client connectToHost:kMQTTServerHost andPort:25200 andName:USER_MOBILE andPassword:USER_PASSWORD ConnectionResult:^(NSUInteger code) {
        NSLog(@"connection result %lu",(unsigned long)code);
        if (code == ConnectionAccepted) {
            [weakSelf connectionSuccess];
           
            NSLog(@"client is connected with id %@",weakSelf.client.clientID);
        } else {
            [weakSelf connectionFailed:code];
        }
        
    } ConnectLost:^(NSUInteger code) {
        NSLog(@"%d",code);
    }];

    [self.client setDisconnectionHandler:^(NSUInteger code){
        NSLog(@"%lu",(unsigned long)code);
        [weakSelf connectionLost:code];
    }];
    //MQTTMessage  里面的数据接收到的是二进制，这里框架将其封装成了字符串
    [self.client setMessageHandler:^(MQTTMessage* message)
     {
         //接收到消息，更新界面时需要切换回主线程
         NSLog(@"%@",message.payloadString);
         [weakSelf getMessage:message.payloadString];
         
     }];
    
}
- (void)getMessage:(NSString *)message{
    //             NSDictionary * dic =[weakSelf dictionaryWithJsonString:message.payloadString];
    //             NSLog(@"%@",dic);
    //
    dispatch_async(dispatch_get_main_queue(), ^{

    self.showMessage.text= message;
    });

}
///连接成功
- (void)connectionSuccess{
    NSLog(@"connectToHost 连接成功");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showMessage.text = @"connectToHost Success !";
    });
}
///连接失败
- (void)connectionFailed:(MQTTConnectionReturnCode)code{
    NSLog(@"connectToHost 连接失败");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showMessage.text = @"connectToHost Failed !";
    });
}
- (void)connectionLost:(NSUInteger)code{
    
    if (!self.client.connected) {
        NSLog(@"%@ connection lost !",self.client.clientID);
        self.showMessage.text = @"connectToHost Lost !";

    }else{
    
    }
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)LoginkeyboardWillChange:(NSNotification *)noti{
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
    //NSLog(@"%f",moveY);
    [UIView animateWithDuration:duration animations:^{
        
    }completion:^(BOOL finished) {
        self.view.transform = CGAffineTransformMakeTranslation(0, moveY / 2);
    }];
}
#pragma mark - TextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag==10){
        if ([string isEqualToString:@"\n"])
        {
            return YES;
        }
        return YES;
        
    }else{
        UIButton * btn = (UIButton *)[self.view viewWithTag:6];
        if (textField.text.length == 0) {
            btn.hidden = NO;
        }
        if ([string isEqualToString:@"\n"])
        {
            return YES;
        }
        
        NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (toBeString.length >= 12  &&  string.length >0)
        {
            textField.text = [toBeString substringToIndex:12];
            return  NO;
        }
//        NSCharacterSet * cs = [[NSCharacterSet characterSetWithCharactersInString:kAlphaNum] invertedSet];
//        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//        BOOL basic = [string isEqualToString:filtered];
        
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //键盘隐藏 也就是让键盘取消第一响应者身份
    return [textField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: NO];
}

- (void)dealloc{
    [self.client disconnectWithCompletionHandler:^(NSUInteger code)
     {
         // The client is disconnected when this completion handler is called
         NSLog(@"MQTT is disconnected");
     }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
