//
//  MqttManager.h
//  mqttClient
//
//  Created by 王亚军 on 17/2/9.
//  Copyright © 2017年 王亚军. All rights reserved.
//

#import "MQTTKit.h"

@interface MqttManager : MQTTClient

typedef void(^DisConnection)(NSUInteger code);
typedef void(^ConnectionResult)(NSUInteger code);
typedef void(^ConnectionLost)(NSUInteger code);


- (void)setupStream;
+(instancetype)sharedMQTTClientManasger:(NSNumber *)userId;
/*
 *连接Mqtt 传入服务器主机地址，端口，用户名，密码，返回结果
 */
- (void)connectToHost:(NSString *)host andPort:(int)port andName:(NSString *)name andPassword:(NSString *)password ConnectionResult:(ConnectionResult)connectresult ConnectLost:(ConnectionLost)connectionlost;

/*
 *主动断开连接
 */
- (void)MQTTdisconnectWithBlock:(DisConnection)disconnectBlock;

/*
 *中途断开连接会进行自动重连
 */
- (void)MQTTDisconnection;

/*
 *未连接到服务器
 */


@end
