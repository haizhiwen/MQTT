//
//  MqttManager.m
//  mqttClient
//
//  Created by 王亚军 on 17/2/9.
//  Copyright © 2017年 王亚军. All rights reserved.
//

#import "MqttManager.h"

@interface MqttManager ()


@end

@implementation MqttManager

- (void)setupStream{
    self.keepAlive = 15;
    self.port = 25200;
    
}
#pragma -mark创建MQTT客户端管理者单例
+(instancetype)sharedMQTTClientManasger:(NSNumber *)userId
{
    static MqttManager * _instance;
    if (_instance && [_instance.clientID isEqualToString:[NSString stringWithFormat:@"%@",userId]]) {
        return _instance;
    }else if(_instance && ![_instance.clientID isEqualToString:[NSString stringWithFormat:@"%@",userId]]){
        NSString * clientID = [NSString stringWithFormat:@"%@",userId];
        _instance = [[MqttManager alloc] initWithClientId:clientID];
        return _instance;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *clientID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
        clientID = [NSString stringWithFormat:@"%@",userId];
        if (userId) {
            _instance = [[MqttManager alloc] initWithClientId:clientID];
        }else{
            _instance = nil;
        }
    });
    
    return _instance;
}

- (void)connectToHost:(NSString *)host andPort:(int)port andName:(NSString *)name andPassword:(NSString *)password ConnectionResult:(ConnectionResult)connectresult ConnectLost:(ConnectionLost)connectionlost{
    self.port = port;
    self.CouldNotConnectToServer = ^(NSUInteger code){
        connectionlost(code);
//        GNQLog(@"连接失败， 错误代码 ： %lu",(unsigned long)code);
    };
    /// 连接IM
    [self connectToHost:host andName:name andPassword:password completionHandler:^(MQTTConnectionReturnCode code) {
        
        connectresult(code);
    }];
}
- (void)MQTTdisconnectWithBlock:(DisConnection)disconnectBlock{
    [self disconnectWithCompletionHandler:^(NSUInteger code) {
//        NSLog(@"disconnectWithCompletionHandler %lu",(unsigned long)code);
        dispatch_async(dispatch_get_main_queue(), ^{
            disconnectBlock(code);
        });
    }];
}
- (void)MQTTDisconnection{
    
    
}

@end
