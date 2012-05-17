//
//  Notifications_ANE.h
//  Notifications ANE
//
//  Created by Christopher Nassar on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import <UIKit/UIKit.h>

@interface Notifications_ANE : NSObject<UIApplicationDelegate>
{
    //id delegate;
}

//@property(nonatomic,assign) id delegate;

@property(nonatomic,assign) FREContext context;

FREObject InitializeNotificationToken();

void NotificationContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void NotificationContextFinalizer(FREContext ctx);
void iOSNotExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void iOSNotExtFinalizer(void* extData);
@end
