//
//  Request.m
//  Request 请求类
//
//  Created by wyj on 15/4/23.
//  Copyright (c) 2015年 王亚军. All rights reserved.
//

#import "Request.h"
#import "AFNetworking.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "SVShow.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#define RESULT_CODE     @"resultCode"
#define RESULT          @"result"
#define UserDefaults [NSUserDefaults standardUserDefaults]
#define kUserDefaultsCookie @"SessionId"

@implementation Request
////get_post 0 get 1 post
+ (void)GET_POST:(int)get_post requestWithUrlString:(NSString *)urlString
   andParameters:(id)dictionary
     finishBlock:(DownloadFinishedBlock)finishBlock
       failBlock:(DownloadFailedBlock)failedBlock{
    
    if (get_post) {
        [Request POSTNewRequestWithUrlString:urlString andParameters:dictionary finishBlock:^(id responseObject) {
            finishBlock(responseObject);
        } failBlock:^(NSString *erroeMsg) {
            failedBlock(erroeMsg);
        }];
    }else{
        [Request GETNewRequestWithUrlString:urlString andParameters:dictionary finishBlock:^(id responseObject) {
            finishBlock(responseObject);
        } failBlock:^(NSString *erroeMsg) {
            failedBlock(erroeMsg);
        }];
    }
}

+(void)POSTNewRequestWithUrlString:(NSString *)urlstring
                     andParameters:(id)dictionary
                       finishBlock:(DownloadFinishedBlock)finishBlock
                         failBlock:(DownloadFailedBlock)failedBlock{
    
    NSString* network = [[NSUserDefaults standardUserDefaults] objectForKey:@"netWork"];
    if ([network isEqualToString:@"offline"]) {
        failedBlock(@"网络不给力,请检查网络设置");
        return;
    }
    
    AFHTTPSessionManager *session = [Request getManagerUrl:urlstring];
    
    NSString * url = urlstring;
    [session POST:url parameters:dictionary progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([[responseObject objectForKey:RESULT_CODE]integerValue] == 100) {
            NSLog(@"responseobject100 post   %@   :   %@",urlstring,dictionary);
            
            [Request ReLoginBlockReturnWith:url andParameter:dictionary finishBlock:^(NSString *urlstring, NSDictionary *dict) {
                
                [Request POSTrequestWithUrlString:urlstring andParameters:dict finishBlock:^(id responseObject) {
                    
                    finishBlock(responseObject);
                    
                } failBlock:^(NSString *erroeMsg) {
                    
                    failedBlock(erroeMsg) ;
                    
                }];
                
            } failBlock:^(NSString *erroeMsg) {
                failedBlock(erroeMsg);
            }];
            
        }else{
            finishBlock(responseObject);
            if ([responseObject[RESULT_CODE] integerValue] != 0) {
                NSLog(@"responseobject post   %@   :   %@  :  %@",urlstring,dictionary,responseObject[RESULT]);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedBlock(error.localizedDescription);
        
        if ([error.localizedDescription isEqualToString:@"未能找到使用指定主机名的服务器。"]) {
            [SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试"];
        }else if([error.localizedDescription isEqualToString:@"未能读取数据，因为它的格式不正确。"]){
            //[SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试。"];
        }else if([error.localizedDescription containsString:@"未能完成该操作"]){
            
        }else if([error.localizedDescription containsString:@"请求超时。"]){
            
        }else if([error.localizedDescription containsString:@"未能连接到服务器。"]){
            
        }else if ([error.localizedDescription isEqualToString:@"网络连接已中断。"]) {
            
        }else{
            [SVShow MBHUDShowError:error.localizedDescription];
        }
        NSLog(@"url:%@  dic:%@  operation: %@  \n error:%@",urlstring,dictionary,task,error.localizedDescription);
        
    }];
}

+ (void)GETNewRequestWithUrlString:(NSString *)urlstring
                     andParameters:(id)dictionary
                       finishBlock:(DownloadFinishedBlock)finishBlock
                         failBlock:(DownloadFailedBlock)failedBlock{
    
    NSString* network=[[NSUserDefaults standardUserDefaults] objectForKey:@"netWork"];
    
    if ([network isEqualToString:@"offline"]) {
        failedBlock(@"网络连接已断开，请稍后重试");
        return;
    }
    AFHTTPSessionManager *session = [Request getManagerUrl:urlstring];
    
    NSString*url = [urlstring stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [session GET:url  parameters:dictionary progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([[responseObject objectForKey:RESULT_CODE]integerValue] == 100) {
            NSLog(@"responseobject100 get   %@   :   %@",urlstring,dictionary);
            
            [Request ReLoginBlockReturnWith:url andParameter:dictionary finishBlock:^(NSString *urlstring, NSDictionary *dict) {
                
                [Request GETrequestWithUrlString:urlstring andParameters:dict finishBlock:^(id responseObject) {
                    
                    finishBlock(responseObject);
                    
                } failBlock:^(NSString *erroeMsg) {
                    
                    failedBlock(erroeMsg) ;
                    
                }];
                
            } failBlock:^(NSString *erroeMsg) {
                failedBlock(erroeMsg);
            }];
            
        }else{
            finishBlock(responseObject);
            if ([responseObject[RESULT_CODE] integerValue] != 0 && [responseObject[RESULT_CODE] integerValue] != 1) {
                NSLog(@"responseobject post   %@   :   %@  :  %@",urlstring,dictionary,responseObject[RESULT]);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedBlock(error.localizedDescription);
        if ([error.localizedDescription isEqualToString:@"未能找到使用指定主机名的服务器。"]) {
            [SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试"];
        }else if([error.localizedDescription containsString:@"未能读取数据，因为它的格式不正确"]){
            //[SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试"];
        }else if([error.localizedDescription containsString:@"未能完成该操作"]){
            
        }else if([error.localizedDescription containsString:@"请求超时。"]){
            
        }else if([error.localizedDescription containsString:@"未能连接到服务器。"]){
            
        }else if ([error.localizedDescription isEqualToString:@"网络连接已中断。"]) {
            
        }else {
            [SVShow MBHUDShowError:error.localizedDescription];
        }
        NSLog(@"%@ ： operation: %@  \n error:%@",urlstring,task,error.localizedDescription);
    }];
}

#pragma mark get post request
+(void)POSTrequestWithUrlString:(NSString *)urlstring
                  andParameters:(id)dictionary
                    finishBlock:(DownloadFinishedBlock)finishBlock
                      failBlock:(DownloadFailedBlock)failedBlock{
    
    NSString* network = [UserDefaults objectForKey:@"netWork"];
    if ([network isEqualToString:@"offline"]) {
        failedBlock(@"网络不给力,请检查网络设置");
        return;
    }
    
    AFHTTPSessionManager *session = [Request getManagerUrl:urlstring];
    
    [session POST:urlstring parameters:dictionary progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        finishBlock(responseObject);
        if ([[responseObject objectForKey:RESULT_CODE]integerValue] == 100) {
            NSLog(@"post   %@   :   %@",urlstring,dictionary);
        }
        //NSLog(@"%@",task.response);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedBlock(error.localizedDescription);
        
        if ([error.localizedDescription isEqualToString:@"未能找到使用指定主机名的服务器。"]) {
            [SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试"];
        }else if([error.localizedDescription isEqualToString:@"未能读取数据，因为它的格式不正确。"]){
            //[SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试。"];
        }else if([error.localizedDescription containsString:@"未能完成该操作"]){
            
        }else if([error.localizedDescription containsString:@"请求超时。"]){
            
        }else if([error.localizedDescription containsString:@"未能连接到服务器。"]){
            
        }else if ([error.localizedDescription isEqualToString:@"网络连接已中断。"]) {
            
        }else{
            [SVShow MBHUDShowError:error.localizedDescription];
        }
        NSLog(@"url:%@  dic:%@  operation: %@  \n error:%@",urlstring,dictionary,task,error.localizedDescription);
        
    }];
}

+ (void)GETrequestWithUrlString:(NSString *)urlstring
                  andParameters:(id)dictionary
                    finishBlock:(DownloadFinishedBlock)finishBlock
                      failBlock:(DownloadFailedBlock)failedBlock{
    
    NSString* network=[UserDefaults objectForKey:@"netWork"];
    
    if ([network isEqualToString:@"offline"]) {
        failedBlock(@"网络连接已断开，请稍后重试");
        return;
    }
    AFHTTPSessionManager *session = [Request getManagerUrl:urlstring];
    
    NSString*url = [urlstring stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [session GET:url  parameters:dictionary progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        finishBlock(responseObject);
        if ([[responseObject objectForKey:RESULT_CODE]integerValue] == 100) {
            NSLog(@"responseobject100 get   %@   :   %@",urlstring,dictionary);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failedBlock(error.localizedDescription);
        if ([error.localizedDescription isEqualToString:@"未能找到使用指定主机名的服务器。"]) {
            [SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试"];
        }else if([error.localizedDescription containsString:@"未能读取数据，因为它的格式不正确"]){
            //[SVShow MBHUDShowError:@"网络连接不稳定，请稍后重试"];
        }else if([error.localizedDescription containsString:@"未能完成该操作"]){
            
        }else if([error.localizedDescription containsString:@"请求超时。"]){
            
        }else if([error.localizedDescription containsString:@"未能连接到服务器。"]){
            
        }else if ([error.localizedDescription isEqualToString:@"网络连接已中断。"]) {
            
        }else {
            [SVShow MBHUDShowError:error.localizedDescription];
        }
        NSLog(@"%@ ： operation: %@  \n error:%@",urlstring,task,error.localizedDescription);
    }];
}
/**
 @brief 把字典转换成字符串
 @param dic 要转成字符串的json字典
 @return 返回字符串
 */
+(NSString*)setDicToStringWithDictionary:(NSDictionary*)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
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

+ (NSString *)chineseToUTf8Str:(NSString*)chineseStr
{
    NSString *string=[chineseStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return string;
}



+ (NSMutableData *)cunquWithDic:(NSDictionary *)dict
{
    NSMutableData* data = [[NSMutableData alloc]init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"Data"];
    [archiver finishEncoding];
    return data;
}

+ (NSDictionary*)dicByData:(NSData*)data{
    
    NSDictionary* myDictionary =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return myDictionary;
}

+ (void)sendCookie:(NSString *)UrlString {
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:UrlString]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    
    [UserDefaults setObject:data forKey:kUserDefaultsCookie];
}
+ (void)setCookies{
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCookie];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}
+ (AFHTTPSessionManager *)getManagerUrl:(NSString *)url{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    //    [session.requestSerializer setTimeoutInterval:5.0];
    
    //    session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    //    AFSecurityPolicy * securityPolicy = [Request getSecurityPolicy];
    //session.securityPolicy = securityPolicy;
    
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [Request setCookies];
    
    //
    //    __weak AFHTTPSessionManager *weakSession = session;
    //    [session setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *_credential) {
    //
    //        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
    //        /**
    //         *  导入多张CA证书（Certification Authority，支持SSL证书以及自签名的CA），请替换掉你的证书名称
    //         */
    //        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"cer"];//自签名证书
    //        NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
    //        NSArray *cerArray = @[caCert];
    //        weakSession.securityPolicy.pinnedCertificates = [NSSet setWithArray:cerArray];
    //
    //        SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
    //        NSCAssert(caRef != nil, @"caRef is nil");
    //
    //        NSArray *caArray = @[(__bridge id)(caRef)];
    //        NSCAssert(caArray != nil, @"caArray is nil");
    //
    //        OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
    //        SecTrustSetAnchorCertificatesOnly(serverTrust,NO);
    //        NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
    //
    //        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    //        __autoreleasing NSURLCredential *credential = nil;
    //        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
    //            if ([weakSession.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
    //                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    //                if (credential) {
    //                    disposition = NSURLSessionAuthChallengeUseCredential;
    //                } else {
    //                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    //                }
    //            } else {
    //                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    //            }
    //        } else {
    //            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    //        }
    //
    //        return disposition;
    //    }];
    
    
    return session;
}
/**
 *AFN https验证类
 */
+ (AFSecurityPolicy *)getSecurityPolicy{
    //    static AFSecurityPolicy *securityPolicy ;
    //    if (!securityPolicy) {
    AFSecurityPolicy* securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO
    //主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    securityPolicy.validatesDomainName = NO;
    
    //validatesCertificateChain 是否验证整个证书链，默认为YES
    //设置为YES，会将服务器返回的Trust Object上的证书链与本地导入的证书进行对比，这就意味着，假如你的证书链是这样的：
    //GeoTrust Global CA
    //    Google Internet Authority G2
    //        *.google.com
    //那么，除了导入*.google.com之外，还需要导入证书链上所有的CA证书（GeoTrust Global CA, Google Internet Authority G2）；
    //如是自建证书的时候，可以设置为YES，增强安全性；假如是信任的CA所签发的证书，则建议关闭该验证；
    //securityPolicy.validatesCertificateChain = NO;
    
    
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    
    //AFSSLPinningModeCertificate 使用证书验证模式
    securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:set];
    
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    //    }
    return securityPolicy;
}


+(NSString*) md5:(NSString*) str
{
    if (!str) {
        str = @"";
    }
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr,(CC_LONG)strlen(cStr), result );
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}

@end
