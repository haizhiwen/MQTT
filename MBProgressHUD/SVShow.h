//
//  SVShow.h
//  云医社
//
//  Created by 王亚军 on 17/2/10.
//  Copyright © 2017年 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SVShow : NSObject

+(void)MBHUDShowError:(NSString *)error;

+(void)MBHUDShowMessage:(NSString *)message;

+(void)MBHUDShowSussces:(NSString *)sussces;

+(void)MBHUDDismiss;

+(void)MBHUDShowError:(NSString *)error View:(UIView *)view;

+(void)MBHUDShowSussces:(NSString *)sussces View:(UIView *)view;

+(void)MBHUDShowMessage:(NSString *)message View:(UIView *)view;

+(void)MBHUDDismissFromView:(UIView *)view;


@end
