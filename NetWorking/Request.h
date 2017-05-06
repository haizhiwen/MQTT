//
//  Request.h
//  云医社
//
//  Created by wyj on 15/4/23.
//  Copyright (c) 2015年 wyj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DownloadErrorBlock)(id responseObject);
typedef void(^DownloadFinishedBlock)(id responseObject);
typedef void(^DownloadFailedBlock)(NSString*erroeMsg);

typedef void(^FinishedLoginBlock)(NSString * urlstring,NSDictionary * dict);

@interface Request : NSObject
////get_post 0 get 1 post
+ (void)GET_POST:(int)get_post requestWithUrlString:(NSString *)urlString
   andParameters:(id)dictionary
     finishBlock:(DownloadFinishedBlock)finishBlock
       failBlock:(DownloadFailedBlock)failedBlock;

+(void)POSTrequestWithUrlString:(NSString *)urlstring
                  andParameters:(id)dictionary
                    finishBlock:(DownloadFinishedBlock)finishBlock
                      failBlock:(DownloadFailedBlock)failedBlock;

+(void)GETrequestWithUrlString:(NSString *)urlstring
                 andParameters:(id)dictionary
                   finishBlock:(DownloadFinishedBlock)finishBlock
                     failBlock:(DownloadFailedBlock)failedBlock;
//重新登录
+ (void)reLoginWith:(NSString *)urlString andParameter:(id )dic;
+ (void)ReLoginWithLoginONfinishBlock:(DownloadFinishedBlock)finishedBlock
                            failBlock:(DownloadFailedBlock)failedBlock;

+ (void)ReLoginBlockReturnWith:(NSString *)urlString
       andParameter:(NSDictionary* )dic
        finishBlock:(FinishedLoginBlock)finishedBlock
          failBlock:(DownloadFailedBlock)failedBlock;
//登录
+ (void)POSTLoginrequestWithUserName:(NSString *)username
                    andUserPassword:(NSString *)password
                            andType:(int)type
                        finishBlock:(DownloadFinishedBlock)finishBlock
                          failBlock:(DownloadFailedBlock)failedBlock;
///发送设备信息
+ (void)requestSendDeviceMessage;
///版本升级
+ (void)requestVersionUPWithfinishBlock:(DownloadFinishedBlock)finishBlock
                              failBlock:(DownloadFailedBlock)failedBlock;
//存储cookie信息
+ (void)sendCookie:(NSString *)UrlString;
/**
 @brief 把字典转换成字符串
 @param dic 要转成字符串的json字典
 @return 返回字符串
 */
+ (NSString*) setDicToStringWithDictionary:(NSDictionary*)dic;

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString ;

/*!
 * @brief 中文转化成UTF8
 * @param chineseStr 中文
 * @return 返回字符串
 */
+(NSString *)chineseToUTf8Str:(NSString*)chineseStr;

/*!
 * @brief 字典转化成可变Data
 * @param dict 字典
 * @return 返回可变Data
 */
+ (NSMutableData *)cunquWithDic:(NSDictionary *)dict;

/*!
 * @brief Data转化成字典
 * @param data 要转字典的data
 * @return 返回字典
 */
+ (NSDictionary*)dicByData:(NSData*)data;


@end
