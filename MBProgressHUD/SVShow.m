//
//  SVShow.m
//  云医社
//
//  Created by 王亚军 on 17/2/10.
//  Copyright © 2017年 王亚军. All rights reserved.
//

#import "SVShow.h"
#import "MBProgressHUD+NJ.h"

@implementation SVShow

#pragma mark MBProgressHUD
+(void)MBHUDShowError:(NSString *)error{
    [MBProgressHUD showError:error];
}

+(void)MBHUDShowSussces:(NSString *)sussces{
    [MBProgressHUD showSuccess:sussces];
}

+(void)MBHUDShowMessage:(NSString *)message{
    [MBProgressHUD showMessage:message];
}

+(void)MBHUDDismiss{
    [MBProgressHUD hideHUD];
}

+(void)MBHUDShowError:(NSString *)error View:(UIView *)view{
    [MBProgressHUD showError:error toView:view];
}

+(void)MBHUDShowSussces:(NSString *)sussces View:(UIView *)view{
    [MBProgressHUD showSuccess:sussces toView:view];
}

+(void)MBHUDShowMessage:(NSString *)message View:(UIView *)view{
    [MBProgressHUD showMessage:message toView:view];
}

+(void)MBHUDDismissFromView:(UIView *)view{
    [MBProgressHUD hideHUDForView:view];
}


@end
